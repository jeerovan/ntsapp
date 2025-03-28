import { createClient } from "jsr:@supabase/supabase-js@2";

export async function getUser(authorization: string) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    {
      global: {
        headers: { Authorization: authorization },
      },
    },
  );
  // First get the token from the Authorization header
  const userToken = authorization.replace("Bearer ", "");

  // Now we can get the session or user object
  const {
    data: { user },
  } = await supabaseClient.auth.getUser(userToken);
  return { user };
}

export async function getUserPlanStatus(
  authorization: string,
  fileSize: number,
  deviceId: string,
) {
  let status = 200;
  let error = "";
  let devices = 0;
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    {
      global: {
        headers: { Authorization: authorization },
      },
    },
  );
  // First get the token from the Authorization header
  const userToken = authorization.replace("Bearer ", "");

  // Now we can get the session or user object
  const {
    data: { user },
  } = await supabaseClient.auth.getUser(userToken);
  const userId = user?.id;

  // Get user plan
  const { data: plan, error: planError } = await supabaseClient
    .from("plans")
    .select("b2_limit,expires_at,devices")
    .eq("user_id", userId)
    .single();

  if (planError || !plan) {
    status = 400;
    error = "Failed to fetch plan";
    return { status, userId, error, devices };
  }

  devices = plan.devices;

  if (plan.expires_at < new Date().getTime()) {
    status = 400;
    error = "Plan expired";
    return { status, userId, error, devices };
  }

  const { data: storage, error: storageError } = await supabaseClient
    .from("storage")
    .select("b2_size")
    .eq("id", userId)
    .single();

  if (storageError || !storage) {
    error = "Failed to fetch storage";
    status = 400;
    return { status, userId, error, devices };
  }

  if (fileSize > (plan.b2_limit - storage.b2_size)) {
    status = 400;
    error = "Storage limit exceeded";
    return { status, userId, error, devices };
  }

  if (deviceId.length > 0) {
    const now = new Date().getTime();
    const { data: device, error: deviceError } = await supabaseClient.from(
      "devices",
    ).update({ "last_at": now }).eq("id", deviceId).eq("user_id", userId).eq(
      "status",
      1,
    ).select().single();
    if (deviceError || !device) {
      error = "device not registered";
      status = 400;
    }
  }

  return { status, userId, error, devices };
}

export async function setFileEntry(
  userId: string,
  fileId: string,
  cipher: string,
  nonce: string,
  parts: number,
  size: number,
) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  const { data: existingFile } = await supabaseClient.from("files").select().eq(
    "id",
    fileId,
  ).single();
  if (existingFile) {
    return existingFile;
  } else {
    const { data: file } = await supabaseClient.from("files").insert({
      id: fileId,
      user_id: userId,
      key_cipher: cipher,
      key_nonce: nonce,
      parts: parts,
      size: size,
    }).select().single();
    return file;
  }
}

export async function setFileUploaded(
  fileId: string,
  parts: number,
) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );
  const now = new Date().getTime();
  await supabaseClient.from("files").update({
    parts_uploaded: parts,
    uploaded_at: now,
  }).eq(
    "id",
    fileId,
  ).lt("uploaded_at", now);
}

export async function setDownloadToken(
  userFileId: string,
  token: string,
  expires: number,
) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // update token and expiry
  await supabaseClient
    .from("files")
    .update({ token: token, expires: expires })
    .eq("id", userFileId);
}

export async function getFile(fileId: string) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // Fetch
  const { data: file, error } = await supabaseClient
    .from("files")
    .select()
    .eq("id", fileId)
    .single();
  if (!error) {
    return file;
  }
  return null;
}
export async function deleteFileEntry(fileId: string) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  await supabaseClient
    .from("files")
    .delete()
    .eq("id", fileId);
}

export async function setB2FileId(userFileId: string, b2FileId: string) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );
  // update b2fileid
  await supabaseClient
    .from("files")
    .update({ b2_id: b2FileId })
    .eq("id", userFileId).is("b2_id", null);
}
