################################################################################
# title
################################################################################
#
# Your Name Here
# Your email here
# date
#
# Description
#
################################################################################

# SET UP #######################################################################

## Load packages ---------------------------------------------------------------
library(here)
library(tidyverse)
library(janitor)
library(sf)

## Load data -------------------------------------------------------------------
turfs_raw <- read_rds(here("data/raw/TURFcoopsMX.Rda"))
  
instal# PROCESSING ###################################################################

## Some step -------------------------------------------------------------------
turfs_clean <- turfs_raw |>
  clean_names() |> 
  select(state, turf_id, coop, contains("especie"),
         eu_rnpa = clave_de_la_unidad_economica,
         n_species = speciesnum) |> 
  drop_na(turf_id) |> # Ere says NAs are not actual TURFs
  st_as_sf() |> 
  st_transform(crs = "EPSG:4326")

# EXPORT #######################################################################


## The final step --------------------------------------------------------------  
write_sf(obj = turfs_clean,
         dsn = here("data/processed/mex_turfs.gpkg"),
         delete_dsn = T)

write_rds(x = turfs_clean |> 
            st_drop_geometry(),
         file = here("data/processed/mex_turfs.rds"))
