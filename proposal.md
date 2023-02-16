# Proposal

# Section 1: Motivation and Purpose

**Our role**: Data Analytics Team in the Vancouver Police Department

**Target audience**: Law enforcement officers and residents of Vancouver

Even though criminal activity is unfortunately unavoidable, there is no question that it is putting the residents' quality of life in jeopardy and harming the reputation of the community. This is especially true for those residents who are younger. It has a strong connection to both the economy of a city and the general well-being of the community.

We believe that if we are able to identify the geospatial and temporal factors that are associated with a high risk of crime, the police force will be able to more effectively prevent criminal actions through the implementation of improved patrol strategies or technological surveillance systems. At the same time, residents will be better informed and educated, taking the right precautions to improve the safety and security of the area. This will be a win-win situation for everyone involved.

We are in the process of building a dashboard that will display historical crime data in the hopes that this will result in a reduction in the amount of criminal activity that takes place as a direct result of our efforts to prevent it. The information will be arranged in a manner that takes into account the different types of criminal behavior, as well as the time periods and neighborhoods involved. It is important to note that the purpose of this dashboard is not to label any specific area of Vancouver with a negative connotation, but rather to educate and inform the residents of the city as well as the security officers who are responsible for maintaining the safety of the city. Customers of this dashboard will be able to glean insights from it that will enable them to be better informed when visiting a specific neighborhood at a specific time during the day. At the same time, law enforcement will be able to monitor the progress of their initiatives and direct the appropriate resources to the locations where they are needed.

# Section 2: Description of Data

We are going to visualize a [dataset](https://geodash.vpd.ca/opendata/) provided by the Vancouver Police Department (VPD) that contains data on crimes that occurred between the years 2003 and 2022. It includes somewhere around 85,000 entries in total. VPD has released this data under the Creative Commons Public Domain Dedication License [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

-   Each of the entries represents a criminal act that occurred at a particular location and at a particular time.

-   Each crime has 10 associated variables that describe the crime type (`TYPE`), date/time (`YEAR`, `MONTH`, `DAY`, `HOUR`, `MINUTE`), and the location (`HUNDRED_BLOCK`, `NEIGHBOURHOOD`, `X` and `Y`).

-   The dataset contains information on eleven distinct types of criminal activity. "X" and "Y" are coordinate values that have been projected into the Universal Transverse Mercator (UTM) zone 10 coordinate system. There is some information regarding locations that is lacking. This is in part due to concerns about the individual's right to privacy.

The data do not include any information that could be used to personally identify anyone. The locations of incidents that were reported to involve offenses committed against a person have been purposefully mixed up across several blocks and shifted to a different intersection. Regarding these infractions, neither the time nor the street location were disclosed. When it comes to crimes against property, the Vancouver Police Department (VPD) has provided the location of these incidents within the general vicinity of the hundred block of the block.

# Section 3: Research questions and usage scenarios

Below is an example usage scenario.

Jonathan is a police officer who focuses on patrolling and preventing criminal activity. When he is using our dashboard, he will be able to get a high-level view of the ways in which the total number of crimes committed in the city of Vancouver has evolved over the course of the years. Jonathan will be able to view the geospatial distribution of previous acts of criminality, which will allow him to assess the current deployment of manpower as well as the potential for criminal activity in each neighborhood. When Jonathan wants to make adjustments on the patrol schedule based on the risk of crime, a line plot will show the average number of crimes that have occurred across the course of an entire day. In the event that Jonathan feels the need to zero in on a particular category of criminal activity, he can make use of the drop-down menu contained within the widget to formulate a more specific hypothesis regarding the illegal activities. Jonathan will be able to select the time frame of the presented data by using a similar widget. Jonathan has a sneaking suspicion that the appearance of Covid-19 in the year 2020 is to blame for the steady increase in the number of reported crimes that have occurred since that year. Jonathan has a hunch that the appearance of Covid-19 in the world in 2020 is to blame for the rise in the overall number of crimes since that year. In addition, on the basis of his observations, he draws the conclusion that the central business district has been the scene of an increased number of criminal acts. The dashboard that we have allows for an in-depth examination to be carried out.
