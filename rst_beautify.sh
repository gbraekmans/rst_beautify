#!/bin/bash

set -e

FIL=''
INPLACE=''
WIDTH=80
TMP=''

show_help() {
  echo "rst_beautify.sh [-i] [-h] [-w NUM] FILE"
  echo "Beautifies an rst file to a specified width"
  echo "  -i: Edit file in place"
  echo "  -w: Set width. Default $WIDTH"
  echo "  -h: show help"
  exit 0
}

output() {
  if [[ -z "$INPLACE" ]]; then
    echo "$1"
  else
    echo "$1" >> "$TMP"
  fi
}

is_heading() {
  # The last line can't have any #, *, =, -, ~, ^, or " character
  [[ -z $(echo "$1" | tail -n1 | tr -d '#*=\-~^"') ]]
}

is_config() {
  local concat=$(echo "$1" | tr -d ' ')
  local first_char=${concat:0:1}
  local first_two_char=${concat:0:2}
  [[ ${first_char} == ":" || ${first_two_char} == ".." ]]
}

is_list() {
  local concat=$(echo "$1" | head -n1 | tr -d ' ')
  local first_char=${concat:0:1}
  [[ "+-*" == *"${first_char}"* ]] && return 0
  if (echo "${concat}" | grep '^[[:digit:]]\+\.' > /dev/null); then
    return 0
  else
    return 1
  fi
}

is_code_segment_start() {
  local concat=$(echo "$1" | head -n1 | tr -d ' ')
  [[ $concat == ..code::* ]]
}

is_indented() {
  local prefix=$(echo "$1" | head -n1 | grep -o '^[[:space:]]\+')
  [[ -n "$prefix" ]]
}

main() {
  [[ -n "$INPLACE" ]] && TMP=$(mktemp)

  # Split file on every empty line
  # see http://stackoverflow.com/questions/18539369/split-text-file-into-array-based-on-an-empty-line-or-any-non-used-character
  declare -a sections
  while IFS= read -r line; do
    [[ $line == "" ]] && ((i++)) && s=1 && continue
    [[ $s == 0 ]] && sections[$i]="${sections[$i]}
$line" || {
      sections[$i]="$line"
      s=0; 
    }
  done < "$FIL"

  local in_code=''
  for section in "${sections[@]}"; do
    # remove all leading empty lines
    section=$(echo "$section" | sed '/./,$!d')
    # don't reformat headings, config sections or lists
    if is_heading "$section" || is_config "$section" || is_list "$section"; then
      output "$section"
      # mark the start of a code segment.
      if is_code_segment_start "$section"; then
        in_code='yes'
      fi
    # don't reformat code segments
    elif [[ -n "$in_code" ]] && is_indented "$section"; then
      output "$section"
    # reformat everything else
    else
      in_code=''
      output "$(echo "$section" | fmt -w "${WIDTH}")"
    fi
    output
  done

  [[ -n "$INPLACE" ]] && mv "$TMP" "$FIL"
  return 0
}

# Parse options
while getopts ":hiw:" flag; do
  case "$flag" in
    i) INPLACE="yes";;
    h) show_help;;
    w) WIDTH=$OPTARG;;
  esac
done
FIL=${@:$OPTIND:1}
[[ -z "$FIL" ]] && show_help

main
