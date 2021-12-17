library(tidyverse)
library(data.table)

df <- data.frame(
  transaction = c("a","a", "b", "b","b"),
  product = c("c", "d","e","f","g")
)

df %>%
  group_by(transaction) %>%
  summarise(prduct = paste(product, collapse=","))

DT <- data.table(df)

DT[, .(prd = paste(product, collapse = ",")), keyby = .(transaction)]
DT[, prd := paste(product, collapse = ","), keyby = .(transaction)]

ir <- data.table(iris)
ir[, twice := Sepal.Length * 2]
ir

myvar <- "thrice"
ir[, myvar := Sepal.Length * 3]
ir

ir[, c(myvar) := Sepal.Length * 3]
ir

ir[, c("myvar") := NULL]
ir

ir[, c("twice", "thrice") := NULL]
ir

myvar <- c("twice", "thrice")

ir[, c(myvar) := .(Sepal.Length * 2, Sepal.Length * 3)]
ir

ir[, list(Sepal.Length, Species)]


DT <- data.table(mtcars)
DT
DT[, mileage_type := ifelse(mpg > 20, "High", "Low")]
DT
DT[, .(mean_mileage = mean(mpg)), keyby = .(cyl)]
DT[, mean_mileage := mean(mpg), keyby = .(cyl)]
DT

# Select the first occurring value of mpg for each unique cyl
DT[, .(first_mileage = mpg[1]), keyby = .(cyl)]

# And what about the last value?
DT[, .(last_mileage = mpg[length(mpg)]), keyby = .(cyl)]
DT[, .(last_mileage = mpg[.N]), keyby = .(cyl)]

# .N contains the number of rows present ie. count
# So to get the number of rows for each unique value of cyl:
DT[, .N, keyby = .(cyl)]

# .I returns the row numbers
DT[, .I]

# To return row numbers where cyl is 6:
DT[, .I[cyl == 6]]
DT[, which(cyl == 6)]
DT[, .I[cyl == 8]]


# Compute the number of cars and the mean mileage for each gear type
DT[, .(number_of_cars = .N, mean_mileage = mean(mpg)), keyby = .(gear)]

# Chaining:
DT[,
   .(
     mean_mpg = mean(mpg),
     mean_disp = mean(disp),
     mean_wt = mean(wt),
     mean_qsec = mean(qsec)
   ),
   keyby = .(cyl)
   ][
     order(-cyl)
   ]


# .SD is basically a data.table containing all columns in DT except the ones
# used in keyby or by
# compute mean of all variables grouped by cyl as above but using .SD:
DT[, lapply(.SD, FUN = mean), .SDcols = c("mpg", "disp", "wt", "qsec"), keyby = .(cyl)]

# You can also do:
DT[, lapply(.SD, FUN = mean), .SDcols = setdiff(colnames(DT), c("mileage_type", "cyl")), keyby = .(cyl)]

# Joins
# dt1 <- DT[5:25, .()]
