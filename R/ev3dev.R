#   R API to the sensors, motors, LEDs and battery of the ev3dev
#   Linux kernel for the LEGO Mindstorms EV3 hardware
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
 
#   Compatibility with ev3dev-jessie-2014-10-07 (pre-release)

#TO DO - check for connected state, more helpfull error handling on Get/SetAttr funcitons level, set connected to false in case of error
#TO DO - TypeId for sensor or Name? Name currently
#TO DO - possible Performance issuse for FloatValue (reading dp every time)
#TO DO - function Position is creating a new generic function for ‘Position’ in the global environment (instead builtin Position)
#TO DO - use explicit integers where possible (e.g. 1L instead of 1), no FPU!
#TO DO - stick to S3/S4/R5 classes only (one of), S4 now so copy constructible initializers would be better
#TO DO - documentation

# Constants 

ports=list(INPUT_AUTO="" , INPUT_1="in1", INPUT_2="in2", INPUT_3="in3", INPUT_4="in4",
           OUTPUT_AUTO="", OUTPUT_A="outA", OUTPUT_B="outB", OUTPUT_C="outC", OUTPUT_D="outD")
lockBinding("ports", globalenv())


# device 

.device=setClass(Class="device", representation(.path="character"))

device = function(path = character(), ...) {  
  .device(.path=path,  ...)
}

setGeneric("GetAttrString", function(.Object, name) standardGeneric("GetAttrString"))
setGeneric("GetAttrStringArray", function(.Object, name) standardGeneric("GetAttrStringArray"))
setGeneric("SetAttrString", function(.Object, name, value) standardGeneric("SetAttrString"))
setGeneric("GetAttrInt", function(.Object, name) standardGeneric("GetAttrInt"))
setGeneric("SetAttrInt", function(.Object, name, value) standardGeneric("SetAttrInt"))
setGeneric("Connected", function(.Object) standardGeneric("Connected"))

setMethod("GetAttrString","device",function(.Object, name){
  readLines(paste(.Object@.path,name,sep=""),warn=FALSE)
})

setMethod("GetAttrStringArray","device",function(.Object, name){
  scan(paste(.Object@.path,name,sep=""), what=character(), quiet=TRUE)
})


setMethod("SetAttrString","device",function(.Object, name, value){
  cat(value, file=paste(.Object@.path,name,sep="") )
  value
})

setMethod("GetAttrInt","device",function(.Object, name){
  as.integer(readLines(paste(.Object@.path,name,sep=""),warn=FALSE))
})

setMethod("SetAttrInt","device",function(.Object, name, value){
  cat(value, file=paste(.Object@.path,name,sep=""))
  value
})

setMethod("Connected","device",function(.Object){
  .Object@.path != ""
})

# motor, medium motor, large motor

.motor=setClass(Class="motor", contains="device")

motor = function(port, type, ...)
{
  #path="~/test/sys/class/tacho-motor"
  path="/sys/class/tacho-motor"
  
  files=list.files(path, full.names = TRUE)
  
  for(f in 1:length(files))
  {
    device_port=readLines(paste(files[f],"/port_name",sep=""), warn=FALSE)      
    device_type=readLines(paste(files[f],"/type",sep=""), warn=FALSE)
    
    if(missing(port) || port=="" || port==device_port )    
      if(missing(type)  || type=="" || type==device_type)
        return ( .motor(device( paste(files[f],"/",sep="")), ...) )
        
  }  
  .motor(device(""), ...)
}

medium.motor = function(port, ...)
{
  motor(port, "minitacho", ...)
}
large.motor = function(port, ...)
{
  motor(port, "tacho", ...)
}

#Duty Cycle|Number|Read

setGeneric("DutyCycle", function(.Object) standardGeneric("DutyCycle"))
setMethod("DutyCycle","motor",function(.Object){
    return (GetAttrInt(.Object, "duty_cycle"))
})

#Duty Cycle SP|Number|Read/Write

setGeneric("DutyCycleSP", function(.Object) standardGeneric("DutyCycleSP"))
setGeneric("SetDutyCycleSP", function(.Object, value) standardGeneric("SetDutyCycleSP"))

setMethod("DutyCycleSP","motor",function(.Object){
  GetAttrInt(.Object, "duty_cycle_sp")
})

