#     REQUIREMENTS:
#     1) Please make sure you have installed the DPLYR package on your system.
#     2) Please make sure you have unzipped the zip file in your R working directory (getwd())
#     3) The folder containing all the data from the Sumsong project is named 'UCI HAR Dataset'
#     4) Please notice that this projec we created on a WINDOWS 10 SYstem.  If you are testing on a Mac system, the routine to load the files might be different. 


PROJECT_FOLDER <- "/UCI HAR Dataset"
library(dplyr)

if(!file.exists("./UCI HAR Dataset"))
{
  print("PLEASE make sure you create and put all the required files in the 'UCI HAR Dataset' folder of your working directory ")
  print("The 'UCI HAR Dataset' folder should contain the following files: ")
  print("/test/subject_test.txt")
  print("/train/subject_train.txt")
  print("/test/X_test.txt")
  print("/train/X_train.txt")
  print("/test/y_test.txt")
  print("/train/y_train.txt")
  print("features.txt")
}
# Read in the data 
FILE_PATH <- paste0(getwd(), PROJECT_FOLDER)

# Let's read in the required files:
TEST_DATA_FILE      <- paste0(FILE_PATH, "/test/X_test.txt" )
TRAIN_DATA_FILE     <- paste0(FILE_PATH, "/train/X_train.txt" )
SUBJECT_TEST_FILE   <- paste0(FILE_PATH, "/test/subject_test.txt" )
SUBJECT_TRAIN_FILE  <- paste0(FILE_PATH, "/train/subject_train.txt" ) 
ACTIVITY_TEST_FILE  <- paste0(FILE_PATH, "/test/y_test.txt" ) 
ACTIVITY_TRAIN_FILE <- paste0(FILE_PATH, "/train/y_train.txt" )
FEATURES_FILE       <- paste0(FILE_PATH, "/features.txt" )

TEST_DATA      <- read.table(TEST_DATA_FILE,      header = FALSE,  dec = ".", numerals = "no.loss")
TRAIN_DATA     <- read.table(TRAIN_DATA_FILE,     header = FALSE,  dec = ".", numerals = "no.loss")
SUBJECT_TEST   <- read.table(SUBJECT_TEST_FILE,   header = FALSE)
SUBJECT_TRAIN  <- read.table(SUBJECT_TRAIN_FILE,  header = FALSE)
ACTIVITY_TEST  <- read.table(ACTIVITY_TEST_FILE,  header = FALSE)
ACTIVITY_TRAIN <- read.table(ACTIVITY_TRAIN_FILE, header = FALSE)
FEATURES       <- read.table(FEATURES_FILE,       header = FALSE)


# Now that we have read in all the data, let's move on to do the first step of the assignment: 
#======================================================================================================================
# STEP 1 of the assignment 
# 1) Merges the training and the test sets to create one data set.
# =====================================================================================================================

# HOWEVER, before we merge both test and train data sets, let's do some preparation work to create some safeguard mechanism to make sure that
# when we bring in the ACTIVITY and SUBJECT data sets in the subsequent steps of the assignment, we can have a means to validate and assure that the merge is correct
# The adjustments will be as follows: 
# A) Rename the variables in the Activity and Subject files
# B) Add a unique index to all data sets 


# Convert activity and subject objects to DPLYR objects 
SUBJECT_TEST   <- tbl_df(SUBJECT_TEST)
SUBJECT_TRAIN  <- tbl_df(SUBJECT_TRAIN)
ACTIVITY_TEST  <- tbl_df(ACTIVITY_TEST)
ACTIVITY_TRAIN <- tbl_df(ACTIVITY_TRAIN)

# A) Rename the variables in the Activity and Subject files
# This mechanism consists of adding an index column to both measurement datasets as well as to the subjects and activity dataset.
SUBJECT_TEST   <- rename(SUBJECT_TEST,   subject  = V1)
SUBJECT_TRAIN  <- rename(SUBJECT_TRAIN,  subject  = V1)
ACTIVITY_TEST  <- rename(ACTIVITY_TEST,  activity = V1)
ACTIVITY_TRAIN <- rename(ACTIVITY_TRAIN, activity = V1)


