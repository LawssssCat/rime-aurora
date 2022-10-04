// 整理词汇
const dealDuplication = require("./lib/dealDuplication");
const path = require('path');

const baseDir = path.join(__dirname, '../'); // 根目录

const taskStart = new Date();
const taskArr = [];
function run(task) {
  const _p = new Promise((resolve, reject) => {
    task(resolve, reject);
  });
  taskArr.push(_p);
}

// opencc
const openccBase = path.join(baseDir, 'opencc');
function runOpencc(input, output, options={}) {
  input = typeof input == 'string' ? [input] : input;
  const _st = new Date();
  run(function(resolve) {
    dealDuplication.handleOpenccFiles(input.map(inputname => {
      return path.join(openccBase, inputname); // emoji_category.yml => ${baseDir}/opencc/emoji_category.yml
    }), 
    path.join(openccBase, output), // output. emoji_all.txt => ${baseDir}/opencc/emoji_all.txt
    options,
    (record) => {
      console.log(record, `${output} 处理完成！`);
      record.fileType = 'opencc';
      const _et = new Date();
      record.taskTime = _et - _st;
      resolve(record);
    });
  });
}
// emoji 表情
runOpencc([
  'emoji_category.yml',
  'emoji_word.yml',
  'emoji_2021t.yml',
  'emoji_getemoji.yml'
], 
'emoji_all.txt');
// kemoji 颜表情
runOpencc([
  'kemoji_base.yml',
  'kemoji_meow.yml',
], 
'kemoji_all.txt');
// 标点/符号
runOpencc([
  'back_mark_ocm.yml',
], 
'back_mark_all.txt',
{
  setWordIntoSuggestion: false // 关键字 添加入 提示队列
});

Promise.all(taskArr).then(resolve => {
  const errorArr = [];
  const infos = resolve.map(record => {
    record.error.forEach(_e => errorArr.push(_e));
    return {
      fileType: record.fileType,
      line: record.line,
      lineOk: record.lineOK,
      lineError: record.lineError,
      word: record.word,
      "运行时间（ms）": record.taskTime,
      // input: record.files.map(file => file.path),
      output: record.output
    }
  });
  // console.clear();
  console.log();
  console.log();
  console.log();
  console.log(`运行结果：${new Date() - taskStart}ms`);
  console.table(infos);
  console.log('运行错误：');
  if(errorArr.length>0) {
    console.log(errorArr.map((_e, index) => {
      return {
        "错误编号": `${index+1}/${errorArr.length}`,
        "错误": _e
      };
    }));
  } else {
    console.log('无');
  }
})