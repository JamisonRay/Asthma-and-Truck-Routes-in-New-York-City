library(tidyverse)
library(fs)
library(janitor)
library(naniar)
library(ggpubr)

theme_set(theme_pubr())

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
                                            ifelse(boro_code == "085", "Staten Island", "no")))))) %>% 
  mutate(tract_code = substr(tractfips,6,11))

glimpse(clean_ct_asthma)


#-----------------------------------------------------------

###Practice with Census Tracts within 2 tenths of a mile from truck routes
#load census tracts fully within two tenths of a mile of a truck route
#two_tenths_mile_cts <- read_csv("/Users/jamie/Documents/MSPP/Summer/Data Studio/ProjectTRA/CTs_in_twotenths_mile.csv")
#select just the ct code and create a column that indicates these census tracts are fully within .2 miles of a truck route
#clean_two_tenths_cts <- two_tenths_mile_cts %>% 
  #select(ct2010) %>% 
  #mutate(within_two_tenths = 1)

#glimpse(clean_two_tenths_cts)

#Join the asthma data with proximity data and change NAs to 0s
#asthma_tr_proximity_twotenths <- 
  #left_join(clean_ct_asthma, clean_two_tenths_cts, by = c("tract_code" = "ct2010"))

#asthma_tr_proximity_twotenths$within_two_tenths <- asthma_tr_proximity_twotenths$within_two_tenths %>% 
  #replace_na(0) %>% 
  #as.logical()

#glimpse(asthma_tr_proximity_twotenths)

#group by if within two tenths of a mile or not
#two_tenths_grouped <- asthma_tr_proximity_twotenths %>% 
  #group_by(within_two_tenths) %>% 
  #summarise(avg_asthma_rate = mean(data_value), med_asthma_rate = median(data_value), max_asthma_rate = max(data_value), min_asthma_rate = min(data_value)) %>%
  #arrange(desc(avg_asthma_rate))

#group by boro and if within two tenths of a mile or not
#two_tenths_boro_grouped <- asthma_tr_proximity_twotenths %>% 
  #group_by(boro, within_two_tenths) %>% 
  #summarise(avg_asthma_rate = mean(data_value), med_asthma_rate = median(data_value), max_asthma_rate = max(data_value), min_asthma_rate = min(data_value))
  

# #calculate average adult asthma (and other descriptive stats) rate by borough
# boro_asthma_rate <- clean_ct_asthma %>% 
#   group_by(boro) %>%
#   summarise(avg_asthma_rate = mean(data_value), med_asthma_rate = median(data_value), max_asthma_rate = max(data_value), min_asthma_rate = min(data_value)) %>%
#   arrange(desc(avg_asthma_rate))

# #tally cts in each group
# two_tenths_boro_tallied <- asthma_tr_proximity_twotenths %>% 
#   group_by(boro, within_two_tenths) %>% 
#   tally()
#   
#graph the asthma by boro and proximity
# asthma_by_boro_and_proximity_graph <- ggplot(two_tenths_boro_grouped) +
#   aes(x=boro, y=avg_asthma_rate, fill=within_two_tenths) +
#   geom_bar(stat = "identity", position = "dodge") +
#   labs(
#     title = "Average Asthma Rate by Borough and Proximity",
#     x = "Average Asthma Rate",
#     y = "Borough",
#   )
# asthma_by_boro_and_proximity_graph

#-----------------------------------------------------------

###CREATING A PROXIMITY SCORE FOR EACH CENSUS TRACT IN RELATION TO TRUCK ROUTES
#Load CSVs of cts proportions in each buffer zone 

prop_cts_5hdrths <- read_csv("/Users/jamie/Documents/MSPP/Summer/Data Studio/ProjectTRA/Proportions of CTs by distance from TRs/prop_area_5hundredths.csv") %>% 
  select(boro_ct201, prop_area_5hundredths) %>% 
  mutate(boro_ct = as.character(boro_ct201)) %>% 
  select(boro_ct, prop_area_5hundredths)

prop_cts_10hdrths <- read_csv("/Users/jamie/Documents/MSPP/Summer/Data Studio/ProjectTRA/Proportions of CTs by distance from TRs/prop_area_10hundredths.csv") %>% 
  select(boro_ct201, prop_area_10hundredths) %>% 
  mutate(boro_ct = as.character(boro_ct201)) %>% 
  select(boro_ct, prop_area_10hundredths)

