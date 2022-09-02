// 整理词汇
const dealDuplication = require("./lib/dealDuplication");
const path = require('path');

const baseDir = path.join(__dirname, '../'); // 根目录

const openccBase = path.join(baseDir, 'opencc');
// emoji 表情
dealDuplication.handleOpenccFiles([
  path.join(openccBase, 'emoji_category.txt'),
  path.join(openccBase, 'emoji_word.txt'),
], 
path.join(openccBase, 'emoji_all.txt'), // output
(record) => {
  console.log(record, 'opencc_emoji 处理完成！');
});
// kemoji 颜表情
dealDuplication.handleOpenccFiles([
  path.join(openccBase, 'kemoji_base.txt'),
  path.join(openccBase, 'kemoji_meow.txt'),
], 
path.join(openccBase, 'kemoji_all.txt'), // output
(record) => {
  console.log(record, 'opencc_kemoji 处理完成！');
});

