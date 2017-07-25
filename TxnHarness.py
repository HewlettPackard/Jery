from __future__ import division
import numpy as np
import os


weight =    [10, 100, 5, 30, 4, 34, 12, 23, 10, 3, 24]
total =     np.sum(weight)
probs =     [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
absCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
relCounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
totalCount = 0

# calculate probabilities based on weighting
for i in range(0, len(weight)):
    probs[i] = weight[i] / total

# choosing values from 0-11 based on probabilities
while True:
    choice = np.random.choice(11, 1, p=probs)[0]
    absCounts[choice] += 1
    totalCount = np.sum(absCounts)

    # calculate relative counts based on weighting
    for i in range(0, len(absCounts)):
        relCounts[i] = absCounts[i] / totalCount

    # print every 10'000th iteration
    if totalCount % 10000 == 0:
        os.system('cls')
        print "weights: " + str(weight) + "\n"
        for i in range(0, len(probs)):
            print "Transaction " + str(i+1)
            print "-------------------------------"
            print "required prob:\t" + str(probs[i])
            print "scored prob:\t" + str(relCounts[i])
            print "\n"