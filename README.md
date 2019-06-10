# Identifying risky loans using logistic regression

===================================================



The project aims at building logistic regression model that identifies risky loan (1 for good loan and 2 for bad loan) from bank details of its sampled 1000 customers.

>The model produced the formula below to identify whether a loan is risky or not. If 1 then good loan, otherwise bad: ![formula](https://latex.codecogs.com/gif.latex?%24%24P%20%3D%20round%5Cleft%28%20%5Cfrac%7B%28exp%5B2.808-%200.0001152208%20%5Ctimes%20amount%5D%29%7D%7B%281%20&plus;%20exp%5B2.808-%200.0001152208%20%5Ctimes%20amount%5D%29%7D%5Cright%29%24%24)



Here are the visuals of the variables from the dataset developed by _creditData-insights.pbix_ file.

![Image](https://github.com/Elaine-AL/Riskyloan_regression/blob/master/visualization%201.PNG)
![Image](https://github.com/Elaine-AL/Riskyloan_regression/blob/master/visualization%202.PNG)

Here is a distribution of the amount of loan on whether it was classified as a bad (2) or good(1) loan by the bank.
![Image](https://github.com/Elaine-AL/Riskyloan_regression/blob/master/amount%20of%20loan.png)

The logit regression model produces a 2-shaped sigmoid curve below produced by the **glm() function** in **R** as seen in the _credit-logistic.R_ file or _credit_logisticAnalysis.Rmd_ file. 

![Image](https://github.com/Elaine-AL/Riskyloan_regression/blob/master/amount%20of%20loan%20regression%20model.png)

It is seen that most low amounts of loan (**less than 3000**) are considered good loan, while above **15000** is considered bad loan.
