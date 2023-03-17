library(shinytest2)

test_that("{shinytest2} recording: test_plot", {
  app <- AppDriver$new(name = "test_plot", height = 811, width = 1014)
  app$set_inputs(tab1 = "Number of crimes")
  app$expect_values()
})


test_that("{shinytest2} recording: test_map", {
  app <- AppDriver$new(name = "test_map", height = 811, width = 1014)
  app$expect_values()
})


test_that("{shinytest2} recording: test_tab3", {
  app <- AppDriver$new(name = "test_tab3", height = 811, width = 1014)
  app$set_inputs(tab1 = "Learn More")
  app$expect_values()
})
