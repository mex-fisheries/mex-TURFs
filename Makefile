all: data/output/mex_turfs_combined.gpkg

data/processed/ere_species_cleaned.gpkg data/processed/subid_species_joined.csv: scripts/clean_ere.R data/raw/TURFcoopsMX.Rda data/processed/unique_species_lookup_edited.xlsx
	Rscript scripts/clean_ere.R

data/processed/stuart_species_cleaned.gpkg: scripts/clean_stuart.R data/raw/TURFs_QRoo.gpkg
	Rscript scripts/clean_stuart.R

data/output/mex_turfs_combined.gpkg: scripts/merge_ere_stuart.R data/processed/ere_species_cleaned.gpkg data/processed/stuart_species_cleaned.gpkg
	Rscript scripts/merge_ere_stuart.R

dag.png: Makefile
	make -Bnd | make2graph -b | dot -Tpng -Gdpi=300 -o dag.png
