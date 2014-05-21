Codebook for the course project of the Coursera Course Getting and Cleaning Data 
========================================================

The dataset for the course project is derived from *Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012*

The **assignment** was to create one R script called run_analysis.R that does the following. 
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive activity names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

**All parts of the assignment were completed, but not in this order.**

1. Merging the training and the test sets to create one data set (Ass. part 1)
-------------------------------------------------------------------
First the datasets were read and stored in seperate dataframes (testSubjectData, trainSubjectData, testActivityData, trainActivityData, testXData and trainXData). Then test and trainingsets were combined and row.IDs were added to merge the sets later on:
```
## read SubjectData, ActivityData and XData from test and train
testSubjectData <- read.table("data/test/subject_test.txt")
trainSubjectData <- read.table("data/train/subject_train.txt")
testActivityData <- read.table("data/test/y_test.txt")
trainActivityData <- read.table("data/train/y_train.txt")
testXData <- read.table("data/test/X_test.txt")
trainXData <- read.table("data/train/X_train.txt")

## merge SubjectData, rename V1 and add a subject.rowID
mergedSubjectData <- rbind(testSubjectData, trainSubjectData)
colnames(mergedSubjectData) <- ("subject.ID")
mergedSubjectData$subject.rowID <- 1:10299

## merge ActivityData, rebane V1 and add activity.rowID
mergedActivityData <- rbind(testActivityData, trainActivityData)
colnames(mergedActivityData) <- ("activity")
mergedActivityData$activity.rowID <- 1:10299

## merge XData
mergedXData <- rbind(testXData, trainXData)

## add rowID
mergedXData$X.rowID <- 1:10299

## [a few lines here are omitted and explained below]

## merge Subjectdata, ActivityData & XData
mergedDfTotal <- merge(mergedSubjectData, mergedActivityData, by.x = "subject.rowID", by.y = "activity.rowID", all = TRUE)
mergedDfTotal <- merge(mergedDfTotal, mergedXData, by.x = "subject.rowID", by.y = "X.rowID")

```

2. Appropriately label the data set with descriptive activity names (Ass. part 4)
-------------------------------------------------------------------

All elements of the features.txt (second column) were renamed to create descriptive activity names. The gsub() function was used extensively to achieve this. After that the new names were used to create columnnames.

```
## read names from features.txt
## and clean names from () and , and -
## change names to make them descriptive enough to understand
features <- read.table("data/features.txt")
features[,2] <- gsub(c("Acc"),"_acceleration_",features[,2])
features[,2] <- gsub(c("Mag"),"_magnitude_",features[,2])
features[,2] <- gsub(c("tBody"),"- time_body",features[,2])
features[,2] <- gsub(c("tGravity"),"- time_gravity",features[,2])
features[,2] <- gsub(c("fBody"),"- frequencydomain_body",features[,2])
features[,2] <- gsub(c("fGravity"),"- frequencydomain_gravity",features[,2])
features[,2] <- gsub(c("Jerk"),"jerk_",features[,2])
features[,2] <- gsub(c("angle"),"angle_",features[,2])
features[,2] <- gsub(c("Gyro"),"_gyro_",features[,2])
features[,2] <- gsub(c("Freq"),"_frequency",features[,2])
features[,2] <- gsub(c("Mean"),"_mean",features[,2])
features[,2] <- gsub(c("gravity"),"_gravity",features[,2])
features[,2] <- gsub(c("bodyBody"),"_body",features[,2])
features[,2] <- gsub(c("\\(\\)"),"",features[,2])
features[,2] <- gsub("\\(","",features[,2])
features[,2] <- gsub("\\)","",features[,2])
features[,2] <- gsub(",","",features[,2])
features[,2] <- gsub("-","",features[,2])
features[,2] <- gsub("X","_x",features[,2])
features[,2] <- gsub("Y","_y",features[,2])
features[,2] <- gsub("Z","_z",features[,2])
features[,2] <- gsub("__","_",features[,2])
names(mergedXData) <- features[,2]
```

3. Extract only the measurements on the mean and standard deviation for each measurement (Ass. part 2)
-------------------------------------------------------------------
Because only columns regarding means and standard deviations must be included, columns that contain mean or std (case insensitive) are selected to create a subset.

