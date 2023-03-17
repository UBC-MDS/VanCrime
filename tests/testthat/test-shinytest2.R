library(shinytest2)

test_that("{shinytest2} recording: test_tab1_empty_map", {
  app <- AppDriver$new(name = "test_tab1_empty_map", height = 857, width = 1406, load_timeout = 100000)
  app$set_inputs(crimetype = character(0))
  app$expect_values()
})
