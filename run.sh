#!/bin/bash

opt=$1
start_time=$(date +%s)
case $opt in
  log)
    bash tools/tailLog.sh
    ;;
  sort)
    ( cd lua ; lua build/sort_opencc.lua -v )
    ;;
  test)
    ( cd lua ; lua test/init.lua -v )
    ;;
  *)
    echo "Unknowed args#1 \"${opt}\""
    ;;
esac
end_time=$(date +%s)
cost_time=$[ $end_time - $start_time ]
echo "run time: $(($cost_time/60))min $(($cost_time%60))s"
