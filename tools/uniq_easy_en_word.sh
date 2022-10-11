#
# ```
# abc	aaa	222
# abc	bb
# ```
# =>  
# ```
# abc	aaa	222
# ```
#
# 词去重
# cat ./dict/easy_en_a.dict.yaml ./dict/easy_en_b.dict.yaml | . ./tools/uniq_easy_en_word.sh  > ./dict/easy_en_word.dict.yaml
# 注释去重
# cat ./dict/easy_en_super* | . ./tools/uniq_easy_en_word.sh | grep "⌗" > ./dict/easy_en_comment.dict.yaml
# 词（出现注释）去重
# cat ./dict/easy_en_* | . ./tools/uniq_easy_en_word.sh | grep -v "⌗" > ./dict/easy_en_word.dict.yaml1

cat $1 | sort -k1 |
grep -E "^[^-.#]" | 
grep -v -P "^[\d\w]+:.*" | 
awk -F "	" '
{
    if(!pre_key) {
        pre_key = tolower($1)
        pre_text = $0
        pre_len = length($0)
    } else {
        key = tolower($1)
        if(pre_key==key) {
            len = length($0)
            if(len>pre_len) {
                pre_text = $0
                pre_len = len
            }
        } else {
            print pre_key substr(pre_text, length(pre_key)+1, pre_len)
            pre_key = tolower($1)
            pre_text = $0
            pre_len = length($0)
        }
    }
}
END {
    if(pre_key) {
        print pre_key substr(pre_text, length(pre_key)+1, pre_len)
    }
}'