#!/usr/bin/env bash

# check if we are running from tests directory, if not exit
export BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export CWD="$(pwd)"
if [[ $BASE_DIR != $CWD ]]; then
    echo "You need to run from tests directory"
    exit 1
fi


# run with ./test.sh 1 to run visual interactive tests too
# visual tests are those that require user interaction

function cleanUp()
{
    \rm -f dir/.git/test.py
    \rm -f dir/.git/HelloWorld.java
    \rm -fr dir/.git
    \rm -f a.tar.gz
    \rm -f a.tar.bz2
    \rm -f a.tgz
    \rm -f a.tbz2
    \rm -f a.tar
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

# isAbsoluteDir
isAbsoluteDir "/etc/" || (echo "isAbsoluteDir failed" && exit 1)
! isAbsoluteDir "etc/" || (echo "isAbsoluteDir failed" && exit 1)

# fromEpoch
d=$(fromEpoch 1543786787)
[[ $d =~ .*2018.* ]] || (echo "fromEpoch failed" && exit 1)
t=$(toEpoch $d)
[[ $t == 1543786787 ]] || (echo "toEpoch failed" && exit 1)

if hasCommand 'bc' ; then
    r=$(c '12 * 5')
    [[ $r == "60" ]] || (echo "c has failed" && exit 1)
fi

cd tmp
ln -s ../dir/src/main main
cd main

realPath=$(getRealPath .)
[[ $realPath =~ .*tmp\/main$ ]] || (echo "getRealPath failed" && exit 1)

cd - > /dev/null
\rm -r main
cd ..

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
files=($(findDuplicateFiles.sh dir))
[[ ${#files[@]} == 4 ]] || (echo "findDuplicateFiles.sh . failed" && exit 1)
IFS=$oldIFS

oldIFS=$IFS
IFS=$'\n'
files=($(findDuplicateFiles.sh))
[[ ${#files[@]} == 4 ]] || (echo "findDuplicateFiles.sh . failed" && exit 1)
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
\rm -r tmp/*

# md5
md5=$(getMd5 dir/src/HelloWorld.java)
[[ $md5 == '18b1517b17398ab3f35ced58444f85be' ]] || (echo "getMd5 failed" && exit 1)

# prependPath
hasThisPath=$(echo $PATH | tr ":" "\n" | while read i
do
    if [ "$i" = "$ENV_BASE_DIR/bin/for_test_only" ]; then
        printf "t"
        break;
    fi
done
echo "f"
)
[[ $hasThisPath == "f" ]] || (echo "$ENV_BASE_DIR/bin/for_test_only already exists" && exit 1)
prependPath PATH "$ENV_BASE_DIR/bin/for_test_only"
hasThisPath=$(echo $PATH | tr ":" "\n" | while read i
do
    if [ "$i" = "$ENV_BASE_DIR/bin/for_test_only" ]; then
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
cd ..
\rm -r tmp/*

# findRecentlyModified.sh
cd tmp
cp ../dir/src/main/com/java/ext/User.java .
touch User.java

oldIFS=$IFS
IFS=$'\n'
files=($(findRecentlyModified.sh 1 2> /dev/null))
[[ ${#files[@]} == 1 ]] || (echo "findRecentlyModified.sh 1 failed" && exit 1)
IFS=$oldIFS

oldIFS=$IFS
IFS=$'\n'
files=($(findRecentlyModified.sh 1m 2> /dev/null))
[[ ${#files[@]} == 1 ]] || (echo "findRecentlyModified.sh 1m failed" && exit 1)
IFS=$oldIFS

oldIFS=$IFS
IFS=$'\n'
files=($(findRecentlyModified.sh 1d 2> /dev/null))
[[ ${#files[@]} == 1 ]] || (echo "findRecentlyModified.sh 1d failed" && exit 1)
IFS=$oldIFS

oldIFS=$IFS
IFS=$'\n'
files=($(findRecentlyModified.sh 1h 2> /dev/null))
[[ ${#files[@]} == 1 ]] || (echo "findRecentlyModified.sh 1h failed" && exit 1)
IFS=$oldIFS

oldIFS=$IFS
IFS=$'\n'
files=($(findRecentlyModified.sh 1 '*.class' 2> /dev/null))
[[ ${#files[@]} == 0 ]] || (echo "findRecentlyModified.sh 1 '*.class' failed" && exit 1)
IFS=$oldIFS

touch -mt 201006301525  User.java

oldIFS=$IFS
IFS=$'\n'
files=($(findRecentlyModified.sh 180 2> /dev/null))
[[ ${#files[@]} == 0 ]] || (echo "findRecentlyModified.sh 180 failed" && exit 1)
IFS=$oldIFS

oldIFS=$IFS
IFS=$'\n'
files=($(findRecentlyModified.sh 100000d 2> /dev/null))
[[ ${#files[@]} == 1 ]] || (echo "findRecentlyModified.sh 100000d failed" && exit 1)
IFS=$oldIFS

files=($(findRecentlyModified.sh '*.java' 2> /dev/null))
[[ $? != 0 ]] || (echo "findRecentlyModified '*.java' failed" && exit 1)

cd ..
\rm -r tmp/*


# snapshot.sh
cd tmp
cp -r ../dir .

cd dir
snapshot.sh . > /dev/null 2>&1
sleep 2
snapshot.sh . > /dev/null 2>&1
cd ..

oldIFS=$IFS
IFS=$'\n'
files=($(ls dir_*))
[[ ${#files[@]} == 2 ]] || (echo "snapshot.sh failed" && exit 1)
IFS=$oldIFS

snapshot.sh -d dir . > /dev/null 2>&1
oldIFS=$IFS
IFS=$'\n'
files=($(ls dir_* 2> /dev/null))
[[ ${#files[@]} == 0 ]] || (echo "snapshot.sh -d dir . failed" && exit 1)
IFS=$oldIFS

snapshot.sh -s dir . > /dev/null 2>&1
oldIFS=$IFS
IFS=$'\n'
files=($(ls dir_*))
[[ ${#files[@]} == 1 ]] || (echo "snapshot.sh -d dir . failed" && exit 1)
IFS=$oldIFS
file=${files[0]}

\rm -r dir/
[[ ! -e dir/src/main/com/java/ext/User.java ]] || (echo "rm -r dir failed" && exit 1)
unpack $file
[[ -e dir/src/main/com/java/ext/User.java ]] || (echo "snapshot.sh failed, missing file" && exit 1)

cd ..
\rm -r tmp/*

# findOverSize.sh and largeDirs.sh
cd tmp
dd if=/dev/zero of=1k.file bs=1024 count=1 2> /dev/null
dd if=/dev/zero of=10k.file bs=1024 count=10 2> /dev/null
dd if=/dev/zero of=1m.file bs=1048576 count=1 2> /dev/null
dd if=/dev/zero of=32m.file bs=33554432 count=1 2> /dev/null

cd ../../
oldIFS=$IFS
IFS=$'\n'
files=($(largeDirs.sh 2> /dev/null))
#echo "${files[@]}"
[[ ${files[0]} =~ .*tests/tmp$ ]] || (echo "largeDirs.sh failed" && exit 1)
IFS=$oldIFS
cd tests/tmp

oldIFS=$IFS
IFS=$'\n'
files=($(findOverSize.sh 1 2> /dev/null))
[[ ${#files[@]} == 4 ]] || (echo "findOverSize.sh 1 failed" && exit 1)
IFS=$oldIFS

oldIFS=$IFS
IFS=$'\n'
files=($(findOverSize.sh 1 '*.log' 2> /dev/null))
[[ ${#files[@]} == 0 ]] || (echo "findOverSize.sh 1 '*.log' failed" && exit 1)
IFS=$oldIFS

oldIFS=$IFS
IFS=$'\n'
files=($(findOverSize.sh 1k 2> /dev/null))
[[ ${#files[@]} == 3 ]] || (echo "findOverSize.sh 1k failed" && exit 1)
IFS=$oldIFS

oldIFS=$IFS
IFS=$'\n'
files=($(findOverSize.sh 10k 2> /dev/null))
[[ ${#files[@]} == 2 ]] || (echo "findOverSize.sh 1k failed" && exit 1)
IFS=$oldIFS

oldIFS=$IFS
IFS=$'\n'
files=($(findOverSize.sh 1m 2> /dev/null))
[[ ${#files[@]} == 1 ]] || (echo "findOverSize.sh 1m failed" && exit 1)
IFS=$oldIFS

cd ..
\rm -r tmp/*

#manageVars.sh
manageVars -a test_manage_vars "Testing Manage Vars"
if [[ $test_manage_vars != "Testing Manage Vars" ]]; then
    echo "manageVars.sh failed adding" && exit 1
fi
result=$(manageVars.sh -s test_manage_vars)
if [[ $result != "'Testing Manage Vars'" ]]; then
    echo "manageVars.sh failed showing" && exit 1
fi
manageVars -d test_manage_vars
if [[ $test_manage_vars == "Testing Manage Vars" ]]; then
    echo "manageVars.sh failed removing" && exit 1
fi


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

    # open ports
    echo "Finding open ports"
    findOpenPorts.sh
    printf "Press any key to continue "
    read -n 1 -s -r -p "Press any key to continue "
    printf "\n"

    echo "Showing environment info "
    displayEnv.sh
    echo ""
    echo "--------------------------------------------------"
    echo ""
    echo "Showing directory tree "
    dirTree.sh
    echo "--------------------------------------------------"
fi
