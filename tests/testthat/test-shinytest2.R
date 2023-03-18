library(shinytest2)

test_that("{shinytest2} recording: tab1_with_all_no", {
  app <- AppDriver$new(name = "tab1_with_all_no", height = 857, width = 1406, load_timeout = 100000)
  app$set_inputs(year = c(2003, 2003))
  app$set_inputs(nhood = character(0))
  app$set_inputs(crimetype = character(0))
  app$expect_values()
})
