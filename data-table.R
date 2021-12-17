library(data.table)

# Load the SO 2021 survey data results:
so_survey <- fread("survey_results_public.csv")

# data.table syntax: mydt[i, j, by]
# Interpret as: mydt[row operations, col operations, group by]
# For example, in relation to the `{tidyverse}` syntax:
#  mydt[filter, select, group_by]

# To select the column ResponseId and return as data.table:
so_survey[, .(ResponseId)]

# To select multiple columns, separate them with commas:
so_survey[, .(ResponseId, MentalHealth, ConvertedCompYearly)]

# To filter row(s) where ResponseId is 1:
so_survey[ResponseId == 1]

# You can add more conditions to the filter using `|` and `&`:
so_survey[ResponseId == 1 | ResponseId == 2]

# Filter where ResponseId is 1 & select interested columns:
so_survey[ResponseId == 1, .(Ethnicity, Accessibility)]

# Highlight: When you do `mydt[, .(col1, col2)]` the `.` is actually a short hand
# notation for `list`. That means you can also do: `mydt[., list(col1, col2)]`,
# but using `.` saves a few keystrokes.
so_survey[, list(Ethnicity, Accessibility)]

# If the names of the columns you want to select are in a variable, say:
my_cols <- c("US_State", "EdLevel", "LearnCode", "CompFreq", "Trans")

# This won't work: `so_survey[, my_cols]`
so_survey[, my_cols]

# Neither will this:
so_survey[, .(my_cols)]

# To select the columns in `my_cols` use:
so_survey[, ..my_cols]

# Think of it as the two dots in a unix command line terminal; they move you
# up one directory. In data.table, they move you up one namespace; from
# data.table ns to global env.

# You can get the total number of rows using:
so_survey[, .N]
nrow(so_survey)

# `.N` stands for the number of rows

# ----add columns----
# Say we want to add a column `Hobbyist` showing whether that person codes
# primarily as a hobby. That can be derived from the column `MainBranch` and
# done as follows:
so_survey[, Hobbyist := {MainBranch == "I code primarily as a hobby"}]

# Let's check if that worked:
so_survey[, .(Hobbyist)]
# Alright!

# Note: The `:=` passes by reference and therefore `so_survey` is modified in
# place.
# To pass by value (& hence not modify the original object) you have to call
# `copy()` explicitly:
# ****

# ----by----
# We can now finally use the `by` arg.
# Say we want to group by Hobbyist and get the count of each group:
so_survey[, .N, Hobbyist]

# To order the count from the least to the largest:
so_survey[, .N, Hobbyist][order(N)]


# Let's add two more columns to `so_survey`; whether an RUser or PythonUser:
so_survey[, PythonUser := ifelse(LanguageHaveWorkedWith %like% "Python", TRUE, FALSE)]

# Note: `%like%` is a pattern matching infix operator

so_survey[, RUser := ifelse(LanguageHaveWorkedWith %like% "\\bR\\b", TRUE, FALSE)]

# `\\b` represents word boundary. A word boundary is a position that is either
# preceded by a word character and not followed by one or followed by a word
# character and not preceded by one.

# We can add the two columns at once by calling the walrus operator `:=` as a
# function:
so_survey[, `:=`(
  PythonUser = ifelse(LanguageHaveWorkedWith %like% "Python", TRUE, FALSE),
  RUser = ifelse(LanguageHaveWorkedWith %like% "\\bR\\b", TRUE, FALSE)
)]

# ---%between%----
so_survey[Currency %in% "USD\tUnited States dollar" & CompTotal %between% c(50000, 100000)]
# between(x, lower bound, upper bound)

# ----%chin%----
# Same as base R's %in% but optimized & can only be used for char vectors:
so_survey[Country %chin% c("Kenya", "India")]

# ----fcase----
# `fcase()` is similar to `dplyr::case_when`:
so_survey[, Language := fcase(
  RUser & PythonUser, "Both",
  RUser & !PythonUser, "R",
  !RUser & PythonUser, "Python",
  !RUser & !PythonUser, "Neither"
)]


so_survey[i = !is.na(ConvertedCompYearly) &
            Currency %in% "USD\tUnited States dollar",
          j = .(AvgSalary = mean(ConvertedCompYearly)),
          by = Language][order(-AvgSalary)]


# ----discard rows----
DT <- data.table(
  a = 1:10,
  b = 11:20,
  c = letters[1:10],
  d = rep(LETTERS[1:5], times = 2)
)
DT[!7:10]
DT[-(7:10)]
DT[-c(7:10)]

# ----discard columns----
DT[, !(1:2)]
DT[, !c(1:2)]
DT[, !c("a", "d")]

# You can discard them completely:
DT[, c("a", "d") := NULL]

# ----unique----
DT <- data.table(
  a = 1:10,
  b = 11:20,
  c = letters[1:10],
  d = rep(LETTERS[1:5], times = 2)
)

unique(DT, by = "d")


# ----bang bang----
library(data.table)
DT <- data.table(
  ID = c("b","b","b","a","a","c"),
  a = 1:6,
  b = 7:12,
  c = 13:18
)

DT

ID <- "b"

DT |> dplyr::filter(ID == !!ID)

DT[ID == as.name(ID)]
DT[, .SD[ID == ..ID]]

