#!/bin/bash

# TG variables
chat_id=-1001817086054
bot_token=5498602147:AAGV8n_lBIa-KmPfG884c-MC7xDlBXgRFhU

NAME=NekoKernel
version=Snapshot
START=$(date +"%s")
source=`${pwd}`
date="`date +"%m%d-%H%M"`"

# Cloning kernel source
git clone https://github.com/MOleg1759/android_kernel_xiaomi_sdm660.git

# Cloning AnyKernel
git clone --depth 1 https://github.com/MOleg1759/AnyKernel3-4.19.git -b 4.19 AnyKernel3

# Cloning toolchains
# git clone --depth=1 https://github.com/sohamxda7/llvm-stable.git -b aosp-12.0.6 aosp-clang
# git clone https://github.com/sohamxda7/llvm-stable -b gcc64 --depth=1 gcc
# git clone https://github.com/sohamxda7/llvm-stable -b gcc32  --depth=1 gcc32
git clone https://github.com/kdrag0n/proton-clang.git --depth=1 clang

# PATH="$source/aosp-clang/bin:$source/gcc/bin:${PATH}"

clang_path="${source}/clang/bin/clang"
gcc_path="${source}/clang//bin/aarch64-linux-gnu-"
gcc_32_path="${source}/clang/bin/arm-linux-gnueabi-"

print (){
case ${2} in
	"red")
	echo -e "\033[31m $1 \033[0m";;

	"blue")
	echo -e "\033[34m $1 \033[0m";;

	"yellow")
	echo -e "\033[33m $1 \033[0m";;

	"purple")
	echo -e "\033[35m $1 \033[0m";;

	"sky")
	echo -e "\033[36m $1 \033[0m";;

	"green")
	echo -e "\033[32m $1 \033[0m";;

	*)
	echo $1
	;;
	esac
}

args="CC=$clang_path \
	CROSS_COMPILE=$gcc_path \
	CROSS_COMPILE_ARM32=$gcc_32_path \
	-j$(nproc --all) "

clean(){
	rm -rf out
}

#export KBUILD_BUILD_USER="Incubator"
#export KBUILD_BUILD_HOST="Ratoriku"

build_oldcam(){
	print "Building OLDCAM version..." blue
	make $args lavender_defconfig && make $args
	if [ $? -ne 0 ]; then
    errored "Error while building for OLDCAM!"
    else
    export zipname="$NAME-$version-lavender-OLDCAM-$date.zip"
	mkzip
	fi
}

build_newcam(){
	print "Building NEWCAM version..." blue
	echo CONFIG_MACH_XIAOMI_NEWCAM=y >> arch/arm64/configs/lavender-defconfig
	make $args lavender_defconfig && make $args
	if [ $? -ne 0 ]; then
    errored "Error while building for NEWCAM!"
    else
    export zipname="$NAME-$version-lavender-NEWCAM-$date.zip"
	mkzip
	fi
}

build_qcam(){
	print "Building QCAM version..." blue
	echo CONFIG_MACH_XIAOMI_QCAM=y >> arch/arm64/configs/lavender-defconfig
	make $args lavender_defconfig && make $args
	if [ $? -ne 0 ]; then
    errored "Error while building for QCAM!"
    else
    export zipname="$NAME-$version-lavender-QCAM-$date.zip"
	mkzip
	fi
}

function telegram_notify(){
    curl -s https://api.telegram.org/bot"${bot_token}"/sendMessage -d parse_mode="Markdown" -d text="${1}" -d chat_id="${chat_id}"
}

function errored(){
    telegram_notify "${1}"
    exit 1
}

function telegram_upload(){
    curl -s https://api.telegram.org/bot"${bot_token}"/sendDocument -F document=@"${1}" -F chat_id="${chat_id}"
}

mkzip(){
	cp -f out/arch/arm64/boot/Image.gz-dtb ${HOME}/AnyKernel3
	cd ${HOME}/AnyKernel3
	make
	mv -f *.zip ${HOME}/$zipname
	cd ${HOME}
	telegram_upload ${zipname}
	cd $source
	print "Done! Check your $zipname" green
}

	telegram_notify "Start building 
	Version: $NAME-$version
	Date: $date "
	START=$(date +"%s")

	build_oldcam
#	clean
#	build_newcam
#	clean
#	build_qcam

	END=$(date +"%s")
	KDURTION=$((END - START))
	telegram_notify "Done! Cost time $((KDURTION / 60)) min $((KDURTION % 60)) s"
