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

    const { application_id, status } = await req.json();

    const allowedStatuses = ["submitted", "reviewing", "interview", "accepted", "rejected", "withdrawn"];
    if (!application_id || !allowedStatuses.includes(status)) {
      return new Response(JSON.stringify({ error: `Invalid status or missing application_id. Allowed: ${allowedStatuses.join(", ")}` }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Fetch application details with internship and company info
    const { data: application, error: appError } = await supabase
      .from("applications")
      .select(`
        id,
        status,
        student_id,
        student_profiles(user_id),
        internships(
          id,
          title,
          company_id,
          company_profiles(user_id, company_name)
        )
      `)
      .eq("id", application_id)
      .single();

    if (appError || !application) {
      return new Response(JSON.stringify({ error: "Application not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const internship = (application as any).internships;
    const companyUserId = internship?.company_profiles?.user_id;
    const studentUserId = (application as any).student_profiles?.user_id;

    // Check permissions:
    // Only the company owner can change status (or student can withdraw)
    if (status === "withdrawn") {
      if (user.id !== studentUserId) {
        return new Response(JSON.stringify({ error: "Only the applicant student can withdraw their application." }), {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    } else {
      if (user.id !== companyUserId) {
        return new Response(JSON.stringify({ error: "Forbidden: You are not authorized to update this application status." }), {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    // Update status
    const { data: updatedApp, error: updateError } = await supabase
      .from("applications")
      .update({ status })
      .eq("id", application_id)
      .select()
      .single();

    if (updateError) {
      return new Response(JSON.stringify({ error: updateError.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Send notification to student
    let notifTitle = "Update Status Lamaran";
    let notifMsg = `Status lamaranmu untuk posisi "${internship.title}" telah diperbarui menjadi ${status}.`;

    if (status === "reviewing") {
      notifTitle = "👀 Lamaran Sedang Direview";
      notifMsg = `Lamaran kamu untuk ${internship.title} di ${internship.company_profiles?.company_name} sedang direview oleh tim rekruter.`;
    } else if (status === "interview") {
      notifTitle = "📅 Undangan Interview!";
      notifMsg = `Selamat! Kamu diundang untuk tahap wawancara untuk lowongan ${internship.title}. Silakan cek email/pesan berkala.`;
    } else if (status === "accepted") {
      notifTitle = "🎉 Selamat! Lamaran Diterima";
      notifMsg = `Selamat! Kamu dinyatakan DITERIMA magang untuk posisi ${internship.title} di ${internship.company_profiles?.company_name}!`;
    } else if (status === "rejected") {
      notifTitle = "Status Lamaran Magang";
      notifMsg = `Terima kasih atas minatmu pada posisi ${internship.title}. Saat ini perusahaan belum dapat melanjutkan proses ke tahap berikutnya.`;
    }

    await supabase.from("notifications").insert({
      user_id: studentUserId,
      title: notifTitle,
      message: notifMsg,
      type: `application_${status}`,
    });

    return new Response(JSON.stringify({ success: true, application: updatedApp }), {
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
