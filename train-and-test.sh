#!/bin/sh

# folder for your train and test results
NAME_SCHEME="data/congress-model-all"

# number of passes to take over the data
NUM_PASSES=100

# which loss function to use (logistic or hinge)
LOSS_FUNCTION="logistic"

# ngrams
NGRAM=1

# whether to run an incremental test to see how the system performs as more data is ingested; if you run incremental, NUM_TRAIN and TRAIN_MODEL variables are ignored
INCREMENTAL=false

# determines amount of training set to use for training, -1 means all (only used if not running incremental)
NUM_TRAIN=-1

# whether to build the test and train sets and train the model (set to false if you've previously trained the model, variable only used if not running incremental)
TRAIN_MODEL=true

if [ "$INCREMENTAL" = true ] ; then
  # generate data files
  echo "\n---generating data files for incremental training---\n"
  #python3 incremental-data-to-vw.py $NAME_SCHEME

  # incrementally train the model, test, and provide accuracy

else

  if [ "$TRAIN_MODEL" = true ] ; then
    # create directory to store training data, models, and results
    mkdir -p -- "$NAME_SCHEME"

    # format the test data, this should only need to be run once
    python3 test-data-to-vw.py $NAME_SCHEME

    # format the train data given the specified number to train on
    python3 train-data-to-vw.py $NUM_TRAIN $NAME_SCHEME

    # run vw training
    echo "\n---training model---\n"
    vw -d "$NAME_SCHEME/train.vw" -c --passes $NUM_PASSES --loss_function $LOSS_FUNCTION --ngram $NGRAM -f "$NAME_SCHEME/log_model.vw" --binary
  fi

  # test model on training set
  echo "\n---testing model on training set---\n"
  vw -i "$NAME_SCHEME/log_model.vw" -t -d "$NAME_SCHEME/train.vw" -p "$NAME_SCHEME/log_train_pred.txt" --binary

  # test model on test set
  echo "\n---testing model on test set---\n"
  vw -i "$NAME_SCHEME/log_model.vw" -t -d "$NAME_SCHEME/test.vw" -p "$NAME_SCHEME/log_test_pred.txt" --binary

  # compute accuracy of predictions on training set
  echo "\n---computing accuracy on training set---\n"
  python3 check-accuracy.py "$NAME_SCHEME/log_train_pred.txt" "$NAME_SCHEME/train_labels.txt"

  # compute accuracy of predictions on test set
  echo "\n---computing accuracy on test set---\n"
  python3 check-accuracy.py "$NAME_SCHEME/log_test_pred.txt" "$NAME_SCHEME/test_labels.txt"

  # TODO: get an interpretable model

  # TODO: print the top features for each class
fi
