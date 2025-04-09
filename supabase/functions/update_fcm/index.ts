// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { getUser } from "../_shared/supabase.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
    });
  }
  const { fcmId, deviceId } = await req.json();
  if (!fcmId || !deviceId) {
    return new Response(JSON.stringify({ error: "fcmId,deviceId required" }), {
      status: 400,
    });
  }
  const authorization = req.headers.get("Authorization") ?? "";
  const { user } = await getUser(authorization);
  const userId = user?.id;

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // Initialize response variables
  let error = null;
  let status = 200;
  if (userId) {
    const { error: updateError } = await supabaseClient
      .from("devices")
      .update({ fcm_id: fcmId })
      .eq("user_id", userId).eq("id", deviceId);

    if (updateError) {
      error = updateError.message;
      status = 400;
    }
  } else {
    error = "User not found";
    status = 400;
  }
  // Return response
  if (error) {
    return new Response(JSON.stringify({ error: error }), {
      headers: { "Content-Type": "application/json" },
      status,
    });
  }

  return new Response("", {
    status,
  });
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/update_fcm' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
