// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { getFcmAccessToken, getUserPlanStatus } from "../_shared/supabase.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import serviceAccount from "../service-account.json" with { type: "json" };

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
    });
  }
  try {
    const authorization = req.headers.get("Authorization") ?? "";
    const headerDeviceId = req.headers.get("deviceId") ?? "";
    const plan = await getUserPlanStatus(authorization, 0, headerDeviceId);
    const { deviceId = null } = await req.json();
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
    if (headerDeviceId != "") {
      if (plan.devices > 0) {
        // remove device
        await supabaseClient.from("devices").delete().eq("id", headerDeviceId)
          .eq(
            "user_id",
            plan.userId,
          );
      }
    } else if (deviceId) {
      const { data: device, error } = await supabaseClient.from("devices")
        .update({ "status": 0 }).eq(
          "id",
          deviceId,
        ).eq("user_id", plan.userId).select().maybeSingle();
      // send fcm
      if (device && !error) {
        const fcmToken = device.fcm_id;
        if (fcmToken) {
          const accessToken = await getFcmAccessToken({
            clientEmail: serviceAccount.client_email,
            privateKey: serviceAccount.private_key,
          });
          await fetch(
            `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
            {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${accessToken}`,
              },
              body: JSON.stringify({
                message: {
                  token: fcmToken,
                  data: {
                    type: "Sync",
                    timestamp: Date.now().toString(),
                  },
                  apns: {
                    headers: {
                      "apns-expiration": "0",
                    },
                  },
                  android: {
                    ttl: "0s",
                  },
                  webpush: {
                    headers: {
                      "TTL": "0",
                    },
                  },
                },
              }),
            },
          );
        } else {
          console.error(`FcmId not found ${deviceId}`);
        }
      }
    } else {
      return new Response(JSON.stringify({ error: "Missing deviceId" }), {
        status: 400,
      });
    }
    return new Response("", { status: 200 });
  } catch (e) {
    console.error("Error occurred:", e);

    let errorMessage = "Unknown error occurred";
    if (e instanceof Error) {
      errorMessage = e.message; // Standard JS Error
    } else if (typeof e === "string") {
      errorMessage = e; // If error is a string
    } else {
      try {
        errorMessage = JSON.stringify(e); // Convert objects to string
      } catch {
        errorMessage = "Failed to serialize error";
      }
    }
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 400,
    });
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/remove_device' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
