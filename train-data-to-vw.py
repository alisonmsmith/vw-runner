# CREATE TRAIN AND TEST SETS BASED ON DESIRED NUM TRAINING EXAMPLES AND CONVERT TO VW FORMAT
import os
import re
import random
import sys

# num to train on
TRAINING_EXAMPLES = int(sys.argv[1])

# naming scheme
NAME_SCHEME = sys.argv[2]

# character length cutoff
LENGTH_CUTOFF = 100

# open the training set
train_labels = []
train_set = []
with open('./' + NAME_SCHEME + '/train.vw', 'w') as vw_train_data:
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

    # randomly choose training labels
    if TRAINING_EXAMPLES == -1 or TRAINING_EXAMPLES > len(train_set):
        print('using all training examples', len(train_set))
        TRAINING_EXAMPLES = len(train_set)
    sampling = random.choices(train_set, k=TRAINING_EXAMPLES)
    for s in sampling:
        vw_train_data.write(s[0] + ' |text ' + s[1] + '\n')
        train_labels.append(s[0])

# store the gold train labels
with open('./' + NAME_SCHEME + '/train_labels.txt', 'w') as labels:
    for label in train_labels:
        labels.write(str(label) + '\n')
