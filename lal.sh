# lal — List Aliases
# Source this file or add to your .zshrc / .bashrc

lal() {
  local rc_file

  if [ -n "$ZSH_VERSION" ]; then
    rc_file="$HOME/.zshrc"
  elif [ -n "$BASH_VERSION" ]; then
    rc_file="$HOME/.bashrc"
  else
    echo "Unsupported shell." && return 1
  fi

  # ── Collect aliases and their line numbers in the rc file ──────────
  local alias_line_nums=""   # colon-delimited line numbers
  local alias_entries=""     # newline-delimited "name=value" strings
  local line_num=0
  local count=0
  local stripped

  while IFS= read -r line; do
    line_num=$((line_num + 1))
    stripped="${line#"${line%%[![:space:]]*}"}"
    if [[ "$stripped" == alias\ * ]]; then
      count=$((count + 1))
      alias_line_nums="${alias_line_nums}${line_num}:"
      if [ -z "$alias_entries" ]; then
        alias_entries="${stripped#alias }"
      else
        alias_entries="${alias_entries}
${stripped#alias }"
      fi
    fi
  done < "$rc_file"

  # ── Display ────────────────────────────────────────────────────────
  echo ""
  echo "  Aliases in $rc_file"
  echo "  ──────────────────────────────────────────"

  if [ "$count" -eq 0 ]; then
    echo "  (no aliases found)"
  else
    local i=0
    while IFS= read -r entry; do
      i=$((i + 1))
      # Clean up display: split into name=value, strip escapes and quotes from value
      local aname="${entry%%=*}"
      local aval="${entry#*=}"
      # Remove surrounding quotes (single or double)
      aval="${aval%\'}" ; aval="${aval#\'}"
      aval="${aval%\"}" ; aval="${aval#\"}"
      # Remove backslash escapes (e.g. cd\ ~/foo -> cd ~/foo)
      aval="${aval//\\/}"
      printf "  %2d.  %s = %s\n" "$i" "$aname" "$aval"
    done <<< "$alias_entries"
  fi

  echo ""
  echo "  [a] Add   [m] Modify   [r] Remove   [q] Quit"
  printf "  > "

  local key
  if [ -n "$ZSH_VERSION" ]; then
    read -r -k 1 key
  else
    read -r -n 1 key
  fi
  echo ""

  # ── Helpers ────────────────────────────────────────────────────────
  # Get the Nth colon-delimited value from alias_line_nums
  _lal_nth_line_num() {
    echo "$alias_line_nums" | tr ':' '\n' | sed -n "${1}p"
  }

  # Get the Nth newline-delimited entry from alias_entries
  _lal_nth_entry() {
    echo "$alias_entries" | sed -n "${1}p"
  }

  # Extract just the alias name from an entry like: name='command'
  _lal_alias_name() {
    local entry="$1"
    local name="${entry%%=*}"
    # Strip any surrounding quotes (shouldn't be there, but be safe)
    name="${name%\"}"
    name="${name#\"}"
    name="${name%\'}"
    name="${name#\'}"
    echo "$name"
  }

  # Prompt for an alias number; sets _lal_sel_num, _lal_sel_line, _lal_sel_entry, _lal_sel_name
  _lal_pick_alias() {
    local action="$1"
    if [ "$count" -eq 0 ]; then
      echo "  No aliases to ${action}."
      return 1
    fi

    echo ""
    printf "  Alias # to %s (1-%d): " "$action" "$count"
    read -r _lal_sel_num

    if ! echo "$_lal_sel_num" | grep -qE '^[0-9]+$' || \
       [ "$_lal_sel_num" -lt 1 ] 2>/dev/null || \
       [ "$_lal_sel_num" -gt "$count" ] 2>/dev/null; then
      echo "  Invalid selection."
      return 1
    fi

    _lal_sel_line=$(_lal_nth_line_num "$_lal_sel_num")
    _lal_sel_entry=$(_lal_nth_entry "$_lal_sel_num")
    _lal_sel_name=$(_lal_alias_name "$_lal_sel_entry")
    return 0
  }

  # Delete a line from the rc file by line number (portable macOS + Linux)
  _lal_delete_line() {
    local target="$1"
    local tmp="${rc_file}.lal.tmp"
    awk -v n="$target" 'NR != n' "$rc_file" > "$tmp" && mv "$tmp" "$rc_file"
  }

  # Replace a line in the rc file by line number (portable, no sed delimiter issues)
  _lal_replace_line() {
    local target="$1"
    local replacement="$2"
    local tmp="${rc_file}.lal.tmp"
    local cur=0
    while IFS= read -r file_line; do
      cur=$((cur + 1))
      if [ "$cur" -eq "$target" ]; then
        printf '%s\n' "$replacement"
      else
        printf '%s\n' "$file_line"
      fi
    done < "$rc_file" > "$tmp" && mv "$tmp" "$rc_file"
  }

  # ── Actions ────────────────────────────────────────────────────────
  case "$key" in
    a|A)
      echo ""
      printf "  Alias name : "
      read -r alias_name
      if [ -z "$alias_name" ]; then
        echo "  Cancelled." && echo "" && return 0
      fi

      printf "  Command    : "
      read -r alias_cmd
      if [ -z "$alias_cmd" ]; then
        echo "  Cancelled." && echo "" && return 0
      fi

      printf '\nalias %s='\''%s'\''\n' "$alias_name" "$alias_cmd" >> "$rc_file"
      alias "${alias_name}=${alias_cmd}"

      echo ""
      echo "  + Added: alias ${alias_name}='${alias_cmd}'"
      echo "  Saved to $rc_file and active in this session."
      echo ""
      ;;

    r|R)
      _lal_pick_alias "remove" || { echo ""; return 0; }

      echo ""
      printf "  Remove  %s  ? [y/N] " "$_lal_sel_entry"

      local confirm
      if [ -n "$ZSH_VERSION" ]; then
        read -r -k 1 confirm
      else
        read -r -n 1 confirm
      fi
      echo ""

      if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        _lal_delete_line "$_lal_sel_line"
        unalias "$_lal_sel_name" 2>/dev/null

        echo ""
        echo "  - Removed: $_lal_sel_entry"
        echo "  Deleted from $rc_file and current session."
      else
        echo "  Cancelled."
      fi
      echo ""
      ;;

    m|M)
      _lal_pick_alias "modify" || { echo ""; return 0; }

      echo ""
      echo "  Current: $_lal_sel_entry"
      printf "  New command for '%s': " "$_lal_sel_name"
      read -r new_cmd

      if [ -z "$new_cmd" ]; then
        echo "  Cancelled." && echo "" && return 0
      fi

      local new_line
      new_line="$(printf 'alias %s='\''%s'\''' "$_lal_sel_name" "$new_cmd")"
      _lal_replace_line "$_lal_sel_line" "$new_line"
      alias "${_lal_sel_name}=${new_cmd}"

      echo ""
      echo "  ~ Modified: ${_lal_sel_name} -> '${new_cmd}'"
      echo "  Saved to $rc_file and active in this session."
      echo ""
      ;;

    *)
      echo ""
      ;;
  esac

  # Clean up helper functions
  unset -f _lal_nth_line_num _lal_nth_entry _lal_alias_name \
           _lal_pick_alias _lal_delete_line _lal_replace_line 2>/dev/null
}
