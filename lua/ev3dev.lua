--
-- lua API to the sensors, motors, buttons, LEDs and battery of the ev3dev
-- Linux kernel for the LEGO Mindstorms EV3 hardware
--
-- Copyright (c) 2014 - Franz Detro
--
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
--

require 'class'

------------------------------------------------------------------------------

local sys_class   = "/sys/class/"
local sys_sound   = "/sys/devices/platform/snd-legoev3/"
local sys_power   = "/sys/class/power_supply/"

------------------------------------------------------------------------------
-- Device

Device = class()

function Device:init(sys_class_dir, pattern, match)

  if (sys_class_dir == nil) then
    error("connect needs sys_class_dir")
  end

  if (pattern == nil) then
    error("connect needs pattern")
  end

  -- check that sys_class_dir exists
  local r = io.popen("find "..sys_class.." -name '"..sys_class_dir.."'")
  local dir = r:read("*l")
  r:close()
  
  if (dir == nil) then
    return
  end

  -- lookup all pattern entries
  local devices = io.popen("find "..sys_class..sys_class_dir.." -name '"..pattern.."*'")
  for d in devices:lines() do
    self._path = d.."/"

    local success = true
    if (match ~= nil) then      
      for attr,matches in pairs(match) do
        success = false
        
        -- read attribute
        local pf = io.open(self._path..attr, "r")
        if (pf ~= nil) then
          -- read string value
          local value = pf:read("*l")
          if (value ~= nil) then
            -- check against matches
            local empty = true
            for i,entry in pairs(matches) do
              empty = false
              if (value == entry) then
                success = true
                break
              else 
               matched = false
              end
            end
            -- empty match list is success
            if (empty) then
              success = true
            end
          end
        end
        
        if not success then
          break
        end
      end
    end
    
    if (success) then
      devices:close()
      return true
    end
  end

  devices:close()

  self._path = nil
  
  return false
end

function Device:connected()
  return (self._path ~= nil)
end    

function Device:getAttrInt(name)

  if (self._path == nil) then
    error("no device connected")
  end
  
  local tf = io.open(self._path..name, "r")

  if (tf == nil) then
    error("no such attribute: "..self._path..name)
  end

  local result = tf:read("*n")
  tf:close()
  
  return result
end

function Device:setAttrInt(name, value)

  if (self._path == nil) then
    error("no device connected")
  end
  
  local tf = io.open(self._path..name, "w")

  if (tf == nil) then
    error("no such attribute: "..self._path..name)
  end

  tf:write(tostring(value))
  tf:close()
end

function Device:getAttrString(name)
  
  if (self._path == nil) then
    error("no device connected")
  end
  
  local tf = io.open(self._path..name, "r")

  if (tf == nil) then
    error("no such attribute: "..self._path..name)
  end

  local s = tf:read("*l")
  tf:close()
      
  return s
end

function Device:setAttrString(name, value)
  
  if (self._path == nil) then
    error("no device connected")
  end
  
  local tf = io.open(self._path..name, "w")

  if (tf == nil) then
    error("no such attribute: "..self._path..name)
  end
  
  tf:write(value)
  tf:close()
end

------------------------------------------------------------------------------
-- Port constants

INPUT_AUTO = nil
INPUT_1    = "in1"
INPUT_2    = "in2"
INPUT_3    = "in3"
INPUT_4    = "in4"
 
OUTPUT_AUTO = nil
OUTPUT_A    = "outA"
OUTPUT_B    = "outB"
OUTPUT_C    = "outC"
OUTPUT_D    = "outD"

------------------------------------------------------------------------------
--
-- Motor
--

Motor = class(Device)

Motor.Large  = "tacho"
Motor.Medium = "minitacho"

Motor.ModeOff = "off"
Motor.ModeOn  = "on"

Motor.RunModeForever  = "forever"
Motor.RunModeTime     = "time"
Motor.RunModePosition = "position"
    
