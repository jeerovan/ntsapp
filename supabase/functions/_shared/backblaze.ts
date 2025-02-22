import { createClient } from "jsr:@supabase/supabase-js@2";

const B2_KEY_ID = Deno.env.get("B2_APPLICATION_KEY_ID")!;
const B2_KEY = Deno.env.get("B2_APPLICATION_KEY")!;

const B2_API_URL = "https://api006.backblazeb2.com/b2api/v3";

export async function authenticateB2(generate: boolean) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  let accountToken = null;

  // Fetch existing token from Supabase (Only fetching required columns)
  const { data, error } = await supabaseClient
    .from("server")
    .select("value, state")
    .eq("key", "b2_account_token")
    .single();

  // If no data exists, we must generate a new token
  if (!data || error) {
    generate = true;
  } else {
    accountToken = data.value;
    if (data.state == 1) {
      // Another process is already updating the token, wait & return the old one
      return accountToken;
    }
  }

  // If we need to generate a new token and no update is in progress
  if (generate && (!data || data.state === 0)) {
    // Set update in progress (Ensure atomicity with `state = 0` check)
    // ignore if can not update ( if no row exist)
    await supabaseClient
      .from("server")
      .update({ state: 1 })
      .eq("key", "b2_account_token")
      .eq("state", 0); // Ensure only one process updates

    // Authenticate with Backblaze B2
    try {
      const authResponse = await fetch(`${B2_API_URL}/b2_authorize_account`, {
        headers: { Authorization: `Basic ${btoa(`${B2_KEY_ID}:${B2_KEY}`)}` },
      });
      await supabaseClient.from("server").update({ state: 0 }).eq(
        "key",
        "b2_account_token",
      ); // Reset state
      if (!authResponse.ok) {
        console.error("B2 Authentication failed:");
        return accountToken;
      }

      const { authorizationToken } = await authResponse.json();
      accountToken = authorizationToken;

      // Insert/Update the new token
      await supabaseClient
        .from("server")
        .upsert({ key: "b2_account_token", value: accountToken, state: 0 }, {
          onConflict: "key",
        })
        .eq("key", "b2_account_token");
    } catch (error) {
      console.error("Error fetching B2 token:", error);
      await supabaseClient.from("server").update({ state: 0 }).eq(
        "key",
        "b2_account_token",
      ); // Reset state
    }
  }

  return accountToken;
}
