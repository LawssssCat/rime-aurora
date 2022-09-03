// 整理词汇
const dealDuplication = require("./lib/dealDuplication");
const path = require('path');

const baseDir = path.join(__dirname, '../'); // 根目录

const openccBase = path.join(baseDir, 'opencc');
// emoji 表情
dealDuplication.handleOpenccFiles([
  path.join(openccBase, 'emoji_category.yml'),
  path.join(openccBase, 'emoji_word.yml'),
  path.join(openccBase, 'emoji_2021t.yml'),
], 
path.join(openccBase, 'emoji_all.txt'), // output
(record) => {
  console.log(record, 'opencc_emoji 处理完成！');
});
// kemoji 颜表情
dealDuplication.handleOpenccFiles([
  path.join(openccBase, 'kemoji_base.yml'),
  path.join(openccBase, 'kemoji_meow.yml'),
], 
path.join(openccBase, 'kemoji_all.txt'), // output
(record) => {
  console.log(record, 'opencc_kemoji 处理完成！');
});
// 标点/符号
dealDuplication.handleOpenccFiles([
  path.join(openccBase, 'back_mark_ocm.yml'),
  path.join(openccBase, 'back_mark_punct.yml'),
], 
path.join(openccBase, 'back_mark_all.txt'), // output
{
  setWordIntoSuggestion: false // 关键字 添加入 提示队列
},
(record) => {
  console.log(record, 'opencc_back_mark 处理完成！');
});