prop_cts_15hdrths <- read_csv("/Users/jamie/Documents/MSPP/Summer/Data Studio/ProjectTRA/Proportions of CTs by distance from TRs/Prop_area_15hundredths.csv") %>% 
  select(boro_ct201, prop_area_15hundredths) %>% 
  mutate(boro_ct = as.character(boro_ct201)) %>% 
  select(boro_ct, prop_area_15hundredths)

prop_cts_20hdrths <- read_csv("/Users/jamie/Documents/MSPP/Summer/Data Studio/ProjectTRA/Proportions of CTs by distance from TRs/proportion_area_2tenths.csv") %>% 
  select(boro_ct201, prop_area_2tenths) %>% 
  mutate(boro_ct = as.character(boro_ct201)) %>% 
  select(boro_ct, prop_area_2tenths)

prop_cts_25hdrths <- read_csv("/Users/jamie/Documents/MSPP/Summer/Data Studio/ProjectTRA/Proportions of CTs by distance from TRs/prop_area_25hundredths.csv") %>% 
  select(boro_ct201, prop_area_25hundredths) %>% 
  mutate(boro_ct = as.character(boro_ct201)) %>% 
  select(boro_ct, prop_area_25hundredths)

#create new column that has the boro number attached to the census tract number to match the boro_ct201 code
boro_crosswalk <- read_csv("/Users/jamie/Documents/MSPP/Summer/Data Studio/ProjectTRA/boro_crosswalk.csv")

ct_asthma_edited <- left_join(clean_ct_asthma, boro_crosswalk, c("boro" = "boro_name")) %>% 
  unite("boro_ctcode", boro_num:tract_code, sep = "", remove = FALSE, na.rm = FALSE) %>% 
  select(uniqueid, data_value, low_confidence_limit, high_confidence_limit, populationcount, boro_ctcode)
  
#Join the proportions of census tracts in each buffer distance to my clean ct asthma data
asthma_tr_proximity <- left_join(ct_asthma_edited, prop_cts_5hdrths, by = c("boro_ctcode" = "boro_ct")) %>% 
  left_join(., prop_cts_10hdrths, by = c("boro_ctcode" = "boro_ct")) %>% 
  left_join(., prop_cts_15hdrths, by = c("boro_ctcode" = "boro_ct")) %>% 
  left_join(., prop_cts_20hdrths, by = c("boro_ctcode" = "boro_ct")) %>% 
  left_join(., prop_cts_25hdrths, by = c("boro_ctcode" = "boro_ct"))

asthma_tr_proximity[is.na(asthma_tr_proximity)] <- 0 # make the NA's = 0

## Create proximity score
asthma_tr_prox_seperate <- asthma_tr_proximity %>% 
  mutate(prop_area_10 = prop_area_10hundredths - prop_area_5hundredths) %>% #calculate the area between .05 miles and .1 miles    
  mutate(prop_area_15 = prop_area_15hundredths - prop_area_10hundredths) %>% #calculate the area between .1 miles and .15 miles
  mutate(prop_area_20 = prop_area_2tenths - prop_area_15hundredths) %>% #calculate the area between .15 miles and .2 miles
  mutate(prop_area_25 = prop_area_25hundredths - prop_area_2tenths) %>% #calculate the area between .2 miles and .25 miles
  mutate(prop_area_5 = prop_area_5hundredths) %>% #rename to match style
  mutate(sum_prop_in_25 = prop_area_5 + prop_area_10 + prop_area_15 + prop_area_20 + prop_area_25) %>% #check that proportions' total is less than one
  mutate(prox_score = (5*prop_area_5)+(4*prop_area_10)+(3*prop_area_15)+(2*prop_area_20)+(1*prop_area_25)) %>%  #calculate proximity score
  select(uniqueid, data_value, low_confidence_limit, high_confidence_limit, populationcount, boro_ctcode, 
         prop_area_5, prop_area_10, prop_area_15, prop_area_20, prop_area_25, sum_prop_in_25, prox_score) #select only needed columns


asthma_tr_prox = asthma_tr_prox_seperate %>%
  rename(asthma_rate = data_value) %>% 
  select(boro_ctcode, asthma_rate, prox_score)