setMethod("SetDutyCycleSP","motor",function(.Object, value){
    SetAttrInt(.Object, "duty_cycle_sp", value)
})


#Port Name|String|Read

setGeneric("PortName", function(.Object) standardGeneric("PortName"))
setMethod("PortName","motor",function(.Object){
  GetAttrString(.Object, "port_name")
})


#Position|Number|Read/Write

#Note - we suppress here message to allow for remote calling through RSclient
#We print this notification at the end of the script so that RSeval will return the message

suppressMessages(setGeneric("Position", function(.Object) standardGeneric("Position")))
setGeneric("SetPosition", function(.Object, value) standardGeneric("SetPosition"))

setMethod("Position","motor",function(.Object){ 
    GetAttrInt(.Object, "position")
})

setMethod("SetPosition","motor",function(.Object, value){ 
    SetAttrInt(.Object, "position", value)
})

#Position Mode|String|Read/Write

setGeneric("PositionMode", function(.Object, value) standardGeneric("PositionMode"))
setGeneric("SetPositionMode", function(.Object, value) standardGeneric("SetPositionMode"))

setMethod("PositionMode","motor",function(.Object){
  GetAttrString(.Object, "position_mode")
})

setMethod("SetPositionMode","motor",function(.Object, value){
     SetAttrString(.Object, "position_mode", match.arg(value,c("absolute", "relative")))
})

#Position SP|Number|Read/Write
setGeneric("PositionSP", function(.Object) standardGeneric("PositionSP"))
setGeneric("SetPositionSP", function(.Object, value) standardGeneric("SetPositionSP"))

setMethod("PositionSP","motor",function(.Object){
    GetAttrInt(.Object, "position_sp")
})

setMethod("SetPositionSP","motor",function(.Object, value){
    SetAttrInt(.Object, "position_sp", value)
})

#Pulses Per Second|Number|Read

setGeneric("PulsesPerSecond", function(.Object) standardGeneric("PulsesPerSecond"))

setMethod("PulsesPerSecond","motor",function(.Object){
  GetAttrInt(.Object, "pulses_per_second")
})

#Pulses Per Second SP|Number|Read/Write

setGeneric("PulsesPerSecondSP", function(.Object) standardGeneric("PulsesPerSecondSP"))
setGeneric("SetPulsesPerSecondSP", function(.Object, value) standardGeneric("SetPulsesPerSecondSP"))


setMethod("PulsesPerSecondSP","motor",function(.Object){
    GetAttrInt(.Object, "pulses_per_second_sp")
})

setMethod("SetPulsesPerSecondSP","motor",function(.Object, value){
    SetAttrInt(.Object, "pulses_per_second_sp", value)
})

#Ramp Down SP|Number|Read/Write

setGeneric("RampDownSP", function(.Object) standardGeneric("RampDownSP"))
setGeneric("SetRampDownSP", function(.Object, value) standardGeneric("SetRampDownSP"))

setMethod("RampDownSP","motor",function(.Object){
  GetAttrInt(.Object, "ramp_down_sp")
})

setMethod("SetRampDownSP","motor",function(.Object, value){
    SetAttrInt(.Object, "ramp_down_sp", value)
})


#Ramp Up SP|Number|Read/Write

setGeneric("RampUpSP", function(.Object) standardGeneric("RampUpSP"))
setGeneric("SetRampUpSP", function(.Object, value) standardGeneric("SetRampUpSP"))

setMethod("RampUpSP","motor",function(.Object){
  GetAttrInt(.Object, "ramp_up_sp")
})

setMethod("SetRampUpSP","motor",function(.Object, value){
    SetAttrInt(.Object, "ramp_up_sp", value)
})

#Regulation Mode|String|Read/Write

setGeneric("RegulationMode", function(.Object) standardGeneric("RegulationMode"))
setGeneric("SetRegulationMode", function(.Object, value) standardGeneric("SetRegulationMode"))

setMethod("RegulationMode","motor",function(.Object){
    GetAttrString(.Object, "regulation_mode")
})

setMethod("SetRegulationMode","motor",function(.Object, value){
    SetAttrString(.Object, "regulation_mode", match.arg(value,c("on", "off")))
})


