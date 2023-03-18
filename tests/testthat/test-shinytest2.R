library(shinytest2)

test_that("{shinytest2} recording: tab1_test_should_pass", {
  app <- AppDriver$new(name = "tab1_test_should_pass", height = 814, width = 1015, load_timeout = 100000)
  app$set_inputs(nhood = character(0))
  app$set_inputs(crimetype = character(0))
  app$expect_values()
})


test_that("{shinytest2} recording: tab3_test_should_pass", {
  app <- AppDriver$new(variant = platform_variant(), name = "tab3_test_should_pass", 
      height = 857, width = 1406, load_timeout = 100000)
  app$set_inputs(nhood = character(0))
  app$set_inputs(tab1 = "Learn More")
  app$expect_values()
  app$expect_screenshot()
})
