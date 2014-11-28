VALAC=valac
exec=bin/ev3dev-test

default: lib

lib:
	$(VALAC) --library=ev3dev-lib -H ./bin/ev3dev-lib.h ./ev3dev-lib.vala -X -fPIC -X -shared --vapi=./bin/ev3dev-lib.vapi --pkg gio-2.0 --pkg glib-2.0 -X -lm -o ./bin/ev3dev-lib.so

tests:
	$(VALAC) "./bin/ev3dev-lib.vapi" ./ev3dev-test.vala -X ./bin/ev3dev-lib.so -X -Ibin/. -o ./bin/ev3dev-test --pkg gio-2.0 --pkg glib-2.0

all: lib tests

clean:
	rm -rf ./bin

run:
	$(exec)