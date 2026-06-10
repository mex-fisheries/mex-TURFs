################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jc_villasenor@miami.edu
# June 10, 2026
#
# I load the mex_turfs_combined geopackage and inspect it for consistency
#
################################################################################
  
# SET UP #######################################################################

## Load packages ---------------------------------------------------------------
pacman::p_load(here,
               magrittr,
               tidyverse,
               sf)

## Load data -------------------------------------------------------------------
turfs <- read_sf(here("data/processed/mex_turfs_combined.gpkg"))


# PROCESSING ###################################################################
# Define a non-spatial version. This is only to make computation of groups 
# aster so we don't need to perform spatial unions.
turfs_table <- st_drop_geometry(turfs)

# How many rows and columns?
dim(turfs_table)
# 302 rows and 37 columns
# Clearly, there is something going on. We should not have that many rows and columns.

# Check column names
colnames(turfs_table)

# I see... we have a lot of info that we don't need in terms of columns. See the
# TO DO list for what it should contain

# I'll make an even smaller version for now to keep the most relevant columns. 
# This is not the final data set, just for me to play with it.

turfs_min <- turfs_table |> 
  select(state, sub_id, turf_id, coop, contains("especie"),
         vigencia_de_la_concesion, ano,
         clave_de_la_unidad_economica,
         speciesnum,
         common_name_spanish,
         common_name_english,
         scientific_name,
         aphia_id,
         source)

# Check unique values per column
lapply(turfs_min, unique)

# Notes on the above:
# - source needs to be fixed (only shows as Stuart, no value for Ere)
# - Common names in spanish should be modified to use sentence case (str_to_sentence()) before final export
# - Vigencia is always 20 or NA (there's a 2 but I suspect typo). We don't need this column.
# - Ano is missing for some, but good variable to have
# - columns especie_objetivo_1 : especie_objetivo 6 should no longer exist.
# The species is now contained in a species column (english, spanish, scientific,
# and Aphia) yielding a tidy format
# - I _think_ in Ere's data turf_id means "set of polygons that appear in a given document". 
# But that's not how we define it. For us 1 TURF = 1 polygon. We need to normalize this.
# Perhaps this is what the sub_id does?

## Count # species per TURF ----------------------------------------------------
# Does the reported number of species match after we join them?
# If so, the below should return an empty table
turfs_min |> 
  group_by(turf_id, speciesnum) |> 
  summarize(n_spp = n_distinct(aphia_id, na.rm = T),
            n_poly = n()) |> 
  filter(n_spp != speciesnum)
# There three TURFs have a different number of species in reported vs after cleaning.
# The after cleaning number is always greater by 1, so it could just be things like
# Jaiba being split into two, which would make sense. Let's inspect
turfs_min |> 
  filter(turf_id %in% c("MX_C_052")) |> 
  select(turf_id, speciesnum, contains("especie"), scientific_name)
# Nope... Here turf_id might mean something different?

# Now the big one: Why do we have 302 rows (polygons)?
turf_300 <- turfs_min |> 
  select(sub_id, turf_id, ano, coop, rnpa = clave_de_la_unidad_economica, common_name_spanish:aphia_id) |> 
  mutate(rnpa = str_extract(rnpa, "[:digit:]{10}"))

dim(turf_300)

fn <- function(x){print(dim(x))}

# Print the dimension after each filter
turf_300 %T>% fn() %>%
  drop_na(turf_id) %T>% fn() %>%
  select(-c(common_name_spanish:aphia_id)) %T>% fn() %>%
  distinct() %>%
  dim()

# Ah, this makes sense. It's because we have now modified the data into a long format
# This tells me we have 195 TURFs polygons)
turf_300 |> 
  group_by(sub_id) |> 
  summarize(n = n_distinct(aphia_id)) |> 
  ggplot() +
  geom_histogram(aes(x = n)) +
  labs(x = "# of species in TURF",
       y = "Number of TURFs")


# Ok, the data look roughly correct. The columns just need to be cleaned up.







