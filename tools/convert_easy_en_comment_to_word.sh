# . ./tools/convert_easy_en_comment_to_word.sh ./dict/easy_en_comment.dict.yaml
# cat ./dict/easy_en_word.dict.yaml ./dict/easy_en_comment.dict.yaml.txt | . ./tools/uniq_easy_en_word.sh > ./dict/easy_en_word.dict.yaml1
cat $1 | grep -E "⌗" | 
awk -F "\\t" '{
    split($2, word, "⌗")
    code=word[1]
    gsub("[.\\-/]", "", code)
    print $1 "\t" code "\t" "1"
}' > $1.txt