Motor.PolarityModePositive = "positive"
Motor.PolarityModeNegative = "negative"
    
Motor.PositionModeAbsolute = "absolute"
Motor.PositionModeRelative = "relative"

function Motor:init(port, motor_types)

  local m = { port_name = { port } }
  
  if (motor_types ~= nil) then
    m["type"] = motor_types
  end
  
  Device.init(self, "tacho-motor", "tacho-motor", m)

  if (self:connected()) then
    self._type = self:getAttrString("type")
    self._port = self:getAttrString("port_name")
  else
    self._type = nil
    self._port = nil
  end
end

function Motor:type()
  return self._type
end

function Motor:portName()
  return self._port
end

function Motor:state()
  return self:getAttrString("state")
end

function Motor:run(run)
  if ((run == nil) or (run ~= 0)) then
    self:setAttrInt("run", 1)
  else
    self:setAttrInt("run", 0)
  end
end

function Motor:stop()
  self:setAttrInt("run", 0)
end

function Motor:reset()
  self:setAttrInt("reset", 1)
end

function Motor:running()
  return (self:getAttrInt("run") ~= 0)
end

function Motor:dutyCycle()
  return self:getAttrInt("duty_cycle")
end

function Motor:pulsesPerSecond()
  return self:getAttrInt("pulses_per_second")
end

function Motor:position()
  return self:getAttrInt("position")
end

function Motor:setPosition(value)
  self:setAttrInt("position", value)
end

function Motor:runMode()
  return self:getAttrString("run_mode")
end

function Motor:setRunMode(value)
  self:setAttrString("run_mode", value)
end

function Motor:stopModes()
  return self:getAttrStringArray("stop_modes")
end

function Motor:stopMode()
  return self:getAttrString("stop_mode")
end

function Motor:setStopMode(value)
  self:setAttrString("stop_mode", value)
end

function Motor:regulationMode()
  return self:getAttrString("regulation_mode")
end

function Motor:setRegulationMode(value)
  self:setAttrString("regulation_mode", value)
end

function Motor:positionMode()
  return self:getAttrString("position_mode")
end

function Motor:setPositionMode(value)
  self:setAttrString("position_mode", value)
end

function Motor:dutyCycleSP()
  return self:getAttrInt("duty_cycle_sp")
end

function Motor:setDutyCycleSP(value)
  self:setAttrInt("duty_cycle_sp", value)
end

function Motor:pulsesPerSecondSP()
  return self:getAttrInt("pulses_per_second_sp")
end

function Motor:setPulsesPerSecondSP(value)
  self:setAttrInt("pulses_per_second_sp", value)
end

function Motor:timeSP()
  return self:getAttrInt("time_sp")
end

function Motor:setTimeSP(value)
  self:setAttrInt("time_sp", value)
end

function Motor:positionSP()
  return self:getAttrInt("position_sp")
end

function Motor:setPositionSP(value)
  self:setAttrInt("position_sp", value)
end

function Motor:rampUpSP()
  return self:getAttrInt("ramp_up_sp")
end

function Motor:setRampUpSP(value)
  self:setAttrInt("ramp_up_sp", value)
end

function Motor:rampDownSP()
  return self:getAttrInt("ramp_down_sp")
end

function Motor:setRampDownSP(value)
  self:setAttrInt("ramp_down_sp", value)
end

function Motor:speedRegulationP()
  return self:getAttrInt("speed_regulation_p")
end

function Motor:setSpeedRegulationP(value)
  self:setAttrInt("speed_regulation_p", value)
end

function Motor:speedRegulationI()
  return self:getAttrInt("speed_regulation_i")
end

function Motor:setSpeedRegulationI(value)
  self:setAttrInt("speed_regulation_i", value)
end

function Motor:speedRegulationD()
  return self:getAttrInt("speed_regulation_d")
end

function Motor:setSpeedRegulationD(value)
  self:setAttrInt("speed_regulation_d", value)
end

