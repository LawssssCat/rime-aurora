# （个人）rime方案备份

本项目作用于[rime 输入法](https://rime.im/)，主要为个人自定义的rime方案配置（如：`*.yaml`， `/opencc`， `/lua`， `/font`），同时包含“用户目录”中自动生成部分文件的备份（如，`/sync`）。

## 使用方法

### 步骤一：拷贝文件📄到“用户文件夹📁”

<img src='./.github/assets/userdata-opt.png' style='float:right'></img>

把项目文件全部复制到“用户文件夹📁”（右图，右键点击小图标可见），然后点击“重新部署”即可。

> **注意⚠️**<br>
> 如果有“用户词典快照🎦”需要同步，请先看“步骤二”

> **关于配置**<br>
> 配置入口为 `my_luna_pinyin.custom.yaml` 文件<br>
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
