
# make-pom

This bash script creates the dependencies part of a pom.xml file from a collection of jars. For each jar we have to find the groupId, artifactId and version. This script is useful when converting a project from ant to maven.

To discover this information the script does the following:
1. It first looks inside the jar for META-INF/maven/
2. then it tries to search for the jar by SHA1 checksum on search.maven.org
3. then finally it puts a comment in pom.xml with information about the jar manifest to help you in locating the dependency yourself. Of course you may not find the jar anywhere and then you'll have to host it in your own private maven repository.


## Usage

Execute these commands to run the script. It will recursively process the directory you specify.

		$ git clone https://github.com/sjbotha/make-pom.git
		Cloning into 'make-pom'...
		remote: Enumerating objects: 8, done.
		remote: Counting objects: 100% (8/8), done.
		remote: Compressing objects: 100% (7/7), done.
		remote: Total 8 (delta 1), reused 8 (delta 1), pack-reused 0
		Unpacking objects: 100% (8/8), done.

		$ chmod +x make-pom/make-pom.sh

		$ make-pom/make-pom.sh ~/myproject/lib
		jakarta-oro-2.0.8.jar found dep info at search.maven.org
		log4j-over-slf4j-1.7.12.jar found dep info in jar
		mail.jar ***** dep info not found *****

		$ cat myproject/lib/pom.xml
		<!-- jakarta-oro-2.0.8.jar -->
		<!-- Found info on search.maven.org for jakarta-oro-2.0.8.jar -->
		 <dependency>
		 <groupId>oro</groupId>
		 <artifactId>oro</artifactId>
		 <version>2.0.8</version>
		 </dependency>
		 
		<!-- log4j-over-slf4j-1.7.12.jar -->
		<dependency>
			<groupId>org.slf4j</groupId>
			<artifactId>log4j-over-slf4j</artifactId>
			<version>1.7.12</version>
		</dependency>

		<!-- mail.jar -->
		<!-- TODO find the dep info for jar mail.jar
		Manifest-Version: 1.0
		Implementation-Version: 1.3.3_01
		Specification-Title: JavaMail(TM) API Design Specification
		Specification-Version: 1.3
		Extension-Name: javax.mail
		Created-By: 1.3.1 (Sun Microsystems Inc.)
		Implementation-Vendor-Id: com.sun
		Implementation-Vendor: Sun Microsystems, Inc.
		Specification-Vendor: Sun Microsystems, Inc.
		SCCS-ID: @(#)javamail.mf	1.5 02/03/14

		Name: javax/mail/search/SearchTerm.class
		SHA1-Digest: bJeLilaOUG6Et+Aio7NaAHhvZks=

		Name: javax/mail/SendFailedException.class
		-->
		<dependency>
			<groupId>mail.jar</groupId>
			<artifactId>mail.jar</artifactId>
			<version>1.3.3_01</version>
		</dependency>




I tested this on cygwin with bash. It should work on linux too.

## Dependencies
- bash
- sha1sum
- python

I think these dependencies were included in my cygwin by default.

## TODO

Can probably enhance it to search additional repositories by checksum

