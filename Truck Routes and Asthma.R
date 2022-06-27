library(tidyverse)
library(fs)
library(janitor)

#API Call
url_ct_asthma_rate <- URLencode("https://chronicdata.cdc.gov/resource/6vp6-wxuq.csv?$query=SELECT * WHERE year=2017 AND geographiclevel='Census Tract' AND stateabbr='NY' AND cityname='New York' AND measureid='CASTHMA' LIMIT 100000")

ct_asthma_rate <- read_csv(url_ct_asthma_rate)

#clean up the data, use fips code to labl by boro 
clean_ct_asthma <- ct_asthma_rate %>% 
  clean_names() %>% #clean names
  select(year, uniqueid, data_value, low_confidence_limit, high_confidence_limit, populationcount, geolocation, tractfips) %>% #select columns of interest
  filter(populationcount >= 50) %>% #drop census tracts with too low of a population for an estimate
  mutate(tractfips = as.character(tractfips)) %>% 
  mutate(boro_code = substr(tractfips,3,5)) %>% 
  mutate(boro = ifelse(boro_code == "005", "Bronx",
                       ifelse(boro_code == "047", "Brooklyn",
                              ifelse(boro_code == "061", "Manhattan",
                                     ifelse(boro_code == "081", "Queens",
                                            ifelse(boro_code == "085", "Staten Island", "no"))))))

glimpse(clean_ct_asthma)
  
#calculate average adult asthma (and other descriptive stats) rate by borough
boro_asthma_rate <- clean_ct_asthma %>% 
  group_by(boro) %>% 
  summarise(avg_asthma_rate = mean(data_value), med_asthma_rate = median(data_value), max_asthma_rate = max(data_value), min_asthma_rate = min(data_value)) %>%
  arrange(desc(avg_asthma_rate))

#export csv
write_csv(clean_ct_asthma, 'AsthmaRateCT.csv')
write_csv(boro_asthma_rate, 'AsthmaRateBoro.csv')


 
