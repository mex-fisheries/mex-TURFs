# mex-TURFs

This cleans TURF data, more documentation coming soon

![](map.png)

# Workflow and dependencies

![](dag.png)

## To-Do: Organization

- [] Remove lose plots in root directory (Sab_plot, sab_mexplot...)
- [] This repo should be only for the TURF-cleaning pipeline. I suggest you start a new one for your own dissertation project (perhaps call it `TURF_cc`, `resilient_TURFs`, ...?). Then share it with me at `jcvdav`.
- [] Remove all other files not relevant to this repo
- [] As I see it, this repo should have the following files:
  - [] Under a `scripts` folder:
    - script to clean Ere's data
    - script to clean Stuart's data (if any, so optional)
    - script to merge both datasets and export a final geopackage
    - (optional) a script that builds a map so that the README (see below) contains a map of the data
  - [] Under a `data` folder:
    - A `raw` data folder with Ere's and Stuart's data only
    - A `processed` data folder with intermediate steps data (e.g. the species list, output of clean ere's and clean stuarts' scripts)
    - An `output` data folder with the clean version of the TURFs. This is the final product and I _think_ it should have more or less the following columns:
      - `source`: ere's or stuart's data
      - `state`
      - `owner` : Who owns the TURF? Could be split into two columns, one for the RNPA of the economic unit and one for the name, for example. Or just one.
      - `turf_id`: this identifies the polygon. If fishers can fish for two species within the same polygon, then the same TURF id can appear more than once
      - `species_name_spanish`
      - `species_name_english`
      - `scientific_name`
      - `aphia_id`
      - `geometry`
  - [] A README.md file that clearly explains the contents of the repo as well as a clear description of the main output (columns, data types, any keys, what do things mean?). You can take a look at some of the repos already in [mex-fisheries](https://github.com/mex-fisheries). Alternatively, Emily has also done a great work on [this repo](https://github.com/jcvdav/tuna_data).
  - [] A MAKEFILE clearly connecting each scripts outputs to the script and its inputs. See [here](https://github.com/jcvdav/make_tutorial) for a tutorial. There is already a template from an older version in the repo.

## To-Do: Code

- [] L63 of `clean_ere.R`: I cannot read the file, since 1) the file is not in the GitHub repo and 2) the code uses absolute paths. Use relative paths with the `here` package.
- [] All of `clean_ere.R` needs further documentation to clearly state what each part of the code is doing.
- [] In `clean_ere.R`, avoid overwriting objects (What's done to `unique_spp_lookup` in L63 and L73). Either start a new object or swap the order (you can read and pipe into mutate)
- [] `clean_stuart.R` is empty for me. If that's intentional, remove the script. If not intentional, make sure to push the code.
- [] `merge_ere_stuart.R` is also empty for me.