function Motor:speedRegulationK()
  return self:getAttrInt("speed_regulation_k")
end

function Motor:setSpeedRegulationK(value)
  self:setAttrInt("speed_regulation_k", value)
end

------------------------------------------------------------------------------
-- LargeMotor

LargeMotor = class(Motor)

function LargeMotor:init(port)
  Motor.init(self, port, { "tacho" } )
end

------------------------------------------------------------------------------
-- MediumMotor

MediumMotor = class(Motor)

function MediumMotor:init(port)
  Motor.init(self, port, { "minitacho" } )
end

------------------------------------------------------------------------------
--
-- Sensor
--

Sensor = class(Device)

Sensor.NXTTouch       = "lego-nxt-touch"
Sensor.NXTLight       = "lego-nxt-light"
Sensor.NXTSound       = "lego-nxt-sound"
Sensor.NXTUltrasonic  = "lego-nxt-ultrasonic"

Sensor.EV3Touch       = "lego-ev3-touch"
Sensor.EV3Color       = "ev3-uart-29"
Sensor.EV3Ultrasonic  = "ev3-uart-30"
Sensor.EV3Gyro        = "ev3-uart-32"
Sensor.EV3Infrared    = "ev3-uart-33"

function Sensor:init(port, sensor_types)
  local m = { port_name = { port } }
  
  if (sensor_types ~= nil) then
    m["name"] = sensor_types
  end
  
  Device.init(self, "msensor", "sensor", m)

  if (self:connected()) then
    self._type = self:getAttrString("name")
    self._port = self:getAttrString("port_name")
  else
    self._type = nil
    self._port = nil
  end
end

function Sensor:type()
  return self._type
end

function Sensor:portName()
  return self._port
end

function Sensor:modes()
  return self:getAttrString("modes")
end

function Sensor:mode()
  return self:getAttrString("mode")
end

function Sensor:setMode(value)
  self:setAttrString("mode", value)
end

function Sensor:numValues()
  return self:getAttrInt("num_values")
end

function Sensor:value(id)

  if (id == nil) then
    id = 0
  end

  return self:getAttrInt("value"..id)
end

function Sensor:floatValue(id)

  if (id == nil) then
    id = 0
  end

  local scale = math.pow(10, -self:getAttrInt("dp"))
  return self:getAttrInt("value"..id) * scale
end

function Sensor:dp()
  return self:getAttrInt("dp")
end

------------------------------------------------------------------------------
-- TouchSensor

TouchSensor = class(Sensor)

function TouchSensor:init(port)
  Sensor.init(self, port, { Sensor.EV3Touch })
end

function TouchSensor:pressed()
  return self:value(0)
end

------------------------------------------------------------------------------
-- ColorSensor

ColorSensor = class(Sensor)

ColorSensor.ModeReflect = "COL-REFLECT"
ColorSensor.ModeAmbient = "COL-AMBIENT"
ColorSensor.ModeColor   = "COL-COLOR"

function ColorSensor:init(port)
  Sensor.init(self, port, { Sensor.EV3Color } )
end

------------------------------------------------------------------------------
-- UltrasonicSensor

UltrasonicSensor = class(Sensor)

UltrasonicSensor.ModeDistCM   = "US-DIST-CM"
UltrasonicSensor.ModeDistIN   = "US-DIST-IN"
UltrasonicSensor.ModeListen   = "US-LISTEN"
UltrasonicSensor.ModeSingleCM = "US-SI-CM"
UltrasonicSensor.ModeSingleIN = "US-SI-IN"

function UltrasonicSensor:init(port)
  Sensor.init(self, port, { Sensor.EV3Ultrasonic } )
end

------------------------------------------------------------------------------
-- GyroSensor

GyroSensor = class(Sensor)

GyroSensor.ModeAngle         = "GYRO-ANG"
GyroSensor.ModeSpeed         = "GYRO-RATE"
GyroSensor.ModeAngleAndSpeed = "GYRO-G&A"

