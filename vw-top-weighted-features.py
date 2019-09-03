import os
import sys

FEATURE_FILE = sys.argv[1]

#FEATURE_FILE = 'congress_data_model_tri_readable.vw'

data = []
with open(FEATURE_FILE) as f:
    for line in f:
        if len(line.split(':')) == 3:
            line = line.split(':')
            weight = float(line[2])
            val = line[0]
            absolute = abs(weight)
            data.append((absolute, val, weight))

data.sort(key=lambda tup: tup[0])
top = data[-20:len(data)]
print('top 20 features:')
for feature in top:
    print(feature[1], feature[2])
