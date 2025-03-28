// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { getUserPlanStatus } from "../_shared/supabase.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
    });
  }
  try {
    const authorization = req.headers.get("Authorization") ?? "";
    const plan = await getUserPlanStatus(authorization, 0, "");
    if (plan.status > 200) {
      return new Response(JSON.stringify({ error: plan.error }), {
        status: plan.status,
      });
    }
    const { deviceId, title } = await req.json();
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
    const { data: device, error } = await supabaseClient.from("devices")
      .select().eq("id", deviceId).single();
    if (error || !device) {
      const { data: devices } = await supabaseClient.from("devices").select(
        "id",
      )
        .eq("user_id", plan.userId).eq("status", 1);
      if (devices!.length >= plan.devices) {
        return new Response(
          JSON.stringify({ error: "Device limit exceeded." }),
          { status: 400 },
        );
      } else {
        const now = new Date().getTime();
        await supabaseClient.from("devices").insert({
          "id": deviceId,
          "user_id": plan.userId,
          "title": title,
          "last_at": now,
          "status": 1,
        });
        return new Response("", { status: 200 });
      }
    } else if (device.user_id == plan.userId) {
      return new Response(
        "",
        { status: 200 },
      );
    } else {
      return new Response(
        JSON.stringify({ error: "Registered with another user." }),
        { status: 400 },
      );
    }
  } catch (error) {
    return new Response(JSON.stringify({ error: error }), { status: 400 });
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/register_device' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
