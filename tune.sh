#!/usr/bin/env bash

set -e
set -u

#extract default parameter values from default.cfg
: '
for p in "${PARAMS[@]}"; do
    val=$(cat default.cfg | grep -- "$p" | tr -s ' ' | cut -d ' ' -f2)
    echo -n "$val "
done
echo ""
'

declare -a PARAMS=("-decode:width" "-issue:width" "-commit:width" "-ruu:size" "-res:ialu" "-res:imult" "-res:fpalu" "-res:fpmult")
declare -a COST_FAC=(10 10 10 1 10 10 10 10)
declare -a DEFAULTS=(4 4 4 16 4 1 4 1)		#default parameter values
declare -a LOWER=(1 1 1 4 1 1 1 1)			#parameter search lower bounds
declare -a UPPER=(32 32 32 512 8 8 8 8)		#parameter search upper bounds

SS_PROG="/home/dani/dev/SimpleScalar/build/benchmarks/go.alpha 2 7"
#SS_PROG="/home/dani/dev/SimpleScalar/build/benchmarks/anagram.alpha /home/dani/dev/SimpleScalar/build/benchmarks/words < /home/dani/dev/SimpleScalar/build/benchmarks/anagram.in"

pLen=${#PARAMS[@]}

for (( i=0; i<${pLen}; i++ )); do
    v=${LOWER[$i]}
    while [ $v -le ${UPPER[$i]} ]; do
        dirname="sim"
        others=""
        args=""
        cost=0

        for (( j=0; j<${pLen}; j++)) do
            if [ $i -eq $j ]; then
                value=${v}
                others="${others}_x"
            else
                value=${DEFAULTS[$j]}
                others="${others}_${value}"
            fi
            args="$args ${PARAMS[$j]} ${value}"
            dirname="${dirname}_${value}"
            cost_term=$((${value} * ${COST_FAC[$j]}))
            cost=$(($cost + $cost_term))
        done

        if [ -d "$dirname" ]; then
            echo "${v},$others" >> ${dirname}/params
            v=$((v*2))
            continue
        fi

        mkdir $dirname
        echo $cost > ${dirname}/cost
        echo "${v},$others" > ${dirname}/params
        SS_CMD=$(echo "sim-outorder $args $SS_PROG 2> $dirname/err.log 1> $dirname/out.log")
        echo "testing ${PARAMS[$i]} == $v, Command: $SS_CMD"
        eval $SS_CMD
        v=$((v*2))
    done
done

