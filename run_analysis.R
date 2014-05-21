# 1) a tidy data set as described below, 
# 2) a link to a Github repository with your script for performing the analysis
# 3) a code book that describes the variables, the data, and any transformations 
# or work that you performed to clean up the data called CodeBook.md. 

# You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each 
# activity and each subject. 

## 
## http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

################ DESCRIPTIVE ACTIVITIES ################ 
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING


################  1. Merge the training and the test sets to create one data set. ################ 

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

## read names from features.txt
## and clean names from () and , and - -->> 4. Appropriately label the data set with descriptive activity names. 
features <- read.table("data/features.txt")
features[,2] <- gsub(c("Acc"),"_acceleration_",features[,2])
features[,2] <- gsub(c("Mag"),"_magnitude_",features[,2])
features[,2] <- gsub(c("tBody"),"time_body",features[,2])
features[,2] <- gsub(c("tGravity"),"time_gravity",features[,2])
features[,2] <- gsub(c("fBody"),"frequencydomain_body",features[,2])
features[,2] <- gsub(c("fGravity"),"frequencydomain_gravity",features[,2])
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

## only keep columns that have mean or std in their name -->
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
nm <- grep("std|mean", names(mergedXData), ignore.case = TRUE, value = TRUE)
mergedXData <- mergedXData[, names(mergedXData) %in% nm]

## add rowID
mergedXData$X.rowID <- 1:10299

## merge Subjectdata, ActivityData & XData
mergedDfTotal <- merge(mergedSubjectData, mergedActivityData, by.x = "subject.rowID", by.y = "activity.rowID", all = TRUE)
mergedDfTotal <- merge(mergedDfTotal, mergedXData, by.x = "subject.rowID", by.y = "X.rowID")

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

################  5. Creates a second, independent tidy data set with the average ################ 
################  of each variable for each activity and each subject. ################ 

avgDf <- mergedDfTotal
avgDf <- avgDf[,2:length(names(avgDf))] 
avgDf$subject.ID <- as.factor(avgDf$subject.ID)
avgDf$activity <- as.factor(avgDf$activity)
str(avgDf)
## use plyr package to create averages per column, group by subject.ID and activity
library(plyr)
dt <- ddply(avgDf, .(subject.ID, activity), numcolwise(mean))
## create file and store results
write.table(dt, file = "data/averagesPerSubjectAndActivity.txt")