#Run|Number|Read/Write

setGeneric("Run", function(.Object, value=TRUE) standardGeneric("Run"))

setMethod("Run","motor",function(.Object, value=TRUE){
  if(missing(value) || value!=FALSE)      
    SetAttrInt(.Object, "run", 1)
  else
    SetAttrInt(.Object, "run", 0)
})

setGeneric("Stop", function(.Object) standardGeneric("Stop"))

setMethod("Stop","motor",function(.Object){
    SetAttrInt(.Object, "run", 0)
})

setGeneric("Running", function(.Object) standardGeneric("Running"))

setMethod("Running","motor",function(.Object){
  (GetAttrInt(.Object, "run")==1)
})

#Run Mode|String|Read/Write

setGeneric("RunMode", function(.Object) standardGeneric("RunMode"))
setGeneric("SetRunMode", function(.Object, value) standardGeneric("SetRunMode"))


setMethod("RunMode","motor",function(.Object){
    GetAttrString(.Object, "run_mode")
})

setMethod("SetRunMode","motor",function(.Object, value){
    SetAttrString(.Object, "run_mode", match.arg(value,c("forever", "position")))
})


#Speed Regulation P|Number|Read/Write

setGeneric("SpeedRegulationP", function(.Object) standardGeneric("SpeedRegulationP"))
setGeneric("SetSpeedRegulationP", function(.Object, value) standardGeneric("SetSpeedRegulationP"))

setMethod("SpeedRegulationP","motor",function(.Object){
    GetAttrInt(.Object, "speed_regulation_p")
})

setMethod("SetSpeedRegulationP","motor",function(.Object, value){
    SetAttrInt(.Object, "speed_regulation_p", value)
})

#Speed Regulation I|Number|Read/Write

setGeneric("SpeedRegulationI", function(.Object) standardGeneric("SpeedRegulationI"))
setGeneric("SetSpeedRegulationI", function(.Object, value) standardGeneric("SetSpeedRegulationI"))

setMethod("SpeedRegulationI","motor",function(.Object){
    GetAttrInt(.Object, "speed_regulation_i")
})

setMethod("SetSpeedRegulationI","motor",function(.Object, value){
    SetAttrInt(.Object, "speed_regulation_i", value)
})

#Speed Regulation D|Number|Read/Write

setGeneric("SpeedRegulationD", function(.Object) standardGeneric("SpeedRegulationD"))
setGeneric("SetSpeedRegulationD", function(.Object, value) standardGeneric("SetSpeedRegulationD"))

setMethod("SpeedRegulationD","motor",function(.Object){
    GetAttrInt(.Object, "speed_regulation_d")
})

setMethod("SetSpeedRegulationD","motor",function(.Object, value){      
    SetAttrInt(.Object, "speed_regulation_d", value)
})

#Speed Regulation K|Number|Read/Write

setGeneric("SpeedRegulationK", function(.Object) standardGeneric("SpeedRegulationK"))
setGeneric("SetSpeedRegulationK", function(.Object, value) standardGeneric("SetSpeedRegulationK"))

setMethod("SpeedRegulationK","motor",function(.Object){
    GetAttrInt(.Object, "speed_regulation_k")
})

setMethod("SetSpeedRegulationK","motor",function(.Object, value){
    SetAttrInt(.Object, "speed_regulation_k", value)
})

#State|String|Read

setGeneric("State", function(.Object) standardGeneric("State"))
setMethod("State","motor",function(.Object){
  GetAttrString(.Object, "state")
})

#Stop Mode|String|Read/Write

setGeneric("StopMode", function(.Object) standardGeneric("StopMode"))
setGeneric("SetStopMode", function(.Object, value) standardGeneric("SetStopMode"))

setMethod("StopMode","motor",function(.Object){
    GetAttrString(.Object, "stop_mode")
})

setMethod("SetStopMode","motor",function(.Object, value){
    SetAttrString(.Object, "stop_mode", match.arg(value,c("coast", "break", "hold")))
})


#Stop Modes|String Array|Read

setGeneric("StopModes", function(.Object) standardGeneric("StopModes"))
setMethod("StopModes","motor",function(.Object){
  GetAttrStringArray(.Object, "stop_modes")
})

