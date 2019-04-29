library(ggplot2)
library(ggthemes)
library(reshape2)
library(RColorBrewer)

# Change this to reflect local path to file 
directory.to.path <- "C:/Users/jdbul/Documents/Github/Galaxy-Line-Time"

file <- "forecast_results.csv"
filepath <- paste(directory.to.path,file, sep = '/')

data <- read.csv(filepath)
data$Time <- seq.int(nrow(data))


data_long <- melt(data, id="Time")  # convert to long format


p <- ggplot(data_long, aes(x = Time, y = value, colour=variable)) + geom_line(aes(size=variable)) +
  geom_point(aes(size=variable)) +
  scale_x_discrete(name ="Time", limits=c(1:12)) +
  scale_y_continuous(name="Search Trend Index") +
  ggtitle('Forecast Results for "Samsung Galaxy" Google Search Levels')


p + geom_rangeframe() +
  theme_tufte() + scale_size_manual(values = c(1.5,1,1,1,1), guide='none') +
  scale_color_manual(values=c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#003300"), name="Model", labels = c("Actual Data", "ARIMA(0,1,1)x(1,1,0)", "ARIMA(1,1,1)x(1,1,0)","Classical Decomposition", "Holt-Winters Smoothing"))+ theme( axis.line = element_line(colour = "black", size=0.7))


p + geom_rug() +
  theme_tufte(ticks=FALSE) + scale_size_manual(values = c(1.5,1,1,1,1), guide='none') +
  scale_color_manual(values=c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#003300"), name="Model", labels = c("Actual Data", "ARIMA(0,1,1)x(1,1,0)", "ARIMA(1,1,1)x(1,1,0)","Classical Decomposition", "Holt-Winters Smoothing"))





