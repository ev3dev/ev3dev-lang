#   Copies the files to EV3, starts Rserve on EV3 and starts the tests remotely
# 
#   This script is intended to be used on PC, not EV3!  
#
#   Prerequsities: 
#   -R and Rserve installed on EV3
#   -RSclient package installed on PC
#   -remote connections enabled for Rserve on EV3
#   -ssh keys for user of PC stored on EV3, same PC/EV3 user (doesn't ask for password)
#   -ssh connected at least once from command line (so machine trusted)
#   -working directory set to location of files (setwd on PC)
#
#   Copyright (c) 2014 - Bartosz Meglicki
# 
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#  
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Setup the ip of EV3

ip="192.168.1.10"

# Set working directory to source file location:
# e.g. in RStudio Session->Set Working Directory -> To Source File Location

# End Setup

library(RSclient)
source("ev3_dev_tools.R") #startRemoteRserve, upload, run

scp_path=paste(ip, ":~/R/", sep="")

status=run(ip, "mkdir ~/R") #may warn if directory already exists

startRemoteRserve(ip)
Sys.sleep(15) # let's wait for the server start
c=RSconnect(ip)
RSeval(c, quote(print("It is ready.")))

upload("ev3dev.R", scp_path)
upload("ev3dev_test_all.R", scp_path)
RSeval( c, quote(source("~/R/ev3dev.R") ))

# Starts tests

# Run the motor test
upload("ev3dev_test_motors.R", scp_path)
RSeval( c, quote(source("~/R/ev3dev_test_motors.R") ))

# Run the sensors test
upload("ev3dev_test_sensors.R", scp_path)
RSeval( c, quote(source("~/R/ev3dev_test_sensors.R") ))

# Run the led test
upload("ev3dev_test_leds.R", scp_path)
RSeval( c, quote(source("~/R/ev3dev_test_leds.R") ))

# Run the power supply test
upload("ev3dev_test_power_supply.R", scp_path)
RSeval( c, quote(source("~/R/ev3dev_test_power_supply.R") ))

RSclose(c)
