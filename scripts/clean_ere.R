#cleaning ere data 

#loading packages
library(here)
library(tidyverse)
library(janitor)
library(sf)

#loading ere raw
ere_raw<-read_rds(here("data/raw/TURFcoopsMX.Rda"))
#creating a copy of data
ere_working<-ere_raw %>% 
  clean_names()

#creating smaller dataset with turf ids from ere working
ere_turfs<-ere_working%>%
  select(turf_id, coop, state) %>% 
  drop_na(turf_id)

#creating look up table from ere working
species_lookup <- ere_working %>% 
  st_drop_geometry() %>% 
  #stack species columns 
  pivot_longer( 
    cols = starts_with("especie_objetivo"), 
    names_to = "species_number",
    values_to = "species"
  ) %>%
  #drop the NA rows
  drop_na(species, turf_id) %>% 
  #species becomes species_original
  rename(species_original = species) %>%
  #filling in spanish and scientific name from species_original 
  mutate(
    common_name_spanish = str_trim(str_extract(species_original, "^[^(]+")),
    scientific_name = str_extract(species_original, "(?<=\\().+?(?=\\))")
  ) %>% 
  #create blank rows for english name and aphia id
  mutate(
    common_name_english = NA_character_,
    aphia_id = NA_character_
  ) %>% 
  #order by sci name
  arrange(scientific_name) %>% 
  select(turf_id, scientific_name, common_name_spanish,common_name_english,aphia_id)

write_sf(ere_turfs, "data/processed/ere_turfs.gpkg")
write_csv(species_lookup, "data/processed/species_lookup.csv") #as csv so i can edit and then another script to join them together 

# creating sub_id x species table

subid_species <- ere_working %>%
  st_drop_geometry() %>%
  pivot_longer(
    cols = starts_with("especie_objetivo"),
    names_to = "species_number",
    values_to = "species"
  ) %>%
  drop_na(species, sub_id) %>%
  select(sub_id, turf_id, coop, state, species)