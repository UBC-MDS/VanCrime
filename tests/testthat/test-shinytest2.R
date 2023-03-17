library(shinytest2)

test_that("{shinytest2} recording: test_tab2", {
  app <- AppDriver$new(name = "test_tab2", height = 811, width = 1014, load_timeout=100000)
  app$set_inputs(tab1 = "Number of crimes")
  app$expect_values()
})


test_that("{shinytest2} recording: test_tab1", {
  app <- AppDriver$new(name = "test_tab1", height = 811, width = 1014, load_timeout=100000)
  app$expect_values()
})


test_that("{shinytest2} recording: test_tab3", {
  app <- AppDriver$new(name = "test_tab3", height = 811, width = 1014, load_timeout=100000)
  app$set_inputs(tab1 = "Learn More")
  app$expect_values()
})