function GyroSensor:init(port)
  Sensor.init(self, port, { Sensor.EV3Gyro } )
end

------------------------------------------------------------------------------
-- InfraredSensor

InfraredSensor = class(Sensor)

InfraredSensor.ModeProximity = "IR-PROX"
InfraredSensor.ModeIRSeeker  = "IR-SEEK"
InfraredSensor.ModeIRRemote  = "IR-REMOTE"

function InfraredSensor:init(port)
  Sensor.init(self, port, { Sensor.EV3Infrared } )
end

------------------------------------------------------------------------------
--
-- Power Supply
--

PowerSupply = class(Device)

function PowerSupply:init(device)
  if (device ~= nil) then
    self._path = sys_power..device.."/"
  else
    self._path = sys_power.."legoev3-battery/"
  end

  local file = io.open(self._path.."voltage_now")
  if (file ~= nil) then 
    file:close()
  else
    self._path = nil
  end
end

function PowerSupply:currentNow()
  return self:getAttrInt("current_now")
end

function PowerSupply:voltageNow()
  return self:getAttrInt("voltage_now")
end

function PowerSupply:voltageMinDesign()
  return self:getAttrInt("voltage_min_design")
end

function PowerSupply:voltageMaxDesign()
  return self:getAttrInt("voltage_max_design")
end

function PowerSupply:technology()
  return self:getAttrString("technology")
end

function PowerSupply:type()
  return self:getAttrString("type")
end

function PowerSupply:currentAmps()
  return self:getAttrInt("current_now") / 1000
end

function PowerSupply:voltageVolts()
  return self:getAttrInt("voltage_now") / 1000000
end

Battery = PowerSupply()

------------------------------------------------------------------------------
--
-- LED
--

LED = class(Device)

function LED:init(name)
  self._path = sys_class.."leds/"..name.."/"

  local file = io.open(self._path.."brightness")
  if (file ~= nil) then
    file:close()
  else
    self._path = nil
  end
end

function LED:brightness()
  return self:getAttrInt("brightness")
end

function LED:setBrightness(value)
  self:setAttrInt("brightness", value)
end

function LED:maxBrightness()
  return self:getAttrInt("max_brightness")
end

function LED:trigger()
  local file = io.open(self._path.."trigger", "r")
  if (file ~= nil) then
    local m = string.match(file:read(), "%[%w+[%-%w+]*%]")
    file:close()
    if (m.len) then
      return string.match(m, "%w+[%-%w+]*")
    end
  end
  
  return ""
end

function LED:setTrigger(value)
  self:setAttrString("trigger", value)
end

function LED:on()
  self:setAttrInt("brightness", self:maxBrightness())
end

function LED:off()
  self:setAttrInt("brightness", 0)
end

function LED:flash(interval)
  self:setTrigger("timer")
  if ((interval ~= nil) and (interval ~= 0)) then
    self:setOnDelay(interval)
    self:setOffDelay(interval)
  end 
end

function LED:setOnDelay(ms)
  self:setAttrInt("delay_on", ms)
end

function LED:setOffDelay(ms)
  self:setAttrInt("delay_off", ms)
end
  
function LED:triggers()
  local file = io.open(self._path.."trigger", "r")
  if (file ~= nil) then 
    local m = file:read()
    file:close()
    if (m.len) then
      return m
    end
  end
  
  return ""
end

ledRedRight   = LED("ev3:red:right")
ledRedLeft    = LED("ev3:red:left")
ledGreenRight = LED("ev3:green:right")
ledGreenLeft  = LED("ev3:green:left")

function LED.redOn()
  ledRedRight:on()
  ledRedLeft:on()
end

function LED.redOff()
  ledRedRight:off()
  ledRedLeft:off()
end

function LED.greenOn()
  ledGreenRight:on()
  ledGreenLeft:on()
end

function LED.greenOff()
  ledGreenRight:off()
  ledGreenLeft:off()
end

