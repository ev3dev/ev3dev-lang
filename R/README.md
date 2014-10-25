R  Language Binding for ev3dev 
=============

This is  R script that exposes the features of the ev3dev API. Your brick must be running [ev3dev](http://github.com/ev3dev/ev3dev) to use this script.

Compatibility with ev3dev-jessie-2014-10-07 (pre-release)

Prerequisities:
- R installed on EV3 (apt-get install ....)

Optional (recommended for working with R from PC)
- Rserve installed on EV3 with remote connections enabled (apt-get install, config file)
- ssh keys from PC user trusted on EV3 (and connected once), same PC/EV3 user

The file with bindings is: ev3dev.R

The rest of the files are tests, samples and tools.

Getting Started (recommended path):
- install R on EV3
- install Rserve on EV3
- enable remote connections to Rserve on EV3
- prepare ssh connection (public PC user ssh key known by EV3, same user name recommended)
- begin with ev3dev_test_all_RSclient.R
