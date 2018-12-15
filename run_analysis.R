library(dplyr)

## Create date folder, download file, unzip files
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")
unzip(zipfile="./data/Dataset.zip",exdir="./data")

## Read in training tables, test tables, features, and activity labels
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

features <- read.table('./data/UCI HAR Dataset/features.txt')

activity_labels = read.table('./data/UCI HAR Dataset/activity_labels.txt')

## Label the datasets
colnames(x_train) <- features[,2] 
colnames(x_test) <- features[,2] 
colnames(y_train) <- "activity"
colnames(y_test) <- "activity"
colnames(subject_train) <- "subject"
colnames(subject_test) <- "subject"
colnames(activity_labels) <- c("activity","activityname")

## 1. Merges the training and the test sets to create one data set.
x_full <- rbind(x_train,x_test)
y_full <- rbind(y_train,y_test)
subject_full <- rbind(subject_train,subject_test)
full_data <- cbind(y_full,subject_full,x_full)

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
mean_std <- (grepl("activity", colnames(full_data)) | grepl("subject", colnames(full_data)) |
               grepl("mean..", colnames(full_data)) | grepl("std..", colnames(full_data)))
data_mean_std <- full_data[ , mean_std == TRUE]

## 3. Uses descriptive activity names to name the activities in the data set.
## 4. Appropriately labels the data set with descriptive variable names.
data_activitynames <- merge(data_mean_std, activity_labels, by='activity', all.x=TRUE)

## 5. From the data set in step 4, creates a second, independent tidy data set with the
##    average of each variable for each activity and each subject.
Data_average <-aggregate(. ~subject + activity, data_activitynames, mean)
Data_average <-Data_average[order(Data_average$subject,Data_average$activity),]
write.table(Data_average, file = "average.txt",row.name=FALSE)
