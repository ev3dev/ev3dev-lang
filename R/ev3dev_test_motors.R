#   Simple test for EV3 motors in position mode
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


Speak("Beginning motor test")

Sleep=function(time)
{
  Sys.sleep(time)
}

InitDriveMotor=function(m)
{
  SetRunMode(m, "position")
  SetRegulationMode(m, "on")
  SetRampUpSP(m, 600)
  SetRampDownSP(m, 600)
  SetPulsesPerSecondSP(m, 500)
  SetPositionMode(m, "relative")
  SetPosition(m, 0)  
}

CMToDrivePosition=function(cm) {as.integer(cm*100*5/12)}
DegreeToDrivePosition=function(degree){ as.integer(-degree * 520 / 90) }

Drive=function(left_motor, right_motor, cm)
{
  if(cm==0)
    return (0)
  
  pos=CMToDrivePosition(cm)
  SetPositionSP(left_motor, pos)
  SetPositionSP(right_motor,pos)
  
  Run(left_motor)
  Run(right_motor)
  
  while( Running(left_motor) | Running(right_motor) )
    Sleep(0.01)
  
  cm
}

Rotate=function(left_motor, right_motor, degree)
{
  if(degree==0)
    return (0)
  
  pos=DegreeToDrivePosition(degree)
  SetPositionSP(left_motor, -pos)
  SetPositionSP(right_motor,pos)
  
  Run(left_motor)
  Run(right_motor)
  
  while( Running(left_motor) | Running(right_motor) )
    Sleep(0.01)
  
  degree
}

left=large.motor(ports$OUTPUT_B ) 
right=large.motor(ports$OUTPUT_C )

if( Connected(left) && Connected(right) )
{
  InitDriveMotor(left)
  InitDriveMotor(right)
  
  Speak("Drive test")  
  
  Drive(left, right, 10)
  
  Speak("Rotation test")
  
  Rotate(left, right, 90)  
    
} else
    Speak("Large motors required on ports B and C")

