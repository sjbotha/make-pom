
# make-pom.sh

This bash script creates the dependencies part of a pom.xml file from a collection of jars. Useful if you are converting a project from ant to maven.

Execute these commands to run the script:

	git clone
	
	
    cd myproject/lib/
    ~/make-pom/make-pom.sh

The pom.xml file will be created in the current directory. It will process jar files in the current directory and all sub directories.
	
I tested this on cygwin with bash. It should work on linux too.

# Dependencies
bash
sha1sum
python

I think these dependencies were included in my cygwin by default.

