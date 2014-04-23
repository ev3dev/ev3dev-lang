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
  print("    power: "..o:power().."   speed: "..o:speed().."\n")
  print("  Current run mode is "..o:runMode())
  print("    brake mode: "..o:brakeMode().."   hold mode: "..o:holdMode())
  print("    regulation mode: "..o:regulationMode().."   polarity mode: "..o:polarityMode().."\n")
  print("  Speed setpoint is "..o:speedSetpoint())
  
  if (o:runMode() == o.runModeTime) then
    print("  Time setpoint is "..o:timeSetpoint())
  end
  
  if (o:runMode() == o.runModePosition) then
    print("  Position setpoint is "..m:positionSetpoint())
  end
  
  print("    ramp up: "..o:rampUp().."   ramp down: "..o:rampDown())

end

s = TouchSensor()
if (s:connected()) then
	print("Connected to touch sensor @ in"..s:port())
	print ( s:pressed() )
else
	print("No touch sensor connected")
end

c = ColorSensor()
if (c:connected()) then
	print("Connected to color sensor @ in"..c:port().." with mode "..c:mode())
	print ("Value is "..c:value())
else
	print("No color sensor connected")
end

u = ColorSensor()
if (u:connected()) then
	print("Connected to ultrasonic sensor @ in"..u:port().." with mode "..u:mode())
	print ("Value is "..u:value())
else
	print("No ultrasonic sensor connected")
end

g = GyroSensor()
if (g:connected()) then
	print("Connected to gyro sensor @ in"..g:port().." with mode "..g:mode())
	print ("Value is "..g:value())
else
	print("No gyro sensor connected")
end

i = InfraredSensor()
if (i:connected()) then
	print("Connected to IR sensor @ in"..i:port().." with mode "..i:mode())	
	print ("Value is "..i:value())
else
	print("No IR sensor connected")
end

m = MediumMotor()
if (m:connected()) then
	print("Connected to medium motor @ out"..string.format("%c", m:port()+64))
	printMotorInfo(m)
else
	print("No medium motor connected")
end

l = LargeMotor()
if (l:connected()) then
	print("Connected to large motor @ out"..string.format("%c", l:port()+64))
	printMotorInfo(l)
else
	print("No large motor connected")
end

print("Level of left green led is "..ledGreenLeft:level())
print("Trigger of right red led is "..ledRedRight:trigger())
  
print("Beeping...")
Sound.beep();

print("Sound volume is "..Sound.volume())
  
print("Battery voltage is "..Battery.voltage().." V")
print("Battery current is "..Battery.current().." mA")
