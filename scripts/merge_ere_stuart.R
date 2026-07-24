# merging cleaned Ere and Stuart TURF data

library(here)
library(tidyverse)
library(sf)
library(janitor)

# ------------------------------------------------------------------
# Load cleaned Ere and Stuart data
#
# This data is produced by clean_ere.R and clean_stuart.R.
# ------------------------------------------------------------------
ere_clean <- st_read(here("data/processed/ere_species_cleaned.gpkg"))
stuart_clean <- st_read(here("data/processed/stuart_species_cleaned.gpkg"))

# ------------------------------------------------------------------
# standardize coordinate reference systems
#
# transform Stuart polygons to the same CRS 
# as Ere before checking for overlaps.
# ------------------------------------------------------------------

# trasnform Stuart coordinates to ere's
stuart_clean <- stuart_clean %>%
  st_transform(st_crs(ere_clean))

# ------------------------------------------------------------------
# Identify overlapping QR TURFs
# ------------------------------------------------------------------

#checking overlaps
ere_qr <- ere_clean %>%
  filter(state == "QR")

#T/F matrix
possible_duplicates <- st_intersects(
  stuart_clean,
  ere_qr,
  sparse = FALSE
)

#convert to table I can read
# stuart row =1 
# ere row = 9
#means Stuart polygon 1 overlaps Ere polygon 9

overlap_table <- which(possible_duplicates, arr.ind = TRUE) %>%
  as_tibble() %>%
  rename(
    stuart_row = row,
    ere_row = col
  )

# The following ere sub_ids correspond to coops that
# also appear in Stuart's:
#
# 61_1 = Cozumel
# 62_1 = Vigia Chico
# 62_2 = Empty placeholder polygon (mostly NA)
# 63_1 = Jose Maria Azcorra
# 64_1 = Langosteros del Caribe
# 65_1 = Vanguardia del Mar
# 66_1 = Por La Justicia Social
# 67_1 = Puerto Morelos
# 68_1 = Tulum

ere_subids_to_replace <- c(
  "61_1",
  "62_1",
  "62_2",
  "63_1",
  "64_1",
  "65_1",
  "66_1",
  "67_1",
  "68_1"
)

# ------------------------------------------------------------------
# Remove Ere polygons that will be replaced by Stuart polygons
# ------------------------------------------------------------------

# remove ere polygons that will be replaced 
ere_without_stuart_duplicates <- ere_clean %>%
  filter(!sub_id %in% ere_subids_to_replace)

# ------------------------------------------------------------------
# Standardize columns before merging
#
# Keep only the fields that will appear in the final combined
# dataset.
# ------------------------------------------------------------------

# Keep only shared columns before merging Ere and Stuart.
# This makes the final dataset cleaner and avoids source-specific
# columns that only exist in one dataset.
ere_without_stuart_duplicates <- ere_without_stuart_duplicates %>%
  select(
    sub_id,
    turf_id,
    owner=coop,
    state,
    source,
    species,
    common_name_spanish,
    scientific_name,
    common_name_english,
    aphia_id,
    geom
  )

stuart_clean <- stuart_clean %>%
  select(
    sub_id,
    turf_id,
    owner=coop,
    state,
    source,
    species,
    common_name_spanish,
    scientific_name,
    common_name_english,
    aphia_id,
    geom
  )

# ------------------------------------------------------------------
# Merge Ere and Stuart datasets
# ------------------------------------------------------------------

combined_turfs <- bind_rows(
  ere_without_stuart_duplicates,
  stuart_clean
)

# ------------------------------------------------------------------
# Export final combined TURF dataset
# ------------------------------------------------------------------

write_sf(
  combined_turfs,
  here("data/output/mex_turfs_combined.gpkg"),
  delete_dsn = TRUE
)