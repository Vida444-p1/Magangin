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

    // Get student profile
    const { data: student, error: studentError } = await supabase
      .from("student_profiles")
      .select("id, major, skills, location")
      .eq("user_id", user.id)
      .single();

    if (studentError || !student) {
      // If student profile not completed, return top published internships
      const { data: fallback } = await supabase
        .from("internships")
        .select("*, company_profiles(*)")
        .eq("status", "published")
        .order("created_at", { ascending: false })
        .limit(10);

      return new Response(JSON.stringify({ recommendations: fallback || [] }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Fetch published internships
    const { data: internships, error: intError } = await supabase
      .from("internships")
      .select("*, company_profiles(*)")
      .eq("status", "published");

    if (intError || !internships) {
      return new Response(JSON.stringify({ error: "Could not fetch internships" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const studentSkills = (student.skills || []).map((s: string) => s.toLowerCase());
    const studentMajor = (student.major || "").toLowerCase();
    const studentLocation = (student.location || "").toLowerCase();

    // Scoring logic according to PRD section 47:
    // Skill match +40
    // Major match +30
    // Location match +15
    // Work type Remote or match +10
    // Category match +5
    const scored = internships.map((internship: any) => {
      let score = 0;
      const reqs = (internship.requirements || []).map((r: string) => r.toLowerCase());
      const title = (internship.title || "").toLowerCase();
      const desc = (internship.description || "").toLowerCase();
      const combinedText = `${title} ${desc} ${reqs.join(" ")}`;

      // Skill match check (+40 if any match, bonus for multiple)
      let matchedSkill = false;
      for (const skill of studentSkills) {
        if (combinedText.includes(skill)) {
          score += 40;
          matchedSkill = true;
          break;
        }
      }

      // Major match check (+30)
      if (studentMajor && (combinedText.includes(studentMajor) || title.includes(studentMajor))) {
        score += 30;
      }

      // Location match (+15)
      if (studentLocation && internship.location.toLowerCase().includes(studentLocation)) {
        score += 15;
      }

      // Work type (+10 for Remote or matching)
      if (internship.work_type === "Remote") {
        score += 10;
      }

      return {
        ...internship,
        recommendation_score: score,
      };
    });

    // Sort descending by score
    scored.sort((a: any, b: any) => b.recommendation_score - a.recommendation_score);

    return new Response(JSON.stringify({ recommendations: scored }), {
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
