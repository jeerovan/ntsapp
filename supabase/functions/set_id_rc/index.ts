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
  const { rc_id } = await req.json();
  if (!rc_id) {
    return new Response(JSON.stringify({ error: "rc_id required" }), {
      status: 400,
    });
  }
  const authorization = req.headers.get("Authorization") ?? "";
  const { user } = await getUser(authorization);
  const user_id = user?.id;

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // Initialize response variables
  let error = null;
  let status = 200;

  // Check if row exists
  const { data: existingRow, error: queryError } = await supabaseClient
    .from("plans")
    .select("user_id")
    .eq("rc_id", rc_id)
    .single();
  if (queryError || !existingRow) {
    error = "not found";
    status = 400;
  } else {
    // Check if user_id matches or is null
    if (existingRow.user_id !== null && existingRow.user_id !== user_id) {
      error = "user_id mismatch";
      status = 400;
    } else if (existingRow.user_id === null) {
      // Update the row with new user_id
      const { error: updateError } = await supabaseClient
        .from("plans")
        .update({ user_id: user_id })
        .eq("rc_id", rc_id);

      if (updateError) {
        error = updateError.message;
        status = 400;
      }
    }
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

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/set_id_rc' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
