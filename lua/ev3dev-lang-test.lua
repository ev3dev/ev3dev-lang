#!/usr/bin/lua

--
-- test program for the ev3dev lua binding
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

require 'ev3dev'

function printMotorInfo(o)
  print("  Current state is "..o:state())
  print("    duty cycle: "..o:dutyCycle())
  print("    speed: "..o:speed())
  print("    position: "..o:position())
  print("    stop command: "..o:stopCommand())
  print("    speed regulation: "..o:speedRegulationEnabled())
end

s = TouchSensor()
if (s:connected()) then
	print("Connected to touch sensor @ "..s:portName())
	print ( s:pressed() )
else
	print("No touch sensor connected")
end

ic = I2CSensor()
if (ic:connected()) then
	print("Connected to I2C sensor @ "..c:portName().." with mode "..c:mode())
	print ("Value is "..c:value())
	if (c:decimals() > 0) then
	  print ("Float value is "..c:floatValue())
	end
else
	print("No I2C sensor connected")
end

c = ColorSensor()
if (c:connected()) then
	print("Connected to color sensor @ "..c:portName().." with mode "..c:mode())
	print ("Value is "..c:value())
	if (c:decimals() > 0) then
	  print ("Float value is "..c:floatValue())
	end
else
	print("No color sensor connected")
end

u = UltrasonicSensor()
if (u:connected()) then
	print("Connected to ultrasonic sensor @ "..u:portName().." with mode "..u:mode())
	print ("Value is "..u:value())
	if (u:decimals() > 0) then
	  print ("Float value is "..u:floatValue())
	end
else
	print("No ultrasonic sensor connected")
end

g = GyroSensor()
if (g:connected()) then
	print("Connected to gyro sensor @ "..g:portName().." with mode "..g:mode())
	print ("Value is "..g:value())
	if (g:decimals() > 0) then
	  print ("Float value is "..g:floatValue())
	end
else
	print("No gyro sensor connected")
end

i = InfraredSensor()
if (i:connected()) then
	print("Connected to IR sensor @ "..i:portName().." with mode "..i:mode())	
	print ("Value is "..i:value())
	if (i:decimals() > 0) then
	  print ("Float value is "..i:floatValue())
	end
else
	print("No IR sensor connected")
end

m = MediumMotor()
if (m:connected()) then
	print("Connected to medium motor @ "..m:portName())
	printMotorInfo(m)
else
	print("No medium motor connected")
end

l = LargeMotor()
if (l:connected()) then
	print("Connected to large motor @ "..l:portName())
	printMotorInfo(l)
else
	print("No large motor connected")
end

dc = DCMotor()
if (dc:connected()) then
	print("Connected to DC motor @ "..dc:portName())
  print("  Current command is "..dc:command())
  print("    duty cycle: "..dc:dutyCycle())
  print("    rampUpMS:   "..dc:rampUpMS())
  print("    rampDownMS: "..dc:rampDownMS().."\n")
else
	print("No DC motor connected")
end

sv = ServoMotor()
if (sv:connected()) then
	print("Connected to servo motor @ "..sv:portName())
  print("  Current command is "..sv:command())
  print("    position: "..sv:position().."\n")
  print("    rate:     "..sv:rate().."\n")
else
	print("No servo motor connected")
end

print("Brightness of left green led is "..ledGreenLeft:brightness())
print("Trigger of right red led is "..ledRedRight:trigger())
  
-- PowerFunctions led(s)
ledPFoutA = LED("ev3::outA")
ledPFoutB = LED("ev3::outB")
ledPFoutC = LED("ev3::outC")
ledPFoutD = LED("ev3::outD")

if (ledPFoutA:connected()) then
  print("Brightness of led in port outA is "..ledPFoutA:brightness())
end
if (ledPFoutB:connected()) then
  print("Brightness of led in port outB is "..ledPFoutB:brightness())
end
if (ledPFoutC:connected()) then
  print("Brightness of led in port outC is "..ledPFoutC:brightness())
end
if (ledPFoutD:connected()) then
  print("Brightness of led in port outD is "..ledPFoutD:brightness())
end

print("Beeping...")
--Sound.beep();

print("Sound volume is "..Sound.volume())
  
print("Battery voltage is "..Battery:voltageVolts().." V")
print("Battery current is "..Battery:currentAmps().." A")
