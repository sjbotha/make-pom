#!/bin/bash

if [ "$1" == "" ]; then
	echo "Error: You did not specify the path of the directory to process"
	echo "Syntax: $0 /path/to/project/lib/containing/jar/files"
	exit 1;
fi

cd "$1"

for file in `find -name "*.jar" | sed "s/^\.\///g"`; do 

VERSION=`unzip -p - $file META-INF/maven/*/*/pom.properties 2>/dev/null | grep "^version" | cut -d '=' -f 2 | sed -e 's/[[:space:]]*$//'`
ART=`unzip -p - $file META-INF/maven/*/*/pom.properties 2>/dev/null | grep "^artifactId" | cut -d '=' -f 2 | sed -e 's/[[:space:]]*$//'`
GROUP=`unzip -p - $file META-INF/maven/*/*/pom.properties 2>/dev/null | grep "^groupId" | cut -d '=' -f 2 | sed -e 's/[[:space:]]*$//'`

echo "<!-- $file -->" >> pom.xml

if [ "$VERSION" != "" ]; then
	echo "$file found dep info in jar"
	echo "<dependency>" >> pom.xml
	echo "    <groupId>$GROUP</groupId>" >> pom.xml
	echo "    <artifactId>$ART</artifactId>" >> pom.xml
	echo "    <version>$VERSION</version>" >> pom.xml
	echo "</dependency>" >> pom.xml
else
	SHA1=`sha1sum $file`
	#LOOKUPINFO=`lookup-jar.py $file $SHA1`

	# call python script to lookup jar by SHA1 checksum on search.maven.org
	LOOKUPINFO=$(python - $file $SHA1 << END
import json
import urllib2
import sys
import os

jar = sys.argv[1]
sha = sys.argv[2]

searchurl = 'http://search.maven.org/solrsearch/select?q=1:%22'+sha+'%22&rows=20&wt=json'
page = urllib2.urlopen(searchurl)
data = json.loads("".join(page.readlines()))
if data["response"] and data["response"]["numFound"] == 1:
	print "<!-- Found info on search.maven.org for "+jar+" -->"+os.linesep
	jarinfo = data["response"]["docs"][0]
	print '<dependency>'+os.linesep
	print '    <groupId>'+jarinfo["g"]+'</groupId>'+os.linesep
	print '    <artifactId>'+jarinfo["a"]+'</artifactId>'+os.linesep
	print '    <version>'+jarinfo["v"]+'</version>'+os.linesep
	print '</dependency>'+os.linesep

END
)
	
	if [ "$LOOKUPINFO" != "" ]; then
		echo $file found dep info at search.maven.org
		echo $LOOKUPINFO >> pom.xml
	else
		# did not find on search.maven.org so add info from MANIFEST.MF
		echo "$file ***** dep info not found *****"
		MFHEAD=`unzip -p - $file META-INF/MANIFEST.MF | head -n 15`
		VERSION=`unzip -p - $file META-INF/MANIFEST.MF | head -n 15 | grep "Implementation-Version" | cut -d ':' -f 2 | sed -e 's/[[:space:]]*//'`
		echo "<!-- TODO find the dep info for jar $file" >> pom.xml
		echo "$MFHEAD" >> pom.xml
		echo "-->" >> pom.xml
		echo "<dependency>" >> pom.xml
		echo "    <groupId>$file</groupId>" >> pom.xml
		echo "    <artifactId>$file</artifactId>" >> pom.xml
		echo "    <version>$VERSION</version>" >> pom.xml
		echo "</dependency>" >> pom.xml
	fi
fi

done
