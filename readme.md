Read me
========================================================
*Theo Bakker, 21-05-2014, Amsterdam, The Netherlands*

This project contains all the necessary files for the project assignment of the Coursera course *Getting and Cleaning Data*. It contains the following files:

**run_analysis.R** This file contains all the necessary code to answer the five parts of the main assignment. It
- 1. Merges the training and the test sets to create one data set.
- 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
- 3. Uses descriptive activity names to name the activities in the data set
- 4. Appropriately labels the data set with descriptive activity names. 
- 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

**data** The data folder contains all data that is used to fulfill the assignment:
The dataset includes the following files:
- 'features_info.txt': Shows information about the variables used on the feature vector.
- 'features.txt': List of all features.
- 'activity_labels.txt': Links the class labels with their activity name.
- 'train/X_train.txt': Training set.
- 'train/y_train.txt': Training labels.
- 'test/X_test.txt': Test set.
- 'test/y_test.txt': Test labels.

**averagesPerSubjectAndActivity.txt**: he the new, tidy dataset (the result of step 5 of the assignment) 

**CodeBook.md** This file describes the variables, the data, and any transformations or work that you performed to clean up the data

