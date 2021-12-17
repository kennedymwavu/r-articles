library(tidyverse)

Sys.setenv(`_R_USE_PIPEBIND_` = TRUE)

# Estimate pi

# Number of darts; 1000
dart_count <- 1e6

# Number of darts that've landed inside the circle:
darts_in_circle <- 0

# Now we need a randomly generated x & y axis each btwn -1 & 1.
# For that we're going to use `runif()` since it generates randomly distributed numbers
# btwn a min and max value.

# Define x & y coordinates for one dart:
x <- runif(n = 1, min = -1, max = 1)
y <- runif(n = 1, min = -1, max = 1)

# So far we've only generated x & y values for one dart. To generate for 1000 dart throws,
# we can wrap the above code in a for loop and check whether each throw fell inside
# the circle or not:
for (i in 1:dart_count) {
  x <- runif(n = 1, min = -1, max = 1)
  y <- runif(n = 1, min = -1, max = 1)

  if (x**2 + y**2 <= 1) {
    darts_in_circle <- darts_in_circle + 1
  }
}

# We can now get our estimate of pi:
4 / (1**2 * dart_count / darts_in_circle)


# Let's do that in a more R way:
# ---vectors----
x <- runif(n = dart_count, min = -1, max = 1)
y <- runif(n = dart_count, min = -1, max = 1)

darts_in_circle <- {x**2 + y**2 <= 1} |> sum()

pi_estimate <- 4 * darts_in_circle / dart_count
pi_estimate

# ----dataframes----
pi_df <- tibble(
  x = runif(n = dart_count, min = -1, max = 1),
  y = runif(n = dart_count, min = -1, max = 1),
  darts_in_circle = x**2 + y**2 <= 1
)

pi_df |>
  summarise(
    darts_in_circle = sum(darts_in_circle),
    pi_estimate = 4 * darts_in_circle / dart_count
  )

# ----plot----
# All random points should intuitively make up something like a square when plotted:
# pi_df |>
#   ggplot(mapping = aes(x = x, y = y)) +
#   geom_point()

# And it does!

pi_df |>
  filter(darts_in_circle) |>
  ggplot(mapping = aes(x = x, y = y)) +
  geom_point()


circle_darts <- pi_df |>
  filter(darts_in_circle) |>
  select(-darts_in_circle)
esee
plot(circle_darts$x, circle_darts$y)
