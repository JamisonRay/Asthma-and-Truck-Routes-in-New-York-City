# Asthma-and-Truck-Routes-in-New-York-City
An analysis of the impact of truck routes on asthma rates in New York City, a project for NYU's MSPP Data Studio Class
by Jamie Hamilton 

Download R Studio and open and run ProjectTRA.Rproj
The file locations will need to be edited to wherever you save them to - but all except the shape files are included in the Github repo folder. ex.

##Here are the sources for all the data: 

The data is accessed through an API call included in the code - just download and run the file in R Studio. 
The data source for asthma rates can be found here:
https://chronicdata.cdc.gov/500-Cities-Places/500-Cities-Local-Data-for-Better-Health-2019-relea/6vp6-wxuq

The data for truck routes can be downloaded here: *DOWNLOAD ME*
https://data.cityofnewyork.us/Transportation/New-York-City-Truck-Routes-Map-/wnu3-egq7

The census tract shape file can be downloaded here: *DOWNLOAD ME*
https://data.cityofnewyork.us/City-Government/2010-Census-Tracts/fxpq-c8ku

The median income data can be downloaded here:
https://data.census.gov/cedsci/table?q=B19013&g=0500000US36005%241400000,36047%241400000,36061%241400000,36081%241400000,36085%241400000&tid=ACSDT5Y2020.B19013

The truck traffic density data can be downloaded here: 
https://a816-dohbesp.nyc.gov/IndicatorPublic/VisualizationData.aspx?id=2114,719b87,114,Summarize

##To calculate the proportion of each census tract within 0.05 increments of 0.25 miles of a truck route in QGIS (as is needed in the code):
  1. Load the census tract shape file and the truck route shape file into a project. They may need to be reprojected onto the "ESPG:2263 -NAD83 / New York Long Island (ftUS)" coordinate reference system.
  2. Create shapearea2 variable in the attribute table by calculating shape area of the census tracts based on the original reference map (so that the areas are calculated based on the same coordinate reference system).
  3. Create five buffers with the results dissolved (under geoprocessing tools) around the truck route layer - one for each 0.05 of a mile up through 0.25 miles.
  4. Use the intersection tool (under geoprocessing tools) to create layers containing the area of the census tracts within each of the five buffers.
  5. For each intersection, calculate a new field equal to the proportion of each census tract within each buffer using the formula: $area/shapearea2
  6. Check that all the resulting ouputs are within 0 and 1, as they are proportions. If they are not, it is likely the coordinate reference systems for the buffer areas and the census tract areas are not the same - refer to step 2 and double check these two sources match.
  7. Export the calculated proportions as csv files. 