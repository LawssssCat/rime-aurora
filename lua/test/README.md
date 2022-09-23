单元测试

在 `/lua` 目录下执行 `lua test/init.lua` 或在 `/` 目录下执行 `npm run test` 即可运行单元测试

运行结果（大致）如下：

```bash
C:\Users\lawsssscat\AppData\Roaming\Rime>npm run test

> rime@1.0.0 test
> cd lua && lua test/init.lua -v && cd ..

===================[path: init.lua]======================
@test/init.lua
test/init.lua
===================[package.path]======================
C:\Program Files\lua\lua\?.lua
C:\Program Files\lua\lua\?\init.lua
C:\Program Files\lua\?.lua
C:\Program Files\lua\?\init.lua
C:\Program Files\lua\..\share\lua\5.3\?.lua
C:\Program Files\lua\..\share\lua\5.3\?\init.lua
.\?.lua
.\?\init.lua
==================[package.cpath]=====================
C:\Program Files\lua\?.dll
C:\Program Files\lua\..\lib\lua\5.3\?.dll
C:\Program Files\lua\loadall.dll
.\?.dll
C:\Program Files\lua\?53.dll
.\?53.dll
==================[package.searchers]=====================
function: 00000000000CC440
function: 00000000000CC6C0
function: 00000000000CC640
function: 00000000000CC780
--------- expand ---------
function: 00000000000DA880
==================[time]=====================
0.004
1663899108
20220923101148
2022092310114810
==================[test config]=====================
==================[test run]=====================
1..59
# Started on Fri Sep 23 10:11:48 2022
# Starting class: test_array_list
ok     1        | 0.034 |       test_array_list.test_add
ok     2        | 0.000 |       test_array_list.test_get_at
ok     3        | 0.001 |       test_array_list.test_index_of
ok     4        | 0.000 |       test_array_list.test_iter
ok     5        | 0.000 |       test_array_list.test_remove
ok     6        | 0.000 |       test_array_list.test_size
# Starting class: test_basic
ok     7        | 0.000 |       test_basic.test_for
ok     8        | 0.000 |       test_basic.test_type
# Starting class: test_debug
ok     9        | 0.000 |       test_debug.test_info
ok     10       | 0.000 |       test_debug.test_trace
# Starting class: test_error
ok     11       | 0.000 |       test_error.test_error
ok     12       | 0.000 |       test_error.test_pcall_error
ok     13       | 0.000 |       test_error.test_pcall_ok
# Starting class: test_inspect
ok     14       | 0.000 |       test_inspect.test_inspect
# Starting class: test_linked_list
ok     15       | 0.009 |       test_linked_list.test_add
ok     16       | 0.000 |       test_linked_list.test_get_at
ok     17       | 0.000 |       test_linked_list.test_index_of
ok     18       | 0.000 |       test_linked_list.test_iter
ok     19       | 0.000 |       test_linked_list.test_remove
ok     20       | 0.000 |       test_linked_list.test_size
# Starting class: test_list
ok     21       | 0.000 |       test_list.test_method_undefined
# Starting class: test_logger
ok     22       | 0.001 |       test_logger.test_no_error
# Starting class: test_metatable
ok     23       | 0.000 |       test_metatable.test_getmetatable
# Starting class: test_number
ok     24       | 0.000 |       test_number.test_boolean
ok     25       | 0.000 |       test_number.test_convert_arab_to_chinese
ok     26       | 0.000 |       test_number.test_divide
# Starting class: test_ptry
ok     27       | 0.000 |       test_ptry.test_basefunc
# Starting class: test_reLua
ok     28       | 0.000 |       test_reLua.test_ESC
ok     29       | 0.000 |       test_reLua.test_official_sample
ok     30       | 0.004 |       test_reLua.test_regex
# Starting class: test_string
ok     31       | 0.000 |       test_string.test_boolean
ok     32       | 0.000 |       test_string.test_byte
ok     33       | 0.001 |       test_string.test_char
ok     34       | 0.000 |       test_string.test_equal
ok     35       | 0.000 |       test_string.test_find
ok     36       | 0.000 |       test_string.test_format
ok     37       | 0.000 |       test_string.test_gsub
ok     38       | 0.000 |       test_string.test_helper_format
ok     39       | 0.000 |       test_string.test_helper_sub
ok     40       | 0.000 |       test_string.test_is_ascii_visible
ok     41       | 0.000 |       test_string.test_is_ascii_visible_string
ok     42       | 0.000 |       test_string.test_join
ok     43       | 0.000 |       test_string.test_match
ok     44       | 0.006 |       test_string.test_match_patterns_a
ok     45       | 0.160 |       test_string.test_match_patterns_c
ok     46       | 0.000 |       test_string.test_match_patterns_catch
ok     47       | 0.001 |       test_string.test_match_patterns_g
ok     48       | 0.000 |       test_string.test_match_patterns_p
ok     49       | 0.000 |       test_string.test_match_patterns_x
ok     50       | 0.000 |       test_string.test_replace
ok     51       | 0.000 |       test_string.test_split
ok     52       | 0.000 |       test_string.test_sub
ok     53       | 0.000 |       test_string.test_tostring
ok     54       | 0.000 |       test_string.test_utf8len
# Starting class: test_table
ok     55       | 0.000 |       test_table.test_equal
ok     56       | 0.000 |       test_table.test_len
ok     57       | 0.000 |       test_table.test_len_select
ok     58       | 0.000 |       test_table.test_remove
ok     59       | 0.000 |       test_table.test_unpack
# Ran 59 tests in 0.227 seconds, 59 successes, 0 failures
```