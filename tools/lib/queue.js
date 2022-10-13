class Node {
  constructor(data, next, prev) {
    this.data = data;
    this.next = next;
    this.prev = prev;
  }
  destroy() {
    this.data = undefined;
    this.next = undefined;
    this.prev = undefined;
  }
}

// FIFO
class Queue {
  constructor() {
    this.size = 0;
    this.head = new Node('head');
    this.foot = new Node('foot');
    this.head.next = this.foot;
    this.foot.prev = this.head;
  }
  enQueue(data) {
    const node = new Node(data);
    const next = this.foot;
    const prev = this.foot.prev;
    prev.next = node;
    node.next = next;
    next.prev = node;
    node.prev = prev;
    this.size++;
  }
  deQueue() {
    if(this.size==0) {
      return undefined;
    }
    const prev = this.head;
    const node = this.head.next;
    const next = node.next;
    
    prev.next = next;
    next.prev = prev;
    this.size--; // size

    const data = node.data;
    node.destroy;
    return data;
  }
  forEach(cb) {
    let current = this.head;
    for(let i=0; i<this.size; i++) {
      current = current.next;
      cb(current.data, i);
    }
  }
  clear() {
    const num = this.size;
    for(let i=0; i<num; i++) {
      this.deQueue();
    }
  }
}

function test() {
  const queue = new Queue();
  queue.enQueue('1');
  queue.enQueue('2');
  queue.enQueue('3');
  queue.enQueue('4');
  queue.forEach((data, index) => {
    console.log(`${index}: ${data}`);
  })
  const c1 = queue.deQueue();
  const c2 = queue.deQueue();
  const c3 = queue.deQueue();
  const c4 = queue.deQueue();
  console.log(`${c1}-${c2}-${c3}-${c4}`);
  queue.forEach((data, index) => {
    console.log(`${index}: ${data}`);
  })
  console.log('----------------------------');
  queue.enQueue('11');
  queue.enQueue('22');
  queue.enQueue('33');
  queue.enQueue('44');
  queue.forEach((data, index) => {
    console.log(`${index}: ${data}`);
  })
  queue.clear();
  queue.forEach((data, index) => {
    console.log(`${index}: ${data}`);
  })
}

// test();

module.exports = {
  Queue
};
