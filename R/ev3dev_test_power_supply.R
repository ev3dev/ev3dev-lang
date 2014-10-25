#   Simple test for EV3 power supply
#   
#   Prerequsities: 
#   -functions and classes from ev3dev.R in memory (e.g. source("ev3dev.R"))
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


speak("Beginning power supply test")
Sys.sleep(1)

psu=power.supply()

speak("current now is ", CurrentNow(psu))
speak("voltage now is ", VoltageNow(psu))
speak("voltage max is ", VoltageMax(psu))
speak("voltage min is ", VoltageMin(psu))
speak("technology is ", Technology(psu))
speak("type is ", Type(psu))
speak("current in ampers is ", CurrentAmps(psu))
speak("voltage in volts is ", VoltageVolts(psu))