#--------------------------------------------------------------------
###Calculate average traffic density for each census tract (data is million miles per year, at the Community District level)

prop_ct_by_cd <- read_csv("/Users/jamie/Documents/MSPP/Summer/Data Studio/ProjectTRA/prop_ct_cd.csv") %>% 
  clean_names()#load in proportion of each census tract within overlaying community districts

cd_traffic_density <- read_csv("/Users/jamie/Documents/MSPP/Summer/Data Studio/ProjectTRA/Traffic Density- Annual Vehicle Miles Traveled for Cars/traffic_density_CD.csv") %>% 
  clean_names()#load in millions of miles per year of truck traffic
  
ct_traffic_density <- left_join(prop_ct_by_cd, cd_traffic_density, by = c("boro_cd" = "geography_id")) %>% 
  na.omit() %>% 
  mutate(prop_mmpy = prop_ct_in_cd * data_value) %>% 
  group_by(boro_ct201) %>% 
  summarise(wghtd_avg_mmpy = sum(prop_mmpy))

#--------------------------------------------------------------------
###Clean-up Household Income Data 
median_income <- read_csv("/Users/jamie/Documents/MSPP/Summer/Data Studio/ProjectTRA/Median Income Data/2019_ACS_med_income.csv", skip = 1) %>% 
  clean_names()

working_med_income <- median_income %>% 
  mutate(tract_code = substr(id,15,20)) %>% #extract the census tract id
  mutate(county = str_remove(geographic_area_name, " County, New York")) %>% #remove the end of the string to extract the county name
  mutate(county = str_remove(county,'.*,\\s*')) %>% #remove any number of characters (*) of any type(.) before a comma, and then remove any number of spaces of any type after the comma (\\s*)
  mutate(county_code = ifelse(county == "New York", "1",
                               ifelse(county == "Bronx", "2",
                                      ifelse(county == "Kings", "3",
                                             ifelse(county == "Queens", "4",
                                                    ifelse(county == "Richmond", "5", "no")))))) %>% #use the extracted county name to create new column with county code 
  unite("county_tract", county_code,tract_code, sep = "", remove = FALSE, na.rm = FALSE) %>% #create new column with the county code and the census tract to match with other data frames
  mutate(med_income = estimate_median_household_income_in_the_past_12_months_in_2019_inflation_adjusted_dollars) %>% 
  select(med_income, county_tract) %>% 
  replace_with_na(replace = list(med_income = "-")) %>% 
  na.omit

working_med_income$med_income[working_med_income$med_income == "250,000+"]<- 250000 #change 250000+ to just 250000 so that it can be numeric  

clean_med_income <- working_med_income %>% 
  mutate(med_income = as.double(med_income)) %>% #make med_income type double (numeric) 
  mutate(med_income_10thou = med_income/10000)
glimpse(clean_med_income)

#-------------------------------------------------------------------
###Join data sets
#clean_med_income
#asthma_tr_prox
#ct_traffic_density
ct_traffic_density <- ct_traffic_density %>% 
  mutate(boro_ctcode = as.character(boro_ct201))


complete_df_asthma_traffic_income <- left_join(asthma_tr_prox, ct_traffic_density, by = "boro_ctcode") %>% #join data sets
  inner_join(., clean_med_income, by = c("boro_ctcode" = "county_tract"))

glimpse(complete_df_asthma_traffic_income)

clean_complete <- complete_df_asthma_traffic_income %>% 
  select(boro_ctcode, asthma_rate, med_income_10thou, wghtd_avg_mmpy, prox_score)

glimpse(clean_complete)

##results in 2094 census tracts with full data out of 2168, most of the missing ones are probably non-occupied areas such as parks or airports, and the rest had incomplete data



#-------------------------------------------------------------------
###Regressions 

ggplot(clean_complete, aes(x = prox_score, y = asthma_rate)) +
  geom_point() +
  stat_smooth() #doesn't show a clear trend 

cor(clean_complete$asthma_rate, clean_complete$prox_score) 
# provides a correlation coefficent of -0.047, indicating very little of the variation in asthma rates are explained by the proximity score, suggesting confounding variables 

