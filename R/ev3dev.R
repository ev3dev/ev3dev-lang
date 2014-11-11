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
 
#   Compatibile ev3dev kernels:
#   3.16.1-4-ev3dev
#   3.16.1-5-ev3dev
#   3.16.1-6-ev3dev

#TO DO - TypeId for sensor or Name? Name currently, no type_id in ev3dev-jessie-2014-10-07 (pre-release)
#TO DO - is it an issue really? function Position is creating a new generic function for ‘Position’ in the global environment (instead builtin Position)
#TO DO - documentation

# Constants 

ports=list(INPUT_AUTO="" , INPUT_1="in1", INPUT_2="in2", INPUT_3="in3", INPUT_4="in4",
           OUTPUT_AUTO="", OUTPUT_A="outA", OUTPUT_B="outB", OUTPUT_C="outC", OUTPUT_D="outD")



# device 

.device=setClass(Class="device", representation=representation(cache="environment"))

setMethod("initialize", "device",
          function(.Object, path="", ... , cache=new.env( parent=emptyenv() )){
            cache$.path=path
            callNextMethod(.Object, cache=cache, ...)
          })

setGeneric("GetAttrString", function(.Object, name) standardGeneric("GetAttrString"))
setGeneric("GetAttrStringArray", function(.Object, name) standardGeneric("GetAttrStringArray"))
setGeneric("SetAttrString", function(.Object, name, value) standardGeneric("SetAttrString"))
setGeneric("SetAttrStringArray", function(.Object, name, value) standardGeneric("SetAttrStringArray"))
setGeneric("GetAttrInt", function(.Object, name) standardGeneric("GetAttrInt"))
setGeneric("SetAttrInt", function(.Object, name, value) standardGeneric("SetAttrInt"))
setGeneric("Connected", function(.Object) standardGeneric("Connected"))
setGeneric("DeviceIndex", function(.Object) standardGeneric("DeviceIndex"))

ErrorMessage=function(device_path="", name="")
{
  msg=paste("Unable to access property \"", name, "\" of device ", device_path, sep="")
  if(!file.exists(device_path))
     msg=paste(msg, "\nDevice doesn't exist (disconnected?)")
  else if(!file.exists(paste(device_path , name,sep="")))
    msg=paste(msg, "\nDevice property doesn't exist.")
  else
    msg=paste(msg, "\nCheck device permissions.s") 
  msg=paste(msg, "\nDevice has to be created again")
  msg
}

CheckSystemPath=function(path)
{
  if(!file.exists(path))
  {
    msg=paste("EV3 system path", path,"doesn't exist or is inaccessible.")
    msg=paste(msg, "\nIs device of this type connected to EV3?")
    msg=paste(msg, "\nAre you execeuting the function on ev3dev platform?")
    msg=paste(msg, "\nPossible causes: device not connected to EV3 or function executed on local PC instead of remote EV3")
    print(msg)
  }
}

setMethod("GetAttrString","device",function(.Object, name){  
  stopifnot(Connected(.Object))
  tryCatch( 
    readLines(paste(.Object@cache$.path,name,sep=""),warn=FALSE)
  , error=function(e)
    {
      msg=ErrorMessage(.Object@cache$.path, name)
      .Object@cache$.path="" #Disconnect from device
      stop(msg, call.=FALSE)
    } )
})


setMethod("GetAttrStringArray","device",function(.Object, name){
  stopifnot(Connected(.Object))
  tryCatch( 
    scan(paste(.Object@cache$.path,name,sep=""), what=character(), quiet=TRUE)
    , error=function(e)
    {
      msg=ErrorMessage(.Object@cache$.path, name)
      .Object@cache$.path="" #Disconnect from device
      stop(msg, call.=FALSE)
    } )  
})

setMethod("SetAttrString","device",function(.Object, name, value){
  stopifnot(Connected(.Object))
  tryCatch( 
    cat(value, file=paste(.Object@cache$.path,name,sep="") )
    , error=function(e)
    {
      msg=ErrorMessage(.Object@cache$.path, name)
      .Object@cache$.path="" #Disconnect from device
      stop(msg, call.=FALSE)
    } )  
      
  value
})

setMethod("SetAttrStringArray","device",function(.Object, name, value){
  stopifnot(Connected(.Object))
  tryCatch( 
    cat(paste(value, collapse=" "), file=paste(.Object@cache$.path,name,sep="") )
    , error=function(e)
    {
      msg=ErrorMessage(.Object@cache$.path, name)
      .Object@cache$.path="" #Disconnect from device
      stop(msg, call.=FALSE)
    } )  
})


