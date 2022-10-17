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
echo "拷贝文件到“用户文件夹📁”"
cd ${path_userdata}
git clone https://github.com/LawssssCat/rime-aurora.git -b master --depth=1 ./${repo}
if [ ! -d ./${repo} ]; then
    echo "fail tp clone repo."
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
echo "download .. ${rime_url}"
curl -LJ ${rime_url} -o rime.dll
if [ ! -f rime.dll ]; then
    exit 1
fi
dll_raw=$path_installation/rime.dll
if [ -f $dll_raw ]; then 
    mv $dll_raw $dll_raw.bak
fi
mv rime.dll $path_installation/
