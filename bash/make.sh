#!/usr/bin/env bash

bash=~/prog/ext/bash-dev

function enumerate-change-items {
  iconv -f iso-8859-1 -t utf-8 -c "$bash"/{CWRU/old-changelogs/CWRU.chlog.*,ChangeLog} | awk '
    function flush_item() {
      if (item_text != "") {
        print item_text;
        item_text = "";
      }
    }
    /^[[:space:]]/ {
      content = $0;
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", content);
      if (content ~ /^[0-9]+\/[0-9]+$|^-+$/) next;
      if ($0 ~ /^\t([-o])[[:space:]]/) {
        flush_item();
        item_text = content;
      } else {
        item_text = item_text " " content;
      }
    }
    END { flush_item(); }
  '
}

function sub:generate-chlog-dict {
  enumerate-change-items | awk '
    match($0, /(by|[Ff]rom|with) ([^<>]*) <([^<>[:space:]]*@[[:alnum:].-]+\.[[:alpha:]]+)>/, m) > 0 {
      name = m[2];
      sub(/^.*\y(by|[Ff]rom|with) /, "", name);
      if (name ~ /\y(by|[Ff]rom|with)$/) next;
      print m[3] ":" name;
    }' | sort -u
  #| sort -t : -k 2 | uniq
}

function sub:list-contributions {
  {
    echo "__mode_dict__"
    cat chlog.dict.dat
    echo "__mode_address__"
    enumerate-change-items | grep -Eo '[^()<>`'\''"[:space:]|]+@[^()<>`'\''"[:space:]|]+\.[^()<>`'\''"[:space:]|]+'
  } | awk -F : '
    /^__mode_dict__$/ { mode = "dict"; next; }
    mode == "dict" {
      if (dict[$1] != "")
        print $1 ": dup_name: " dict[$1] ", " $2 > "/dev/stderr";
      else
        dict[$1] = $2;
  
      if (name2addr[$2] != "")
        name2addr[$2] = name2addr[$2] ", " $1;
      else
        name2addr[$2] = $1;
    }
  
    /^__mode_address__$/ { mode = "address"; next; }
    mode == "address" {
      name = $0
      if (dict[name] != "") {
        name = dict[name];
        name = name " (" name2addr[name] ")";
      }
      print name;
    }
  ' | sort | uniq -c | sort -nr
}
function list-items {
  {
    echo "__mode_dict__"
    cat chlog.dict.dat
    echo "__mode_item__"
    enumerate-change-items
  } | awk -F : -v NAME="$1" '
    /^__mode_dict__$/ { mode = "dict"; next; }
    mode == "dict" {
      if (NAME == $2)
        a[n++] = $1;
    }
    /^__mode_item__$/ { mode = "item"; next; }
    function contains_name() {
      if (index($0, NAME) > 0) return 1;
      for (i = 0; i < n; i++)
        if (index($0, a[i]) > 0) return 1;
    }
    mode == "item" && contains_name() { print; item_count++; }
    END { print "item_count = " item_count; }
  ' | ifold -w 80 --indent='- ' --indent-type=spaces --spaces
}

#list-contributions
#list-items "Grisha Levit"                # 20/113 ("From a report by Hyunho Cho <mug896@gmail.com>" が最後の確認済み項目)
#list-items 'Eduardo A. Bustamante Lopez' # 16/61
#list-items 'Stephane Chazelas'           # 2/53
#list-items 'Mike Frysinger'              # 16/50
#list-items "Martijn Dekker"              # 3/50
#list-items 'Andreas Schwab'              # 24/58
#list-items "Koichi Murase"               # 31fix/45
#list-items "Dan Douglas"                 # 0/36
#list-items "Eric Blake"                  # 13/30

sub:"$@"
