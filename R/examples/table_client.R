#   Sample application for EV3 (client, TO DO)
#
#   It transfers the necessary files to EV3, starts Rserve on EV3, sources the files
#   With the correctly built EV3 robot this application TO DO
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
#   This is intented to work in tandem with table.R 
#   table.R is not required to be called manually on EV3 (this script does it)
#
#   The intented hardware for EV3 is: TO DO
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

ip="192.168.1.10"
source("../ev3_dev_tools.R")

con=prepare_ev3(ip, ev3_home_path = "../", script_file = "table.R")

#scp_path=paste(ip, ":~/R/", sep="")
#upload("../ev3dev.R", scp_path)
#RS.eval(con,source("~/R/ev3dev.R"))
#upload("table.R", scp_path)
#RS.eval(con,source("~/R/table.R"))

RS.eval(con, Value(infrared)) 
RS.eval(con, Connected(touch)) 
RS.eval(con, Connected(infrared))
RS.eval(con, Value(touch)) 
RS.eval(con, DriveTouch(left, right, touch, 50))
RS.eval(con, DriveTouch(left, right, touch, 10))

RS.eval(con,Drive(left, right, 5))
RS.eval(con,Drive(left, right, -10))

RS.eval(con, Rotate(left, right, 30))
RS.eval(con, Rotate(left, right, -30))

inf=RS.eval(con, TestInfrared(left, right, infrared, 20))
plot(inf)
hist(inf)
plot(density(inf))

for(i in 1:10)
{
  dist=RS.eval(con, DriveThreshold(left, right, infrared, 100L, 65L, 50L))
  if(dist>=65)
    t=RS.eval(con,Drive(left, right, -5))
    
  angle=as.integer(180-runif(1, 0, 90))
  if(sample(2, 1)==1) angle=-angle
  
  t=RS.eval(con, as.call(list(quote(Rotate), quote(left), quote(right), angle)), lazy=FALSE)
  Sys.sleep(0.1)
}

RS.close(con)
