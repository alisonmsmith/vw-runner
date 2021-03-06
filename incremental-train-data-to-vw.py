# CREATE INCREMENTAL TRAINING SETS AND CONVERT TO VW FORMAT
import os
import re
import random
import sys
import math

# naming scheme
NAME_SCHEME = sys.argv[1]

# whether or not to randomize the data
RANDOMIZE = sys.argv[2]

# character length cutoff
# TODO: make this a sys variable with a default value
LENGTH_CUTOFF = 100

# open the training set
train_set = []
for filename in os.listdir('./congress-data/training_set'):
    party = filename.split('_')[3][0]
    # ignore independents
    if party == 'R':
        party = -1
    elif party == 'D':
        party = 1
    else:
        continue
    with open('./congress-data/training_set/' + filename, 'r') as f:
        text = f.read()
        # remove short, single phrase speeches
        if len(text) >= LENGTH_CUTOFF:
            train_set.append((str(party), ' '.join(re.findall('\w{1,}', text))))

# randomly sort training labels
if RANDOMIZE == "true":
    print('randomizing training data')
    sampling = random.choices(train_set, k=len(train_set))
else:
    sampling = train_set

# create incremental training files for every 50 labels
for i in range(1, math.ceil(len(train_set)/50)+1 ):
    val = min(50*i,len(train_set))
    increment = sampling[0:val]
    with open('./' + NAME_SCHEME + '/incremental/' + str(val) + '_train.vw', 'w') as vw_train_data:
        train_labels = []
        for s in increment:
            vw_train_data.write(s[0] + ' |text ' + s[1] + '\n')
            train_labels.append(s[0])

# store the gold train labels
with open('./' + NAME_SCHEME + '/train_labels.txt', 'w') as labels:
    for label in train_labels:
        labels.write(str(label) + '\n')
