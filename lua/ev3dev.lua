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
	
	local result = 0
	if (self._path ~= nil) then
		local tf = io.open(self._path..name, "r")
		if (tf ~= nil) then
			result = tf:read("*n")
		end
  end
  
  return result;
end

function Device:setAttrInt(name, value)
	
	if (self._path ~= nil) then
		local tf = io.open(self._path..name, "w")
		if (tf ~= nil) then
		  tf:write(tostring(value))
			tf:close()
		end
  end
end

function Device:getAttrString(name)
	
	if (self._path ~= nil) then
		local tf = io.open(self._path..name, "r")
		if (tf ~= nil) then
			local s = tf:read("*l")
			tf:close()
			return s
		end
  end
  
  return nil
end

function Device:setAttrString(name, value)
	
	if (self._path ~= nil) then
		local tf = io.open(self._path..name, "w")
		if (tf ~= nil) then
			tf:write(value)
			tf:close()
		end
  end
end

------------------------------------------------------------------------------
-- Sensor

Sensor = class()

function Sensor:init(sensor_value_fname, port)

	self._fname = sensor_value_fname
	self._type = 0
	self._port = 0
	
	local f = io.open(self._fname)
	if (f ~= nil) then
	  if (port ~= 0) then
		  self._port = port
		else
		  self._port = 1
		end
		f:close()
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

------------------------------------------------------------------------------
-- MSensor

MSensor = class(Sensor)

MSensor.NXTTouch       = 1
MSensor.NXTLight       = 2
MSensor.NXTSound       = 3
MSensor.NXTColor       = 4
MSensor.NXTUltrasonic  = 5
MSensor.NXTTemperature = 6
    
MSensor.EV3Touch       = 16
MSensor.EV3Color       = 29
MSensor.EV3Ultrasonic  = 30
MSensor.EV3Gyro        = 32
MSensor.EV3Infrared    = 33

function MSensor:init(sensor_type, port)

	self._type = 0
	self._port = 0

	for i = 0, 9 do
		self._dname = sys_msensor.."sensor"..i.."/"
		
		local tf = io.open(self._dname.."type_id", "r")
		if (tf ~= nil) then
			self._type = tf:read("*n")
			
			if ((sensor_type == nil) or (sensor_type == 0) or (self._type == sensor_type)) then
				local pf = io.open(self._dname.."port_name", "r")
				self._port = string.match(pf:read(), "%d+")
				pf:close()

				if ((port == nil) or (port == 0) or (self._port == port)) then
				  self._fname = sys_msensor.."sensor"..i.."/value"
				  break;
				else
					self._port = 0
				end
			end	
		end
	end
end

function MSensor:mode()
	if (self._port ~= 0) then
		local mf = io.open(self._dname.."mode", "r")
		local m = string.match(mf:read(), "%[%w+[%-%w+]*%]")
		if (m.len) then
			return string.match(m, "%w+[%-%w+]*")
		end
	end
	return ""
end

function MSensor:modes()
	if (self._port ~= 0) then
		local mf = io.open(self._dname.."mode", "r")
		return mf:read()
	end
	return ""
end

function MSensor:setMode(mode)
	if (self._port ~= 0) then
		local mf = io.open(self._dname.."mode", "w")
		mf:write(mode)
		mf:close()
	end
end

function MSensor:value(id)
	if (self._port ~= 0) then	
		if (id == nil) then
			id = 0
		end

		if (id == 0) then
			local fvalue = io.open(self._fname..id, "r")
			local val = fvalue:read("*n")
			fvalue:close()
			return val
		else		
			local vf = io.open(self._dname.."value"..id, "r")
			if (vf ~= nil) then
				local val = vf:read("*n")
				vf:close()
				return val
			end
		end
	end
	
	return 0
end

------------------------------------------------------------------------------
-- TouchSensor

TouchSensor = class(MSensor)

function TouchSensor:init(port)
	MSensor.init(self, 16, port)
end

function TouchSensor:pressed()
  return self:value(0)
end

------------------------------------------------------------------------------
-- ColorSensor

ColorSensor = class(MSensor)

ColorSensor.ModeReflect = "COL-REFLECT"
ColorSensor.ModeAmbient = "COL-AMBIENT"
ColorSensor.ModeColor   = "COL-COLOR"

function ColorSensor:init(port)
	MSensor.init(self, 29, port)
end

------------------------------------------------------------------------------
-- UltrasonicSensor

UltrasonicSensor = class(MSensor)

UltrasonicSensor.ModeDistCM   = "US-DIST-CM"
UltrasonicSensor.ModeDistIN   = "US-DIST-IN"
UltrasonicSensor.ModeListen   = "US-LISTEN"
UltrasonicSensor.ModeSingleCM = "US-SI-CM"
UltrasonicSensor.ModeSingleIN = "US-SI-IN"

function UltrasonicSensor:init(port)
	MSensor.init(self, 30, port)
end

------------------------------------------------------------------------------
-- GyroSensor

