# vw-runner
simple scripts to run vowpal wabbit locally and compute accuracy

currently includes convote http://www.cs.cornell.edu/home/llee/data/convote.html dataset (debate speeches from 2005 congressional record)

# getting started

install vowpal wabbit https://github.com/VowpalWabbit/vowpal_wabbit.

train-and-test.sh converts congress data to vw format, trains a binary classification model (to predict republican or democrat for the debate speech speaker), tests the trained model on the training and test set and computes accuracy for the predicted labels.

change params in the train-and-test.sh file to specify output directory, number of passes to take over the data, which loss function to use (logistic or hinge), ngrams, and how much of the training set to use.

** note: the train-and-test.sh file uses python3, you might need to change this to python depending on your environment

# congress data preprocessing

the python scripts train-data-to-vw.py and test-data-to-vw.py remove speeches where the speaker is independent (I), speeches shorter than 100 characters, and all punctuation from the speeches.

# incremental testing

by setting $INCREMENTAL to true in train-and-test.sh, you can perform incremental training of the dataset broken into 50 training label chunks; there's certainly a better way to do it,  but the script works by creating training data for 50 labels, 100 labels, 150 labels and so on up until the full training data size. Then, for each input size, we train a model, test on the full test set, and compute the accuracy. The result is accuracies.txt which contains the mapping of number of training samples to accuracy. You can use this output to create a chart showing the how model accuracy changes as the learner encounters more training input.

# randomizing the training input

use the $RANDOMIZE variable in train-and-test.sh to specify whether or not to randomize the training input. vw runs online, so order is important. setting $RANDOMIZE to false, means vw will learn a consistent model each time, but this model might not be optimal.  

# interpretability
running --invert_hash produces a human-readable set of the word features (unigrams, bigrams, trigrams, etc.) and the score they contribute to the class. 