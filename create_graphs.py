#!/usr/bin/env python2

import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm

def file_to_str(filename):
    s = None
    try:
        with open(filename, 'r') as f:
            s = f.read().split('\n')
    except IOError:
        exit('Could not read ' + filename)
    return filter(None, s)

def read_chart_data():
    charts = {}
    for filename in os.listdir('.'):
        if not filename.startswith('sim_'):
            continue
        if not (os.path.exists(filename + '/params') and os.path.exists(filename + '/cycles')):
            exit('Files missing for ' + filename)
        
        cycles=int(file_to_str(filename + '/cycles')[0])
        param_combs = file_to_str(filename + '/params')
        for p in param_combs:
            param=p.split(',')[1]
            param_val=int(p.split(',')[0])
            if not param in charts:
                charts[param] = []
            charts[param].append((param_val,cycles,param))

    return charts

def assign_nums(classes):
    class_to_num = {}
    class_nums = []
    num = 0
    for c in classes:
        if not c in class_to_num:
            class_to_num[c] = num
            num += 1
        class_nums.append(class_to_num[c])
    return class_nums

def main():
    PARAM_NAMES=['Decode width', 'Issue width', 'Commit width', 'RUU size', 'Number of IALUs', 'Number of IMULTs', 'Number of FPALUs', 'Number of FPMULTs']

    charts = read_chart_data()    
    for chart in charts:
        index_of_x = filter(None, chart.split('_')).index('x')
        points = sorted(charts[chart], key=lambda x: x[0])
        x, y, labels = list(zip(*points))
        label_nums = assign_nums(labels)
        fig = plt.scatter(x, y, c=label_nums, label=label_nums, cmap=cm.get_cmap("viridis",5))
        plt.xscale('log', basex=2)
        plt.ylabel('Clock cycles')
        plt.title(PARAM_NAMES[index_of_x] + ' vs clock cycles')
        plt.xlabel(PARAM_NAMES[index_of_x])
        #plt.axis([None, None, 10000000, 36000000])
        filename=PARAM_NAMES[index_of_x].replace(' ','_')
        plt.savefig(filename)
        plt.clf()

if __name__ == '__main__':
    main()
