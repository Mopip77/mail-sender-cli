#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SMTP_SERVER=${SMTP_SERVER:-}
SMTP_PORT=${SMTP_PORT:-}
MAIL_FROM=${MAIL_FROM:-}
PASSWORD=${PASSWORD:-}

MAIL_TO=
SUBJECT=
BODY=

param_validate() {
  if [[ -z $SMTP_SERVER ]]; then
    echo "smtp-server is required."
    exit 1
  elif [[ -z $SMTP_PORT ]]; then
    echo "smtp-port is required."
    exit 1
  elif [[ -z $MAIL_FROM ]]; then
    echo "mail-from is required."
    exit 1
  elif [[ -z $PASSWORD ]]; then
    echo "password is required."
    exit 1
  elif [[ -z $MAIL_TO ]]; then
    echo "mail-to is required."
    exit 1
  elif [[ -z $SUBJECT ]]; then
    echo "subject is required."
    exit 1
  fi
}

usage() {
  echo """mail-sender-cli 
  <--smtp-server server> 
  <--smtp-port port> 
  <--mail-from from_mail> 
  <--password from_password> 
  <--mail-to to_mail> 
  [--subject subj] 
  [--body body]

Arguments below can be replaced by envirionment variable.
  --smtp-server <=> SMTP_SERVER
  --smtp-port   <=> SMTP_PORT
  --password    <=> PASSWORD
  --mail-from   <=> MAIL_FROM

Arguments below can be repeatly assigned.
  --mail-to
"""
}

# $1 string
# $2 delimiter
string_split() {
  string="$1"
  delimiter="$2"

  OLD_IFS="$IFS"
  IFS="$delimiter"
  arr=($1)
  IFS=$OLD_IFS

  return $arr
}

quit=false

while [ $# -gt 0 ]; do
  case "$1" in
    --smtp-server ) SMTP_SERVER="$2"; shift 2 ;;
    --smtp-port ) SMTP_PORT="$2"; shift 2 ;;
    --mail-from ) MAIL_FROM="$2"; shift 2 ;;
    --password ) PASSWORD="$2"; shift 2 ;;
    --mail-to ) 
      if [ -n "$2" ]; then
        MAIL_TO="$2,${MAIL_TO}"
      fi
      shift 2
      ;;
    -s | --subject ) SUBJECT="$2"; shift 2 ;;
    -b | --body ) BODY="$2"; shift 2 ;;
    -h ) usage ; quit=true; break ;;
    * ) break ;;
  esac
done

if $quit; then exit 0; fi

param_validate

# parse mail receivers
TO_IN_MAIL=
declare -a TO_CURL_ARGS
while IFS="," read -ra receivers; do
  i=0
  for receiver in "${receivers[@]}"; do
    TO_IN_MAIL="${TO_IN_MAIL:+$TO_IN_MAIL\n}To: <${receiver}>"
    TO_CURL_ARGS+=("--mail-rcpt" "${receiver}")
  done
done <<< ${MAIL_TO}

echo -e """From: <${MAIL_FROM}>
${TO_IN_MAIL}
Subject: "$SUBJECT"

${BODY}
""" | \
curl --ssl-reqd \
  --url "smtps://${SMTP_SERVER}:${SMTP_PORT}" \
  --user "${MAIL_FROM}:${PASSWORD}" \
  --mail-from "${MAIL_FROM}" \
  ${TO_CURL_ARGS[@]} \
  -T -