function LED.allOn()
  self:redOn()
  self:greenOn()
end

function LED.allOff()
  self:redOff()
  self:greenOff()
end

------------------------------------------------------------------------------
--Sound
Sound = class()

function Sound.beep()
  Sound.tone(1000, 100)
end

function Sound.tone(frequency, durationMS)
  local file = io.open(sys_sound.."tone", "w")
  if (file ~= nil) then 
    if (durationMS ~= nil) then
      file:write(" "..frequency.." "..durationMS)
    else
      file:write(frequency)
    end   
    file:close()
  end 
end

function Sound.play(soundfile)
  os.execute("aplay "..soundfile)
end

function Sound.speak(text)
  os.execute("espeak -a 200 --stdout \""..text.."\" | aplay")
end

function Sound.volume()
  local file = io.open(sys_sound.."volume")
  if (file ~= nil) then 
    local val = file:read("*n")
    file:close()
    return val
  end 
  
  return 50
end

function Sound.setVolume(levelInPercent)
  local file = io.open(sys_sound.."volume", "w")
  if (file ~= nil) then
    file:write(levelInPercent)
    file:close()
  end 
end

------------------------------------------------------------------------------
--RemoteControl
RemoteControl = class()

function RemoteControl:init(sensor, channel)
  if (sensor ~= nil) then
    if (sensor:type() == Sensor.EV3Infrared) then
      self._sensor = sensor
    end
  else
    self._sensor = InfraredSensor()
  end

  if (self._sensor ~= nil) then
    self._sensor:setMode(InfraredSensor.ModeIRRemote)
  end

  if (channel ~= nil) then
    self._channel = channel-1
  else
    self._channel = 0
  end
  
  self._lastValue = 0
  self._redUp     = false
  self._redDown   = false
  self._blueUp    = false
  self._blueDown  = false
  self._beacon    = false
end

function RemoteControl:connected()
  if (self._sensor ~= nil) then
    return self._sensor:connected()
  end
  
  return false
end

function RemoteControl:process()

  if (self._sensor ~= nil) then
    
    local value = self._sensor:value(self._channel)
    if (value ~= self._lastValue) then
      self:onNewValue(value)
      self._lastValue = value
      return true
    end
    
  end
  
end

function RemoteControl:onNewValue(value)

  local redUp    = false
  local redDown  = false
  local blueUp   = false
  local blueDown = false
  local beacon   = false
  
  if     (value == 1) then
    redUp = true
  elseif (value == 2) then
    redDown = true
  elseif (value == 3) then
    blueUp = true
  elseif (value == 4) then
    blueDown = true
  elseif (value == 5) then
    redUp  = true
    blueUp = true
  elseif (value == 6) then
    redUp    = true
    blueDown = true
  elseif (value == 7) then
    redDown = true
    blueUp  = true
  elseif (value == 8) then
    redDown  = true
    blueDown = true
  elseif (value == 9) then
    beacon = true
  elseif (value == 10) then
    redUp   = true
    redDown = true
  elseif (value == 11) then
    blueUp   = true
    blueDown = true
  end
  
  if (redUp ~= self._redUp) then
    self:onRedUp(redUp)
    self._redUp = redUp
  end
  if (redDown ~= self._redDown) then
    self:onRedDown(redDown)
    self._redDown = redDown
  end
  if (blueUp ~= self._blueUp) then
    self:onBlueUp(blueUp)
    self._blueUp = blueUp
  end
  if (blueDown ~= self._blueDown) then
    self:onBlueDown(blueDown)
    self._blueDown = blueDown
  end
  if (beacon ~= self._beacon) then
    self:onBeacon(beacon)
    self._beacon = beacon
  end
  
end

function RemoteControl:onRedUp(pressed)
end

function RemoteControl:onRedDown(pressed)
end
  
function RemoteControl:onBlueUp(pressed)
end

function RemoteControl:onBlueDown(pressed)
end

function RemoteControl:onBeacon(on)
end
