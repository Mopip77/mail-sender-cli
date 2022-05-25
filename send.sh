#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SMTP_SERVER=${SMTP_SERVER:-}
SMTP_PORT=${SMTP_PORT:-}
FROM=${FROM:-}
PASSWORD=${PASSWORD:-}
TO=${TO:-}

SUBJECT=
BODY=

param_validate() {
  if [[ -z $SMTP_SERVER ]]; then
    echo "smtp_server is required."
    exit 1
  elif [[ -z $SMTP_PORT ]]; then
    echo "smtp_port is required."
    exit 1
  elif [[ -z $FROM ]]; then
    echo "from is required."
    exit 1
  elif [[ -z $PASSWORD ]]; then
    echo "password is required."
    exit 1
  elif [[ -z $TO ]]; then
    echo "to is required."
    exit 1
  elif [[ -z $SUBJECT ]]; then
    echo "SUBJECT is required."
    exit 1
  fi
}

usage() {
  echo """mail-sender-cli 
  <--smtp-server server> 
  <--smtp-port port> 
  <--from from_mail> 
  <--password from_password> 
  <--to to_mail> 
  [--subject subj] 
  [--body body]

Argument below can be replaced by envirionment variable.
  --smtp-server <=> SMTP_SERVER
  --smtp-port   <=> SMTP_PORT
  --password    <=> PASSWORD
  --from        <=> FROM
  --to          <=> TO
  """
}

quit=false

while [ $# -gt 0 ]; do
  case "$1" in
    --smtp-server ) SMTP_SERVER="$2"; shift 2 ;;
    --smtp-port ) SMTP_PORT="$2"; shift 2 ;;
    --from ) FROM="$2"; shift 2 ;;
    --password ) PASSWORD="$2"; shift 2 ;;
    --to ) TO="$2"; shift 2 ;;
    -s | --subject ) SUBJECT="$2"; shift 2 ;;
    -b | --body ) BODY="$2"; shift 2 ;;
    -h ) usage ; quit=true; break ;;
    * ) break ;;
  esac
done

if $quit; then exit 0; fi

set -x

param_validate

tmp_file=/tmp/$(uuidgen)
echo """
From: "${FROM}" <${FROM}>
To: "${TO}" <${TO}>
Subject: "$SUBJECT"

${BODY}
""" > $tmp_file

curl --ssl-reqd \
  --url "smtps://${SMTP_SERVER}:${SMTP_PORT}" \
  --user "${FROM}:${PASSWORD}" \
  --mail-from "${FROM}" \
  --mail-rcpt "${TO}" \
  --upload-file $tmp_file