#Time SP|Number|Read/Write

setGeneric("TimeSP", function(.Object) standardGeneric("TimeSP"))
setGeneric("SetTimeSP", function(.Object, value) standardGeneric("SetTimeSP"))

setMethod("TimeSP","motor",function(.Object){
    GetAttrInt(.Object, "time_sp")
})

setMethod("SetTimeSP","motor",function(.Object, value){
    SetAttrInt(.Object, "time_sp", value)
})

#Type|String|Read

setGeneric("Type", function(.Object) standardGeneric("Type"))
setMethod("Type","motor",function(.Object){
  GetAttrString(.Object, "type")
})


#Reset|Void|None|Sets the `reset` motor property to `1`, which causes the motor driver to reset all of the parameters.

setGeneric("Reset", function(.Object) standardGeneric("Reset"))
setMethod("Reset","motor",function(.Object){
  SetAttrInt(.Object, "reset", 1)
})

# sensor, infraredSensor

.sensor=setClass(Class="sensor", contains="device")

sensor = function(port, name, ...)
{
  #path="~/test/sys/class/msensor"
  path="/sys/class/msensor"
  
  files=list.files(path, full.names = TRUE)
  
  for(f in 1:length(files))
  {
    device_port=readLines(paste(files[f],"/port_name",sep=""), warn=FALSE)      
    device_name=readLines(paste(files[f],"/name",sep=""), warn=FALSE)
    
    if(missing(port) || port=="" || port==device_port )    
      if(missing(name)  || name=="" || device_name %in% name)
        return (.sensor(device( paste(files[f],"/",sep="")), ...))

  }  
    
  .sensor(device(""), ...)
}

infrared.sensor = function(port, ...) { sensor(port, "ev3-uart-33",...)  }
touch.sensor = function(port, ...) { sensor(port, "lego-ev3-touch",...)  }
color.sensor = function(port, ...) { sensor(port, "ev3-uart-29",...)  }
ultrasonic.sensor = function(port, ...) { sensor(port, "ev3-uart-30",...)  }
gyro.sensor = function(port, ...) { sensor(port, "ev3-uart-32",...)  }

#Port Name|String|Read

setMethod("PortName","sensor",function(.Object){
  GetAttrString(.Object, "port_name")
})

#Num Values|Number|Read

setGeneric("NumValues", function(.Object) standardGeneric("NumValues"))
setMethod("NumValues","sensor",function(.Object){
  GetAttrInt(.Object, "num_values")
})

#Type ID|Number|Read

# TO DO implement or not? Name instead for now
setGeneric("Name", function(.Object) standardGeneric("Name"))

setMethod("Name","sensor",function(.Object){
  GetAttrString(.Object, "name")
})

#Mode|String|Read/Write

setGeneric("Mode", function(.Object) standardGeneric("Mode"))
setGeneric("SetMode", function(.Object, value) standardGeneric("SetMode"))

setMethod("Mode","sensor",function(.Object){
  GetAttrString(.Object, "mode")  
})

setMethod("SetMode","sensor",function(.Object, value){
    modes=Modes(.Object)
    SetAttrString(.Object, "mode", match.arg(value,modes))  
})

#Modes|String Array|Read

setGeneric("Modes", function(.Object) standardGeneric("Modes"))

setMethod("Modes","sensor",function(.Object){
  GetAttrStringArray(.Object, "modes")
})

#Get Value|Number (int)|Value Index : Number|Gets the raw value at the specified index

setGeneric("Value", function(.Object, index=0) standardGeneric("Value"))
setMethod("Value","sensor",function(.Object, index){
  GetAttrInt(.Object, paste("value", index, sep=""))
})

#Get Float Value|Number (float)|Value Index : Number|Gets the value at the specified index, adjusted for the sensor's `dp` value

setGeneric("FloatValue", function(.Object, index=0) standardGeneric("FloatValue"))
setMethod("FloatValue","sensor",function(.Object, index){
  dp=GetAttrInt(.Object,"dp")
  GetAttrInt(.Object, paste("value", index, sep="")) / 10^dp
})

.power.supply=setClass(Class="power.supply", contains="device")

