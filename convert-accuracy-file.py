import os, sys

# file containing the intermediate accuracy information
ACCURACY_FILE = sys.argv[1]

accuracy_map = []
min_accuracy = 1
max_accuracy = 0
with open(ACCURACY_FILE) as accuracies:
    num = 0
    accuracy = 0
    for line in accuracies:
        if "accuracy" in line:
            accuracy = float(line.split(' ')[1])
            if accuracy < min_accuracy:
                min_accuracy = accuracy
            if accuracy > max_accuracy:
                max_accuracy = accuracy
            accuracy_map.append((num, accuracy))
        else:
            num = int(line.split('/')[3].split('_')[0])

with open(ACCURACY_FILE, "w") as accuracies:
    for accuracy in accuracy_map:
        accuracies.write(str(accuracy[0]) + ' ' + str(accuracy[1]) + "\n")
#print(accuracy_map)

print('min accuracy', min_accuracy)
print('max accuracy', max_accuracy)
