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
local sys_msensor = "/sys/class/msensor/"
local sys_motor   = "/sys/class/tacho-motor/"
local sys_button  = "/sys/devices/platform/ev3dev/button"
local sys_sound   = "/sys/devices/platform/snd-legoev3/"
local sys_power   = "/sys/class/power_supply/legoev3-battery/"

------------------------------------------------------------------------------
-- Device

Device = class()

function Device:getAttrInt(name)

	local tf = io.open(self._path..name, "r")
  assert(tf ~= nil)

	local result = tf:read("*n")
	tf:close()
  
  return result;
end

function Device:setAttrInt(name, value)

	local tf = io.open(self._path..name, "w")
  assert(tf ~= nil)

	tf:write(tostring(value))
	tf:close()
end

function Device:getAttrString(name)
	
	local tf = io.open(self._path..name, "r")
  assert(tf ~= nil)

	local s = tf:read("*l")
	tf:close()
			
	return s
end

function Device:setAttrString(name, value)
	
	local tf = io.open(self._path..name, "w")
  assert(tf ~= nil)
	
	tf:write(value)
	tf:close()
end

------------------------------------------------------------------------------
-- Sensor

Sensor = class(Device)

Sensor.NXTTouch       = 1
Sensor.NXTLight       = 2
Sensor.NXTSound       = 3
Sensor.NXTColor       = 4
Sensor.NXTUltrasonic  = 5
Sensor.NXTTemperature = 6
    
Sensor.EV3Touch       = 16
Sensor.EV3Color       = 29
Sensor.EV3Ultrasonic  = 30
Sensor.EV3Gyro        = 32
Sensor.EV3Infrared    = 33

function Sensor:init(sensor_type, port)

	self._type = 0
	self._port = 0

	for i = 0, 9 do
		self._path = sys_msensor.."sensor"..i.."/"
		
		local tf = io.open(self._path.."type_id", "r")
		if (tf ~= nil) then
			self._type = tf:read("*n")
			
			if ((sensor_type == nil) or (sensor_type == 0) or (self._type == sensor_type)) then
				local pf = io.open(self._path.."port_name", "r")
				self._port = string.match(pf:read(), "%d+")
				pf:close()

				if ((port == nil) or (port == 0) or (self._port == port)) then
				  break
				else
					self._port = 0
				end
			end	
		end
	end
end

function Sensor:connected()
	return (self._port ~= 0)
end

function Sensor:type()
	return self._type
end

function Sensor:port()
	return self._port
end

function Sensor:mode()
  return self:getAttrString("mode")
end

function Sensor:modes()
  return self:getAttrString("modes")
end

function Sensor:setMode(mode)
  self:setAttrString("mode", mode)
end

function Sensor:value(id)

	if (id == nil) then
		id = 0
	end

  return self:getAttrInt("value"..id)
end

------------------------------------------------------------------------------
-- TouchSensor

TouchSensor = class(Sensor)

function TouchSensor:init(port)
	Sensor.init(self, 16, port)
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
	Sensor.init(self, 29, port)
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
	Sensor.init(self, 30, port)
end

------------------------------------------------------------------------------
-- GyroSensor

GyroSensor = class(Sensor)

GyroSensor.ModeAngle         = "GYRO-ANG"
GyroSensor.ModeSpeed         = "GYRO-RATE"
GyroSensor.ModeAngleAndSpeed = "GYRO-G&A"

function GyroSensor:init(port)
	Sensor.init(self, 32, port)
end

------------------------------------------------------------------------------
-- InfraredSensor

InfraredSensor = class(Sensor)

InfraredSensor.ModeProximity = "IR-PROX"
InfraredSensor.ModeIRSeeker  = "IR-SEEK"
InfraredSensor.ModeIRRemote  = "IR-REMOTE"

function InfraredSensor:init(port)
	Sensor.init(self, 33, port)
end

------------------------------------------------------------------------------
-- Motor

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

