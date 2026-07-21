#!/usr/bin/env python3
"""
Merge new translation strings from `new_strings/` into existing `.arb` files.

Usage: python3 lib/l10n/merge_new_strings.py

Reads each file in `lib/l10n/new_strings/app_<locale>.arb`,
adds any keys not already present in `lib/l10n/app_<locale>.arb`,
then writes back the existing file with new keys appended before `}`.

Skips missing target files and keys already present.
"""

import json
import os
import sys

L10N_DIR = os.path.dirname(os.path.abspath(__file__))
NEW_DIR = os.path.join(L10N_DIR, "new_strings")


def read_arb(path):
    """Read ARB file, return (raw_text, parsed_data)."""
    with open(path, encoding="utf-8") as f:
        text = f.read()
    return text, json.loads(text)


def merge_into_target(target_path, new_data):
    """Merge keys from new_data into target ARB file, skipping duplicates."""
    with open(target_path, encoding="utf-8") as f:
        orig_text = f.read()
    orig_data = json.loads(orig_text)

    # Collect new key-value pairs and their metadata
    new_entries = []
    for key, value in new_data.items():
        if key.startswith("@"):
            continue  # metadata keys handled with their value key
        if key in orig_data:
            continue  # skip duplicates

        new_entries.append(f"  {json.dumps(key, ensure_ascii=False)}: "
                           f"{json.dumps(value, ensure_ascii=False)}")

        meta_key = "@" + key
        if meta_key in new_data:
            new_entries.append(f"  {json.dumps(meta_key, ensure_ascii=False)}: "
                               f"{json.dumps(new_data[meta_key], ensure_ascii=False)}")

    if not new_entries:
        return 0

    # Insert before the final closing brace
    stripped = orig_text.rstrip()
    if not stripped.endswith("}"):
        print(f"  WARN: {os.path.basename(target_path)} missing closing brace",
              file=sys.stderr)
        return 0

    insert = ",\n" + ",\n".join(new_entries) + "\n"
    idx = stripped.rfind("}")
    new_text = stripped[:idx] + insert + "}"

    with open(target_path, "w", encoding="utf-8") as f:
        f.write(new_text)

    return len(new_entries) // 2  # count of value keys (not metadata)


def main():
    if not os.path.isdir(NEW_DIR):
        print(f"ERROR: new_strings dir not found at {NEW_DIR}", file=sys.stderr)
        sys.exit(1)

    total_keys = 0
    total_files = 0
    errors = []

    for fname in sorted(os.listdir(NEW_DIR)):
        if not fname.endswith(".arb"):
            continue

        new_path = os.path.join(NEW_DIR, fname)
        target_path = os.path.join(L10N_DIR, fname)

        if not os.path.exists(target_path):
            errors.append(f"{fname}: target not found")
            continue

        _, new_data = read_arb(new_path)
        count = merge_into_target(target_path, new_data)

        if count > 0:
            print(f"{fname}: {count} key(s) added")
            total_keys += count
            total_files += 1
        else:
            print(f"{fname}: no new keys")

    print(f"\nDone. {total_files} file(s) updated, {total_keys} key(s) merged.")

    if errors:
        print("\nErrors:", file=sys.stderr)
        for err in errors:
            print(f"  {err}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
