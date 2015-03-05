#!/bin/sh

echo "Content-type: text/html"
echo ""

cat <<HEADER
<html>
  <body style="font-family: monospace;">
HEADER

HTTPDTOPDIR=`dirname ${PWD}`
FULLPATH="${HTTPDTOPDIR}${REQUEST_URI}"
FULLHOSTURL="http://${HTTP_HOST}"
FULLREQ="${FULLHOSTURL}${REQUEST_URI}"

if `echo ${FULLREQ} | grep -q /$` ; then
  echo "<a href=\"${FULLHOSTURL}\">top directory</a> <br /> <br />"
  echo "<a href=\"${FULLREQ}..\">parent directory</a> <br /> <br />"
  for i in `ls ${FULLPATH}` ; do
    ls -lAd ${FULLPATH}${i} | \
      sed "s#${HTTPDTOPDIR}##g" | \
      egrep -v '(^total |cgi-bin)' | \
      sed "s#${i}#<a href=\"${i}\">${i}</a>#g" | \
      sort | \
      tr '\n' '|' | \
      sed 's#|#<br />|#g' | \
      tr '|' '\n'
    echo '<br />'
  done
fi

cat <<FOOTER
  </body>
</html>
FOOTER
