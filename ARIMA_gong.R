library(forecast)
tsvalues = Galaxy_5_Year_Timeline$Samsung.Galaxy...United.States.

tsvalues = as.matrix(tsvalues)

myts <- ts(tsvalues, start=c(2014, 6, 4), end=c(2019, 31, 3 ), frequency=52)

?ts

plot(myts)


fit <- stl(myts, s.window="period")
plot(fit)


monthplot(myts)

pacf(myts)


acf(myts)


seasonplot(myts)


fit <- auto.arima(myts)
summary(fit)


plot(fit)

decomposed <- decompose(myts, type="mult")

plot(decomposed)

stlRes <- stl(myts, s.window = "periodic")

plot(stlRes)




forecast(fit, 30)
plot(forecast(fit, 30))


?plot

accuracy(fit)
