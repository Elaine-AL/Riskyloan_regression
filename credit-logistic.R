# PROBLEM DEFINITION :
####  IDENTIFYING RISKY LOANS 
#
# For the outcome variable --default column-- :
## 1 - good loan and 2 - bad loan
# download and load the following packages : popbio, tidyr, broom, ggplot2, caret, visreg, rcompanion, ROCR, dplyr, skimr, purr, margins

# load the data to a dataframe
credit = read.csv("credit data.csv")

#====================
#EXPLORATORY ANALYSIS
#====================

View(credit)
# view the structure of the data and see if there are any missing values
str(credit)
credit$default = as.factor(credit$default)
colnames(credit)
sum(is.na(credit))

credit %>% skim() #get a summary of the values
credit %>% map_df(~n_distinct(.)) %>% gather() # get the number of unique values for each column

# see the distribution of some notable independent variables 
ggplot(data = credit) + 
  geom_histogram(mapping = aes(x = age), binwidth = 0.5) # for age x-variable

ggplot(data = credit) + 
  geom_histogram(mapping = aes(x = months_loan_duration), binwidth = 0.5) # for months_loan_duration x-variable

ggplot(credit) + 
  geom_bar(aes(x = credit_history, fill = credit_history), width = 1) + 
  theme(aspect.ratio = 1) + 
  coord_polar() # for credit history

# and the relationship between others
ggplot(data = credit) + 
  geom_point(aes(x = amount, y = months_loan_duration)) + 
  facet_wrap(~credit_history)
ggplot(credit) + 
  geom_smooth(mapping = aes(x = amount, y = months_loan_duration)) + 
  geom_point(mapping = aes(x = amount, y = months_loan_duration))


#=========
#MODELLING
#=========

#change the levels of the target variable so that '1' remains as 1 and '2' to be 0 so that it 
#may be possible to compare with our predicted values
credit$default = ifelse(credit$default == 1, 1, 0)

#let us first see how the amount of loan varies by default type
plot(credit$amount, jitter(credit$default, 0.15), 
     pch =19,
     xlab = "amount",
     ylab = "default(1-good, 0-bad loan)")

logi.hist.plot(credit$amount, 
               credit$default, 
               boxp = FALSE,
               type = "count", 
               col = "gray", 
               xlabel = "amount", 
               ylabel = "Prob(1-good, 0-bad loan)"
               )

set.seed(123) 

#We divide our data into two groups; train and test sets
splitCredit = sample(x = 2, 
                     size = nrow(credit), 
                     replace = TRUE, 
                     prob = c(0.70, 0.30)
                     )

train.credit = subset(credit, splitCredit ==1)
test.credit = subset(credit, splitCredit ==2)

#create the logistic model using glm() function 
defaultmodel = glm(default ~ ., 
                   family = "binomial", 
                   data = train.credit
                   )
summary(defaultmodel)
tidy(defaultmodel)

# therefore to identify risky loans use:
##   P = round((exp{2.808-0.0001152208*amount}/ (1 + exp{2.808-0.0001152208*amount}))))

# calculate the odd ratios, that is, the coeffiecients or change of the dependent variables with change in the target variabl
odd_ratio = exp(coef(defaultmodel))
log(odd_ratio)

#plot the log odds
visreg(defaultmodel, xvar = "amount", xlab = "Amount of credit", ylab = "Log odds of 'default'")
visreg(defaultmodel, xvar = "months_loan_duration", xlab = "Loan duration", ylab = "Log odds of 'default'")
visreg(defaultmodel, xvar = "credit_history", xlab = "Credit history", ylab = "Log odds of 'default'")
visreg(defaultmodel, xvar = "employment_length", xlab = "Employment length", ylab = "Log odds of 'default'")
visreg(defaultmodel, xvar = "age", xlab = "Age", ylab = "Log odds of 'default'")

# plot the probabilities
visreg(defaultmodel, xvar = "amount", scale = "response", rug = 2, xlab = "Amount of credit", ylab = "Prob of 'default'")
visreg(defaultmodel, xvar = "age", scale = "response", rug = 2, xlab = "Age", ylab = "Prob of 'default'")
visreg(defaultmodel, xvar = "credit_history", scale = "response", rug = 2, xlab = "Credit history", ylab = "Prob of 'default'")
visreg(defaultmodel, xvar = "months_loan_duration", scale = "response", rug =2, xlab = "Loan duration", ylab = "Prob of 'default")

#average marginal effects that measures the rate of change of y(default) to a single unit change in x(independent variables)
AME = margins(defaultmodel)
plot(AME)
#OR
AME_df = summary(AME)
ggplot(data = AME_df, aes(x = factor, y = AME)) + 
  geom_point() + 
  geom_errorbar(aes(x = factor, ymin = lower, ymax = upper)) +
  geom_hline(yintercept = 0) +
  theme_minimal() + 
  coord_flip() +
  scale_color_grey()

#==========
#EVALUATION
#==========
# let's now predict our test dataset
creditPredict = round(predict(defaultmodel, newdata = test.credit, type = "response")) #round off the values to get the in 0s and 1s  
creditPredict
# see the comparison between our predicted and test dataset values
crediteval = data.frame(observed = test.credit$default, predicted = creditPredict)
crediteval
#table the results 
creditTable = table(test.credit$default, creditPredict)
creditTable
#get the accuracy
sum(diag(creditTable))/sum(creditTable) * 100
#or simply
confusionMatrix(creditTable)

#get the pseudo R2
nagelkerke(defaultmodel)
# the value is way lower than 0.5, hence the actual values are far away very from the regression line 

#the ROCR curve
cpred_df = round(predict(defaultmodel, newdata = train.credit, type = "response"))
ROCRpred = prediction(predictions = cpred_df, labels = train.credit$default)
ROCRperf = performance(prediction.obj = ROCRpred, "tpr", "fpr")

plot(ROCRperf, colorize = TRUE, print.cutoffs.at = seq(0.1, by = 0.1))

# max = which.max(slot(ROCRper, "y.values")[[1]])
# max
# acc = slot(ROCRper, "y.values")[[1]][max]
# cut = slot(ROCRper, "x.values")[[1]][max]
# print(c(accuracy = acc, cutoff = cut))

