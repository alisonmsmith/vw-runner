# vw-runner
simple scripts to run vowpal wabbit and compute accuracy 

currently includes convote http://www.cs.cornell.edu/home/llee/data/convote.html dataset (debate speeches from 2005 congressional record)

# getting started

install vowpal wabbit https://github.com/VowpalWabbit/vowpal_wabbit.

train-and-test.sh converts congress data to vw format, trains a binary classification model (to predict republican or democrat for the debate speech speaker), tests the trained model on the training and test set and computes accuracy for the predicted labels.

change params in the train-and-test.sh file to specify output directory, number of passes to take over the data, which loss function to use (logistic or hinge), ngrams, and how much of the training set to use.

# congress data preprocessing

train-data-to-vw.py and test-data-to-vw.py remove speeches where the speaker is independent (I), speeches shorter than 100 characters, and all punctuation from the speeches.
