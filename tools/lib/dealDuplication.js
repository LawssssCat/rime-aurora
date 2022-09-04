const fs = require('fs');
const EventEmitter = require('events');
const readline = require('readline');
const {Queue} = require('./queue');
const {Set} = require('./set');

/**
 * opencc文件格式：
 * 关键字（key）\t提示1（suggestion）\s提示2（suggestion）...
 * 例子：
 * OK	OK 🆗 🙆‍♂ 🙆 🙆‍♀ 👌 👍
 */
class OpenccWord {
  static parse(line, options) {
    if(/^[#]/.test(line)) {
      // 注释
      return undefined;
    }
    const blocks = line.split(/\t/);
    let word = blocks[0];
    let suggestion = blocks[1];
    suggestion = suggestion.trim();
    return new OpenccWord(word, suggestion, options);
  }
  constructor(word, suggestion, options={}) {
    this.word = word;
    this.suggestion = new Set();
    this.options = {
      setWordIntoSuggestion: options.setWordIntoSuggestion
    }
    this.addSuggestion(suggestion);
  }
  addSuggestion(suggestion) {
    let arr;
    if(typeof suggestion == 'string') {
      arr = suggestion.split(/\s+/g);
    } else if(suggestion instanceof Array) {
      arr = suggestion;
    } else {
      throw new Error(`unmatched type: ${suggestion.constructor}`);
    }
    arr.forEach(item => {
      this.suggestion.add(item);
    })
  }
  getSortedSuggestion() {
    const arr = this.suggestion.values();
    arr.sort((a, b) => a-b); // 1,2,3,...
    // 删除word
    const index = arr.indexOf(this.word);
    if(index>-1) {
      arr.splice(index, 1);
    }
    // 头部添加word
    if(this.options.setWordIntoSuggestion != false) {
      arr.unshift(this.word);
    }
    return arr;
  }
}

function defaultOption(options={}) {
  if(options.setWordIntoSuggestion == undefined) {
    options.setWordIntoSuggestion = true;
  }
  return options;
}

function handleOpenccFiles(paths, output, options, cb) {
  // 选项
  if(typeof options == 'function') {
    cb = options;
    options = undefined
  }
  options = defaultOption(options);
  // 处理
  const qLine = new Queue(), events = new EventEmitter(), wordMap = {};
  const record = new Proxy({
    files: [],
    load: false,
    output: output,
    line: 0, lineOK: 0, lineError: 0,
    word: 0,
    error: []
  }, {
    set: function(target, prop, value) {
      const result = Reflect.set(target, prop, value);
      if(['load', 'lineOK', 'lineError'].includes(prop)) {
        if(target.load) {
          if(target.line == target.lineOK + target.lineError) {
            events.emit('done');
          }
        }
      }
      return result
    }
  });
  paths.forEach(path => {
    const rs = fs.createReadStream(path);
    const rl = readline.createInterface(rs, {
      crlfDelay: Infinity
    });
    const info = {
      path: path,
      load: false,
      line: 0
    };
    let lineNum = 0;
    record.files.push(info);
    rl.on('line', (line) => {
      lineNum++;
      qLine.enQueue({
        line,
        lineNum,
        path
      });
      record.line++;
      info.line++;
      events.emit('readline');
    });
    rl.on('close', () => {
      info.load = true
      const flag = record.files.every(file => file.load);
      if(flag) {
        record.load = true
      }
    })
  });
  events.on('readline', () => {
    const {line, path, lineNum} = qLine.deQueue();
    try {
      const newWord = OpenccWord.parse(line, {
        setWordIntoSuggestion: options.setWordIntoSuggestion // 把word插入suggestion第一位
      });
      if(newWord) {
        const oldWord = wordMap[newWord.word];
        if(oldWord) {
          oldWord.addSuggestion(newWord.suggestion.values());
        } else {
          wordMap[newWord.word] = newWord;
          record.word++;
        }
      }
      record.lineOK++;
    } catch (err) {
      record.lineError++;
      record.error.push({
        err,
        path,
        line,
        lineNum
      });
    }
  })
  events.on('done', () => {
    // 输出为文件
    const ws = fs.createWriteStream(output);
    const keyArr = Object.keys(wordMap).sort((a,b) => {
      return a-b; // 1,2,3,....
    });
    const pArr = new Array(keyArr.length); // 待处理promise
    keyArr.forEach((key, index) => {
      const word = wordMap[key];
      const line = `${word.word}\t${word.getSortedSuggestion().join(' ')}${index!=(keyArr.length-1)?'\n':''}`;
      pArr.push(new Promise((resolve) => {
        ws.write(line, resolve);
      }));
    })
    // 回调
    Promise.all(pArr).then(() => {
      cb(record);
    })
  })
}

module.exports = {
  handleOpenccFiles
};