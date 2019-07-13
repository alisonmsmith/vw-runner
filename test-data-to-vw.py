# CONVERT TEST DATA TO VW FORMAT AND SAVE GOLD STANDARD LABEL FILE
# Republican (R) is -1 and Democrat (D) is 1
import os
import re
import random
import sys

# naming scheme
NAME_SCHEME = sys.argv[1]

# character length cutoff
# TODO: make this a sys variable with a default value
LENGTH_CUTOFF = 100

# convert the test set to vw format
test_labels = []
with open('./' + NAME_SCHEME + '/test.vw', 'w') as vw_test_data:
    for filename in os.listdir('./congress-data/test_set'):
        party = filename.split('_')[3][0]
        if party == 'R':
            party = -1
        elif party == 'D':
            party = 1
        else:
            continue

        with open('./congress-data/test_set/' + filename, 'r') as f:
            text = f.read()
            # remove short, single phrase speeches
            if len(text) >= LENGTH_CUTOFF:
                vw_test_data.write(str(party) + ' |text ' + ' '.join(re.findall('\w{1,}', text)) + '\n')
                test_labels.append(party)

# store the gold test labels
with open('./' + NAME_SCHEME + '/test_labels.txt', 'w') as labels:
    for label in test_labels:
        labels.write(str(label) + '\n')
