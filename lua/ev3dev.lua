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
local sys_button  = "/sys/devices/platform/ev3dev/button"
local sys_sound   = "/sys/devices/platform/snd-legoev3/"
local sys_power   = "/sys/class/power_supply/legoev3-battery/"

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
	return self._port
end

function Sensor:port()
	return self._port
end

------------------------------------------------------------------------------
-- MSensor

MSensor = class(Sensor)

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

function ColorSensor:init(port)
	MSensor.init(self, 29, port)
end

------------------------------------------------------------------------------
-- UltrasonicSensor

UltrasonicSensor = class(MSensor)

function UltrasonicSensor:init(port)
	MSensor.init(self, 30, port)
end

------------------------------------------------------------------------------
-- GyroSensor

GyroSensor = class(MSensor)

function GyroSensor:init(port)
	MSensor.init(self, 32, port)
end

------------------------------------------------------------------------------
-- InfraredSensor

InfraredSensor = class(MSensor)

function InfraredSensor:init(port)
	MSensor.init(self, 33, port)
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
--Sound
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
