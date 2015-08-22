from ev3dev_ext import *
from ev3dev.version import __version__
from PIL import Image, ImageDraw
from struct import unpack

#---------------------------------------------------------------------------
# Furnish mode_set class (which is a wrapper around std::set<std::string>)
# with __repr__ and __str__ methods which are better than defaults.
#---------------------------------------------------------------------------
def mode_set_repr(self):
    return list(self).__repr__()

def mode_set_str(self):
    return list(self).__str__()

mode_set.__repr__ = mode_set_repr
mode_set.__str__  = mode_set_str

#---------------------------------------------------------------------------
# proxy classes for easy attribute access for device class
#---------------------------------------------------------------------------
class attr_int_proxy:
    def __init__(self, dev):
        self.__dict__['dev'] = dev

    def __getattr__(self, name):
        return self.__dict__['dev'].get_attr_int(name)

    def __setattr__(self, name, val):
        self.__dict__['dev'].set_attr_int(name, val)

def attr_int_get(dev):
    return attr_int_proxy(dev)

device.attr_int = property(fget=attr_int_get,
        doc="Reads/writes integer attributes.\n Example::\n\n    d.attr_int.speed_sp = 100\n"
    )


class attr_string_proxy:
    def __init__(self, dev):
        self.__dict__['dev'] = dev

    def __getattr__(self, name):
        return self.__dict__['dev'].get_attr_string(name)

    def __setattr__(self, name, val):
        self.__dict__['dev'].set_attr_string(name, val)

def attr_string_get(dev):
    return attr_string_proxy(dev)

device.attr_string = property(fget=attr_string_get,
        doc="Reads/writes string attributes.\nExample::\n\n    d.attr_string.mode = 'IR-PROX'\n"
        )

class attr_line_proxy:
    def __init__(self, dev):
        self.__dict__['dev'] = dev

    def __getattr__(self, name):
        return self.__dict__['dev'].get_attr_line(name)

def attr_line_get(dev):
    return attr_line_proxy(dev)

device.attr_line = property(fget=attr_line_get,
        doc="Reads line attributes.\n Example::\n\n    print(d.attr_line.modes)\n"
        )

class attr_set_proxy:
    def __init__(self, dev):
        self.__dict__['dev'] = dev

    def __getattr__(self, name):
        return self.__dict__['dev'].get_attr_set(name)

def attr_set_get(dev):
    return attr_set_proxy(dev)

device.attr_set = property(fget=attr_set_get,
        doc="Reads set attributes.\n Example::\n\n    print(d.attr_set.commands)\n"
        )

#---------------------------------------------------------------------------
# Helper function to compute power for left and right motors when steering
#---------------------------------------------------------------------------
def steering(direction, power=100):
    """
    Computes how fast each motor in a pair should turn to achieve the
    specified steering.

    Input:
        direction [-100, 100]:
            * -100 means turn left as fast as possible,
            *  0   means drive in a straight line, and
            *  100 means turn right as fast as possible.

        power: the power that should be applied to the outmost motor (the one
            rotating faster). The power of the other motor will be computed
            automatically.

    Output:
        a tuple of power values for a pair of motors.

    Example::

        for (motor, power) in zip((left_motor, right_motor), steering(50, 900)):
            motor.run_forever(speed_sp=power)
    """

    pl = power
    pr = power
    s = (50 - abs(float(direction))) / 50

    if direction >= 0:
        pr *= s
    else:
        pl *= s

    return (int(pl), int(pr))

#---------------------------------------------------------------------------
# Stop a motor on destruction
#---------------------------------------------------------------------------
def stop_taho_motor(self):
    self.command = 'stop'

large_motor.__del__ = stop_taho_motor
medium_motor.__del__ = stop_taho_motor

def stop_dc_motor(self):
    self.command = 'coast'

dc_motor.__del__ = stop_dc_motor

def stop_servo_motor(self):
    self.command = 'float'

servo_motor.__del__ = stop_servo_motor

#---------------------------------------------------------------------------
# Batch set method
#---------------------------------------------------------------------------
def batch_set(device, **attr):
    """Set device attributes provided as keyword arguments

    Example::

        motor.set(speed_regulation_enabled='on', stop_command='brake')
    """

    for key in attr:
        setattr(device, key, attr[key])

sensor.set      = batch_set
motor.set       = batch_set
dc_motor.set    = batch_set
servo_motor.set = batch_set


#~autogen python_motor_commands classes.motor>currentClass

def motor_run_forever(self, **attr):
    """Run the motor until another command is sent.
    """

    for key in attr:
        setattr(self, key, attr[key])
    self.command = "run-forever"

motor.run_forever = motor_run_forever

def motor_run_to_abs_pos(self, **attr):
    """Run to an absolute position specified by `position_sp` and then
    stop using the command specified in `stop_command`.
    """

    for key in attr:
        setattr(self, key, attr[key])
    self.command = "run-to-abs-pos"

motor.run_to_abs_pos = motor_run_to_abs_pos

