#!/bin/sh

echo "Content-type: text/html"
echo ""

cat <<HEADER
<html>
  <body>
HEADER

echo "CGI Environment"
echo "<br />"
echo "<br />"

env | tr '\n' '|' | sed 's#|#<br />|#g' | tr '|' '\n'

cat <<FOOTER
  </body>
</html>
FOOTER
