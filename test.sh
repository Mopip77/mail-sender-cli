#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "-----------------------"
curl --ssl-reqd --url "smtps://smtp.qq.com:465" --user 'mopip77@qq.com:' --mail-from mopip77@qq.com --mail-rcpt notice@x3x.fun -T <(echo -e 'From: mopip77@qq.com\nTo: notice@x3x.fun\nSubject:  备份成功\n\n nixops.me已全部备份完成，请检查')

#./send.sh \
  #--smtp-server smtp.qq.com \
  #--smtp-port 465 \
  #--from mopip77@qq.com \
  #--password '' \
  #--to notice@x3x.fun \
  #--subject nihao \
  #--body haha
