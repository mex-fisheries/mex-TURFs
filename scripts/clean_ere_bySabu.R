#cleaning ere data 

#loading packages
library(here)
library(tidyverse)
library(janitor)
library(sf)

#loading ere raw
ere_raw<-read_rds(here("data/raw/TURFcoopsMX.Rda"))
#creating a copy of data
ere_working<-ere_raw

#make all lowercase and consistent
names(ere_working) <- make_clean_names(names(ere_working))

#creating smaller dataset for spp. 
ere_species<-ere_working%>%
  select(turf_id, coop, state, starts_with("especie_objetivo"))

#stacking species columns into one column
ere_species_long <- ere_species %>%
  pivot_longer(
    cols = starts_with("especie_objetivo"),
    names_to = "species_number",
    values_to = "species"
  )

#delete the NA columns
ere_species_long <- ere_species_long %>%
  filter(!is.na(species)) 

#dropping species number columm
ere_species_long <- ere_species_long %>%
  select(-species_number)

#creating a lookup table (I will later join this) 
species_lookup<- ere_species_long%>% 
  distinct(species)
#rename "species" to "species original"
species_lookup <- species_lookup %>%
  rename(species_original = species)

#building table template, filling scientific name column 
species_lookup <- species_lookup %>%
  mutate(
    common_name_spanish = as.character(common_name_spanish),
    common_name_english = as.character(common_name_english),
    scientific_name = as.character(scientific_name),
    aphia_id = as.character(aphia_id)
  )

#filling spanish common name column (have to review)
species_lookup <- species_lookup %>%
  mutate(
    common_name_spanish = str_trim(str_extract(species_original, "^[^(]+"))
  )

species_lookup <- species_lookup %>%
  mutate(
    scientific_name = str_extract(species_original, "(?<=\\().+?(?=\\))")
  )

write_rds(ere_species_long, "ere_species_long.rds")
write_rds(species_lookup, "species_lookup.rds")
