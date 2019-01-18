#!/usr/bin/env bash

function cleanUp()
{
    \rm dir/.git/test.py
    \rm dir/.git/HelloWorld.java
    \rm -r dir/.git
    \rm a.tar.gz
    \rm a.tar.bz2
    \rm a.tgz
    \rm a.tbz2
    \rm a.tar
    \rm -rf tmp
}

visualTests=${1:0}

#cleanUp
trap cleanUp EXIT
trap cleanUp TERM

source ../start.sh

# prepare
mkdir dir/.git 2> /dev/null
\cp dir/src/HelloWorld.java dir/.git/HelloWorld.java
touch dir/.git/test.py
mkdir tmp 2> /dev/null


# hasCommand
hasCommand "ls" || (echo "You don't have ls command" && exit 1)

# findFiles
files=($(findFiles '*.java'))
[[ ${#files[@]} == 3 ]] || (echo "findFiles '*.java' failed" && exit 1)

# findGrepi
oldIFS=$IFS
IFS=$'\n'
files=($(findGrepi "hello world" '*.java'))
[[ ${#files[@]} == 1 ]] || (echo "findGrepi "hello world" '*.java' failed" && exit 1)
IFS=$oldIFS

# findGrep
oldIFS=$IFS
IFS=$'\n'
files=($(findGrep "hello world" '*.java'))
[[ ${#files[@]} == 0 ]] || (echo "findGrep "hello world" '*.java' failed" && exit 1)
IFS=$oldIFS

oldIFS=$IFS
IFS=$'\n'
files=($(findGrep "Jane"))
[[ ${#files[@]} == 5 ]] || (echo "findGrep 'Jane' failed" && exit 1)
IFS=$oldIFS

oldIFS=$IFS
IFS=$'\n'
files=($(findGrep "Jane" '*.txt'))
[[ ${#files[@]} == 1 ]] || (echo "findGrep 'Jane' '*.txt' failed" && exit 1)
IFS=$oldIFS

# pack and peek
pack a.tar dir/
[[ -f a.tar ]] || (echo "pack a.tar dir failed" && exit 1)
[[ $(peek a.tar | grep "/main/com/java/ext/User.java") ]] || (echo "peek failed" && exit 1)

pack a.tar.gz a.tar
pack a.tar.bz2 a.tar
[[ ! $(peek a.tar.gz | grep "/main/com/java/ext/User.java") ]] || (echo "peek failed" && exit 1)
[[ ! $(peek a.tar.bz2 | grep "/main/com/java/ext/User.java") ]] || (echo "peek failed" && exit 1)

\rm a.tar.gz
\rm a.tar.bz2

pack a.tar.gz dir/
[[ -f a.tar.gz ]] || (echo "pack a.tar.gz dir failed" && exit 1)
[[ $(peek a.tar.gz | grep "/main/com/java/ext/User.java") ]] || (echo "peek failed" && exit 1)

pack a.tar.bz2 dir/
[[ -f a.tar.bz2 ]] || (echo "pack a.tar.bz2 dir failed" && exit 1)
[[ $(peek a.tar.bz2 | grep "/main/com/java/ext/User.java") ]] || (echo "peek failed" && exit 1)

pack a.tgz dir/
[[ -f a.tgz ]] || (echo "pack a.tgz dir failed" && exit 1)
[[ $(peek a.tgz | grep "/main/com/java/ext/User.java") ]] || (echo "peek failed" && exit 1)

pack a.tbz2 dir/
[[ -f a.tbz2 ]] || (echo "pack a.tbz2 dir failed" && exit 1)
[[ $(peek a.tbz2 | grep "/main/com/java/ext/User.java") ]] || (echo "peek failed" && exit 1)

# unpacking
\cp a.tar.gz tmp
cd tmp
unpack a.tar.gz
files=($(findFiles '*.java'))
[[ ${#files[@]} == 3 ]] || (echo "findFiles '*.java' failed" && exit 1)
cd ..

# md5
md5=$(getMd5 dir/src/HelloWorld.java)
[[ $md5 == '18b1517b17398ab3f35ced58444f85be' ]] || (echo "getMd5 failed" && exit 1)

# prependPath
hasThisPath=$(echo $PATH | tr ":" "\n" | while read i
do
    if [ "$i" = "$ENV_BASE_DIR/bin/test" ]; then
        printf "t"
        break;
    fi
done
echo "f"
)
[[ $hasThisPath == "f" ]] || (echo "$ENV_BASE_DIR/bin/test already exists" && exit 1)
prependPath PATH "$ENV_BASE_DIR/bin/test"
hasThisPath=$(echo $PATH | tr ":" "\n" | while read i
do
    if [ "$i" = "$ENV_BASE_DIR/bin/test" ]; then
        printf "t"
        exit 0;
    fi
done
echo "f"
)
[[ $hasThisPath == "tf" ]] || (echo "prependPath failed" && exit 1)

# crypt.sh
cd tmp
cp ../dir/src/main/com/java/ext/User.java .
crypt.sh create privateKey.pem  > /dev/null 2>&1
crypt.sh public privateKey.pem > publicKey.pem 2> /dev/null
echo "Hello World" > shortMesg.txt
crypt.sh encrypt privateKey.pem < shortMesg.txt > shortMesg.enc.bin 2> /dev/null
crypt.sh decrypt privateKey.pem < shortMesg.enc.bin > shortMesg.dec.txt 2> /dev/null
diff shortMesg.txt shortMesg.dec.txt || (echo "Failed: crypt.sh decrypt privateKey.pem < shortMesg.enc.bin > shortMesg.dec.txt" && exit 1)
crypt.sh encrypt publicKey.pem < shortMesg.txt > shortMesg.pub.enc.bin 2> /dev/null
crypt.sh decrypt privateKey.pem < shortMesg.pub.enc.bin > shortMesg.dec2.txt 2> /dev/null
diff shortMesg.txt shortMesg.dec2.txt || (echo "Failed: crypt.sh decrypt privateKey.pem < shortMesg.pub.enc.bin > shortMesg.dec2.txt" && exit 1)
crypt.sh sign privateKey.pem < User.java > User.sig.file 2> /dev/null
crypt.sh verify publicKey.pem User.sig.file < User.java > /dev/null 2>&1 || (echo "Failed: crypt.sh verify publicKey.pem User.sig.file < User.java" && exit 1)
touch User2.java
! crypt.sh verify publicKey.pem User.sig.file < User2.java > /dev/null 2>&1 || (echo "Failed: crypt.sh verify publicKey.pem User.sig.file < User2.java" && exit 1)
crypt.sh generate 32 > secretKey.txt
crypt.sh encrypt secretKey.txt < User.java > User.java.enc
crypt.sh decrypt secretKey.txt < User.java.enc > UserCopy.java
diff User.java UserCopy.java || (echo "Failed: crypt.sh decrypt secretKey.txt < enc.txt > UserCopy.java" && exit 1)
\rm User.java User2.java UserCopy.java secretKey.txt User.java.enc User.sig.file
\rm privateKey.pem publicKey.pem shortMesg.txt shortMesg.dec.txt shortMesg.pub.enc.bin shortMesg.dec2.txt
cd ..

if [[ $visualTests == 1 ]] ; then
    #setTitle and resetTitle
    setTitle "Hello World"
    printf "Is the title of this terminal 'Hello World'? [Y/n] "
    read answer
    [[ $answer == 'y' || $answer == 'Y' || $answer == "" ]] || (echo "setTitle failed" & exit 1)
    resetTitle

    # openResource
    openResource "http://www.optoshare.com"
    printf "Did we open a url in your browser ? [Y/n] "
    read answer
    [[ $answer == 'y' || $answer == 'Y' || $answer == "" ]] || (echo "openResource failed" & exit 1)
fi
