#!/bin/sh

# folder for your train and test results
NAME_SCHEME="results/logistic-unigram"

# number of passes to take over the data
NUM_PASSES=1

# which loss function to use (logistic or hinge)
LOSS_FUNCTION="logistic"

# ngrams
NGRAM=1

# whether to run an incremental test to see how the system performs as more data is ingested; if you run incremental, NUM_TRAIN and TRAIN_MODEL variables are ignored
INCREMENTAL=false

# whether to randomize the training data or select from the set as ordered
# as vw trains online, order is important (use RANDOMIZE=false to get a consistent, although possibly not optimal, model)
RANDOMIZE=false

# TODO: support optimizing data (uniformly shuffle by label)
OPTIMIZE=false

# determines amount of training set to use for training, -1 means all (only used if not running incremental)
NUM_TRAIN=-1

# whether to build the test and train sets and train the model (set to false if you've previously trained the model, variable only used if not running incremental)
TRAIN_MODEL=true

if [ "$INCREMENTAL" = true ] ; then
  # create directory to store training data, models, and results
  mkdir -p -- "$NAME_SCHEME"
  mkdir -p -- "$NAME_SCHEME/incremental"

  # generate data files
  echo "\n---generating data files for incremental training---\n"
  python3 incremental-train-data-to-vw.py $NAME_SCHEME $RANDOMIZE
  python3 test-data-to-vw.py $NAME_SCHEME

  # incrementally train the model, test, and provide accuracy
  echo "\n---incrementally training model and computing accuracy---\n"
  FILES="$NAME_SCHEME/incremental/*"
  for f in $FILES
  do
    echo "processing $f"
    echo $f >> "$NAME_SCHEME/accuracies.txt"
    # run vw training
    #echo "\n---training model---\n"
    vw -d "$f" --passes $NUM_PASSES --loss_function $LOSS_FUNCTION --ngram $NGRAM -f "$NAME_SCHEME/log_model.vw" --binary --quiet

    # test model on training set
    #echo "\n---testing model on training set---\n"
    vw -i "$NAME_SCHEME/log_model.vw" -t -d "$f" -p "$NAME_SCHEME/log_train_pred.txt" --binary --quiet

    # test model on test set
    #echo "\n---testing model on test set---\n"
    vw -i "$NAME_SCHEME/log_model.vw" -t -d "$NAME_SCHEME/test.vw" -p "$NAME_SCHEME/log_test_pred.txt" --binary --quiet

    # compute accuracy of predictions on test set
    #echo "\n---computing accuracy on test set---\n"
    python3 check-accuracy.py "$NAME_SCHEME/log_test_pred.txt" "$NAME_SCHEME/test_labels.txt" >> "$NAME_SCHEME/accuracies.txt"
  done

  # convert accuracy information
  python3 convert-accuracy-file.py "$NAME_SCHEME/accuracies.txt"

else

  if [ "$TRAIN_MODEL" = true ] ; then
    # create directory to store training data, models, and results
    mkdir -p -- "$NAME_SCHEME"

    # format the test data
    # TODO: technically this doesn't need to be done for every new run (only if the preprocessing requirements change)
    python3 test-data-to-vw.py $NAME_SCHEME

    # format the train data given the specified number to train on
    python3 train-data-to-vw.py $NUM_TRAIN $NAME_SCHEME $RANDOMIZE

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
