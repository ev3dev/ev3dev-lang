/*
Live tests and basic examples for Vala ev3dev library
*/

using GLib;
using ev3dev;

const string BUILD_VERSION = "0.9.1";

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
        {"continuous sensor read",
            "This test will continuously read a sensor value for 5 seconds.\n"
            + "Make sure you have a sensor plugged in before continuing.",
            test_sensor_continuous},
        {"motor run w/ ramping",
            "This test will run the first motor it finds for one second.\n"
            + "Make sure you have a motor plugged in before continuing.",
            test_run_motor},
        {"fade LEDs", 
            "This test will fade the built-in LED pairs from green to red.",
            test_fade_leds},
        {"read battery info",
            "This test will read the current and voltage being supplied by the main battery.",
            test_battery_info},
            
            
        {" run all tests",
            "This will run all tests.",
            test_all_generic}
    };
    
    static int test_sensor_continuous()
    {
        Sensor test_sensor = new Sensor(INPUT_AUTO);
        if(!test_sensor.connected)
        {
            print("We were unable to connect to a valid sensor. Make sure that is is plugged in and try again.\n");
            return 1;
        }
        
        stdout.printf("Using sensor on port %s: %s\n", test_sensor.port_name, test_sensor.type_name);
        
        for(int i = 0; i < 50; i++)
        {
            stdout.printf("Sensor value 0: %f\n", test_sensor.get_float_value(0));
            
            Thread.usleep((ulong)(1000000 * 5 / 50));
        }
        
        return 0;
    }
    
    static int test_run_motor()
    {
        Motor test_motor = new Motor(OUTPUT_AUTO);
        test_motor.ramp_up_sp = 100;
        test_motor.ramp_down_sp = 100;
        test_motor.run_mode = "time";
        test_motor.time_sp = 1000;
        test_motor.duty_cycle_sp = 50;
        test_motor.run = 1;
        
        while(test_motor.duty_cycle > 0)
            Thread.usleep((ulong)(1000000 * 0.1));
            
        return 0;
    }
    
    static int test_battery_info()
    {
        PowerSupply battery = new PowerSupply();
        stdout.printf("Type: %s\n", battery.device_type); 
        stdout.printf("Battery technology: %s\n", battery.technology);       
        stdout.printf("Battery voltage: %d microvolts, %f volts\n", battery.voltage_now, battery.voltage_volts);
        stdout.printf("Battery current: %d microamps, %f amps\n", battery.current_now, battery.current_amps);
        return 0;
    }
    
    static int test_fade_leds()
    {
        LED[] leds = new LED[4];
        leds[0] = new LED("ev3:green:left");
        leds[1] = new LED("ev3:red:left");
        leds[2] = new LED("ev3:green:right");
        leds[3] = new LED("ev3:red:right");
        
        for(int i = 0; i < 100; i++)
        {
            for(int led_i = 0; led_i < leds.length; led_i++)
            {
                double led_val =  (i / 100d) * leds[led_i].max_brightness;
                if(led_i % 2 == 0)
                    led_val = (100 - i) / 100d * leds[led_i].max_brightness;
                
                leds[led_i].brightness = (int)led_val;
            }
            
            if(i % 10 == 0)
                print(i.to_string() + "%\n");
            
            Thread.usleep((ulong)(1000000 * 0.1));
        } 
        
        print("100%\n");
        
        Thread.usleep((ulong)(1000000 * 0.5));

        for(int led_i = 0; led_i < leds.length; led_i++)
        {
            leds[led_i].brightness = 0;
        }
        
        return 0;        
    }
    
    static int test_all_generic()
    {
        int status = 0;
        for(int i = 0; i < tests.length - 1; i++)
        {
            stdout.printf("Running test %d...\n", i + 1);
            Test test = tests[i];
             
            int last_result = execute_test(test, true);
            if(status == 0 && last_result != 0)
                status = last_result;
            
            stdout.printf("Test %d complete (status code %d).\n", i + 1, last_result);
        }
        
        return status;
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
            
            print("select a test to execute: ");
            test_preset = int.parse(stdin.read_line());
        }
        
        if(test_preset < 1 || test_preset > tests.length)
        {
            print("You must specify a valid integer between 0 and " + tests.length.to_string() + ".\n");
            return 1;
        }
        
        Test selected_test = tests[test_preset - 1];
        return execute_test(selected_test);
    }

    static int execute_test(Test test, bool indent = false)
    {
        string desc_output = test.test_description + "\n";
        desc_output += "You can abort the test by presing ^C.\n";
        desc_output += "Press ENTER to continue.";
        
        if(indent)
        {
            desc_output = "\t" + desc_output.replace("\n", "\n\t");
        }
        
        print(desc_output);
        stdin.read_line();
        return test.test_method();
    }
}

delegate int TestDelegateType();

struct Test
{
    public string test_name;
    public string test_description;
    public TestDelegateType test_method;
}