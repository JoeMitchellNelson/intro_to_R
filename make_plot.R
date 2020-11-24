# Much of the utility of R is in its packages, so we first want to install a package manager.
# I like pacman.

# To execute a single line of code, put your cursor on that line and click ctrl-enter.
# Execute the line below the install pacman.

install.packages("pacman")

# Then we need to tell R we want to use pacman in the current R session.

library(pacman)

# R now knows the function p_load(). 
# If we pass names of other packages to p_load(), R will install those packages only if they aren't already installed.

p_load(tidyverse,lubridate)

# Tidyverse is actually a suite of packages, including dplyr and ggplot2.
# Read more about Tidyverse here: https://www.tidyverse.org/packages/
# Lubridate handles dates and times.
# Read more about lubridate here: https://rawgit.com/rstudio/cheatsheets/master/lubridate.pdf

# Let's read in some data and graph it.
# The function read.csv() reads in csv (comma separated values) files for use in R.
# The line of code below stores the data in an object called dat, using a little arrow (<-)
# Note the ~ in the file name below. This tells R to look for the file in the current working directory.
# You can check your current working directory with getwd()

dat <- read.csv("~/intro_to_R/tp.csv")

# Let's look at what we've got.
# You can click dat in the upper right panel, or run the line below.

View(dat)

# tp.csv is a file I downloaded from google trends showing search interest for "toilet paper" over time
# It should have two variables, one for time and one for search interst.
# But we only have one variable, with the time variable stored as row names instead of data.
# Let's take a look at the raw file to see what went wrong.
# Click the "Files" tab in the bottom right panel, click on tp.csv, then click "View file"

# Now we see the problem: there are two extra lines at the top of our file: a title and then a blank line.
# This is a common issue, since lots of data files will include a header like this one.
# We can get around the problem by altering our code to skip the header:

dat <- read.csv("~/intro_to_R/tp.csv", skip=2)

# The option skip=2 tells R to skip the first two lines in the csv file.
# Note that we've assigned this fixed data to the same object, "dat."
# This overwrites the data that was previously stored in "dat."

# Let's check the variable names in our data
names(dat)

# That second variable name is kind of ugly, but we can change it.
# The [2] tells R we only want to re-assign the second variable name in dat.

names(dat)[2] <- "interest"

# Check that it worked:

names(dat)

# Nice. A convenient way to preview data is the head() function, which prints the first six observations:

head(dat)

# Let's check the class of the first column.
# The $ operator indicates we want to pick out a column in a data frame.

class(dat$Week)

# It's a factor, but we want R to interpret it as a date object.
# Let's use lubridate to change the Week variable into something R can understand

dat$Week <- ymd(dat$Week)

# We're replacing the column Week with a modified version of the same column.
# The function ymd() converts the variable to a date object, provided that the original variable is in year-month-day order.
# (If our variable was in month-day-year format, we would use mdy().)

class(dat$Week)

# Now we've got a date object.

# Finally, let's use ggplot() to graph our data.
# Here are a bunch of ways we might do that.

# We'll start with a barebones plot, which will appear in the bottom right panel.
ggplot(dat) +
  geom_point(aes(x=Week,y=interest))

# Maybe we want a line instead of points
ggplot(dat) +
  geom_line(aes(x=Week,y=interest))

# And we can use a built-in theme to get rid of the grey background
ggplot(dat) +
  geom_line(aes(x=Week,y=interest)) +
  theme_minimal()

# ggplot is using the variable names as axis titles, but we can override that
ggplot(dat) +
  geom_line(aes(x=Week,y=interest)) +
  labs(x="Time",y="Google search interest",title="The Great COVID-TP Scramble") +
  theme_minimal()

# Let's add some color and make the line a little thicker. 
# ggplot understands many color names, but you can also use RGB hex codes.
# to see a list of valid color names, run colors()

ggplot(dat) +
  geom_line(aes(x=Week,y=interest),color="limegreen",size=2) +
  labs(x="Time",y="Google search interest",title="The Great COVID-TP Scramble") +
  theme_minimal()

# One way to save our plot is the Export button in the bottom right panel
# but that typically produces a low-res image
# Instead, we can use the function ggsave() to save an image that isn't so grainy
# the dpi option allows you to control the resolution
# replace "FILENAME" with a file name for your plot

ggsave("~/intro_to_R/FILENAME.png",last_plot(),dpi=300,height=4,width=4,units="in")
