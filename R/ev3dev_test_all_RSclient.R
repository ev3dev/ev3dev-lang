#   Copies the files to EV3, starts Rserve on EV3 and starts the tests remotely
# 
#   This script is intended to be used on PC, not EV3!  
#
#   Prerequsities: 
#   -R and Rserve installed on EV3
#   -RSclient package installed on PC
#   -remote connections enabled for Rserve on EV3
#   -Rserve running on EV3 
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

c=RS.connect(ip) # will fail if: remote Rserve connections are disabled on EV3 (default!), or server not started yet

# Starts tests

# Run the motor test
UploadFile(con, "ev3dev_test_motors.R")
RS.eval( c, source("ev3dev_test_motors.R") )

# Run the sensors test
UploadFile(con, "ev3dev_test_sensors.R")
RS.eval( c, source("ev3dev_test_sensors.R") )

# Run the led test
UploadFile(con, "ev3dev_test_leds.R")
RS.eval( con, source("ev3dev_test_leds.R"))

# Run the power supply test
UploadFile(con, "ev3dev_test_power_supply.R")
RS.eval( c, source("ev3dev_test_power_supply.R") )

RS.close(c)
