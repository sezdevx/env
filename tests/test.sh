#!/usr/bin/env bash

function cleanUp()
{
    \rm dir/.git/test.py
    \rm dir/.git/HelloWorld.java
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
fi
