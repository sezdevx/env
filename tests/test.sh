#!/usr/bin/env bash

function cleanUp()
{
    \rm dir/.git/test.py
    \rm dir/.git/HelloWorld.java
    \rm a.tar.gz
    \rm a.tar.bz2
    \rm a.tgz
    \rm a.tbz2
    \rm a.tar
    \rm -rf tmp
}

trap cleanUp EXIT
trap cleanUp TERM

source ../start.sh

mkdir dir/.git 2> /dev/null
\cp dir/src/HelloWorld.java dir/.git/HelloWorld.java
touch dir/.git/test.py

files=($(findFiles '*.java'))
[[ ${#files[@]} == 3 ]] || (echo "findFiles '*.java' failed" && exit 1)

oldIFS=$IFS
IFS=$'\n'
files=($(findGrepi "hello world" '*.java'))
[[ ${#files[@]} == 1 ]] || (echo "findGrepi "hello world" '*.java' failed" && exit 1)
IFS=$oldIFS

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

mkdir tmp
\cp a.tar.gz tmp
cd tmp
unpack a.tar.gz
files=($(findFiles '*.java'))
[[ ${#files[@]} == 3 ]] || (echo "findFiles '*.java' failed" && exit 1)
cd ..


md5=$(getMd5 dir/src/HelloWorld.java)
[[ $md5 == '18b1517b17398ab3f35ced58444f85be' ]] || (echo "getMd5 failed" && exit 1)

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

if [[ 0 == 1 ]] ; then
    setTitle "Hello World"
    printf "Is the title of this terminal 'Hello World'? [Y/n] "
    read answer
    [[ $answer == 'y' || $answer == 'Y' || $answer == "" ]] || (echo "setTitle failed" & exit 1)
    resetTitle

    openResource "http://www.optoshare.com"
    printf "Did we open a url in your browser ? [Y/n] "
    read answer
    [[ $answer == 'y' || $answer == 'Y' || $answer == "" ]] || (echo "openResource failed" & exit 1)
fi