setMethod("GetAttrInt","device",function(.Object, name){
  stopifnot(Connected(.Object))
  tryCatch( 
    as.integer(readLines(paste(.Object@cache$.path,name,sep=""),warn=FALSE))
    , error=function(e)
    {
      msg=ErrorMessage(.Object@cache$.path, name)
      .Object@cache$.path="" #Disconnect from device
      stop(msg, call.=FALSE)
    } )      
})

setMethod("SetAttrInt","device",function(.Object, name, value){
  stopifnot(Connected(.Object))
  tryCatch( 
    cat(as.integer(value), file=paste(.Object@cache$.path,name,sep=""))
    , error=function(e)
    {
      msg=ErrorMessage(.Object@cache$.path, name)
      .Object@cache$.path="" #Disconnect from device
      stop(msg, call.=FALSE)
    } )      
  
  value
})

setMethod("Connected","device",function(.Object){
  .Object@cache$.path != ""
})

# motor, medium motor, large motor

.motor=setClass(Class="motor", contains="device")

setMethod("initialize", "motor",
          function(.Object, port="", type="", ... ){
            #path="~/test/sys/class/tacho-motor"
            path="/sys/class/tacho-motor"            
            device_path=""
            
            if(file.exists(path))
            {            
              files=list.files(path, full.names = TRUE)
              
              for(f in 1:length(files))
              {
                device_port=try(readLines(paste(files[f],"/port_name",sep=""), warn=FALSE), silent = TRUE)
                device_type=try(readLines(paste(files[f],"/type",sep=""), warn=FALSE), silent=TRUE)
                if(!(is.character(device_port) & is.character(device_type)))
                  next
                                  
                if(missing(port) || port=="" || port==device_port )    
                  if(missing(type)  || type=="" || type==device_type)                  
                  {
                    device_path=paste(files[f],"/",sep="")
                    break
                  }              
              }  
            }                                          
            callNextMethod(.Object, path=device_path, ...)
          })

motor = function(port="", type="", ...)
{
  .motor(port, type, ...)
}
medium.motor = function(port="", ...)
{
  motor(port, "minitacho", ...)
}
large.motor = function(port="", ...)
{
  motor(port, "tacho", ...)
}

setMethod("DeviceIndex","motor",function(.Object){  
  stopifnot(Connected(.Object))
  device_name=basename(.Object@cache$.path)
  match=regexpr("[[:digit:]]+$", device_name) #match the digits at the end
  as.integer(substr(device_name, match, match+attr(match, "match.length")  ) )
})


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
    SetAttrInt(.Object, "run", 1L)
  else
    SetAttrInt(.Object, "run", 0L)
})

setGeneric("Stop", function(.Object) standardGeneric("Stop"))

setMethod("Stop","motor",function(.Object){
    SetAttrInt(.Object, "run", 0L)
})

setGeneric("Running", function(.Object) standardGeneric("Running"))

setMethod("Running","motor",function(.Object){
  (GetAttrInt(.Object, "run")==1L)
})

#Run Mode|String|Read/Write

setGeneric("RunMode", function(.Object) standardGeneric("RunMode"))
setGeneric("SetRunMode", function(.Object, value) standardGeneric("SetRunMode"))


setMethod("RunMode","motor",function(.Object){
    GetAttrString(.Object, "run_mode")
})