```
## only keep columns that have mean or std in their name -->
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
nm <- grep("std|mean", names(mergedXData), ignore.case = TRUE, value = TRUE)
mergedXData <- mergedXData[, names(mergedXData) %in% nm]
```

4. Use descriptive activity names to name the activities in the data set (Ass. part 3)
-------------------------------------------------------------------
The activity column contained numbers that were converted to descriptive activity names.

```
################ 3. Use descriptive activity names to name the activities in the data set ################  
# 1 WALKING, 2 WALKING_UPSTAIRS, 3 WALKING_DOWNSTAIRS, 4 SITTING, 5 STANDING, 6 LAYING

# cast activity to character; store activities in a list and loop through them to replace the numbers with
# dersciptive activity names
mergedDfTotal$activity <- as.character(mergedDfTotal$activity)
lActivities <- list("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")
j = 0
for(i in lActivities){
    j <- j+1
    mergedDfTotal$activity <- sub(j,i,mergedDfTotal$activity)
}
```

5. Create a second, independent tidy data set with the average of each variable for each activity and each subject. (Ass. part 5)
-------------------------------------------------------------------

Finally, a second data set was created with the average of each variable for each activity and each subject. 
The original merged data frame was copied to a average data frame. The first column (row.ID) was dropped; subject.ID and activity were recast as factor to be able to group them later on. The plyr package was used to count the means for each activity. The reshaped data frame was transformed to a table and written to a file: averagesPerSubjectAndActivity.txt.
```
################  5. Creates a second, independent tidy data set with the average ################ 
################  of each variable for each activity and each subject. ################ 

avgDf <- mergedDfTotal
avgDf <- avgDf[,2:length(names(avgDf))] 
avgDf$subject.ID <- as.factor(avgDf$subject.ID)
avgDf$activity <- as.factor(avgDf$activity)

## use plyr package to create averages per column, group by subject.ID and activity
library(plyr)
dt <- ddply(avgDf, .(subject.ID, activity), numcolwise(mean))
## create file and store results
write.table(dt, file = "data/averagesPerSubjectAndActivity.txt")
```

