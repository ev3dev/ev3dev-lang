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

print("Level of left green led is "..ledGreenLeft:level())
print("Trigger of right red led is "..ledRedRight:trigger())
  
print("Beeping...")
Sound.beep();

print("Sound volume is "..Sound.volume())
  
print("Battery voltage is "..Battery.voltage().." V")
print("Battery current is "..Battery.current().." mA")
