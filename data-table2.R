library(tidyverse)
library(data.table)

# read in some data:
mydata = fread("https://github.com/arunsrinivasan/satrdays-workshop/raw/master/flights_2014.csv")

flights <- copy(mydata)

head(flights)

# select only origin column:
# - As a vector:
flights[, origin]

# - As data.table:
flights[, .(origin)]

# To select multiple columns, say origin, year, month & hour:
flights[, .(origin, year, month, hour)]

# Say they were in a variable:
toselect <- c("origin", "year", "month", "hour")
flights[, ..toselect]


# Dropping columns, say origin, year, month, hour:
flights[, !c("origin", "year", "month", "hour")]

# Say we had them in a variable:
todrop <- c("origin", "year", "month", "hour")
flights[, !..todrop]

# Let's see if a function would work:
dropcols <- function(DT, cols_to_drop) {
  DT[, !..cols_to_drop]
}

dropcols(DT = flights, cols_to_drop = todrop)
dropcols(DT = flights, cols_to_drop = c("origin"))

# Alright!

# Keep vars that contain "dep":
flights[, names(flights) %like% "dep", with = FALSE]

# subset vars containing "time":
flights[, names(flights) %like% "time", with = FALSE]


# Renaming vars, use setnames. Let's rename dest to destination:
setnames(flights, "dest", "destination")

flights[, .(destination)]

# Rename multiple columns:
setnames(
  flights, c("dep_time", "dep_delay"), c("departure_time", "departure_delay")
)

colnames(flights)

# Filtering
# filter all flights whose origin is "JFK":
flights[origin == "JFK"]

# filter all flights whose origin is either "JFK" or "LGA":
jfk_lga <- flights[origin %chin% c("JFK", "LGA")]

# confirm if that worked:
jfk_lga$origin |> unique()

# filter all flights whose origin is NOT "JFK" nor "LGA":
not_jfk_lga <- flights[!origin %chin% c("JFK", "LGA")]

# check if that worked:
not_jfk_lga$origin |> unique()

# Filter where origin is "JFK" and carrier is "AA":
flights[origin == "JFK" & carrier == "AA"]


# When you set key using `setkey()`, any filtering is done on the basis of that key:
setkey(flights, "origin")

# To get the set key:
key(flights)
haskey(flights)

# To filter where origin is "JFK":
flights["JFK"]

# To filter where origin is either "JFK" or "LGA":
flights[c("JFK", "LGA")]

# To remove key set it to null:
setkey(flights, NULL)

haskey(flights)

# Say you have the row values of a variable that you want to filter in a variable:
origin <- c("JFK", "LGA")

# You can filter them as follows:
flights[origin, on = "origin"]

# The syntax is something along the lines of:
# DT[row_value, on = c("variable")]

# And so to answer my own question on SO:
DT <- data.table(
  ID = c("b","b","b","a","a","c"),
  a = 1:6,
  b = 7:12,
  c = 13:18
)

ID <- c("a")

DT[ID, on = "ID"]

# You can also do:
flights[.("LGA", "JFK"), on = "origin"]

# Say we want to return arr_delay variable alone corresponding to origin = "LGA" and 
# destination = "TPA":
flights[.("LGA", "TPA"), .(arr_delay), on = .(origin, destination)]

# Using the command above, use chaining to order the column in decreasing order:
flights[.("LGA", "TPA"), .(arr_delay), on = .(origin, destination)][order(-arr_delay)]

# Find the max arrival delay corresponding to origin = "LGA" and dest = "TPA":
flights[.("LGA", "TPA"), max(arr_delay), on = .(origin, destination)]

# Take a look at all unique hours available in flights:
flights[, unique(hour) |> sort()]

# We see that both 0 and 24 are available. Let's replace 24 with 0:
flights[.(24L), hour := 0, on = .(hour)]

# Let's check if that worked:
flights[, unique(hour) |> sort()]

# Get the maximum departure delay for each month corresponding to origin = "JFK" and 
# order the result by month:
flights[.("JFK"), max(departure_delay), on = .(origin), keyby = .(month)]


# subset only the first matching row where destination matches "BOS" and "DAY":
flights[.(c("BOS", "DAY")), on = .(destination), mult = "first"]

# subset only the last matching row where origin matches "LGA", "JFK", "EWR" and 
# destination matches "XNA"
flights[.(c("LGA", "JFK", "EWR"), "XNA"), on = .(origin, destination), mult = "last"]

# From above note that the second row is just NAs meaning there was no match for 
# origin = "JFK" and destination = "XNA". 
# We can confirm that by:
flights[.("JFK", "XNA"), on = .(origin, destination)]

# You can supply a nomatch argument for when there are no matches:
flights[
  .(c("LGA", "JFK", "EWR"), "XNA"), 
  on = .(origin, destination), 
  mult = "last", nomatch = NULL
]
# Setting it to NULL omits those rows

flights[.("JFK", "XNA"), on = .(origin, destination), nomatch = NULL]

