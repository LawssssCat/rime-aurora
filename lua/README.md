
目录结构

```yaml
/lua # 脚本由 /rime.lua 引用
├─ ./tool/            # 工具 or 第三方代码
│  ├─ logger.lua    # 日志打印
│  ├─ luaunit.lua      # 单元测试 https://github.com/bluebird75/luaunit
│  ├─ inspect.lua      # 对象打印 https://github.com/kikito/inspect.lua
├─ ./test/            # 测试
└─ *.lua
```