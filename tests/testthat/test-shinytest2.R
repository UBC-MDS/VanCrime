library(shinytest2)

test_that("{shinytest2} recording: should_show_no_map_t1", {
  app <- AppDriver$new(name = "should_show_no_map_t1", height = 857, width = 1406, load_timeout=100000)
  app$set_inputs(crimetype = character(0))
  app$expect_values()
})