Columns of the file averagesPerSubjectAndActivity.txt are:
-------------------------------------------------------------------
|    | averagesPerSubjectAndActivity.txt                                                       |
|----|-----------------------------------------------------------------|
| 1  | subject.ID                                                |
| 2  | activity                                                  |
| 3  | time_body_acceleration_mean_x                                   |
| 4  | time_body_acceleration_mean_y                                   |
| 5  | time_body_acceleration_mean_z                                   |
| 6  | time_body_acceleration_std_x                                    |
| 7  | time_body_acceleration_std_y                                    |
| 8  | time_body_acceleration_std_z                                    |
| 9  | time_gravity_acceleration_mean_x                                |
| 10 | time_gravity_acceleration_mean_y                                |
| 11 | time_gravity_acceleration_mean_z                                |
| 12 | time_gravity_acceleration_std_x                                 |
| 13 | time_gravity_acceleration_std_y                                 |
| 14 | time_gravity_acceleration_std_z                                 |
| 15 | time_body_acceleration_jerk_mean_x                              |
| 16 | time_body_acceleration_jerk_mean_y                              |
| 17 | time_body_acceleration_jerk_mean_z                              |
| 18 | time_body_acceleration_jerk_std_x                               |
| 19 | time_body_acceleration_jerk_std_y                               |
| 20 | time_body_acceleration_jerk_std_z                               |
| 21 | time_body_gyro_mean_x                                           |
| 22 | time_body_gyro_mean_y                                           |
| 23 | time_body_gyro_mean_z                                           |
| 24 | time_body_gyro_std_x                                            |
| 25 | time_body_gyro_std_y                                            |
| 26 | time_body_gyro_std_z                                            |
| 27 | time_body_gyro_jerk_mean_x                                      |
| 28 | time_body_gyro_jerk_mean_y                                      |
| 29 | time_body_gyro_jerk_mean_z                                      |
| 30 | time_body_gyro_jerk_std_x                                       |
| 31 | time_body_gyro_jerk_std_y                                       |
| 32 | time_body_gyro_jerk_std_z                                       |
| 33 | time_body_acceleration_magnitude_mean                           |
| 34 | time_body_acceleration_magnitude_std                            |
| 35 | time_gravity_acceleration_magnitude_mean                        |
| 36 | time_gravity_acceleration_magnitude_std                         |
| 37 | time_body_acceleration_jerk_magnitude_mean                      |
| 38 | time_body_acceleration_jerk_magnitude_std                       |
| 39 | time_body_gyro_magnitude_mean                                   |
| 40 | time_body_gyro_magnitude_std                                    |
| 41 | time_body_gyro_jerk_magnitude_mean                              |
| 42 | time_body_gyro_jerk_magnitude_std                               |
| 43 | frequencydomain_body_acceleration_mean_x                        |
| 44 | frequencydomain_body_acceleration_mean_y                        |
| 45 | frequencydomain_body_acceleration_mean_z                        |
| 46 | frequencydomain_body_acceleration_std_x                         |
| 47 | frequencydomain_body_acceleration_std_y                         |
| 48 | frequencydomain_body_acceleration_std_z                         |
| 49 | frequencydomain_body_acceleration_mean_frequency_x              |
| 50 | frequencydomain_body_acceleration_mean_frequency_y              |
| 51 | frequencydomain_body_acceleration_mean_frequency_z              |
| 52 | frequencydomain_body_acceleration_jerk_mean_x                   |
| 53 | frequencydomain_body_acceleration_jerk_mean_y                   |
| 54 | frequencydomain_body_acceleration_jerk_mean_z                   |
| 55 | frequencydomain_body_acceleration_jerk_std_x                    |
| 56 | frequencydomain_body_acceleration_jerk_std_y                    |
| 57 | frequencydomain_body_acceleration_jerk_std_z                    |
| 58 | frequencydomain_body_acceleration_jerk_mean_frequency_x         |
| 59 | frequencydomain_body_acceleration_jerk_mean_frequency_y         |
| 60 | frequencydomain_body_acceleration_jerk_mean_frequency_z         |
| 61 | frequencydomain_body_gyro_mean_x                                |
| 62 | frequencydomain_body_gyro_mean_y                                |
| 63 | frequencydomain_body_gyro_mean_z                                |
| 64 | frequencydomain_body_gyro_std_x                                 |
| 65 | frequencydomain_body_gyro_std_y                                 |
| 66 | frequencydomain_body_gyro_std_z                                 |
| 67 | frequencydomain_body_gyro_mean_frequency_x                      |
| 68 | frequencydomain_body_gyro_mean_frequency_y                      |
| 69 | frequencydomain_body_gyro_mean_frequency_z                      |
| 70 | frequencydomain_body_acceleration_magnitude_mean                |
| 71 | frequencydomain_body_acceleration_magnitude_std                 |
| 72 | frequencydomain_body_acceleration_magnitude_mean_frequency      |
| 73 | frequencydomain_body_acceleration_jerk_magnitude_mean           |
| 74 | frequencydomain_body_acceleration_jerk_magnitude_std            |
| 75 | frequencydomain_body_acceleration_jerk_magnitude_mean_frequency |
| 76 | frequencydomain_body_gyro_magnitude_mean                        |
| 77 | frequencydomain_body_gyro_magnitude_std                         |
| 78 | frequencydomain_body_gyro_magnitude_mean_frequency              |
| 79 | frequencydomain_body_gyro_jerk_magnitude_mean                   |
| 80 | frequencydomain_body_gyro_jerk_magnitude_std                    |
| 81 | frequencydomain_body_gyro_jerk_magnitude_mean_frequency         |
| 82 | angle_time_body_acceleration_mean_gravity                       |
| 83 | angle_time_body_acceleration_jerk_mean_gravity_mean             |
| 84 | angle_time_body_gyro_mean_gravity_mean                          |
| 85 | angle_time_body_gyro_jerk_mean_gravity_mean                     |
| 86 | angle_x_gravity_mean                                            |
| 87 | angle_y_gravity_mean                                            |
| 88 | angle_z_gravity_mean                                            |