power.supply = function(dev, ...)
{
  path="/sys/class/power_supply"
  
  files=list.files(path)
  if(missing(dev) || dev=="")
    dev="legoev3-battery"
  
  for(f in 1:length(files))  
    if(files[f]==dev)    
        return (.power.supply (device( paste(path, "/", files[f],"/",sep="")), ...) )
  
  .power.supply(device(""), ...)
}

#Current Now|Number (int)|Read

setGeneric("CurrentNow", function(.Object) standardGeneric("CurrentNow"))
setMethod("CurrentNow","power.supply",function(.Object){
  return (GetAttrInt(.Object, "current_now"))
})

#Voltage Now|Number (int)|Read

setGeneric("VoltageNow", function(.Object) standardGeneric("VoltageNow"))
setMethod("VoltageNow","power.supply",function(.Object){
  return (GetAttrInt(.Object, "voltage_now"))
})


#Voltage Max Design|Number (int)|Read

setGeneric("VoltageMax", function(.Object) standardGeneric("VoltageMax"))
setMethod("VoltageMax","power.supply",function(.Object){
  return (GetAttrInt(.Object, "voltage_max_design"))
})

#Voltage Min Design|Number (int)|Read

setGeneric("VoltageMin", function(.Object) standardGeneric("VoltageMin"))
setMethod("VoltageMin","power.supply",function(.Object){
  return (GetAttrInt(.Object, "voltage_min_design"))
})

#Technology|String|Read

setGeneric("Technology", function(.Object) standardGeneric("Technology"))
setMethod("Technology","power.supply",function(.Object){
  return (GetAttrString(.Object, "technology"))
})

#Type|String|Read

setMethod("Type","power.supply",function(.Object){
  return (GetAttrString(.Object, "type"))
})

#Current Amps|Number (float)|Read|The amount of current, in amps, coming from the device (`current_now` / 1000000)

setGeneric("CurrentAmps", function(.Object) standardGeneric("CurrentAmps"))

setMethod("CurrentAmps","power.supply",function(.Object){
  return (CurrentNow(.Object)/ 1000000)
})

#Voltage Volts|Number (float)|Read|The number of volts (not µV) coming from the device (`voltage_now` / 1000000)

setGeneric("VoltageVolts", function(.Object) standardGeneric("VoltageVolts"))

setMethod("VoltageVolts","power.supply",function(.Object){
  return (VoltageNow(.Object) / 1000000)
})

.led=setClass(Class="led", contains="device")

led = function(dev, ...)
{
  path="/sys/class/leds"
  
  files=list.files(path)
  
  if( missing(dev) || dev=="")
    return (.led(device(""), ...))
  
  for(f in 1:length(files))  
    if(files[f]==dev)    
      return (.led(device( paste(path, "/", files[f],"/",sep="")), ...) )
  
  .led(device(""), ...)
}

#Max Brightness|Number (int)|Read

setGeneric("MaxBrightness", function(.Object) standardGeneric("MaxBrightness"))
setMethod("MaxBrightness","led",function(.Object){
  return (GetAttrInt(.Object, "max_brightness"))
})

#Brightness|Number (int)|Read/Write

setGeneric("Brightness", function(.Object) standardGeneric("Brightness"))
setGeneric("SetBrightness", function(.Object, value) standardGeneric("SetBrightness"))

setMethod("Brightness","led",function(.Object){
    GetAttrInt(.Object, "brightness")
})

setMethod("SetBrightness","led",function(.Object, value){
    SetAttrInt(.Object, "brightness", value)
})

#Trigger|String|Read/Write

setGeneric("Trigger", function(.Object) standardGeneric("Trigger"))
setGeneric("SetTrigger", function(.Object, value) standardGeneric("SetTrigger"))

setMethod("Trigger","led",function(.Object){
    GetAttrStringArray(.Object, "trigger")
})

setMethod("SetTrigger","led",function(.Object, value){
    SetAttrString(.Object, "trigger", value)
})


speak=function(..., sync=TRUE)
{
  text=paste(list(...), collapse="")
  command=paste("espeak -a 200 --stdout \"", text, "\" | aplay", collapse="")  
  if(!sync) command=paste(command, "&")
  system(command)
}

print("Creating a new generic function for ‘Position’ in the global environment")