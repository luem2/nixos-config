clear_after=45

entries_json="$(rbw list --raw)"
entry_lines="$(jq -r '
  to_entries[]
  | .value as $entry
  | (($entry.folder // "") + if ($entry.folder // "") == "" then "" else "/" end + $entry.name)
    + "\t" + ($entry.user // "")
    + "\t[idx:\(.key)]"
' <<< "$entries_json")"

if [ -z "$entry_lines" ]; then
  notify-send -t 2500 "Bitwarden" "No entries found"
  exit 0
fi

selected_entry="$(printf '%s\n' "$entry_lines" | noctalia dmenu -p "Bitwarden entry")" || exit 0
entry_index="$(printf '%s' "$selected_entry" | cut -f3 | cut -d ':' -f2 | tr -d ']')"
entry_json="$(jq -c --argjson i "$entry_index" '.[$i]' <<< "$entries_json")"
name="$(jq -r '.name' <<< "$entry_json")"
user="$(jq -r '.user // empty' <<< "$entry_json")"
folder="$(jq -r '.folder // empty' <<< "$entry_json")"

rbw_entry_args=()
if [ -n "$user" ]; then
  rbw_entry_args+=("$user")
fi
if [ -n "$folder" ]; then
  rbw_entry_args+=("--folder" "$folder")
fi

item_json="$(rbw get --raw "$name" "${rbw_entry_args[@]}")"

field_lines="$({
  if [ -n "$user" ]; then
    printf '[username] Username: %s\n' "$user"
  fi

  jq -r '
    def one_line:
      tostring | gsub("\\r?\\n"; " | ");
    def mask:
      tostring as $value
      | if $value == "" then ""
        elif ($value | length) == 1 then "*"
        else $value[0:1] + ("*" * (($value | length) - 1))
        end;
    def display_field:
      if (.type // "") == "hidden" then
        (.value // "" | mask)
      else
        (.value // "" | one_line)
      end;

    if (.data.password // "") != "" then
      "[password] Password: " + (.data.password | mask)
    else empty end,
    if (.data.totp // null) != null then
      "[totp] TOTP: ******"
    else empty end,
    if (.notes // "") != "" then
      "[notes] Notes: " + (.notes | one_line)
    else empty end,
    (.data.uris // [] | to_entries[] | "[uri:\(.key)] URI \(.key + 1): \(.value.uri)"),
    (.fields // [] | to_entries[] | "[field:\(.key)] \(.value.name): \(.value | display_field)")
  ' <<< "$item_json"
})"

if [ -z "$field_lines" ]; then
  notify-send -t 2500 "Bitwarden" "No fields found"
  exit 0
fi

selected_field="$(printf '%s\n' "$field_lines" | noctalia dmenu -p "Bitwarden field")" || exit 0
target="$(printf '%s' "$selected_field" | cut -d ']' -f1 | cut -c2-)"
clear_secret=0

case "$target" in
  username)
    secret="$user"
    ;;
  password)
    secret="$(jq -r '.data.password // empty' <<< "$item_json")"
    clear_secret=1
    ;;
  totp)
    secret="$(rbw code "$name" "${rbw_entry_args[@]}")"
    clear_secret=1
    ;;
  notes)
    secret="$(jq -r '.notes // empty' <<< "$item_json")"
    ;;
  uri:*)
    field_index="$(printf '%s' "$target" | cut -d ':' -f2)"
    secret="$(jq -r --argjson i "$field_index" '.data.uris[$i].uri // empty' <<< "$item_json")"
    ;;
  field:*)
    field_index="$(printf '%s' "$target" | cut -d ':' -f2)"
    secret="$(jq -r --argjson i "$field_index" '.fields[$i].value // empty | tostring' <<< "$item_json")"
    field_type="$(jq -r --argjson i "$field_index" '.fields[$i].type // empty' <<< "$item_json")"
    if [ "$field_type" = "hidden" ]; then
      clear_secret=1
    fi
    ;;
  *)
    exit 1
    ;;
esac

printf '%s' "$secret" | wl-copy
notify-send -t 2500 "Bitwarden" "Copied $target"

if [ "$clear_secret" -eq 1 ] && [ "$clear_after" -gt 0 ]; then
  (
    sleep "$clear_after"
    if [ "$(wl-paste 2>/dev/null || true)" = "$secret" ]; then
      wl-copy --clear
    fi
  ) >/dev/null 2>&1 &
fi
