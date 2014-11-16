#   Sample application - prediction of hitting obstacle from Duty Cycles
#   
#   Prerequsities: 
#   -functions and classes from ev3dev.R in memory (e.g. source("ev3dev.R"))
#
#   Copyright (c) 2014 - Bartosz Meglicki
# 
#   This script is intented to work in tandem with hit_prediction_client.R and should not be called directly
#   The script in hit_prediciton_client.R uploads it to EV3 and sources it and uses the functions remotely through RSclient
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


Sleep=function(time)
{
  Sys.sleep(time)
  invisible(NULL)
}

InitDriveMotor=function(m)
{
  SetRunMode(m, "time")
  SetRegulationMode(m, "on")
  SetRampUpSP(m, 600)
  SetRampDownSP(m, 600)
  SetPulsesPerSecondSP(m, 500)  
  SetStopMode(m, "coast")  
  invisible(NULL)
}

DriveStart=function(left_motor, right_motor, time_ms)
{    
  SetTimeSP(left_motor, time_ms)
  SetTimeSP(right_motor,time_ms)
  
  Run(left_motor)
  Run(right_motor)     
  invisible(NULL)
}

DriveWait=function(left_motor, right_motor, sleep_time=0.01)
{
  while( Running(left_motor) | Running(right_motor) )
    Sleep(sleep_time)  
  invisible(NULL)
}

Drive=function(left_motor, right_motor, time_ms)
{
  DriveStart(left_motor, right_motor, time_ms)
  DriveWait(left_motor, right_motor)
  invisible(NULL)
}
DutyCycles=function(left_motor, right_motor, samples=1, sleep=0.01)
{
  s=1
  duty_cycles=integer(samples)

  for(s in 1:samples)
  {
    duty_cycles[s]=max(DutyCycle(left_motor), DutyCycle(right_motor))
    s=s+1
    if(s<samples)
      Sleep(sleep)
  }
  
  duty_cycles
}

TestDutyCycles=function(time_ms)
{
  size=100
  readings=1
  duty_cycles=integer(size)
    
  DriveStart(left, right, time_ms)  
    
  while(MotorsRunning(left, right))
  {    
    duty_cycles[readings]=DutyCycles(left,right)
    readings=readings+1
    
    Sys.sleep(0.02)
  }    
  duty_cycles[1:(readings-1)]
}

DriveSafely=function(left, right, time_ms, dc_threshold, samples)
{
  DriveStart(left, right, time_ms)
  
  Sleep(0.2) #let the motors start
  
  while( MotorsRunning(left, right) )
  {  
    dc=mean(DutyCycles(left,right, samples, 0.01))
    
    if(dc>dc_threshold)
    {
      StopMotors(left,right)
      Speak("Wall hit!")      
    }
    
    Sys.sleep(0.01)
  }  
}


MotorsRunning=function(left_motor, right_motor)
{
  Running(left_motor) | Running(right_motor)  
}

StopMotors=function(left_motor, right_motor)
{
  Stop(left_motor)
  Stop(right_motor)
}

left=large.motor(ports$OUTPUT_B ) 
right=large.motor(ports$OUTPUT_C )

InitDriveMotor(left)
InitDriveMotor(right)
