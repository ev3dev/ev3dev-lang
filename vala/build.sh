#This is a quick build script to build the library.

#cp ev3dev-lib.cs ev3dev-lib.vala # Use a .cs extension to get partial syntax highlighting in editors that don't support vala
valac --library=ev3dev-lib -H bin/ev3dev-lib.h ev3dev-lib.vala -X -fPIC -X -shared --vapi=bin/ev3dev-lib.vapi --pkg gio-2.0 -o bin/ev3dev-lib.so
cp ev3dev-lib.vala bin/ev3dev-lib.vala

#valac "bin/ev3dev-lib.vapi" ev3dev.vala -X bin/ev3dev-lib.so -X -Ibin/. -o bin/ev3dev
#cp ev3dev.vala bin/ev3dev.vala
