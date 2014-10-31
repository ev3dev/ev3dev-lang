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
  print("    duty cycle: "..o:dutyCycle().."   pulses/sec: "..o:pulsesPerSecond().."\n")
  print("  Current run mode is "..o:runMode())
  print("    stop mode: "..o:stopMode())
  print("    regulation mode: "..o:regulationMode().."\n")
  --print("  Speed setpoint is "..o:speedSetpoint())
  
  if (o:runMode() == o.runModeTime) then
    print("  Time setpoint is "..o:timeSetpoint())
  end
  
  if (o:runMode() == o.runModePosition) then
    print("  Position setpoint is "..m:positionSetpoint())
  end
  
  --print("    ramp up: "..o:rampUp().."   ramp down: "..o:rampDown())

end

s = TouchSensor()
if (s:connected()) then
	print("Connected to touch sensor @ "..s:portName())
	print ( s:pressed() )
else
	print("No touch sensor connected")
end

c = ColorSensor()
if (c:connected()) then
	print("Connected to color sensor @ "..c:portName().." with mode "..c:mode())
	print ("Value is "..c:value())
	if (c:dp() > 0) then
	  print ("Float value is "..c:floatValue())
	end
else
	print("No color sensor connected")
end

u = UltrasonicSensor()
if (u:connected()) then
	print("Connected to ultrasonic sensor @ "..u:portName().." with mode "..u:mode())
	print ("Value is "..u:value())
	if (u:dp() > 0) then
	  print ("Float value is "..u:floatValue())
	end
else
	print("No ultrasonic sensor connected")
end

g = GyroSensor()
if (g:connected()) then
	print("Connected to gyro sensor @ "..g:portName().." with mode "..g:mode())
	print ("Value is "..g:value())
	if (g:dp() > 0) then
	  print ("Float value is "..g:floatValue())
	end
else
	print("No gyro sensor connected")
end

i = InfraredSensor()
if (i:connected()) then
	print("Connected to IR sensor @ "..i:portName().." with mode "..i:mode())	
	print ("Value is "..i:value())
	if (i:dp() > 0) then
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

print("Brightness of left green led is "..ledGreenLeft:brightness())
print("Trigger of right red led is "..ledRedRight:trigger())
  
print("Beeping...")
Sound.beep();

print("Sound volume is "..Sound.volume())
  
print("Battery voltage is "..Battery:voltageVolts().." V")
print("Battery current is "..Battery:currentAmps().." mA")
