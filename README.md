本项目用于[rime 输入法](https://rime.im/)“用户目录”备份

## 使用方法


**同步用户配置**

<img src='./.github/assets/userdata-opt.png' style='float:right'></img>

将 `/*.yaml` 配置文件直接复制粘贴在 “用户目录”，然后 “重新部署”
（随着功能扩展，部分配置文件还依赖额外文件，如：`/font`、`lua`、...）

具体使用方法，参考我的使用笔记：<http://t.csdn.cn/grD5H>
<!-- https://blog.csdn.net/LawssssCat/article/details/103482619 -->

> 配置入口 `luna_pinyin.custom.yaml`

<div style='clear: both;'></div>

**同步用户词典快照**：

<img src='./.github/assets/dict-opt.png' style='float:right'></img>

> 用户词典快照通常由程序自动生成，包含了用户常用的词。重新安装时，通过导入快照，可以迅速的还原熟悉的输入环境

选择“用户词典管理”

<div style='clear: both;'></div>

![同步词典快照](./.github/assets/dict-merge.png)

选择 `/sync` 文件夹中的 “词典快照” 进行导入