function Motor:init(motor_type, port)

	for i = 0, 9 do
		self._path = sys_motor.."tacho-motor"..i.."/"

		local pf = io.open(self._path.."port_name", "r")
		if (pf ~= nil) then
		  self._port = string.byte(pf:read("*l"), 4) - 64;
		  pf:close()

			if ((port == nil) or (port == 0) or (self._port == port)) then		
		    self._type = self:getAttrString("type")

		    if ((motor_type == nil) or (motor_type == "") or (self._type == motor_type)) then		    
		      return
		    end
		  end
		end
	end

	self._type = 0
	self._port = 0
	self._path = nil	
end

function Motor:connected()
  return (self._port ~= 0)
end

function Motor:type()
  return self._type
end

function Motor:port()
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

function Motor:state()
  return self:getAttrString("state")
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

function Motor:dutyCycleSetpoint()
  return self:getAttrInt("duty_cycle_sp")
end

function Motor:setDutyCycleSetpoint(value)
  self:setAttrInt("duty_cycle_sp", value)
end

function Motor:pulsesPerSecondSetpoint()
  return self:getAttrInt("pulses_per_second_sp")
end

function Motor:setPulsesPerSecondSetpoint(value)
  self:setAttrInt("pulses_per_second_sp", value)
end
  
function Motor:timeSetpoint()
  return self:getAttrInt("time_sp")
end

function Motor:setTimeSetpoint(value)
  self:setAttrInt("time_sp", value)
end

function Motor:positionSetpoint()
  return self:getAttrInt("position_sp")
end

function Motor:setPositionSetpoint(value)
  self:setAttrInt("position_sp", value)
end

function Motor:rampUp()
  return self:getAttrInt("ramp_up_sp")
end

function Motor:setRampUp(value)
  self:setAttrInt("ramp_up_sp", value)
end
  
function Motor:rampDown()
  return self:getAttrInt("ramp_down_sp")
end

function Motor:setRampDown(value)
  self:setAttrInt("ramp_down_sp", value)
end

------------------------------------------------------------------------------
-- LargeMotor

LargeMotor = class(Motor)

function LargeMotor:init(port)
	Motor.init(self, "tacho", port)
end

------------------------------------------------------------------------------
-- MediumMotor

MediumMotor = class(Motor)

function MediumMotor:init(port)
	Motor.init(self, "minitacho", port)
end

------------------------------------------------------------------------------
-- LED

LED = class(Device)

function LED:init(name)
  self._path = sys_class.."leds/ev3:"..name.."/"
end

function LED:level()
  return self:getAttrInt("brightness")
end

function LED:on()
  self:setAttrInt("brightness", 1)
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

function LED:setTrigger(trigger)
  self:setAttrString("trigger", trigger)
end

ledRedRight   = LED("red:right")
ledRedLeft    = LED("red:left")
ledGreenRight = LED("green:right")
ledGreenLeft  = LED("green:left")

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
-- Button

Button = class()

function Button:init(name)
	self._fname = sys_button..name
	self._sf = io.open(self._fname)
end

function Button:pressed()
	if (self._port ~= 0) then	
		local fvalue = io.open(self._fname)
		local val = fvalue:read("*n")
		fvalue:close()
		return (val ~= 0)
	end
	return false
end

btnBack  = Button("back")
btnLeft  = Button("left")
btnRight = Button("right")
btnUp    = Button("up")
btnDown  = Button("down")
btnEnter = Button("enter")

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
--Battery
Battery = class()

function Battery.voltage()
	local file = io.open(sys_power.."voltage_now")
	if (file ~= nil) then	
		local val = file:read("*n")
		file:close()
		return val / 1000000
	end	
	
	return 0
end

function Battery.current()
	local file = io.open(sys_power.."current_now")
	if (file ~= nil) then	
		local val = file:read("*n")
		file:close()
		return val / 1000
	end	
	
	return 0
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
