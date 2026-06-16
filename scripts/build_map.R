# build map of cleaned Mexican TURFs

library(here)
library(tidyverse)
library(sf)
library(terra)

# ------------------------------------------------------------------
# Load data
# ------------------------------------------------------------------

turfs <- read_sf(
  here("data/output/mex_turfs_combined.gpkg")
)

# Keep one row per polygon so TURFs with multiple species
# are not plotted multiple times.
turfs_map <- turfs %>%
  distinct(sub_id, .keep_all = TRUE)

# ------------------------------------------------------------------
# Load Mexico state boundaries
# ------------------------------------------------------------------

mex_states <- readRDS(
  here("data/raw/gadm/gadm41_MEX_1_pk.rds")
) %>%
  sf::st_as_sf()

# ------------------------------------------------------------------
# Create state labels
# ------------------------------------------------------------------

state_labels <- tibble(
  lon = c(
    -114.5,  # BC
    -111.5,  # BCS
    -110.5,  # SON
    -107.5,  # SIN
    -103.5,  # JAL
    -92.5,   # CHIS
    -96.5,   # VER
    -88.5    # QROO
  ),
  lat = c(
    30.0,
    25.5,
    29.0,
    25.0,
    20.5,
    16.5,
    19.0,
    19.5
  ),
  label = c(
    "BC",
    "BCS",
    "SON",
    "SIN",
    "JAL",
    "CHIS",
    "VER",
    "QROO"
  )
)

# ------------------------------------------------------------------
# Build map
# ------------------------------------------------------------------

p <- ggplot() +
  geom_sf(
    data = mex_states,
    fill = "gray90",
    color = "gray70",
    linewidth = 0.2
  ) +
  geom_sf(
    data = turfs_map,
    fill = "steelblue",
    color = "steelblue",
    alpha = 0.7
  ) +
  geom_text(
    data = state_labels,
    aes(
      x = lon,
      y = lat,
      label = label
    ),
    size = 3,
    fontface = "bold"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "Mexican TURFs",
    subtitle = "Cleaned TURF polygons from Ere and Stuart datasets"
  )

# ------------------------------------------------------------------
# Export map
# ------------------------------------------------------------------

dir.create(
  here("figures"),
  showWarnings = FALSE
)

ggsave(
  filename = here("figures/mex_turfs_map.png"),
  plot = p,
  width = 8,
  height = 6,
  dpi = 300
)