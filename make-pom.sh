#!/bin/bash

if [ "$1" == "" ]; then
	echo "Error: You did not specify the path of the directory to process"
	echo "Syntax: $0 /path/to/project/lib/containing/jar/files"
	exit 1
fi

cd "$1"

for file in $(gfind -name "*.jar" | sed "s/^\.\///g"); do

	VERSION=$(unzip -p - $file META-INF/maven/*/*/pom.properties 2>/dev/null | grep "^version" | cut -d '=' -f 2 | sed -e 's/[[:space:]]*$//')
	ART=$(unzip -p - $file META-INF/maven/*/*/pom.properties 2>/dev/null | grep "^artifactId" | cut -d '=' -f 2 | sed -e 's/[[:space:]]*$//')
	GROUP=$(unzip -p - $file META-INF/maven/*/*/pom.properties 2>/dev/null | grep "^groupId" | cut -d '=' -f 2 | sed -e 's/[[:space:]]*$//')

	echo "<!-- $file -->" >>pom.xml

	if [ "$VERSION" != "" ]; then
		echo "$file found dep info in jar"
		echo "<dependency>" >>pom.xml
		echo "    <groupId>$GROUP</groupId>" >>pom.xml
		echo "    <artifactId>$ART</artifactId>" >>pom.xml
		echo "    <version>$VERSION</version>" >>pom.xml
		echo "</dependency>" >>pom.xml
		echo "" >>pom.xml
	else
		SHA1=$(shasum $file)
		shas=($SHA1)
		#LOOKUPINFO=`lookup-jar.py $file $SHA1`

		# call python script to lookup jar by SHA1 checksum on search.maven.org
		LOOKUPINFO=$(
			python - $file ${shas[0]} <<END
import json
from urllib.request import urlopen
import sys
import os

jar = sys.argv[1]
sha = sys.argv[2]

searchurl = 'https://central.sonatype.com/solrsearch/select?q=1:%22'+sha+'%22&rows=20&wt=json'
page = urlopen(searchurl)
data = json.loads(page.read())
if data["response"] and data["response"]["numFound"] == 1:
   print("<!-- Found info on search.maven.org for "+jar+" -->\r\n")
   jarinfo = data["response"]["docs"][0]
   print('<dependency>\r\n')
   print('    <groupId>'+jarinfo["g"]+'</groupId>\r\n')
   print('    <artifactId>'+jarinfo["a"]+'</artifactId>\r\n')
   print('    <version>'+jarinfo["v"]+'</version>\r\n')
   print('</dependency>\r\n')
   print('\r\n')

END
		)

		if [ "$LOOKUPINFO" != "" ]; then
			echo $file found dep info at search.maven.org
			echo $LOOKUPINFO >>pom.xml
		else
			# did not find on search.maven.org so add info from MANIFEST.MF
			echo "$file ***** dep info not found *****"
			MFHEAD=$(unzip -p - $file META-INF/MANIFEST.MF | head -n 15)
			VERSION=$(unzip -p - $file META-INF/MANIFEST.MF | head -n 15 | grep "Implementation-Version" | cut -d ':' -f 2 | sed -e 's/[[:space:]]*//' | tr -d "\r")
			echo "<!-- TODO find the dep info for jar $file" >>pom.xml
			echo "$MFHEAD" >>pom.xml
			echo "-->" >>pom.xml
			echo "<dependency>" >>pom.xml
			echo "    <groupId>$file</groupId>" >>pom.xml
			echo "    <artifactId>$file</artifactId>" >>pom.xml
			echo "    <version>$VERSION</version>" >>pom.xml
			echo "</dependency>" >>pom.xml
			echo "" >>pom.xml
		fi
	fi

done

