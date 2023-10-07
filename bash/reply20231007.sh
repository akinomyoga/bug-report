# -*- mode: sh; mode: sh-bash; -*-

# Reply-To: https://lists.gnu.org/archive/html/help-bash/2023-10/msg00007.html
#
# An example to serialize the current status of keybindings. This is based on
# https://github.com/akinomyoga/ble.sh/blob/master/src/decode.sh#L2846-L2968

function ble/decode/bind/serialize {
  ble/decode/bind/serialize/.impl 3>/dev/null
}

function ble/decode/bind/serialize/restore {
  builtin eval -- "$(ble/decode/bind/serialize/.impl 3>&1 1>/dev/null)"
  builtin eval -- "$1"
}

function ble/decode/bind/serialize/.impl {
  {
    if ((BASH_VERSINFO[0] >= 5 || BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 3)); then
      builtin printf '__BINDX__\n'
      builtin bind -X
    fi
    builtin printf '__BINDP__\n'
    builtin bind -sp
  } | ble/decode/bind/serialize/.process

  # Note: To suppress errors appearing when the system's locale is broken, the
  # awk invokation is separated into a function and 2>/dev/null is specified.
} 2>/dev/null

## @fd 1 output codes to set up the current keybindings
## @fd 3 output codes to remove the current keybindings
function ble/decode/bind/serialize/.process {
  # switch awk implementation in Solaris
  local awk=awk is_xpg4=0
  [[ $OSTYPE == solaris* ]] &&
    type /usr/xpg4/bin/awk >/dev/null &&
    awk=/usr/xpg4/bin/awk is_xpg4=1

  local q=\' Q="'\''"
  LC_ALL=C exec "$awk" -v q="$q" '
    BEGIN {
      IS_XPG4 = '"$is_xpg4"';
      rep_Q         = str2rep(q "\\" q q);
      rep_bslash    = str2rep("\\");
      rep_kseq_1c5c = str2rep("\"\\x1c\\x5c\"");
      rep_kseq_1c   = str2rep("\"\\x1c\"");
      mode = 1;
    }

    function str2rep(str) {
      if (IS_XPG4) sub(/\\/, "\\\\\\\\", str);
      return str;
    }

    function quote(text) {
      gsub(q, rep_Q, text);
      return q text q;
    }

    function unescape_control_modifier(str, _, i, esc, chr) {
      for (i = 0; i < 32; i++) {
        if (i == 0 || i == 31)
          esc = sprintf("\\\\C-%c", i + 64);
        else if (27 <= i && i <= 30)
          esc = sprintf("\\\\C-\\%c", i + 64);
        else
          esc = sprintf("\\\\C-%c", i + 96);

        chr = sprintf("%c", i);
        gsub(esc, chr, str);
      }
      gsub(/\\C-\?/, sprintf("%c", 127), str);
      return str;
    }
    function unescape(str) {
      if (str ~ /\\C-/)
        str = unescape_control_modifier(str);
      gsub(/\\e/, sprintf("%c", 27), str);
      gsub(/\\"/, "\"", str);
      gsub(/\\\\/, rep_bslash, str);
      return str;
    }

    function output_bindr(line0, _seq) {
      if (match(line0, /^"(([^"\\]|\\.)+)"/) > 0) {
        _seq = substr(line0, 2, RLENGTH - 2);

        # Note: We need to convert "\M-" to "\e" because in Bash 3.1, bind -sp
        # outputs "\M-" instead of "\e", but bind -r only recognizes "\e".
        gsub(/\\M-/, "\\e", _seq);

        print "builtin bind -r " quote(_seq) > "/dev/stderr";
      }
    }

    /^__BINDP__$/ { mode = 1; next; }
    /^__BINDX__$/ { mode = 2; next; }

    mode == 1 && $0 ~ /^"/ {

      # Note: Bash 5.0 has a bug that bind -p produces broken keyseqs like
      # "\C-\\\" and "\C-\".  This code fixes it to the correct ones.
      sub(/^"\\C-\\\\\\"/, rep_kseq_1c5c);
      sub(/^"\\C-\\\\?"/, rep_kseq_1c);

      output_bindr($0);

      print "builtin bind " quote($0);
    }

    mode == 2 && $0 ~ /^"/ {
      output_bindr($0);

      line = $0;

      # In Bash 4.3..5.0, "bind -x" entry is not removed from the output of
      # "bind -X" even if the key binding is deleted.  Suspicious key bindings
      # are filtered out here.  The following is an EXAMPLE used in ble.sh.
      # You may customize the pattern depending on your usage.
      if (line ~ /(^|[^[:alnum:]])ble-decode\/.hook($|[^[:alnum:]])/) next;

      # Note: We cannot directly pass the output of "bind -X" to "bind -x".  We
      # need to resolve the escapes such as \C-a, \C-?, \e, \\, and \".
      # Typical escape sequences in C, such as \n\r\f\t\v\b\a, do not seem to
      # appear.
      if (match(line, /^("([^"\\]|\\.)*":) "(([^"\\]|\\.)*)"/) > 0) {
        rlen = RLENGTH;
        match(line, /^"([^"\\]|\\.)*":/);
        rlen1 = RLENGTH;
        rlen2 = rlen - rlen1 - 3;
        sequence = substr(line, 1        , rlen1);
        command  = substr(line, rlen1 + 3, rlen2);

        if (command ~ /\\/)
          command = unescape(command);

        line = sequence command;
      }

      print "builtin bind -x " quote(line);
    }
  ' 2>&3
}
