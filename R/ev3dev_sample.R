#   Sample application for EV3   
#
#   Prerequsities: 
#   -functions and classes from ev3dev.R in memory (e.g. source("ev3dev.R"))
#
#   This is intented to work in tandem with ev3dev_sample_client.R and should not be called directly
#   The script in ev3dev_sample_client.R uploads it to EV3 and sources it and uses the functions remotely through RSclient
#
#   The intented hardware for EV3 is:
#   -large motor on OUTPUT_B
#   -large motor on OUTPUT_C
#   -(optional) infrared sensor mounted on medium motor with long cable so that it can rotate 360 degrees and back
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


left_motor=large.motor(ports$OUTPUT_B ) 
right_motor=large.motor(ports$OUTPUT_C ) 
head_motor=medium.motor(ports$OUTPUT_AUTO)
infrared=infrared.sensor(ports$INPUT_AUTO)

if(!Connected(left_motor) || !Connected(right_motor))
  stop("Large motors on OUTPUT_B and OUTPUT_C are mandatory")

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

InitHeadMotor=function(m)
{
  if(!Connected(m))
    return ("Head motor not connected")
  SetRunMode(m, "position")
  SetRegulationMode(m, "on")
  SetRampUpSP(m, 100)
  SetRampDownSP(m, 100)
  SetPulsesPerSecondSP(m, 200)
  SetPositionMode(m, "absolute")
  SetPosition(m, 0)    
}
  
InitDriveMotor(left_motor)
InitDriveMotor(right_motor)
InitHeadMotor(head_motor)

DegreeToHeadPosition=function(deg) {as.integer(deg * 300 / 180)}
PositionToHeadDegree=function(pos){ pos * 180 / 300}
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

Look=function(head_motor, degree)
{
  if(!Connected(head_motor))
    return ("Head motor not connected")
  
  target=DegreeToHeadPosition(degree)
  SetPositionSP(head_motor, target)
  Run(head_motor)
      
  while(Running(head_motor))
    Sleep(0.01)
}

Sense=function(infrared_sensor)
{
  if(!Connected(infrared_sensor))
    return (0)
    
  Value(infrared_sensor)
}

CalculateLookAroundLimits=function(current_position)
{
  degree_from=degree_to=current_position
  
  if(current_position>-10)
  {
    degree_from=current_position
    degree_to=-360
  }
  else if(current_position< -350)
  {
    degree_from=current_position
    degree_to=0  	
  }
  else
  {
    degree_from=0
    degree_to=-360	
  }
  list(from=degree_from, to=degree_to) 
}

LookAround=function(head, infrared)
{
  readings=array(0L, dim=c(300, 2))
  colnames(readings)=c("heading", "reading")
  
  if(!Connected(head) || !Connected(infrared))
    return (readings[0,])
  
  current_position=PositionToHeadDegree(Position(head))

  limits=CalculateLookAroundLimits(PositionToHeadDegree(Position(head)))
  degree_from=limits$from
  degree_to=limits$to
  
  Look(head, degree_from)
      
  target=DegreeToHeadPosition(degree_to)
  SetPositionSP(head, target)
  Run(head)
  
  row=1
  
  while(Running(head)) 
  {    
    reading=Value(infrared)
    heading=PositionToHeadDegree(Position(head))
    
    readings[row,]=c(heading, reading)
    row=row+1
    if(row>300)
      break
  }	
  
  readings[1:(row-1),]
}