# B) Add a unique index to all data sets 
# While I know that this step is not required and has not been explicitly asked, it will improve our ability to validate our proceedures. 
# So, let's create this temporary extra index column on all datasets. We will call it "id"
TEST_DATA       <- cbind("id"  = sprintf("%04d",  1:nrow(TEST_DATA)),       TEST_DATA)
TRAIN_DATA      <- cbind("id"  = sprintf("%04d",  1:nrow(TRAIN_DATA)),      TRAIN_DATA)
SUBJECT_TEST    <- cbind("id"  = sprintf("%04d",  1:nrow(SUBJECT_TEST)),    SUBJECT_TEST)
SUBJECT_TRAIN   <- cbind("id"  = sprintf("%04d",  1:nrow(SUBJECT_TRAIN)),   SUBJECT_TRAIN)
ACTIVITY_TEST   <- cbind("id"  = sprintf("%04d",  1:nrow(ACTIVITY_TEST)),   ACTIVITY_TEST)
ACTIVITY_TRAIN  <- cbind("id"  = sprintf("%04d",  1:nrow(ACTIVITY_TRAIN)),  ACTIVITY_TRAIN)


# Now lets merge the subject and activity data into the measurement data sets. We will leverage the unique ids we have created in the previous step.
# Merge subject & activity  into the measurement data set for their respective types (Test and Train)
TEST_DATA  <- merge(TEST_DATA,  SUBJECT_TEST,   by.x="id", by.y="id", all=TRUE)
TRAIN_DATA <- merge(TRAIN_DATA, SUBJECT_TRAIN,  by.x="id", by.y="id", all=TRUE)
TEST_DATA  <- merge(TEST_DATA,  ACTIVITY_TEST,  by.x="id", by.y="id", all=TRUE)
TRAIN_DATA <- merge(TRAIN_DATA, ACTIVITY_TRAIN, by.x="id", by.y="id", all=TRUE)

# CHECK
# A validation check shows that the data sets have been merged accurately by id. 
# We confirmed that both sets have been merged accurately by checking that the resulting data set contains 10,299 observation and that 
# row number 7353 maps to id 0001 of the test set data. 

# Since the merged columns get added to the very end of the data set, let's bring them to the beginning of the column list
# We can also drop the id column since we no longer need it. 
TEST_DATA  <-  TEST_DATA   %>% select(id, subject, activity, everything())
TRAIN_DATA <-  TRAIN_DATA  %>% select(id, subject, activity, everything())


# Now that both data sets contain the subject and activites properly merged into the data sets, we can merge both data sets, train and test.
# We add the rows from the test set to the train set
FULL_DATA_SET <- rbind(TRAIN_DATA, TEST_DATA)


#======================================================================================================================
# STEP 2 of the assignment 
# 2) Extracts only the measurements on the mean and standard deviation for each measurement
# =====================================================================================================================

# #In order to accomplish step 2, we need to add the variable names to the header column, since currently they are named V1, v2... 
#RENAME:
# Rename all variables and assign the names defined in the features.txt
# The FEATURES object (created in step 1)  currently holds the table with the name of the variables, 
# so we will convert it to a char vector, so that we can apply this vector as column names. 
FEATURES_VECTOR <- as.character(FEATURES$V2)

# Since we added two more columns to our data set, we need to account for them. 
# So, lets add these columns to the veatures vector that we will use to rename the columns 
ADDED_COLUMNS <- c("id", "subject", "activity")
FULL_FEATURES_VECTOR <- c(ADDED_COLUMNS, FEATURES_VECTOR)

# Finally, we can invoke the colnames function to rename the columns
# We will first empty the current column names, and then name them with the feature names currently stored in the FULL_FEATURES_VECTOR vector
colnames(FULL_DATA_SET) =  NULL
colnames(FULL_DATA_SET) <- FULL_FEATURES_VECTOR

# The current data.frame has repeated column names. Before we can subset it, we need to eliminste these repeated columns
# Theese repreated names start at column 461 through 502.  Since these values do not involve means values, 
# we can safely drop them and start creating a tidy set applying the narrowing approach 
FULL_DATA_SET <- FULL_DATA_SET[,-(461:502)]

#Finally, extract only the measurements on the mean and standard deviation for each measurement.
# Additionally, drop the id column since we no longer need it. 
 FULL_DATA_SET <- select(FULL_DATA_SET, starts_with("subject"), starts_with("activity"), contains("mean"), contains("std"))
 
