library(caret); 

# read data
inData <- read.csv("~/courses/ml/pml-training.csv", stringsAsFactors=FALSE)
validData <- read.csv("~/courses/ml/pml-testing.csv", stringsAsFactors=FALSE)

# function to clean data
clean_data<- function(inData) {
  # cleaning up DIV#0 and empty strings
  inData[inData=="#DIV/0!"] <- NA
  inData[inData==""] <- NA
  
  # transforming to the right type
  inData$user_name <- factor(inData$user_name)
  inData$new_window <- factor(inData$new_window)
  
  castNumeric = lapply(inData[6:160], class) == "character"
  for (col in names(Filter(function(x) x,castNumeric))) {
    inData[[col]] <- as.numeric(inData[[col]]) 
  }
  return (inData)
}

# classe in a factor
inData$classe <- factor(inData$classe)

# cleaning both input and test data
inData = clean_data(inData)
validData = clean_data(validData)

# computing the number of NA in each column
nas = colSums(is.na(inData[-160]))
# selecting only the columns with <10000 NAs 
snas = nas[nas<10000]

# selecting only the columns that don't have NAs
cleanData = inData[names(snas)]
cleanTest = validData[names(snas)]
cleanData["classe"] <- inData["classe"]

# train a personalized model 
trainModel = function(data) {
  # removing data irelevant for model building
  data$X=0
  data$raw_timestamp_part_1=0
  data$raw_timestamp_part_2=0
  data$num_window=0
  
  modelFit <- train(classe ~ ., data=data, method="rf")
  return(modelFit)
}

users = c("adelmo", "carlitos", "charles", "eurico", "jeremy", "pedro")
modelUser <- new.env()
personalRes <- c();

for (user in users) {
  print(user)
  userData = cleanData[cleanData$user_name==user, ]
  userTestData = cleanTest[validData$user_name==user, ]
  
  modelUser[[user]] = trainModel(userData)
  personalRes[userTestData$problem_id] <- predict(modelUser[[user]], userTestData)
}

personalRes

