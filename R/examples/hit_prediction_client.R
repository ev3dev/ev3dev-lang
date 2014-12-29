#   Sample application for EV3 (client, prediciton of obstacle hitting from duty cycles).
#
#   It transfers the necessary files to EV3, starts Rserve on EV3, sources the files
#   With the correctly built EV3 robot this application predicts obstacle hit from duty cycles.
#   -first duty cycles in normal circumstances is collected
#   -then duty cycles when hitting obstacle is collected
#   -on PC one can see the distribution of first and second, select the duty cycle threshold level at hitting obstacle is probable
#   
#   This script is intended to be run from PC (not EV3)  
#
#   Prerequsities: 
#   -R and Rserve installed on EV3
#   -RSclient package installed on PC
#   -remote connections enabled for Rserve on EV3
#   -ssh client installed on PC and in the system path (e.g. www.openssh.org/ for Windows)
#   -ssh keys for user of PC stored on EV3, same PC/EV3 user (doesn't ask for password)
#   -ssh connected at least once from command line (so machine trusted)
#   -working directory set to location of files (setwd on PC)
#
#   This is intented to work in tandem with hit_prediction.R 
#   hit_prediction.R is not required to be called manually on EV3 (this script does it)
#
#   The intented hardware for EV3 is:
#   -large motor on OUTPUT_B
#   -large motor on OUTPUT_C
#
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

source("../ev3_dev_tools.R") #startRemoteRserve, upload, run
               
con=prepare_ev3(ip, ev3_home_path = "../", script_file = "hit_prediction.R")

Cutoff=function(data, low_quantile=0.1, high_quantile=0.9)
{
  data[data>quantile(data, low_quantile) & data<quantile(data, high_quantile)]
}

running_dc=RS.eval(con, TestDutyCycles(4000))
hit_dc=RS.eval(con, TestDutyCycles(2000))

par(mfrow=c(1,2))
plot(running_dc, ylim=c(0,100))
plot(hit_dc, ylim=c(0,100))

running_dc=Cutoff(running_dc, 0.1, 0.9)
hit_dc=Cutoff(hit_dc, 0.3, 1)

plot(running_dc, ylim=c(0,100))
plot(hit_dc, ylim=c(0,100))

plot(density(running_dc))
plot(density(hit_dc))

threshold=(max(running_dc)+min(hit_dc))/2

t=RS.eval(con, as.call(list(quote(DriveSafely), quote(left), quote(right), quote(4000), threshold, quote(3))), lazy=FALSE)

RS.close(con)
