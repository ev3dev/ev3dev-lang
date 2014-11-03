/*
Live tests and examples for Vala ev3dev library
*/

using GLib;
using ev3dev;

const string BUILD_VERSION = "0.9.1-beta";

class Tests
{	
	static bool version;
	static int test_preset = 0;
	const OptionEntry[] options = 
	{
		{"version", 'v', 0, OptionArg.NONE, ref version, "Display version number", null},
		{"test", 't', 0, OptionArg.INT, ref test_preset, "Specify a test to execute ", null}, 
		{null}
	};
	
	const Test[] tests = 
	{
		{"continuous sensor read", test_sensor_continuous}
	};
	
	static int test_sensor_continuous()
	{
		stdout.printf("This test will continuously read a sensor value.\nMake sure you have a sensor plugged in, and then press ENTER.\nYou can end the test by presing ^C.\n");
		stdin.read_line();
		Sensor test_sensor = new Sensor(OUTPUT_AUTO);
		if(!test_sensor.connected)
		{
			print("We were unable to connect to a valid sensor. Make sure that is is plugged in and try again.\n");
			return 1;
		}
		
		stdout.printf("Using sensor on port %s: %s\n", test_sensor.port_name, test_sensor.type_name);
		
		while(true)
		{
			stdout.printf("Sensor value 0: %f\n", test_sensor.get_float_value(0));
		}
		
		return 0;
	}
	
	static int main(string[] args)
	{
		try
		{
			var opt_context = new OptionContext ();
			opt_context.set_help_enabled (true);
			opt_context.add_main_entries (options, null);
			opt_context.parse (ref args);
		}
		catch (OptionError e)
		{
			stdout.printf ("%s\n", e.message);
			stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			return 1;
		}
		
		if(version)
		{
			stdout.printf ("ev3dev vala tests and examples %s\n", BUILD_VERSION);
			return 0;
		}
		
		if(test_preset == 0)
		{
			stdout.printf("available tests: \n");
		
			for (int i = 0; i < tests.length; i++)
			{
				Test test = tests[i];
				stdout.printf("\t%d: %s\n", i + 1, test.test_name);
			}
			
			print("select the desired test to execute: ");
			test_preset = int.parse(stdin.read_line());
		}
		
		if(test_preset < 1 || test_preset > tests.length)
		{
			print("You must specify a valid integer between 0 and " + tests.length.to_string() + ".\n");
			return 1;
		}
		
		Test selected_test = tests[test_preset - 1];
		return selected_test.test_exec();
		
		/*Motor motor = new Motor(Ports.OUTPUT_A, null);
		motor.run_mode = "forever";
		motor.regulation_mode = "off";
		motor.duty_cycle_sp = 20;
		
		Sensor touch = new Sensor(Ports.INPUT_2, {});
		
		while(true) {
			if(touch.get_value(0) == 1)
				motor.run = 1;
			else
				motor.run = 0;
		}*/
	}
}

delegate int TestDelegateType();

struct Test
{
	public string test_name;
	public TestDelegateType test_exec;
}