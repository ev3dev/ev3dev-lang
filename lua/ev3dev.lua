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
  
  Device.init(self, "tacho-motor", "motor", m)

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

-- ~autogen lua_generic-get-set classes.motor>currentClass

function Motor:setCommand(value)
  self:setAttrString("command", value)
end

function Motor:commands()
  return self:getAttrStringArray("commands")
end

function Motor:countPerRot()
  return self:getAttrInt("count_per_rot")
end

function Motor:driverName()
  return self:getAttrString("driver_name")
end

function Motor:dutyCycle()
  return self:getAttrInt("duty_cycle")
end

function Motor:dutyCycleSp()
  return self:getAttrInt("duty_cycle_sp")
end

function Motor:setDutyCycleSP(value)
  self:setAttrInt("duty_cycle_sp", value)
end

function Motor:encoderPolarity()
  return self:getAttrString("encoder_polarity")
end

function Motor:setEncoderPolarity(value)
  self:setAttrString("encoder_polarity", value)
end

function Motor:polarity()
  return self:getAttrString("polarity")
end

function Motor:setPolarity(value)
  self:setAttrString("polarity", value)
end

function Motor:portName()
  return self:getAttrString("port_name")
end

function Motor:position()
  return self:getAttrInt("position")
end

function Motor:setPosition(value)
  self:setAttrInt("position", value)
end

function Motor:positionP()
  return self:getAttrInt("hold_pid/Kp")
end

function Motor:setPositionP(value)
  self:setAttrInt("hold_pid/Kp", value)
end

function Motor:positionI()
  return self:getAttrInt("hold_pid/Ki")
end

function Motor:setPositionI(value)
  self:setAttrInt("hold_pid/Ki", value)
end

function Motor:positionD()
  return self:getAttrInt("hold_pid/Kd")
end

function Motor:setPositionD(value)
  self:setAttrInt("hold_pid/Kd", value)
end

function Motor:positionSp()
  return self:getAttrInt("position_sp")
end

function Motor:setPositionSP(value)
  self:setAttrInt("position_sp", value)
end

function Motor:speed()
  return self:getAttrInt("speed")
end

function Motor:speedSp()
  return self:getAttrInt("speed_sp")
end

function Motor:setSpeedSP(value)
  self:setAttrInt("speed_sp", value)
end

function Motor:rampUpSp()
  return self:getAttrInt("ramp_up_sp")
end

function Motor:setRampUpSP(value)
  self:setAttrInt("ramp_up_sp", value)
end

function Motor:rampDownSp()
  return self:getAttrInt("ramp_down_sp")
end

function Motor:setRampDownSP(value)
  self:setAttrInt("ramp_down_sp", value)
end

function Motor:speedRegulationEnabled()
  return self:getAttrString("speed_regulation")
end

function Motor:setSpeedRegulationEnabled(value)
  self:setAttrString("speed_regulation", value)
end

function Motor:speedRegulationP()
  return self:getAttrInt("speed_pid/Kp")
end

function Motor:setSpeedRegulationP(value)
  self:setAttrInt("speed_pid/Kp", value)
end

function Motor:speedRegulationI()
  return self:getAttrInt("speed_pid/Ki")
end

function Motor:setSpeedRegulationI(value)
  self:setAttrInt("speed_pid/Ki", value)
end

function Motor:speedRegulationD()
  return self:getAttrInt("speed_pid/Kd")
end

function Motor:setSpeedRegulationD(value)
  self:setAttrInt("speed_pid/Kd", value)
end

function Motor:state()
  return self:getAttrStringArray("state")
end

function Motor:stopCommand()
  return self:getAttrString("stop_command")
end

function Motor:setStopCommand(value)
  self:setAttrString("stop_command", value)
end

function Motor:stopCommands()
  return self:getAttrStringArray("stop_commands")
end

function Motor:timeSp()
  return self:getAttrInt("time_sp")
end

function Motor:setTimeSP(value)
  self:setAttrInt("time_sp", value)
end


-- ~autogen

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
-- DC Motor
--

DCMotor = class(Device)

-- Constants
DCMotor.commandRun = "run"
DCMotor.commandBrake = "brake"
DCMotor.commandCoast = "coast"
DCMotor.polarityNormal = "normal"
DCMotor.polarityInverted = "inverted"

function DCMotor:init(port)

  local m = { port_name = { port } }
  
  Device.init(self, "dc-motor", "motor", m)

  if (self:connected()) then
    self._type = self:getAttrString("name")
    self._port = self:getAttrString("port_name")
  else
    self._type = nil
    self._port = nil
  end
end

function DCMotor:type()
  return self._type
end

function DCMotor:typeName()
  return self:getAttrString("name")
end

function DCMotor:portName()
  return self._port
end

-- ~autogen lua_generic-get-set classes.dcMotor>currentClass

function DCMotor:command()
  return self:getAttrString("command")
end

function DCMotor:setCommand(value)
  self:setAttrString("command", value)
end

function DCMotor:commands()
  return self:getAttrStringArray("commands")
end

function DCMotor:driverName()
  return self:getAttrString("driver_name")
end

function DCMotor:dutyCycle()
  return self:getAttrInt("duty_cycle")
end

function DCMotor:dutyCycleSp()
  return self:getAttrInt("duty_cycle_sp")
end

function DCMotor:setDutyCycleSP(value)
  self:setAttrInt("duty_cycle_sp", value)
end

function DCMotor:polarity()
  return self:getAttrString("polarity")
