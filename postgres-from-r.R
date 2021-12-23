library(shiny)
library(DBI)
library(pool)
library(tidyverse)

pool <- dbPool(
  drv = RPostgres::Postgres(),
  host = "localhost",
  port = 5432,
  dbname = "***",
  user = "***",
  password = "***"
)

# Create an empty table "iris" in the database:
dbCreateTable(pool, name = "iris", fields = iris)

# List tables in the database:
dbListTables(pool)

# To remove the table:
dbRemoveTable(conn = pool, name = "iris")

dbListTables(conn = pool)

# To write "iris" and it's contents:
dbWriteTable(conn = pool, name = "iris", value = iris)

dbListTables(conn = pool)

# Get tables from the DB:
ir <- tbl(src = pool, "iris")
ir
str(ir)
nrow(ir)

ir |> show_query()

# All dplyr calls are lazily evaluated, generating sql code that is sent to the
# DB only when you request the data:
res <- ir |>
  group_by(Species) |>
  summarise(across(.cols = colnames(ir)[-5], .fns = mean))

# Show query:
res |> show_query()

# Execute query and retrieve results:
res |> collect()

# To execute a query make sure you `collect()`

# All rows where Sepal.Length > 5:
ir |> filter(Sepal.Length > 5) |> collect()

# mutate:
mutate_cols <- ir |> mutate(new_col = Sepal.Length + Sepal.Width) |> collect()
mutate_cols

# schemas----
# I have a schema called myschema table "iris".
from_schema <- tbl(
  src = pool,
  in_schema(schema = sql("myschema"), table = sql("iris"))
)

from_schema |> show_query()

from_schema |> collect()

# we can perform normal operations on the tables:
list(
  tbl(src = pool, in_schema(schema = sql("myschema"), table = sql("iris"))) |>
    collect(),
  tbl(src = pool, "iris") |> collect()
)

# Note that this doesn't create "mtcars" in "myschema":
dbWriteTable(conn = pool, name = "myschema.mtcars", value = mtcars)

# it creates a table called "myschema.mtcars" in schema public:
dbListTables(conn = pool)

dbRemoveTable(conn = pool, name = "myschema.mtcars")

dbListTables(conn = pool)

# To create "mtcars" table in schema "myschema" use DBI's `dbWriteTable()` and
# `SQL()` commands:
dbWriteTable(
  conn = pool,
  name = SQL("myschema.mtcars"),
  value = mtcars
)

dbListTables(conn = pool)

# To access the table:
mtcars1 <- tbl(
  src = pool,
  in_schema(schema = sql("myschema"), table = sql("mtcars"))
)

mtcars1 |> collect()

# Write ToothGrowth table in myschema:
dbWriteTable(
  conn = pool,
  name = SQL("myschema.toothgrowth"),
  value = ToothGrowth
)

tg <- tbl(
  src = pool,
  in_schema(schema = sql("myschema"), table = sql("toothgrowth"))
)

tg |> collect()