#======================================================================================================================
# STEP 3 of the assignment 
# 3) Uses descriptive activity names to name the activities in the data set
# =====================================================================================================================

# Convert the FULL_DATA_SET from data.frame to DPLYr frame so that we can invoke the mutate function
# HOWEVER, this conversion is not going to work because 
# Now we can convert our data set from  data.frame to DPLYR frame, so that we can use mutate and select functions 
FULL_DATA_SET <- tbl_df(FULL_DATA_SET)
# Let's create a new column to hold the activity names
FULL_DATA_SET <- mutate(FULL_DATA_SET, activityName  = "A")

# Assign the activity name to the newly created "activityName" column based on the 6 activity numbers. 
FULL_DATA_SET <- mutate(FULL_DATA_SET, activityName = replace(activityName, activity == 1, "WALKING"))
FULL_DATA_SET <- mutate(FULL_DATA_SET, activityName = replace(activityName, activity == 2, "WALKING_UPSTAIRS"))
FULL_DATA_SET <- mutate(FULL_DATA_SET, activityName = replace(activityName, activity == 3, "WALKING_DOWNSTAIRS"))
FULL_DATA_SET <- mutate(FULL_DATA_SET, activityName = replace(activityName, activity == 4, "SITTING"))
FULL_DATA_SET <- mutate(FULL_DATA_SET, activityName = replace(activityName, activity == 5, "STANDING"))
FULL_DATA_SET <- mutate(FULL_DATA_SET, activityName = replace(activityName, activity == 6, "LAYING"))

# Drop the activity column
# Also move the newly created column to the beginning of the data set.
FULL_DATA_SET <- select(FULL_DATA_SET,  subject, activityName, everything() )
FULL_DATA_SET_MINUS_ACTIVITY  <- select(FULL_DATA_SET,   everything(), -activity )

#======================================================================================================================                     
# STEP  4 of the assignment
# 4) Appropriately labels the data set with descriptive variable names.
#======================================================================================================================
#The current data set has 88 unique variables. So, we create a char vector with 88 