end

function DCMotor:setPolarity(value)
  self:setAttrString("polarity", value)
end

function DCMotor:portName()
  return self:getAttrString("port_name")
end

function DCMotor:rampDownMs()
  return self:getAttrInt("ramp_down_ms")
end

function DCMotor:setRampDownMS(value)
  self:setAttrInt("ramp_down_ms", value)
end

function DCMotor:rampUpMs()
  return self:getAttrInt("ramp_up_ms")
end

function DCMotor:setRampUpMS(value)
  self:setAttrInt("ramp_up_ms", value)
end


-- ~autogen

------------------------------------------------------------------------------
--
-- Servo Motor
--

ServoMotor = class(Device)

-- Constants
ServoMotor.commandRun = "run"
ServoMotor.commandFloat = "float"
ServoMotor.polarityNormal = "normal"
ServoMotor.polarityInverted = "inverted"

function ServoMotor:init(port)

  local m = { port_name = { port } }
  
  Device.init(self, "servo-motor", "motor", m)

  if (self:connected()) then
    self._type = self:getAttrString("name")
    self._port = self:getAttrString("port_name")
  else
    self._type = nil
    self._port = nil
  end
end

function ServoMotor:type()
  return self._type
end

function ServoMotor:portName()
  return self._port
end

-- ~autogen lua_generic-get-set classes.servoMotor>currentClass

function ServoMotor:command()
  return self:getAttrString("command")
end

function ServoMotor:setCommand(value)
  self:setAttrString("command", value)
end

function ServoMotor:driverName()
  return self:getAttrString("driver_name")
end

function ServoMotor:maxPulseMs()
  return self:getAttrInt("max_pulse_ms")
end

function ServoMotor:setMaxPulseMS(value)
  self:setAttrInt("max_pulse_ms", value)
end

function ServoMotor:midPulseMs()
  return self:getAttrInt("mid_pulse_ms")
end

function ServoMotor:setMidPulseMS(value)
  self:setAttrInt("mid_pulse_ms", value)
end

function ServoMotor:minPulseMs()
  return self:getAttrInt("min_pulse_ms")
end

function ServoMotor:setMinPulseMS(value)
  self:setAttrInt("min_pulse_ms", value)
end

function ServoMotor:polarity()
  return self:getAttrString("polarity")
end

function ServoMotor:setPolarity(value)
  self:setAttrString("polarity", value)
end

function ServoMotor:portName()
  return self:getAttrString("port_name")
end

function ServoMotor:position()
  return self:getAttrInt("position")
end

function ServoMotor:setPosition(value)
  self:setAttrInt("position", value)
end

function ServoMotor:rate()
  return self:getAttrInt("rate")
end

function ServoMotor:setRate(value)
  self:setAttrInt("rate", value)
end


-- ~autogen

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

-- ~autogen lua_generic-get-set classes.sensor>currentClass

function Sensor:setCommand(value)
  self:setAttrString("command", value)
end

function Sensor:commands()
  return self:getAttrStringArray("commands")
end

function Sensor:decimals()
  return self:getAttrInt("decimals")
end

function Sensor:driverName()
  return self:getAttrString("driver_name")
end

function Sensor:mode()
  return self:getAttrString("mode")
end

function Sensor:setMode(value)
  self:setAttrString("mode", value)
end

function Sensor:modes()
  return self:getAttrStringArray("modes")
end

function Sensor:numValues()
  return self:getAttrInt("num_values")
end

function Sensor:portName()
  return self:getAttrString("port_name")
end

function Sensor:units()
  return self:getAttrString("units")
end


-- ~autogen

------------------------------------------------------------------------------
--
-- I2C Sensor
--

I2CSensor = class(Sensor)

function I2CSensor:init(port, i2cAddress)
  local m = { port_name = { port } }
  m["name"] = { "nxt-i2c-sensor" }
  
  if (i2cAddress ~= nil) then
    m["address"] = i2cAddress
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

-- ~autogen lua_generic-get-set classes.i2cSensor>currentClass

function I2CSensor:fwVersion()
  return self:getAttrString("fw_version")
end

function I2CSensor:pollMs()
  return self:getAttrInt("poll_ms")
end

function I2CSensor:setPollMS(value)
  self:setAttrInt("poll_ms", value)
end


-- ~autogen

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

-- ~autogen lua_generic-get-set classes.powerSupply>currentClass

function PowerSupply:measuredCurrent()
  return self:getAttrInt("current_now")
end

function PowerSupply:measuredVoltage()
  return self:getAttrInt("voltage_now")
end

function PowerSupply:maxVoltage()
  return self:getAttrInt("voltage_max_design")
end

function PowerSupply:minVoltage()
  return self:getAttrInt("voltage_min_design")
end

function PowerSupply:technology()
  return self:getAttrString("technology")
end

function PowerSupply:type()
  return self:getAttrString("type")
end


-- ~autogen

function PowerSupply:currentAmps()
  return self:getAttrInt("current_now") / 1000000
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

-- ~autogen lua_generic-get-set classes.led>currentClass

function LED:maxBrightness()
  return self:getAttrInt("max_brightness")
end

function LED:brightness()
  return self:getAttrInt("brightness")
end

function LED:setBrightness(value)
  self:setAttrInt("brightness", value)
end

function LED:trigger()
  return self:getAttrString("trigger")
end

function LED:setTrigger(value)
  self:setAttrString("trigger", value)
end


-- ~autogen

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
