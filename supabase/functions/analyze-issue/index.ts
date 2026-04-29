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
    const { description, image_urls, user_id, latitude, longitude } = await req.json();

    const openaiApiKey = Deno.env.get("OPENAI_API_KEY");
    if (!openaiApiKey) {
      throw new Error("OPENAI_API_KEY not configured");
    }

    // Check for repeat issues
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    let isRepeatIssue = false;
    let relatedRequestIds: string[] = [];

    if (user_id) {
      const { data: previousRequests } = await supabase
        .from("ai_requests")
        .select("id, input_text, problem")
        .eq("user_id", user_id)
        .order("created_at", { ascending: false })
        .limit(10);

      if (previousRequests && previousRequests.length > 0) {
        const previousProblems = previousRequests.map((r: any) => r.input_text).join("\n");
        isRepeatIssue = previousRequests.some(
          (r: any) => r.input_text.toLowerCase().includes(description.toLowerCase().substring(0, 20))
        );
        relatedRequestIds = previousRequests.map((r: any) => r.id);
      }
    }

    const systemPrompt = `You are an AI home service diagnostic assistant for Fixly AI.
Analyze the user's problem and return ONLY a valid JSON object with this exact structure:
{
  "problem": "Clear description of the identified problem",
  "causes": [
    {
      "cause": "Possible cause description",
      "probability": 0.7,
      "explanation": "Why this might be the cause"
    }
  ],
  "estimated_cost_min": 50,
  "estimated_cost_max": 200,
  "urgency_level": "low|medium|high|critical",
  "confidence_score": 0.85,
  "safety_disclaimer": "Any safety warnings if applicable, null if none",
  "diy_steps": ["Step 1", "Step 2"],
  "preventive_tips": ["Tip 1", "Tip 2"],
  "suggested_service_category": "plumbing|electrical|hvac|cleaning|roofing|painting|locksmith|appliance|general"
}

Rules:
- confidence_score: 0.0 to 1.0
- urgency_level: low (can wait), medium (should fix soon), high (fix today), critical (immediate danger)
- Always include safety_disclaimer for gas, electrical, or structural issues
- Provide at least 2 causes with probability scores that sum to ~1.0
- Cost estimates in USD
- NEVER return raw text, ONLY valid JSON`;

    const messages: any[] = [
      { role: "system", content: systemPrompt },
      { role: "user", content: `Problem description: ${description}${
        latitude && longitude ? `\nLocation: ${latitude}, ${longitude}` : ""
      }${isRepeatIssue ? "\nNote: This appears to be a recurring issue for this user." : ""}` },
    ];

    if (image_urls && image_urls.length > 0) {
      const imageContent = image_urls.map((url: string) => ({
        type: "image_url",
        image_url: { url },
      }));
      messages.push({
        role: "user",
        content: [
          { type: "text", text: "Here are images of the problem:" },
          ...imageContent,
        ],
      });
    }

    const openaiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${openaiApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4o",
        messages,
        temperature: 0.3,
        max_tokens: 1500,
        response_format: { type: "json_object" },
      }),
    });

    const openaiData = await openaiResponse.json();
    const aiResponse = JSON.parse(openaiData.choices[0].message.content);

    // Save to database
    const requestData = {
      user_id,
      input_text: description,
      input_image_urls: image_urls || [],
      problem: aiResponse.problem,
      causes: aiResponse.causes,
      estimated_cost_min: aiResponse.estimated_cost_min,
      estimated_cost_max: aiResponse.estimated_cost_max,
      urgency_level: aiResponse.urgency_level,
      confidence_score: aiResponse.confidence_score,
      safety_disclaimer: aiResponse.safety_disclaimer,
      diy_steps: aiResponse.diy_steps || [],
      preventive_tips: aiResponse.preventive_tips || [],
      suggested_service_category: aiResponse.suggested_service_category,
      is_repeat_issue: isRepeatIssue,
      related_request_ids: relatedRequestIds,
      raw_response: aiResponse,
    };

    const { data: savedRequest, error: saveError } = await supabase
      .from("ai_requests")
      .insert(requestData)
      .select()
      .single();

    if (saveError) {
      console.error("Failed to save AI request:", saveError);
    }

    return new Response(
      JSON.stringify({
        id: savedRequest?.id || "",
        user_id,
        input_text: description,
        ...aiResponse,
        is_repeat_issue: isRepeatIssue,
        related_request_ids: relatedRequestIds,
        created_at: savedRequest?.created_at || new Date().toISOString(),
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});
