# Proposal

# Section 1: Motivation and Purpose

Our role: Data Analytics Team in the Vancouver Police Department

Target audience: Police Officers and executives

While crime is unfortunately inevitable, it is undoubtedly jeopardizing residents’ quality of life and harming the community’s reputation. It is highly linked to a city’s economy and the community’s welfare. We believe identifying geospatial and temporal factors associated high risk of crime will assist the police force to better prevent criminal actions by better patrol strategies or installation of surveillance technologies. With the goal of minimizing crime by preventing it, we are building a dashboard to present historical crime data sorted by time, neighborhood, and types of crime. It will provide insights for users to evaluate the risk of crime in a specific neighborhood at a specific time in a day.

# Section 2: Description of Data

We will be visualizing a dataset of crime data happened between 2003 and 2022 from Vancouver Police Department (VPD). It contains approximately 85,000 entries. Each of the entries denotes a crime happened in a specific location at a specific time.

Each crime has 10 associated variables that describe the crime type (`TYPE`), date/time (`YEAR`, `MONTH`, `DAY`, `HOUR`, `MINUTE`), and the location (`HUNDRED_BLOCK`, `NEIGHBOURHOOD`, `X` and `Y`).

The dataset includes information about eleven types of crime. `X` and `Y` are coordinate values projected in Universal Transverse Mercator (UTM) zone 10. There are some missing location data. Part of that is due to privacy issue.


# Section 3: Research questions and usage scenarios

Below is an example usage scenario.

Jonathan is a police officer specialized in crime prevention. When he is using our dashboard, he will be able to have a general overview of how the number of crimes in Vancouver city has changed over the years. Geospatial distribution of past criminal acts will be visible to Jonathan for him to evaluate the current deployment of manpower and the risk of crime in each neighborhood. A line plot will show the average numbers of crime across a whole day when Jonathan wants to make adjustment on the patrol schedule based on the risk of crime. With the need to focus on any specific type of crime, Jonathan can use the drop-down menu in the widget to have a more detailed speculation on the criminal acts. A similar widget will also enable Jonathan to select the time frame of the presented data, as data in the most recent 3 years will be more valuable to be used than those in the 90s. Jonathan suspects that the number of crime has been increasing since 2020 because of the emergence of Covid-19. Moreover, he hypothesizes that more crimes have occurred in the central business area based on his experience. A close scrutinization can be done with our dashboard.

