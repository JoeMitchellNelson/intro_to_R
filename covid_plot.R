### Let's run a more interesting analysis ###

require(pacman)

p_load(tidyverse,lubridate,zoo,here)

# First, let's pull some covid-19 data from the new york times

nyt <- read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv")

cov <- read.csv(here::here("covid-19.csv"),skip=2)
names(cov)[2] <- "interest"
cov$interest <- as.character(cov$interest) %>% as.numeric()

head(nyt)

# change date variables to date class.
nyt$date <- ymd(nyt$date)
cov$Week <- ymd(cov$Week)


# we want to combine our two data sets into a single data frame, matched by date
# we use the function left_join() to accomplish that
# left_join takes the "left" data frame (nyt in the line below)
# and merges the "right" data frame (cov) into it
# we use the "by" option to match the dataframes by the two time variables
dat <- left_join(nyt,cov,by=c("date"="Week"))


# let's take a peek at our data
ggplot(dat) +
  geom_point(aes(x=date,y=deaths))

# this graph isn't what we expected--we want to see new deaths each day
# instead we have cumulative deaths over time
# we can use the diff() function to create the variable we want

dat$new_deaths <- c(NA,diff(dat$deaths))

# plot that
ggplot(dat) +
  geom_point(aes(x=date,y=new_deaths))

# this plot is better, but it's pretty messy
# we can see the trend a bit more clearly if we "smooth" the data
# by using a 7-day moving average
# rollmean() from the package zoo accomplishes this


dat$deaths_smoothed <- rollmean(dat$new_deaths,k=7,fill=NA)

# plot our smoothed data
ggplot(dat) +
  geom_point(aes(x=date,y=deaths_smoothed))

# looks much better
# now let's take a look at google search interest for Covid-19

ggplot(dat) +
  geom_point(aes(x=date,y=interest))

# possibly a similar shape?
# let's get both sets of data into the same plot to see if they follow similar patterns

ggplot(dat) +
  geom_point(aes(x=date,y=deaths_smoothed),color="red") +
  geom_point(aes(x=date,y=interest),color="blue")

# this isn't very useful. the search interest data (in blue) gets smushed to the bottom
# because the data sets use very different scales. Google normalizes trends data so that the
# highest value in a period is 100, whereas there are more than 2000 deaths on some days.
# so let's scale down the deaths data so that the highest value is also 100
# to do that, we divide the death data by the highest value in that column, and then multiply by 100

# what's the highest deaths value?

max(dat$deaths_smoothed)

# we got NA, which indicates a missing value.
# we introduced a few missing values when we smoothed our deaths data
# so when R searches for the maximum value, it decides that the "missing" observations
# might actually be the highest value (if only we knew that value)
# so it returns NA to indicate that the highest value is unknown
# you'll find similar behavior if you calculate the mean of the data, for example
# let's tell R to ignore NAs when it finds the maximum using the option "na.rm"

max(dat$deaths_smoothed,na.rm=T)


# now we can re-scale our deaths data and store it as a new variable

dat$deaths_rescaled <- (dat$deaths_smoothed*100)/max(dat$deaths_smoothed,na.rm=T)

ggplot(dat) +
  geom_point(aes(x=date,y=deaths_rescaled),color="red") +
  geom_point(aes(x=date,y=interest),color="blue")

# it looks like the spikes in search history actually *precede* the spikes in deaths
# what could cause this?

# cases cause deaths, and perhaps cases also cause search interest,
# giving the appearance that search interest is predictive of deaths
# let's compare search interest to case numbers instead of death numbers
# to test that hypothesis
# first we'll do the same transformation to the cases variable

dat$new_cases <- c(NA,diff(dat$cases))
dat$cases_smoothed <- rollmean(dat$new_cases,k=7,fill=NA)
dat$cases_rescaled <- (dat$cases_smoothed*100)/max(dat$cases_smoothed,na.rm=T)

ggplot(dat) +
  geom_point(aes(x=date,y=cases_rescaled),color="red") +
  geom_point(aes(x=date,y=interest),color="blue")

# we see cases peak in April, late July, and November
# but for each spike, we see search interest peaks a week or two earlier
# so much for our hypothesis

# what else might account for search interest increasing *before* cases and deaths?
# are experts accurately predicting covid spikes and people are listening?
# is it the so-called "wisdom of crowds"?
# cases and deaths are not reported immediately, so maybe there's a lag in the covid data but not in the search interest data?
# I don't have an answer.

