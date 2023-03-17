library(shinytest2)

test_that("{shinytest2} recording: should_return_empty_map", {
  app <- AppDriver$new(name = "should_return_empty_map", height = 857, width = 1406, load_timeout=100000)
  app$set_inputs(crimetype = character(0))
  app$expect_values()
})


test_that("{shinytest2} recording: should_return_correct_map", {
  app <- AppDriver$new(variant = platform_variant(), name = "should_return_correct_map", 
      height = 857, width = 1406, load_timeout=100000)
  app$set_inputs(nhood = character(0))
  app$expect_values()
  app$expect_screenshot()
})


test_that("{shinytest2} recording: should_return_correct_tab3", {
  app <- AppDriver$new(name = "should_return_correct_tab3", height = 857, width = 1406, load_timeout=100000)
  app$set_inputs(nhood = character(0))
  app$set_inputs(tab1 = "Learn More")
  app$expect_values()
})
