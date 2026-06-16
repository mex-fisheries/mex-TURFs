#cleaning ere data 

#loading packages
library(here)
library(tidyverse)
library(janitor)
library(sf)
library(readxl)

# ------------------------------------------------------------------
# Load and standardize raw Ere data
#
# This loads the original Ere TURF dataset
# and standardizes column names 
# ------------------------------------------------------------------

#loading ere raw
<<<<<<< HEAD
ere_raw <- read_rds(here("data/raw/TURFcoopsMX.Rda"))
#creating a copy of data
ere_working <- ere_raw %>% 
  clean_names()

#creating smaller dataset with turf ids from ere working
ere_turfs <- ere_working%>%
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
=======
ere_raw<-read_rds(here("data/raw/TURFcoopsMX.Rda"))

#creating copy of data
ere_working<-ere_raw %>% 
  clean_names()

# ------------------------------------------------------------------
# Create TURF-species table
#
# The original Ere dataset stores target species across multiple
# columns. Here I reshape columns into a long table with
# one row per sub_id x species combination.
# ------------------------------------------------------------------
>>>>>>> 3917d72 (Clean TURF data pipeline and reorganize repo)

# creating sub_id x species table
subid_species <- ere_working %>%
  #remove geometry temporarily
  st_drop_geometry() %>%
  #convert species columns from wide format to long format
  #one row per sub_id x species combination
  pivot_longer(
    cols = starts_with("especie_objetivo"),
    names_to = "species_number",
    values_to = "species"
  ) %>%
  #remove rows with no species or no sub_id
  drop_na(species, sub_id) %>%
  #keep only columns needed for species cleaning
  select(sub_id, turf_id, coop, state, species)

# ------------------------------------------------------------------
# Load manually edited species lookup table
#
# This table links Spanish common names to scientific names, English
# common names, and Aphia IDs.
# ------------------------------------------------------------------

# in this file I added Aphia IDs, scientific names, and English names
# to the Spanish common names
unique_spp_lookup_raw <- read_excel(
  here("data/processed/unique_species_lookup_edited.xlsx")
)

# extracting common spanish name from original "species" field
# going from "Abulon (Haliotis spp.)" to "Abulon"
subid_species <- subid_species %>%
  mutate(
    common_name_spanish = str_trim(str_extract(species, "^[^(]+"))
  )

# prepare species lookup table for the join 
unique_spp_lookup_clean <- unique_spp_lookup_raw %>%
  select(
    common_name_spanish,
    scientific_name,
    common_name_english,
    aphia_id
  )

# join Aphia IDs, scientific names, and English names
# to every sub_id x species row using the Spanish common name.
subid_species_joined <- subid_species %>%
  left_join(
    unique_spp_lookup_clean,
    by = "common_name_spanish"
  )

# ------------------------------------------------------------------
# Manual exceptions of Callinectes spp 
# replacing generic JAIBA in MX_C_208 and MX_C_210
# to Callinectes sapidus and Callinectes rathbunae
# ------------------------------------------------------------------

# find Jaiba rows for those two TURFs
callinectes_exception <- subid_species_joined %>%
  filter(
    sub_id %in% c("208_1", "210_1"),
    common_name_spanish == "JAIBA"
  ) %>%
  select(sub_id, turf_id, coop, state, species, common_name_spanish) %>%
  
# create one row for each identified species 
  tidyr::crossing(
    tibble::tibble(
      scientific_name = c("Callinectes sapidus", "Callinectes rathbunae"),
      common_name_english = c("Blue Crab", "Sharptooth Swimming Crab"),
      aphia_id = c("107379", "422039")
    )
  )
# remove the original JAIBA and replace them
# with the rows created above
subid_species_joined <- subid_species_joined %>%
  filter(
    !(sub_id %in% c("208_1", "210_1") &
        common_name_spanish == "JAIBA")
  ) %>%
  bind_rows(callinectes_exception)

# ------------------------------------------------------------------
# Export cleaned TURF-species table
#
# Save the cleaned sub_id x species table containing Spanish names,
# scientific names, English names, and Aphia IDs. This table does
# not contain polygon geom
# ------------------------------------------------------------------

#saving subid_species_joined
write_csv(
  subid_species_joined,
  "data/processed/subid_species_joined.csv"
)

# ------------------------------------------------------------------
# create final cleaned Ere spatial dataset
#
# join cleaned species information back to the TURF polygons
# ------------------------------------------------------------------

#joining cleaned species information back to the TURF polygons
ere_species_gpkg <- ere_working %>%
  
# keep only the columns needed for final cleaned Ere dataset
# remove original species columns 
# and other raw-data fields that are no longer needed
  select(
    sub_id,
    turf_id,
    coop,
    state,
    ano,
    clave_de_la_unidad_economica,
    geometry
  ) %>%
  
# add a source column to distinguish 
# Ere and Stuart data after they are merged 
  mutate(source = "Ere") %>%

# join cleaned species info to each TURF polygon
# using sub_id as the unique identifier 
  left_join(
    subid_species_joined %>%
      select(
        sub_id,
        species,
        common_name_spanish,
        scientific_name,
        common_name_english,
        aphia_id
      ),
    by = "sub_id"
  )

# ------------------------------------------------------------------
# Export cleaned Ere geopackage
# ------------------------------------------------------------------

write_sf(
  ere_species_gpkg,
  "data/processed/ere_species_cleaned.gpkg",
  delete_dsn = TRUE
)
