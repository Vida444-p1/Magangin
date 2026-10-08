import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Get Auth token from request
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);

    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { internship_id, cv_url, cover_letter } = await req.json();

    if (!internship_id || !cv_url) {
      return new Response(JSON.stringify({ error: "internship_id and cv_url are required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 1. Validate student profile exists
    const { data: student, error: studentError } = await supabase
      .from("student_profiles")
      .select("id, user_id, university, major")
      .eq("user_id", user.id)
      .single();

    if (studentError || !student) {
      return new Response(JSON.stringify({ error: "Student profile not found. Please complete your profile first." }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Validate internship exists and is published & active
    const { data: internship, error: internshipError } = await supabase
      .from("internships")
      .select("id, title, status, deadline, company_id, company_profiles(user_id, company_name)")
      .eq("id", internship_id)
      .single();

    if (internshipError || !internship) {
      return new Response(JSON.stringify({ error: "Internship not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (internship.status !== "published") {
      return new Response(JSON.stringify({ error: "This internship is not accepting applications." }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (new Date(internship.deadline) < new Date()) {
      return new Response(JSON.stringify({ error: "Deadline for this internship has passed." }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 3. Check for existing application
    const { data: existingApp } = await supabase
      .from("applications")
      .select("id")
      .eq("internship_id", internship_id)
      .eq("student_id", student.id)
      .maybeSingle();

    if (existingApp) {
      return new Response(JSON.stringify({ error: "You have already applied for this internship." }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 4. Insert application
    const { data: application, error: appError } = await supabase
      .from("applications")
      .insert({
        internship_id,
        student_id: student.id,
        cv_url,
        cover_letter: cover_letter || null,
        status: "submitted",
      })
      .select()
      .single();

    if (appError) {
      return new Response(JSON.stringify({ error: appError.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 5. Send notification to student
    await supabase.from("notifications").insert({
      user_id: user.id,
      title: "🎉 Lamaran Berhasil Dikirim",
      message: `Lamaran kamu untuk posisi "${internship.title}" telah berhasil dikirim.`,
      type: "application_submitted",
    });

    // Send notification to company owner if available
    const companyUserId = (internship as any).company_profiles?.user_id;
    if (companyUserId) {
      await supabase.from("notifications").insert({
        user_id: companyUserId,
        title: "📄 Pelamar Baru",
        message: `Ada pelamar baru untuk lowongan "${internship.title}".`,
        type: "new_applicant",
      });
    }

    return new Response(JSON.stringify({ success: true, application }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
