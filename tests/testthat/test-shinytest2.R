library(shinytest2)

test_that("{shinytest2} recording: number_crimes", {
  app <- AppDriver$new(variant = platform_variant(), name = "number_crimes", height = 857, 
      width = 1406)
  app$set_inputs(nhood = c("Arbutus Ridge", "Central Business District", "Dunbar-Southlands", 
      "Fairview"))
  app$set_inputs(crimetype = c("Break and Enter Residential/Other", "Mischief", "Other Theft", 
      "Theft from Vehicle", "Theft of Bicycle", "Theft of Vehicle", "Vehicle Collision or Pedestrian Struck (with Fatality)", 
      "Vehicle Collision or Pedestrian Struck (with Injury)"))
  app$expect_values()
  app$expect_screenshot()
})


test_that("{shinytest2} recording: crime_map", {
  app <- AppDriver$new(variant = platform_variant(), name = "crime_map", height = 857, 
      width = 1406)
  app$set_inputs(nhood = c("Arbutus Ridge", "Central Business District"))
  app$set_inputs(crimetype = c("Break and Enter Commercial", "Break and Enter Residential/Other", 
      "Other Theft", "Theft from Vehicle", "Theft of Bicycle", "Theft of Vehicle", 
      "Vehicle Collision or Pedestrian Struck (with Fatality)", "Vehicle Collision or Pedestrian Struck (with Injury)"))
  app$set_inputs(crimetype = c("Break and Enter Commercial", "Break and Enter Residential/Other", 
      "Theft from Vehicle", "Theft of Bicycle", "Theft of Vehicle", "Vehicle Collision or Pedestrian Struck (with Fatality)", 
      "Vehicle Collision or Pedestrian Struck (with Injury)"))
  app$expect_values()
  app$expect_screenshot()
})


test_that("{shinytest2} recording: year_2003", {
  app <- AppDriver$new(variant = platform_variant(), name = "year_2003", height = 857, 
      width = 1406)
  app$set_inputs(year = c(2003, 2003))
  app$expect_values()
  app$expect_screenshot()
})
