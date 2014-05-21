Codebook for the course project of the Coursera Course Getting and Cleaning Data 
========================================================

About this dataset
-------------------------------------------------------------------
The dataset for the course project is derived from *Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012*

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

For each record it is provided:

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.


The **assignment** was to create one R script called run_analysis.R that does the following: 
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

## merge SubjectData, rename V1 and add a subjectrowID
mergedSubjectData <- rbind(testSubjectData, trainSubjectData)
colnames(mergedSubjectData) <- ("subject")
mergedSubjectData$subject.rowID <- 1:10299

## merge ActivityData, rebane V1 and add activityrowID
mergedActivityData <- rbind(testActivityData, trainActivityData)
colnames(mergedActivityData) <- ("activity")
mergedActivityData$activityrowID <- 1:10299

## merge XData
mergedXData <- rbind(testXData, trainXData)

## add rowID
mergedXData$XrowID <- 1:10299

## [a few lines here are omitted and explained below]

## merge Subjectdata, ActivityData & XData
mergedDfTotal <- merge(mergedSubjectData, mergedActivityData, by.x = "subjectrowID", by.y = "activityrowID", all = TRUE)
mergedDfTotal <- merge(mergedDfTotal, mergedXData, by.x = "subjectrowID", by.y = "XrowID")

```

2. Appropriately label the data set with descriptive activity names (Ass. part 4)
-------------------------------------------------------------------

All elements of the features.txt (second column) were renamed to create descriptive activity names. The gsub() function was used extensively to achieve this. After that the new names were used to create columnnames.

```
## read names from features.txt
## and clean names from () and , and - and _
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
features[,2] <- gsub("_","",features[,2])
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
avgDf$subject <- as.factor(avgDf$subject)
avgDf$activity <- as.factor(avgDf$activity)

