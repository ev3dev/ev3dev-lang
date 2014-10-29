#   Simple test for EV3 leds
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


Speak("Beginning led test")
Sys.sleep(1)

Speak("Testing red left led")
led1=led("ev3:red:left")

Speak("Max brightness is ", MaxBrightness(led1))

Speak("Brightness is ", Brightness(led1) )

Speak("Setting brightness to 100")
SetBrightness(led1, 100)
Sys.sleep(1)

Speak("Setting brightness to 0")
SetBrightness(led1, 0)

Speak("The triggers are ", Trigger(led1))