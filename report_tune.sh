#/bin/bash

min=100000000
min_cost=100000000
min_name=""

for s in sim_*; do
    cycles=$(cat $s/err.log | grep sim_cycle | tr -s ' ' | cut -d ' ' -f2)
    echo $cycles > $s/cycles
    cost=$(cat $s/cost)
    echo -e "$s:\t$cycles\t$cost"
    if ([ $cycles -eq $min ] && [ $cost -lt $min_cost ]) || [ $cycles -lt $min ]; then
        min=$cycles
        min_name=$s
        min_cost=$cost
    fi
done
echo "Minimum:"
echo -e "${min_name}:\t$min\t$min_cost"

echo -n "declare -a DEFAULTS=("
for i in {2..9}; do
    p=$(echo $min_name | tr -s '_' | cut -d '_' -f$i)
    echo -n "$p "
done
echo ")"
