# CHECKS ACCURACY OF PREDICTIONS GIVEN PREDICTED MODEL OUTPUT (ON TEST OR TRAINING DATA) AND ASSOCIATED TRUTH LABELS

import os
import sys


# prediction file for testing accuracy
PREDICT_FILE = sys.argv[1]

# ground truth label file
LABEL_FILE = sys.argv[2]

# get the labels from the file
labels = []
with open(LABEL_FILE) as label_file:
    labels = [float(label) for label in label_file.readlines()]

# compare the labels to the prediction file
correct = 0
with open(PREDICT_FILE) as pred_file:
     valid_prediction = [float(label) for label in pred_file.readlines()]
     total = len(valid_prediction)
     for i in range(0,len(valid_prediction)):
         if valid_prediction[i] == labels[i]:
             correct += 1
     print('accuracy', correct/total)
