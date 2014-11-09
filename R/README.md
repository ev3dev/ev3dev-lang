R  Language Binding for ev3dev 
==========================

This is  R script that exposes the features of the ev3dev API. 
Your brick must be running [ev3dev](http://github.com/ev3dev/ev3dev) to use this script.

Compatibility with ev3dev-jessie-2014-10-07 (pre-release)
- **CAUTION** the WiFI dongle Netgear WNA 1100 (the only one officially supported by LEGO for EV3) is currently not working with ev3dev-jessie-2014-10-07 (pre-release)
- other WiFI dongles are working with ev3dev-jessie-2014-10-07 (pre-release), details on www.ev3dev.org

Prerequisities:
- R installed on EV3

Optional (recommended for working with R from PC)
- Rserve installed on EV3 with remote connections enabled 
- ssh keys from PC user trusted on EV3 (and connected once), same PC/EV3 user

Getting Started (recommended path):
---------------------------------------------------------------

- install ev3dev on SD card 
 * follow getting started on www.ev3dev.org
- install R on EV3 
  * `sudo apt-get install r-base r-base-dev`
- install Rserve on EV3
  * `sudo apt-get install r-cran-rserve`

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

- Rserve remote setup:
- enable remote connections to Rserve on EV3
  * on EV3 create a file /etc/Rserv.conf with line 'remote enable' 
	sudo nano /etc/Rserv.conf
	remote enabley
 * if you are concerned about your EV3 security follow recommendations at [rforge](rforge.net/Rserve/doc.html) ;-)

- prepare ssh connection (public PC user ssh key known by EV3, same user name recommended)
* if on Windows, install open-ssh, (should be already installed on other platforms):
	sourceforge.net/projects/sshwindows
 * on PC generate public/private key with ssh-keygen for your user
	ssh-keygen -t rsa
 * on PC copy the generated public key for your user to EV3
	scp ~/.ssh/id_rsa.pub [your_user]@[ev3 ip]:~/id_rsa.pub
 * ssh to EV3 from PC at least once, so that it is added to the trusted machines
	ssh [ev3 ip]

- test R on EV3 through Rserve:
- on PC open your favourite IDE for R (e.g. RStudio)
- on PC in R shell or through IDE install package RSclient
	install.packages("RSclient")
- open ev3dev_test_all_RSclient.R and set working directory to its location
- follow instructions in script
* set ip variable to your EV3 ip
* execute the script line by line
* the script starts Rserve on EV3 thorugh ssh
* the script copies the files to EV3 through scp
* the script sources the files on EV3 through RSclient to Rserve
* peek into the files ev3dev_test_*.R to see API examples

Other things to consider:
- you can add line to /etc/Rserv.conf to automatically source ev3dev.R when starting Rserve
 * sudo nano /etc/Rserv.conf
	remote enable 
	source /[your_path_here]/ev3dev.R
- to start Rserve manually on EV3 type:
	R CMD Rserve
- if you are planning to use R/Rserve a lot consider starting Rserve deamon at boot