## use plyr package to create averages per column, group by subject and activity
library(plyr)
dt <- ddply(avgDf, .(subject, activity), numcolwise(mean))
## create file and store results
write.table(dt, file = "data/averagesPerSubjectAndActivity.txt")
```

Variables in the file averagesPerSubjectAndActivity.txt are:
-------------------------------------------------------------------
|    | averagesPerSubjectAndActivity.txt                                                       |
|----|-----------------------------------------------------------------|
| 1  | subject                                                |
| 2  | activity                                                  |
| 3  | timebodyaccelerationmeanx                                   |
| 4  | timebodyaccelerationmeany                                   |
| 5  | timebodyaccelerationmeanz                                   |
| 6  | timebodyaccelerationstdx                                    |
| 7  | timebodyaccelerationstdy                                    |
| 8  | timebodyaccelerationstdz                                    |
| 9  | timegravityaccelerationmeanx                                |
| 10 | timegravityaccelerationmeany                                |
| 11 | timegravityaccelerationmeanz                                |
| 12 | timegravityaccelerationstdx                                 |
| 13 | timegravityaccelerationstdy                                 |
| 14 | timegravityaccelerationstdz                                 |
| 15 | timebodyaccelerationjerkmeanx                              |
| 16 | timebodyaccelerationjerkmeany                              |
| 17 | timebodyaccelerationjerkmeanz                              |
| 18 | timebodyaccelerationjerkstdx                               |
| 19 | timebodyaccelerationjerkstdy                               |
| 20 | timebodyaccelerationjerkstdz                               |
| 21 | timebodygyromeanx                                           |
| 22 | timebodygyromeany                                           |
| 23 | timebodygyromeanz                                           |
| 24 | timebodygyrostdx                                            |
| 25 | timebodygyrostdy                                            |
| 26 | timebodygyrostdz                                            |
| 27 | timebodygyrojerkmeanx                                      |
| 28 | timebodygyrojerkmeany                                      |
| 29 | timebodygyrojerkmeanz                                      |
| 30 | timebodygyrojerkstdx                                       |
| 31 | timebodygyrojerkstdy                                       |
| 32 | timebodygyrojerkstdz                                       |
| 33 | timebodyaccelerationmagnitudemean                           |
| 34 | timebodyaccelerationmagnitudestd                            |
| 35 | timegravityaccelerationmagnitudemean                        |
| 36 | timegravityaccelerationmagnitudestd                         |
| 37 | timebodyaccelerationjerkmagnitudemean                      |
| 38 | timebodyaccelerationjerkmagnitudestd                       |
| 39 | timebodygyromagnitudemean                                   |
| 40 | timebodygyromagnitudestd                                    |
| 41 | timebodygyrojerkmagnitudemean                              |
| 42 | timebodygyrojerkmagnitudestd                               |
| 43 | frequencydomainbodyaccelerationmeanx                        |
| 44 | frequencydomainbodyaccelerationmeany                        |
| 45 | frequencydomainbodyaccelerationmeanz                        |
| 46 | frequencydomainbodyaccelerationstdx                         |
| 47 | frequencydomainbodyaccelerationstdy                         |
| 48 | frequencydomainbodyaccelerationstdz                         |
| 49 | frequencydomainbodyaccelerationmeanfrequencyx              |
| 50 | frequencydomainbodyaccelerationmeanfrequencyy              |
| 51 | frequencydomainbodyaccelerationmeanfrequencyz              |
| 52 | frequencydomainbodyaccelerationjerkmeanx                   |
| 53 | frequencydomainbodyaccelerationjerkmeany                   |
| 54 | frequencydomainbodyaccelerationjerkmeanz                   |
| 55 | frequencydomainbodyaccelerationjerkstdx                    |
| 56 | frequencydomainbodyaccelerationjerkstdy                    |
| 57 | frequencydomainbodyaccelerationjerkstdz                    |
| 58 | frequencydomainbodyaccelerationjerkmeanfrequencyx         |
| 59 | frequencydomainbodyaccelerationjerkmeanfrequencyy         |
| 60 | frequencydomainbodyaccelerationjerkmeanfrequencyz         |
| 61 | frequencydomainbodygyromeanx                                |
| 62 | frequencydomainbodygyromeany                                |
| 63 | frequencydomainbodygyromeanz                                |
| 64 | frequencydomainbodygyrostdx                                 |
| 65 | frequencydomainbodygyrostdy                                 |
| 66 | frequencydomainbodygyrostdz                                 |
| 67 | frequencydomainbodygyromeanfrequencyx                      |
| 68 | frequencydomainbodygyromeanfrequencyy                      |
| 69 | frequencydomainbodygyromeanfrequencyz                      |
| 70 | frequencydomainbodyaccelerationmagnitudemean                |
| 71 | frequencydomainbodyaccelerationmagnitudestd                 |
| 72 | frequencydomainbodyaccelerationmagnitudemeanfrequency      |
| 73 | frequencydomainbodyaccelerationjerkmagnitudemean           |
| 74 | frequencydomainbodyaccelerationjerkmagnitudestd            |
| 75 | frequencydomainbodyaccelerationjerkmagnitudemeanfrequency |
| 76 | frequencydomainbodygyromagnitudemean                        |
| 77 | frequencydomainbodygyromagnitudestd                         |
| 78 | frequencydomainbodygyromagnitudemeanfrequency              |
| 79 | frequencydomainbodygyrojerkmagnitudemean                   |
| 80 | frequencydomainbodygyrojerkmagnitudestd                    |
| 81 | frequencydomainbodygyrojerkmagnitudemeanfrequency         |
| 82 | angletimebodyaccelerationmeangravity                       |
| 83 | angletimebodyaccelerationjerkmeangravitymean             |
| 84 | angletimebodygyromeangravitymean                          |
| 85 | angletimebodygyrojerkmeangravitymean                     |
| 86 | anglexgravitymean                                            |
| 87 | angleygravitymean                                            |
| 88 | anglezgravitymean                                            |
