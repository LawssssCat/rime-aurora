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
  static parse(line) {
    const blocks = line.split(/\t/);
    return new OpenccWord(blocks[0], blocks[1]);
  }
  constructor(word, suggestion) {
    this.word = word;
    this.suggestion = new Set();
    this.addSuggestion(word);
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
}

function handleOpenccFiles(paths, output, cb) {
  const qLine = new Queue(), events = new EventEmitter(), wordMap = {};
  const record = new Proxy({
    files: [],
    load: false,
    output: output,
    line: 0, lineOK: 0, lineError: 0,
    word: 0,
    error: {}
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
    record.files.push(info);
    rl.on('line', (line) => {
      line = line.trim();
      if(line && /^[^#]/.test(line)) {
        qLine.enQueue(line);
        record.line++;
        info.line++;
        events.emit('readline');
      }
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
    const line = qLine.deQueue();
    try {
      const newWord = OpenccWord.parse(line);
      const oldWord = wordMap[newWord.word];
      if(oldWord) {
        oldWord.addSuggestion(newWord.suggestion.values());
      } else {
        wordMap[newWord.word] = newWord;
        record.word++;
      }
      record.lineOK++;
    } catch (err) {
      record.lineError++;
      record.error[line] = err;
    }
  })
  events.on('done', () => {
    // 输出为文件
    const ws = fs.createWriteStream(output);
    const keyArr = Object.keys(wordMap);
    const pArr = new Array(keyArr.length);
    keyArr.forEach((key, index) => {
      const word = wordMap[key];
      const line = `${word.word}\t${word.suggestion.values().join(' ')}${index!=(keyArr.length-1)?'\n':''}`;
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