library(shinytest2)

test_that("{shinytest2} recording: should_return_empty", {
  app <- AppDriver$new(name = "should_return_empty", height = 811, width = 1014, load_timeout = 100000)
  app$set_inputs(nhood = character(0))
  app$expect_values()
})
