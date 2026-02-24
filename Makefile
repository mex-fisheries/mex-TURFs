all: data figures

data: data/processed/mex_turfs.gpkg data/processed/mex_turfs.rds
figures: map.png

data/processed/mex_turfs.gpkg: scripts/clean_turfs_from_ere.R data/raw/TURFcoopsMX.Rda
	cd $(<D); Rscript $(<F)

data/processed/mex_turfs.rds: scripts/clean_turfs_from_ere.R data/raw/TURFcoopsMX.Rda
	cd $(<D); Rscript $(<F)

map.png: scripts/build_map.R data/processed/mex_turfs.gpkg
	cd $(<D); Rscript $(<F)

dag.png: Makefile
	make -Bnd | make2graph -b | dot -Tpng -Gdpi=300 -o dag.png