#   Sample application - TO DO
#   
#   Prerequsities: 
#   -functions and classes from ev3dev.R in memory (e.g. source("ev3dev.R"))
#
#   Copyright (c) 2014 - Bartosz Meglicki
# 
#   This script is intented to work in tandem with table_client.R and should not be called directly
#   The script in table_client.R uploads it to EV3 and sources it and uses the functions remotely through RSclient
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


left=large.motor(ports$OUTPUT_B ) 
right=large.motor(ports$OUTPUT_C ) 

touch=touch.sensor(ports$INPUT_AUTO)
infrared=infrared.sensor(ports$INPUT_AUTO)

if(!Connected(left) || !Connected(right))
  stop("Large motors on OUTPUT_B and OUTPUT_C are mandatory")

Sleep=function(time)
{
  Sys.sleep(time)
}

InitDriveMotor=function(m)
{
  SetRunMode(m, "position")
  SetRegulationMode(m, "on")
  SetRampUpSP(m, 1000)
  SetRampDownSP(m, 1000)
  SetPulsesPerSecondSP(m, 300)
  SetPositionMode(m, "relative")
  SetPosition(m, 0)  
}

InitDriveMotor(left)
InitDriveMotor(right)

DegreeToHeadPosition=function(deg) {as.integer(deg * 300 / 180)}
PositionToHeadDegree=function(pos){ pos * 180 / 300}
CMToDrivePosition=function(cm) {as.integer(cm*100*5/12)}
DegreeToDrivePosition=function(degree){ as.integer(-degree * 520 / 90) }

DriveStart=function(left_motor, right_motor, cm)
{    
  pos=CMToDrivePosition(cm)
  SetPositionSP(left_motor, pos)
  SetPositionSP(right_motor, pos)
  
  Run(left_motor)
  Run(right_motor)       
}

TestInfrared=function(left, right, infrared, cm)
{
  size=100L
  readings=1L
  inf=integer(size)
  
  DriveStart(left, right, cm)  
  
  while(Running(left) | Running(right))
  {    
    inf[readings]=Value(infrared)
    readings=readings+1
    
    Sys.sleep(0.02)
  }    
  inf[1L:(readings-1L)]
}


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
  if(degree==0L)
    return (0L)
  
  pos=DegreeToDrivePosition(degree)
  SetPosition(left_motor,0L)
  SetPosition(right_motor,0L)  
  SetPositionSP(left_motor, -pos)
  SetPositionSP(right_motor,pos)
  
  Run(left_motor)
  Run(right_motor)
  
  while( Running(left_motor) | Running(right_motor) )
    Sleep(0.1)
  
  degree
}

DriveThreshold=function(left_motor, right_motor, infrared,  cm, threshold_up, threshold_down)
{
  if(cm==0L)
    return (0L)
  
  inf=Value(infrared)
  
  if(inf > threshold_up | inf < threshold_down)
    return (inf)
    
  pos=CMToDrivePosition(cm)
  SetPositionSP(left_motor, pos)
  SetPositionSP(right_motor,pos)
  
  Run(left_motor)
  Run(right_motor)
  
  readings=integer(1L)
  i=0L
  
  while( Running(right_motor) | (Running(left_motor) ))
  { 
    i=i+1L
    if( (readings=Value(infrared) ) > threshold_up | readings < threshold_down)
    {
      Stop(left_motor)
      Stop(right_motor)
      SetPosition(left_motor,0L)
      SetPosition(right_motor,0L)
      break
    }
    
    Sleep(0.02)
  }
      
  readings
}

DriveTouch=function(left_motor, right_motor, touch,  cm)
{
  if(Value(touch)==0L)
    return (0L)
  
  if(cm==0L)
    return (0L)
        
  pos=CMToDrivePosition(cm)
  SetPositionSP(left_motor, pos)
  SetPositionSP(right_motor,pos)
  
  Run(left_motor)
  Run(right_motor)
    
  while( Running(right_motor) | (Running(left_motor) ))
  { 
    if( Value(touch)==0L )
    {
      EmergencyStop(left_motor)
      EmergencyStop(right_motor)
      SetPosition(left_motor,0L)
      SetPosition(right_motor,0L)
      Sleep(0.5)
      DisarmEmergencyStop(left_motor)
      DisarmEmergencyStop(right_motor)    
      return (0L)
    }
    
    Sleep(0.02)
  }
  
  return (1L)
}
