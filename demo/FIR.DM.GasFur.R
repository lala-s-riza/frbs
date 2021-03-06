library(frbs)

## Input data
data(frbsData)
data.train <- frbsData$GasFurnance.dt[1 : 204, ]
data.fit <- data.train[, 1 : 2]
data.tst <- frbsData$GasFurnance.dt[205 : 292, 1 : 2]
real.val <- matrix(frbsData$GasFurnance.dt[205 : 292, 3], ncol = 1)
range.data <- matrix(c(-2.716, 2.834, 45.6, 60.5, 45.6, 60.5), nrow=2)

## Set the method and its parameters
control <- list(num.labels = 5, max.iter = 1000, step.size = 0.01, name = "GasFur", type.tnorm = "MIN", 
                type.snorm = "MAX", type.implication.func = "ZADEH")  
method.type <- "FIR.DM"

## Generate fuzzy model 
object <- frbs.learn(data.train, range.data, method.type, control)

## Fitting step
res.fit <- predict(object, data.fit)

## Predicting step
res.test <- predict(object, data.tst)

## Error calculation
y.pred <- res.test
y.real <- real.val
bench <- cbind(y.pred, y.real)
colnames(bench) <- c("pred. val.", "real. val.")
print("Comparison FIR.DM Vs Real Value on Gas Furnace Data Set")
print(bench)

residuals <- (y.real - y.pred)
MSE <- mean(residuals^2)
RMSE <- sqrt(mean(residuals^2))
SMAPE <- mean(abs(residuals)/(abs(y.real) + abs(y.pred))/2)*100
err <- c(MSE, RMSE, SMAPE)
names(err) <- c("MSE", "RMSE", "SMAPE")
print("FIR.DM: Error Measurement: ")
print(err) 

## Comparing between simulation and real data
op <- par(mfrow = c(2, 1))
x1 <- seq(from = 1, to = nrow(res.fit))
result.fit <- cbind(data.train[, 3], res.fit)
plot(x1, result.fit[, 1], col="red", main = "Gas Furnance: Fitting phase (the training data(red) Vs Sim. result(blue))", type = "l", ylab = "CO2")
lines(x1, result.fit[, 2], col="blue")

result.test <- cbind(real.val, res.test)
x2 <- seq(from = 1, to = nrow(result.test))
plot(x2, result.test[, 1], col="red", main = "Gas Furnance: Predicting phase (the Real Data(red) Vs Sim. result(blue))", type = "l", ylab = "CO2")
lines(x2, result.test[, 2], col="blue", type = "l")

par(op)

