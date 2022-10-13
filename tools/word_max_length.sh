
cat $1 | sort -k1 |
grep -E "^[^-.#]" | 
grep -v -P "^[\d\w]+:.*" | 
awk -F "	" '
{
    if(length($1)<=4) {
        print $0
    }
}'