library(knitr)
library(RWordPress)

# v0*8^!n&EK#cvms4

options (WordpressLogin = c (codemwavu = 'v0*8^!n&EK#cvms4'),
         WordpressURL = 'codebible.io/xmlrpc.php')

# upload all images to imgur.com:
opts_knit$set(upload.fun = imgur_upload, base.url = NULL)

opts_chunk$set(cache = TRUE)

postTitle <- "Customize Selectize Options in R Shiny"
fileName <- "selectize_options.Rmd"

postID <- knit2wp(
  input = fileName,
  title = postTitle,
  publish = FALSE,
  action = "newPost"
)

