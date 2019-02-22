#!/bin/bash 
if [ "$#" -ne 2 ] || ! [ -d "$1" ] || ! [ -e "$2" ]; then
  echo "Usage: $0 PROJECT_DIRECTORY LOCALIZABLE_PATH" >&2
  exit 1
fi

diff <((grep -roh '".*"\.localized' $2 | sed 's/\.localized//'; grep -Eroh 'LocalizedString\(@".*?"' $1 | sed 's/LocalizedString(@//') | sort -u) <(grep -roh '".*" =' $2 | sed 's/ =//' | sort -u)