setMethod("SetRunMode","motor",function(.Object, value=c("forever", "position", "time")){
  value=match.arg(value)  
  SetAttrString(.Object, "run_mode", value)
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

setMethod("SetStopMode","motor",function(.Object, value=c("coast", "break", "hold")){
    value=match.arg(value)
    SetAttrString(.Object, "stop_mode", value)
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
  SetAttrInt(.Object, "reset", 1L)
})

# sensor, infraredSensor

.sensor=setClass(Class="sensor", contains="device")

setMethod("initialize", "sensor",
          function(.Object, port="", name="", ... ){            
  
  callNextMethod(.Object, "", ...)            
  .Object@cache$.path=""
  .Object@cache$.dp_scale=1
  .Object@cache$.num_values=0
    
  #path="~/test/sys/class/msensor"
  path="/sys/class/msensor"
    
  if(file.exists(path))
  {  
    files=list.files(path, full.names = TRUE)
    
    for(f in 1:length(files))
    {
      device_port=try(readLines(paste(files[f],"/port_name",sep=""), warn=FALSE))
      device_name=try(readLines(paste(files[f],"/name",sep=""), warn=FALSE))
      
      if(!(is.character(device_port) & is.character(device_name)))
        next
      
      if(missing(port) || port=="" || port==device_port )    
        if(missing(name)  || name=="" || device_name %in% name)
        {
          .Object@cache$.path=paste(files[f],"/",sep="")
          .Object@cache$.dp_scale=try(10^GetAttrInt(.Object, "dp"))
          .Object@cache$.num_values=try(NumValues(.Object))                
          break
        }
    }
  }
  .Object  
})

sensor=function(port="", name="", ...) {.sensor(port, name,...)}
infrared.sensor = function(port="", ...) {sensor(port, "ev3-uart-33",...)  }
touch.sensor = function(port="", ...) { sensor(port, "lego-ev3-touch",...)  }
color.sensor = function(port="", ...) { sensor(port, "ev3-uart-29",...)  }
ultrasonic.sensor = function(port="", ...) { sensor(port, "ev3-uart-30",...)  }
gyro.sensor = function(port="", ...) { sensor(port, "ev3-uart-32",...)  }

setMethod("DeviceIndex","sensor",function(.Object){  
  stopifnot(Connected(.Object))
  device_name=basename(.Object@cache$.path)
  match=regexpr("[[:digit:]]+$", device_name) #match the digits at the end
  as.integer(substr(device_name, match, match+attr(match, "match.length")  ) )
3})


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
    mode=SetAttrString(.Object, "mode", match.arg(value,modes))  
    .Object@cache$.dp_scale=10^GetAttrInt(.Object, "dp")
    .Object@cache$.num_values=NumValues(.Object)  
    mode
})

#Modes|String Array|Read

setGeneric("Modes", function(.Object) standardGeneric("Modes"))

setMethod("Modes","sensor",function(.Object){
  GetAttrStringArray(.Object, "modes")
})

#Get Value|Number (int)|Value Index : Number|Gets the raw value at the specified index

setGeneric("Value", function(.Object, index=0L) standardGeneric("Value"))
setMethod("Value","sensor",function(.Object, index){
  stopifnot(index<.Object@cache$.num_values)
  GetAttrInt(.Object, paste("value", index, sep=""))
})

#Get Float Value|Number (float)|Value Index : Number|Gets the value at the specified index, adjusted for the sensor's `dp` value

setGeneric("FloatValue", function(.Object, index=0L) standardGeneric("FloatValue"))
setMethod("FloatValue","sensor",function(.Object, index){
  stopifnot(index<.Object@cache$.num_values)
  GetAttrInt(.Object, paste("value", index, sep="")) / .Object@cache$.dp_scale 
})

.power.supply=setClass(Class="power.supply", contains="device")

setMethod("initialize", "power.supply",
          function(.Object, dev="", ... ){            
  path="/sys/class/power_supply"
  device_path=""              
    
  if(file.exists(path))
  {  
    files=list.files(path)
    if(missing(dev) || dev=="")
      dev="legoev3-battery"
    
    for(f in 1:length(files))  
      if(files[f]==dev)    
      {
          device_path=paste(path, "/", files[f],"/",sep="")
          break
      }
  }  
  callNextMethod(.Object, path=device_path, ...)
}
)

power.supply=function(dev="") {.power.supply(dev=dev)}

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

setMethod("initialize", "led",
          function(.Object, dev="", ... ){            

  path="/sys/class/leds"
  device_path=""      
      
  if(file.exists(path))
  {  
    files=list.files(path)
    
    if( missing(dev) || dev=="")
      device_path=""
    
    for(f in 1:length(files))  
      if(files[f]==dev)
      {
        device_path=paste(path, "/", files[f],"/",sep="")
        break
      }
  }  
  callNextMethod(.Object, path=device_path, ...)
})

led=function(dev="") {.led(dev=dev)}

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
    SetAttrStringArray(.Object, "trigger", value)
})


Speak=function(..., sync=TRUE)
{
  text=paste(list(...), collapse="")
  command=paste("espeak -a 200 --stdout \"", text, "\" | aplay", collapse="")  
  if(!sync) command=paste(command, "&")
  system(command, intern=TRUE, ignore.stderr=TRUE)
}

#print("Creating a new generic function for ‘Position’ in the global environment")