GyroSensor = class(MSensor)

GyroSensor.ModeAngle         = "GYRO-ANG"
GyroSensor.ModeSpeed         = "GYRO-RATE"
GyroSensor.ModeAngleAndSpeed = "GYRO-G&A"

function GyroSensor:init(port)
	MSensor.init(self, 32, port)
end

------------------------------------------------------------------------------
-- InfraredSensor

InfraredSensor = class(MSensor)

InfraredSensor.ModeProximity = "IR-PROX"
InfraredSensor.ModeIRSeeker  = "IR-SEEK"
InfraredSensor.ModeIRRemote  = "IR-REMOTE"

function InfraredSensor:init(port)
	MSensor.init(self, 33, port)
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

	self._type = 0
	self._port = 0
 
  local fromPort = 1
  local toPort = 4
  if ((port ~= nil) and (port > 0)) then
    fromPort = port
    toPort = port
  end
  
	for p = fromPort, toPort do
		self._path = sys_motor.."out"..string.format("%c", p+64)..":motor:tacho/"
		
		local tf = io.open(self._path.."type", "r")
		if (tf ~= nil) then
			self._type = tf:read("*l")
			
			if ((motor_type == nil) or (motor_type == "") or (self._type == motor_type)) then
				self._port = p;
				break;
			end
		end
	end
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

function Motor:power()
  return self:getAttrInt("power")
end

function Motor:speed()
  return self:getAttrInt("speed")
end

function Motor:position()
  return self:getAttrInt("position")
end

function Motor:pulsesPerSecond()
  return self:getAttrInt("pulses_per_second")
end
  
function Motor:runMode()
  return self:getAttrString("run_mode")
end

function Motor:setRunMode(value)
  self:setAttrString("run_mode", value)
end
  
function Motor:brakeMode()
  return self:getAttrString("brake_mode")
end

function Motor:setBrakeMode(value)
  self:setAttrString("brake_mode", value)
end
  
function Motor:holdMode()
  return self:getAttrString("hold_mode")
end

function Motor:setHoldMode(value)
  self:setAttrString("hold_mode", value)
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

function Motor:polarityMode()
  return self:getAttrString("polarity_mode")
end

function Motor:setPolarityMode(value)
  self:setAttrString("polarity_mode", value)
end
  
function Motor:speedSetpoint()
  return self:getAttrInt("speed_setpoint")
end

function Motor:setSpeedSetpoint(value)
  self:setAttrInt("speed_setpoint", value)
end
  
function Motor:timeSetpoint()
  return self:getAttrInt("time_setpoint")
end

function Motor:setTimeSetpoint(value)
  self:setAttrInt("time_setpoint", value)
end

function Motor:position_setpoint()
  return self:getAttrInt("position_setpoint")
end

function Motor:setPositionSetpoint(value)
  self:setAttrInt("position_setpoint", value)
end

function Motor:rampUp()
  return self:getAttrInt("ramp_up")
end

function Motor:setRampUp(value)
  self:setAttrInt("ramp_up", value)
end
  
function Motor:rampDown()
  return self:getAttrInt("ramp_down")
end

function Motor:setRampDown(value)
  self:setAttrInt("ramp_down", value)
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

LED = class()

function LED:init(name)
  self._dname = sys_class.."leds/ev3:"..name.."/"
end

function LED:level()
	local file = io.open(self._dname.."brightness", "r")
	if (file ~= nil) then	
		local val = file:read("*n")
		file:close()
		return val
	end
	
	return 0
end

function LED:on()
	local file = io.open(self._dname.."brightness", "w")
	if (file ~= nil) then	
		file:write("1")
		file:close()
	end
end

function LED:off()
	local file = io.open(self._dname.."brightness", "w")
	if (file ~= nil) then	
		file:write("0")
		file:close()
	end
end

function LED:flash(interval)
  self:setTrigger("timer")
  if ((interval ~= nil) and (interval ~= 0)) then
    self:setOnDelay(interval)
    self:setOffDelay(interval)
	end	
end

function LED:setOnDelay(ms)
	local file = io.open(self._dname.."delay_on", "w")
	if (file ~= nil) then	
		file:write(tostring(ms))
		file:close()
	end
end

function LED:setOffDelay(ms)
	local file = io.open(self._dname.."delay_off", "w")
	if (file ~= nil) then	
		file:write(tostring(ms))
		file:close()
	end
end
  
function LED:trigger()
	local file = io.open(self._dname.."trigger", "r")
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
	local file = io.open(self._dname.."trigger", "r")
	if (file ~= nil) then	
		local m = file:read()
		file:close()
		if (m.len) then
		  return m
		--	return string.match(m, "%w+[%-%w+]*")
		end
	end
	
	return ""
end

function LED:setTrigger(trigger)
	local file = io.open(self._dname.."trigger", "w")
	if (file ~= nil) then	
		file:write(trigger)
		file:close()
	end
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
    if (sensor:type() == MSensor.EV3Infrared) then
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