def motor_run_to_rel_pos(self, **attr):
    """Run to a position relative to the current `position` value.
    The new position will be current `position` + `position_sp`.
    When the new position is reached, the motor will stop using
    the command specified by `stop_command`.
    """

    for key in attr:
        setattr(self, key, attr[key])
    self.command = "run-to-rel-pos"

motor.run_to_rel_pos = motor_run_to_rel_pos

def motor_run_timed(self, **attr):
    """Run the motor for the amount of time specified in `time_sp`
    and then stop the motor using the command specified by `stop_command`.
    """

    for key in attr:
        setattr(self, key, attr[key])
    self.command = "run-timed"

motor.run_timed = motor_run_timed

def motor_run_direct(self, **attr):
    """Run the motor at the duty cycle specified by `duty_cycle_sp`.
    Unlike other run commands, changing `duty_cycle_sp` while running *will*
    take effect immediately.
    """

    for key in attr:
        setattr(self, key, attr[key])
    self.command = "run-direct"

motor.run_direct = motor_run_direct

def motor_stop(self, **attr):
    """Stop any of the run commands before they are complete using the
    command specified by `stop_command`.
    """

    for key in attr:
        setattr(self, key, attr[key])
    self.command = "stop"

motor.stop = motor_stop

def motor_reset(self, **attr):
    """Reset all of the motor parameter attributes to their default value.
    This will also have the effect of stopping the motor.
    """

    for key in attr:
        setattr(self, key, attr[key])
    self.command = "reset"

motor.reset = motor_reset


#~autogen

#~autogen python_motor_commands classes.dcMotor>currentClass

def dc_motor_run_forever(self, **attr):
    """Run the motor until another command is sent.
    """

    for key in attr:
        setattr(self, key, attr[key])
    self.command = "run-forever"

dc_motor.run_forever = dc_motor_run_forever

def dc_motor_run_timed(self, **attr):
    """Run the motor for the amount of time specified in `time_sp`
    and then stop the motor using the command specified by `stop_command`.
    """

    for key in attr:
        setattr(self, key, attr[key])
    self.command = "run-timed"

dc_motor.run_timed = dc_motor_run_timed

def dc_motor_stop(self, **attr):
    """Stop any of the run commands before they are complete using the
    command specified by `stop_command`.
    """

    for key in attr:
        setattr(self, key, attr[key])
    self.command = "stop"

dc_motor.stop = dc_motor_stop


#~autogen

#~autogen python_motor_commands classes.servoMotor>currentClass

def servo_motor_run(self, **attr):
    """Drive servo to the position set in the `position_sp` attribute.
    """

    for key in attr:
        setattr(self, key, attr[key])
    self.command = "run"

servo_motor.run = servo_motor_run

def servo_motor_float(self, **attr):
    """Remove power from the motor.
    """

    for key in attr:
        setattr(self, key, attr[key])
    self.command = "float"

servo_motor.float = servo_motor_float


#~autogen

#---------------------------------------------------------------------------
# Convenience method for accessing sensor.bin_data
#---------------------------------------------------------------------------
def sensor_bin_data(self, fmt=None):
    """Bin Data: read-only
    Reads the unscaled raw values in the `value<N>` attributes as raw byte
    array. Use `bin_data_format`, `num_values` and the individual sensor
    documentation to determine how to interpret the data.

    In case format string is provided, unpacks the raw data and returns the
    unpacked tuple. Without arguments returns the raw data as byte buffer.

    See help(struct) for more on format strings.
    """

    if fmt is None:
        return self.bin_data_raw
    else:
        return unpack(fmt, self.bin_data_raw)

sensor.bin_data = sensor_bin_data

#---------------------------------------------------------------------------
# Provide a convenience wrapper for ev3dev.lcd class
#---------------------------------------------------------------------------
class LCD(lcd):
    """A convenience wrapper for ev3dev.lcd class.
    Provides drawing functions from python imaging library (PIL).
    """

    def __init__(self):
        super(LCD, self).__init__()

        def alignup(n, m):
            r = n % m
            if r == 0:
                return n
            else:
                return n - r + m


        nx = alignup(self.resolution_x, 32)
        ny = self.resolution_y

        self.img = Image.new("1", (nx, ny), "white")

    @property
    def shape(self):
        """
        Dimensions of the LCD screen.
        """
        return (self.resolution_x, self.resolution_y)

    @property
    def draw(self):
        """
        Returns a handle to PIL.ImageDraw.Draw class associated with LCD.

        Example::

            lcd.draw.rectangle((10,10,60,20), fill=True)
        """
        return ImageDraw.Draw(self.img)

    def clear(self):
        """
        Clears the LCD.
        """
        self.draw.rectangle(((0,0),(self.shape)), fill="white")

    def update(self):
        """
        Applies pending changes to LCD.
        Nothing will be drawn on the screen until this function is called.
        """
        self.frame_buffer[:] = self.img.tobytes("raw", "1;IR")