DESCRIPTIVE_NAMES <- c("subject","activityName","TimeBoddyAccelerationMean_X_Axis","TimeBoddyAccelerationMean_Y_Axis","TimeBoddyAccelerationMean_Z_Axis","TimeGravityAccelerationMean_X_Axis",
                       "TimeGravityAccelerationMean_Y_Axis","TimeGravityAccelerationMean_Z_Axis","TimeBoddyAccelerationJerkMean_X_Axis","TimeBoddyAccelerationJerkMean_Y_Axis",
                       "TimeBoddyAccelerationJerkMean_Z_Axis","TimeBoddyGyroscopeMean_X_Axis","TimeBoddyGyroscopeMean_Y_Axis","TimeBoddyGyroscopeMean_Z_Axis","TimeBoddyGyroscopeJerkMean_X_Axis",
                       "TimeBoddyGyroscopeJerkMean_Y_Axis","TimeBoddyGyroscopeJerkMean_Z_Axis","TimeBoddyAccelerationMagnitudeMean","TimeGravityAccelerationMagnitudeMean",
                       "TimeBoddyAccelerationJerkMagnitudeMean","TimeBoddyGyroscopeMagnitudeMean","TimeBoddyGyroscopeJerkMagnitudeMean","FrequencyBodyAccelerationMean_X_Axis",
                       "FrequencyBodyAccelerationMean_Y_Axis","FrequencyBodyAccelerationMean_Z_Axis","FrequencyBodyAccelerationMeanFrequency_X_Axis",
                       "FrequencyBodyAccelerationMeanFrequency_Y_Axis","FrequencyBodyAccelerationMeanFrequency_Z_Axis","FrequencyBodyAccelerationJerkMean_X_Axis",
                       "FrequencyBodyAccelerationJerkMean_Y_Axis","FrequencyBodyAccelerationJerkMean_Z_Axis","FrequencyBodyAccelerationJerkMeanFrequency_X_Axis",
                       "FrequencyBodyAccelerationJerkMeanFrequency_Y_Axis","FrequencyBodyAccelerationJerkMeanFrequency_Z_Axis","FrequencyBodyGyroscopeMean_X_Axis",
                       "FrequencyBodyGyroscopeMean_Y_Axis","FrequencyBodyGyroscopeMean_Z_Axis","FrequencyBodyGyroscopeMeanFrequency_X_Axis","FrequencyBodyGyroscopeMeanFrequency_Y_Axis",
                       "FrequencyBodyGyroscopeMeanFrequency_Z_Axis","FrequencyBoddyAccelerationMagnitudeMean","FrequencyBoddyAccelerationMagnitudeMeanFrequency",
                       "FrequencyBodyAccellerationJerkMagnitudeMean","FrequencyBodyAccellerationJerkMagnitudeMeanFrequency","FrequencyBodyGyroscopeMagnitudeMean",
                       "FrequencyBodyGyroscopeMagnitudeMeanFrequency","FrequencyBodyGyroscopeJerkMagnitudeMean","FrequencyBodyGyroscopeJerkMagnitudeMeanMenFrequency",
                       "AngleForTimeBodyAccellerationMeanAndGravity","AngleForTimeBodyAccellerationJerkMeanAndGravityMean","AngleForTimeBodyGyroscopeMeanAndGravityMean",
                       "AngleForTimeBodyGyroscopeJerkMeanAndGravityMean","AngleFor_X_AxisAndGravityMean","AngleFor_Y_AxisAndGravityMean","AngleFor_Z_AxisAndGravityMean",
                       "TimeBodyAccellerationStandardDeviation_X_Axis","TimeBodyAccellerationStandardDeviation_Y_Axis","TimeBodyAccellerationStandardDeviation_Z_Axis",
                       "TimeGravityAccellerationStandardDeviation_X_Axis","TimeGravityAccellerationStandardDeviation_Y_Axis","TimeGravityAccellerationStandardDeviation_Z_Axis",
                       "TimeBodyAccellerationJerkStandardDeviation_X_Axis","TimeBodyAccellerationJerkStandardDeviation_Y_Axis","TimeBodyAccellerationJerkStandardDeviation_Z_Axis",
                       "tTimeBodyGyroscopeStandardDeviation_X_Axis","TimeBodyGyroscopeStandardDeviation_Y_Axis","TimeBodyGyroscopeStandardDeviation_Z_Axis",
                       "TimeBodyGyroscopeJerkStandardDeviation_X_Axis","TimeBodyGyroscopeJerkStandardDeviation_Y_Axis","TimeBodyGyroscopeJerkStandardDeviation_Z_Axis",
                       "TimeBodyAccellerationMagnitudeStandardDeviation","TimeGravityAccellerationMagnitudeStandardDeviation","TimeBodyAccellerationJerkMagnitudeStandardDeviation",
                       "TimeBodyGyroscopeMagnitudeStandardDeviation","TimeBodyGyroscopeJerkMagnitudeStandardDeviation","FrequencyAccellerationStandardDeviation_X_Axis",
                       "FrequencyAccellerationStandardDeviation_Y_Axis","FrequencyAccellerationStandardDeviation_Z_Axis","FrequencyBodyAccellerationJerkStandardDeviation_X_Axis",
                       "FrequencyBodyAccellerationJerkStandardDeviation_Y_Axis","FrequencyBodyAccellerationJerkStandardDeviation_Z_Axis","FrequencyBodyGyroscopeStandardDeviation_X_Axis",
                       "FrequencyBodyGyroscopeStandardDeviation_Y_Axis","FrequencyBodyGyroscopeStandardDeviation_Z_Axis","FrequencyBodyAccellerationMagnitudeStandardDeviation",
                       "FrequencyBodyAccellerationJerkMagnitudeStandardDeviation","FrequencyBodyGyroscopeMagnitudeStandardDeviation","FrequencyBodyGyroscopeJerkMagnitudeStandardDeviation")

# Replace the column names with the descript names from the DESCRIPTIVE_NAMES vector
colnames(FULL_DATA_SET_MINUS_ACTIVITY) =  NULL
colnames(FULL_DATA_SET_MINUS_ACTIVITY) <- DESCRIPTIVE_NAMES

#======================================================================================================================
# STEP 5 of the assignment
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#======================================================================================================================

DATA_SET_MEAN <- aggregate(. ~subject + activityName, FULL_DATA_SET_MINUS_ACTIVITY, mean)

SORTED_DATA_SET_MEAN <- arrange(DATA_SET_MEAN, subject, activityName)
