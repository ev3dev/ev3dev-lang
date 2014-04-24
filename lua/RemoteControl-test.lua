#!/usr/bin/lua

--
-- test program for the ev3dev lua RemoteControl class
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

function printRedUp(ir, pressed)
  if (pressed) then
    print("redUp pressed")
  else
    print("redUp released")
  end
end

function printRedDown(ir, pressed)
  if (pressed) then
    print("redDown pressed")
  else
    print("redDown released")
  end
end
  
function printBlueUp(ir, pressed)
  if (pressed) then
    print("blueUp pressed")
  else
    print("blueUp released")
  end
end

function printBlueDown(ir, pressed)
  if (pressed) then
    print("blueDown pressed")
  else
    print("blueDown released")
  end
end

function printBeacon(ir, on)
  if (on) then
    print("beacon on")
  else
    print("beacon off")
  end
end

r = RemoteControl()

-- overload callback functions
r.onRedUp = printRedUp
r.onRedDown = printRedDown
r.onBlueUp = printBlueUp
r.onBlueDown = printBlueDown
r.onBeacon = printBeacon

if (r:connected()) then
  print("ensure that channel 1 is selected,")
  print("press middle (beacon) button to exit!")
  print("")
  
  while (not r._beacon) do
    r:process()
  end
else
  print("no infrared sensor detected!")
end