simple_linear_model <- lm(asthma_rate ~ prox_score, data = clean_complete)
simple_linear_model
#Coefficients:
#(Intercept)   prox_score  
# 9.94302     -0.04981 
#suggests same as above

ggplot(clean_complete, aes(prox_score, asthma_rate)) + #graph of the regression above
  geom_point() +
  stat_smooth(method = lm)

options(scipen=999) #turns off scientific notation, change 999 to 0 to turn on 
#multiple regression 
multi_model <- lm(asthma_rate ~ prox_score + med_income_10thou + wghtd_avg_mmpy, data = clean_complete)
summary(multi_model)
write.csv(as.data.frame(summary(multi_model)$coef), file="multi_model.csv")
#-------------------------------------------------------------------
###Regressions by Borough

#Creating separate data frames for each borough
clean_complete_mn <- clean_complete %>% 
  filter(str_detect(boro_ctcode, "1......")) #filter for only census tracts in Manhattan 

clean_complete_bx <- clean_complete %>% 
  filter(str_detect(boro_ctcode, "2......")) #filter for only census tracts in the Bronx

clean_complete_bk <- clean_complete %>% 
  filter(str_detect(boro_ctcode, "3......")) #filter for only census tracts in Brooklyn

clean_complete_qn <- clean_complete %>% 
  filter(str_detect(boro_ctcode, "4......")) #filter for only census tracts in the Queens

clean_complete_st <- clean_complete %>% 
  filter(str_detect(boro_ctcode, "5......")) #filter for only census tracts on Staten Island

#Regression for Manhattan 

multi_model_mn <- lm(asthma_rate ~ prox_score + med_income_10thou + wghtd_avg_mmpy, data = clean_complete_mn)
summary(multi_model_mn)

#Regression for the Bronx 

multi_model_bx <- lm(asthma_rate ~ prox_score + med_income_10thou + wghtd_avg_mmpy, data = clean_complete_bx)
summary(multi_model_bx)

#Regression for Brooklyn 

multi_model_bk <- lm(asthma_rate ~ prox_score + med_income_10thou + wghtd_avg_mmpy, data = clean_complete_bk)
summary(multi_model_bk)

#Regression for Queens 

multi_model_qn <- lm(asthma_rate ~ prox_score + med_income_10thou + wghtd_avg_mmpy, data = clean_complete_qn)
summary(multi_model_qn)

#Regression for Staten Island 

multi_model_st <- lm(asthma_rate ~ prox_score + med_income_10thou + wghtd_avg_mmpy, data = clean_complete_st)
summary(multi_model_st)


#export csv's

write_csv(clean_complete, "clean_complete_asthma_proximity_data.csv")

#--------------------------------------------------
### data manipulation for visualizations 

ed_child_asthma <- read_csv("/Users/jamie/Documents/MSPP/Summer/Data Studio/ProjectTRA/UHF Asthma Data/Asthma Emergency Department Visits.csv", skip = 5) %>% 
  clean_names() %>% 
  filter(str_detect(fips, "uhf...")) %>% 
  filter(data_format == "Rate") %>% 
  filter(time_frame == 2016) %>% 
  group_by(fips) %>% 
  summarise(ed_vis_rate_per_10thou = mean(data)) %>% 
  mutate(uhf = str_extract(fips, "\\d\\d\\d")) %>%
  mutate(uhf = as.double(uhf)) %>%
  select(uhf, ed_vis_rate_per_10thou)
  
glimpse(ed_child_asthma)

hosp_child_asthma <- read_csv("/Users/jamie/Documents/MSPP/Summer/Data Studio/ProjectTRA/UHF Asthma Data/Asthma Hospitalizations.csv", skip = 5) %>% 
  clean_names() %>% 
  filter(str_detect(fips, "uhf...")) %>% 
  filter(data_format == "Rate") %>% 
  filter(time_frame == 2016) %>% 
  group_by(fips) %>% 
  summarise(hosp_rate_per_10thou = mean(data)) %>% 
  mutate(uhf = str_extract(fips, "\\d\\d\\d")) %>%
  mutate(uhf = as.double(uhf)) %>% 
  select(uhf, hosp_rate_per_10thou)

child_asthma <- left_join(ed_child_asthma, hosp_child_asthma) 


write.csv(child_asthma, "childhood_asthma_data.csv") 
