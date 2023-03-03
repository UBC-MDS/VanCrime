# Reflections: 2023-03-03 (Updated 2023-03-03)

## App Strengths
- The app utilizes interactive widgets, such as sliders and picker inputs, that enable users to filter data based on their interests. This allows users to select the year range, neighborhoods, and types of crimes they want to explore.
- The app offers multiple visualization options based on user selections. For instance, users can visualize the trend of the total number of crimes in different neighborhoods, the number of crimes by type, and the total number of crimes by hour.
- The app provided map for visualization. This allow us to create interactive plots that allow the user to hover over data points and see detailed information. In addition, we use thematic to enhance the aesthetics of the dashboard, resulting in a more professional and visually appealing interface.
- Crime trend chart easily allows user to dive deeper into a neighbourhood's crime changes across year. Multiple neighbourhoods can also be compared to see trends within each.
- Dashboard layout is simple and doesn't overhwlem the user.

## App Weaknesses
- One weakness of our dashboard is that it can be difficult to differentiate between neighbourhoods on the map as their size is not immediately visible. Users need to hover their mouse over each neighbourhood to see its size. To address this, we could consider making the neighbourhoods static so that their sizes are visible at all times.
- Another limitation of our map plot is that it currently lacks a two-way binding with the widget, which would allow users to directly filter the data on the map and see its effect on the other plots.


## Future Improvements
- To enhance user experience, we can implement a two-way binding feature for our map plot and the filtering widget. This will enable users to directly filter data on the map and see the immediate effects on the rest of the plot.
- Currently, the crime map is showing all crimes in the selected neighbourhood and time range, which can be overwhelming for users. Consider adding filters or options to the map to allow users to select specific crime types or time periods.