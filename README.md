

README file for the Getting and Cleaning Data course Project.   
---

This project contains fours files:   
&nbsp; 1) run_analysis.R  
&nbsp; 2) TidyDatabyHelmarMartens.txt  
&nbsp; 3) CodeBook.md  
&nbsp; 4) README.md (This file)  
  
Following is an explanation of the content of these files:  

  

__run_analysis.R__ --> Contains the R code to produce the tidy data set. 

__TidyDatabyHelmarMartens.txt__ --> File containing the tidy data set created with the read.table() function.  In order to lead this file into your rStudion environment, please follow the steps below:  
1) Please make sure you have installed the DPLYR package on your system.  
2) Please make sure you have unzipped the zip file containig the Samsung project data into your R working directory (getwd())  
3) The folder containing all the data from the Samsung project is named 'UCI HAR Dataset'. Please keep this original name.   
4) Please notice that this projec was created on a __WINDOWS 10__ System.  If you are testing on a Mac system, the routine to load the files might be different.   
5) To load the file, use the following command: TidyData <- read.table(file = "TidyDatabyHelmarMartens.txt", header=TRUE)    
  
  
  
__CodeBook.md__ --> The CodeBook.md file contains four major sections, namely:  
1) DATA DICTIONARY --> Describes the variables, data types, variable names and descriptive name for each variable present in the Tidy Data data set produced by the run_analysis.R file. A total of 88 variables.  
2) A description of the data.    
3) Transformation to clean up the data --> This section describes all the steps that were taken in the __run_analysis.R__ script to produce the Tidy Data data set.  Just for your convenience, the referred section has been added to this files too.   
4) Result --> Un explanation of how the resulting data set conforms to the definition of a tidy data set.   
  
  
Following, is an explanation of the programming routines that have been performed in the analysis script to accomplish the requirements established by this project.  

                                                      TRANSFORMATION TO CLEAN UP THE DATA      

The steps below describe the tasks that have been performed to transform the original data into a clean tidy data set.  
In the first set of tasks, the data sets were initially treated independently, test and training data.   For each of these categories, the following tasks were performed. 

1) An unique index variable was created in each data set. These indices were created to assure that merging of the data occur correctly and accurately.   
2) Subjects and Activities data was added to each dataset. One column for each variable.   
3) Subsequently, the data from each data set, test and training, were merged based on the common unique ID from each row in each data set.   
4) Using the row binding function (rbind), the test data set was merged into the training data set, creating a single data set with 10,299 observations and 564 variables.
5) Lastly, the id column was dropped from the dataset.   


Once both data sets were merged, we next extracted only the measurements on the mean and standard deviation for each measurement. This task was accoomplished by performing the following steps:  

1) Created a vector containing all the variables names extracted from the 'features.txt' file.    
2) By using the 'colnames' function, all the variables were assigned to their respective columns.   
3) Columns from 461 to 502 were dropped from the dataset because they had repeated names.     
4) By dropping columns that were repeated, we made the data set tidy, by making the data set narrow.   

Subsequently, the numeric categories from the 'activityName' column was replace with the activity names, which were extracted from the 'y_test.txt' file. We used the 'replace' function, as one of the arguments to the mutate function to accomplish this task. This created a new column named activityName, and the old activity column was 'dropped'.       

The next step in the transformation process was to 'Appropriately label the data set with descriptive variable names' This task was accomplished executing the following steps.      

1) Created a vector with 88 variables with the matching descriptive names, since the set currently has 88 unique variables.     
2) Use the 'colnames' function to rename all the column names to display descriptive variables.    

Lastly, we created a tidy data set with the average of each variable for each activity and each subject. The following steps were performed:      
1) Calculate the mean for the aggregated values by subject and category.     
2) Sorted the entire data set by subject and activityName.   


