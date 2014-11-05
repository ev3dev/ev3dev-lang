R  Language Binding for ev3dev 
=============

This is  R script that exposes the features of the ev3dev API. 
Your brick must be running [ev3dev](http://github.com/ev3dev/ev3dev) to use this script.

Compatibility with ev3dev-jessie-2014-10-07 (pre-release)

Prerequisities:
- R installed on EV3

Optional (recommended for working with R from PC)
- Rserve installed on EV3 with remote connections enabled 
- ssh keys from PC user trusted on EV3 (and connected once), same PC/EV3 user

Getting Started (recommended path):
- install R on EV3 
  * `apt-get install r-base r-base-dev`
- install Rserve on EV3
  * `apt-get install r-cran-rserve`
  * (configure to be detailed)

- download ev3dev-lang R to the brick
  * make a directory to download into and `cd` into that directory
  * download the master or development repository (your choice)
  * `wget https://github.com/ev3dev/ev3dev-lang/archive/develop.zip`
  * `unzip develop.zip`
  * go to the R subdirectory:
  * `cd ev3dev-lang-develop/R`
    * The file with bindings is: ev3dev.R
    * The rest of the files are tests, samples and tools.

- test `R` on the ev3-brick:
  * start R here: `R` and wait until the R prompt `>` is presented. The EV3 is no race monster..
  * load the ev3 language bindings: `source("ev3dev.R")` 
    * wait for `[1] "Creating a new generic function for ‘Position’ in the global environment"`
  * show what has been defined up to here: `ls()`
  * show the contents of the current directory: `dir()`
  * test e.g. the bindings for the leds. Status and settings are reported by speak. 
    * `source("ev3dev_test_leds.R")`
  * test all bindings. 
    * needs EV3 motors on ports B and C
    * needs EV3-infrared sensor and EV3 or NXT touch sensor.
    * `source("ev3dev_test_all.R")`

- remote setup (to be detailed)
- enable remote connections to Rserve on EV3
- prepare ssh connection (public PC user ssh key known by EV3, same user name recommended)
- begin with ev3dev_test_all_RSclient.R
