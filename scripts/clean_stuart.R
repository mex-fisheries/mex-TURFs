# cleaning Stuart Q Roo TURF data

library(here)
library(tidyverse)
library(janitor)
library(sf)

# ------------------------------------------------------------------
# Loading Stuart data
# ------------------------------------------------------------------

stuart_raw <- st_read(here("data/raw/TURFs_QRoo.gpkg"))

# ------------------------------------------------------------------
# Create cleaned Stuart spatial dataset
#
# This step adds species info and creates columns 
# that match cleaned Ere so the two can be merged
# ------------------------------------------------------------------

stuart_clean <- stuart_raw %>%
  clean_names() %>%
  rename(comments = coments) %>%
  mutate(
    sub_id = paste0("stuart_", row_number()),
    turf_id = NA_character_,
    coop = cooperativ,
    state = "QR",
    source = "Stuart",
    species = "LANGOSTA DEL CARIBE (Panulirus argus)",
    common_name_spanish = "LANGOSTA DEL CARIBE",
    scientific_name = "Panulirus argus",
    common_name_english = "Caribbean Spiny Lobster",
    aphia_id = "382891"
  ) %>%
  select(
    sub_id,
    turf_id,
    coop,
    state,
    source,
    species,
    common_name_spanish,
    scientific_name,
    common_name_english,
    aphia_id,
    area_ha,
    comments
  )

# ------------------------------------------------------------------
# export cleaned Stuart geopackage
# ------------------------------------------------------------------

write_sf(
  stuart_clean,
  here("data/processed/stuart_species_cleaned.gpkg"),
  delete_dsn = TRUE
)