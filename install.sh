#!/bin/bash

set -ex

echo "参数校验🔎"
if [ -z $1 ]; then
    echo "请输入参数 \$1 以指定输入法的“安装目录”。"
    exit 1
fi
if [ ! -d $1 ]; then
    echo "目录 \"${1}\" 不存在。"
    exit 1
fi
path_installation=$1
if [ -z $2 ]; then
    echo "请输入参数 \$2 以指定输入法的“用户目录”。"
    exit 1
fi
if [ ! -d $2 ]; then
    echo "目录 \"${2}\" 不存在。"
    exit 1
fi
path_userdata=$2
owner=LawssssCat
repo=rime-aurora

rime_dll="rime.dll"
rime_dll_sha256sum_v1_3="76b7e5af9dd60c5296510756fa81f30a42a92d5fea6277e63415939f7740f0dc  ${rime_dll}"
rime_dll_sha256sum="${rime_dll_sha256sum=${rime_dll_sha256sum_v1_3}}"

echo "拷贝文件到“用户文件夹📁”"
cd ${path_userdata}
git clone https://github.com/LawssssCat/rime-aurora.git -b master --depth=1 ./${repo}
if [ ! -d ./${repo} ]; then
    echo "fail clone repo."
    exit 1
fi
cp ./${repo}/dict                ./ -r
cp ./${repo}/lua                 ./ -r
cp ./${repo}/opencc              ./ -r
cp ./${repo}/patch               ./ -r
cp ./${repo}/*.yaml              ./
cp ./${repo}/rime.lua            ./
cp ./${repo}/*.gram              ./
cp ./${repo}/custom_phrase.txt   ./

echo "更新 librime-lua 📄"
rime_url=`curl -s https://api.github.com/repos/${owner}/${repo}/releases/latest | grep browser_download_url | grep rime.dll | cut -f4 -d "\""`
# rime_name=`echo ${rime_url} | cut -d "/" -f9`
curl -LJ ${rime_url} -o "${rime_dll}"
if [ ! -f rime.dll ]; then
    echo "fail download ${rime_dll}"
    exit 1
fi
echo "${rime_dll_sha256sum}" | shasum -a 256 -c
dll_raw=${path_installation}/${rime_dll}
if [ -f $dll_raw ]; then 
    dll_raw_new="${dll_raw}.bak"
    mv $dll_raw ${dll_raw_new}
    echo "move old \"${rime_dll}\" to \"${dll_raw_new}\""
fi
mv ${rime_dll} ${path_installation}/
