class Set {
  constructor() {
    this.data = {};
  }
  add(data) {
    const arr = data instanceof Array ? data : [data];
    arr.forEach(item => {
      this.data[item] = undefined;
    });
  }
  remove(data) {
    const arr = data instanceof Array ? data : [data];
    arr.forEach(item => {
      delete this.data[item];
    });
  }
  values() {
    return Object.keys(this.data);
  }
  size() {
    return this.values().length;
  }
}

module.exports = {
  Set
}