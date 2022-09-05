# （个人）rime方案备份

本项目作用于[rime 输入法](https://rime.im/)（Weasel），主要为个人自定义的rime方案配置（如：`*.yaml`， `/opencc`， `/lua`， `/font`），同时包含“用户目录”中自动生成部分文件的备份（如，`/sync`）。

## 内容说明

基于“地球拼音”修改，添加配色、英文、符号&表情、一些lua脚本。

1. 配色 “凝光紫x申布伦黄”
    
    <div style="text-align:center;margin:3px 0px;background:#422256;width:100px;height:20px;">422256</div>
    <!-- 0x562242 422256 -->
    <div style="text-align:center;margin:3px 0px;background:#FBD26A;width:100px;height:20px;color:#422256;">FBD26A</div>
    <!-- 0x6AD2FB FBD26A -->
    <div style="text-align:center;margin:3px 0px;background:#7D41A3;width:100px;height:20px;">7D41A3</div>
    <!-- 0xA3417D 7D41A3 -->
    
    调色板：<https://bennyyip.github.io/Rime-See-Me/>

2. 英文 

    直接输入英文，会提示含义

    ![输入法英文预览gif](./.github/assets/preview-easy_en.gif)

    “`/`”  前缀：开启纯英文模式

    ![输入法英文预览（prefix）gif](./.github/assets/preview-easy_en_prefix-compress.gif)

3. “`//`” 前缀：符号 & 表情 & 颜表情

    todo 

4. 输入 “rq”、“sj”、“xq” 等可显示当前系统时间

    ![输入法系统时间预览gif](./.github/assets/preview-luatime-compress.gif)

5. 网站提示

    todo 

## 方案说明

编写了两个方案：（个人）地球拼音、（个人）朙月拼音

1. （个人）地球拼音

    + 配置入口：`my_terra_pinyin.schema.yaml`
    +  以 `terra_pinyin` 作为基础码表
    + 显示音调（e.g. 朙月 ming2 yue4 => míng yuè）
    
    todo shift+1~4 转换音调

2. （个人）朙月拼音

    + 配置入口： `my_luna_pinyin.schema.yaml`
    + 以 `luna_pinyin` 作为基础码表
    + 忽略音调

## 字体说明

默认使用系统字体，可能出现字大小不一的的情况。

可以根据 `font` 目录的 [文档](./font/README.md) 设置字体。

## 使用方法

### 步骤一：拷贝文件📄到“用户文件夹📁”

<img src='./.github/assets/userdata-opt.png' style='float:right'></img>

把项目文件全部复制到“用户文件夹📁”（右图，右键点击小图标可见），然后点击“重新部署”即可。

> **注意⚠️**<br>
> 如果有“用户词典快照🎦”需要同步，请先看“步骤二”

> **关于配置**<br>
> 配置入口为 `my_luna_pinyin.custom.yaml` 文件、`my_terra_pinyin.schema.yaml`文件<br>
> 配置文件具体作用，请参考我的笔记：<http://t.csdn.cn/grD5H>
<!-- https://blog.csdn.net/LawssssCat/article/details/103482619 -->

```yml
# 不同系统中，“用户文件夹📁”的一般路径
%APPDATA%\Rime  ( Windows 小狼毫 )
~/Library/Rime  ( Mac OS 鼠鬚管 )
~/.config/ibus/rime  ( Linux 中州韻 )
~/.config/fcitx/rime  ( Linux )
```

<div style='clear: both;'></div>

### 步骤二：**同步“用户词典快照🎦”**：

<img src='./.github/assets/dict-opt.png' style='float:right'></img>

> “用户词典快照🎦”包含了用户常用的词。重新安装时，可以通过导入快照，迅速的还原熟悉的打字环境

1. 选择“用户词典管理”（右图，右键点击小图标可见）打开“快照管理界面”。
2. 导出<br>
    左边选择要导出“用户词典快照🎦”的快照名，点击右边的“输出词典快照”。
    > “用户词典快照🎦”一般会被导出到`./sync`目录
3. 导入<br>
    点击右边的“合入词典快照”，选择需要的“用户词典快照🎦”进行导入。

<div style='clear: both;'></div>

![同步词典快照](./.github/assets/dict-merge.png)

## 其他

### opencc 词汇去重

```bash
npm install
npm run sort
```
