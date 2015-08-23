from ev3dev import *
import time

dc_motor1 = DC_Motor( 'usb*wedo1' )

# print dc_motor1.commands
# print dc_motor1.driver_name
# print dc_motor1.duty_cycle
# print dc_motor1.duty_cycle_sp
# print dc_motor1.polarity
# print dc_motor1.port_name
# print dc_motor1.ramp_down_sp
# print dc_motor1.ramp_up_sp
# print dc_motor1.state
# print dc_motor1.stop_commands
# 
# dc_motor1.duty_cycle_sp = '{0:d}'.format( 40 )
# dc_motor1.command = 'run-direct'
# 
# for i in range(-100,100):
#     dc_motor1.duty_cycle_sp = '{0:d}'.format( i )
# #   dc_motor1.command = 'run-direct'
#     time.sleep(0.1)
#     print dc_motor1.duty_cycle_sp
# 
# time.sleep(5)
# dc_motor1.duty_cycle_sp = '{0:d}'.format( 0 )
# dc_motor1.command = 'run-forever'
# 
# time.sleep(0.5)
# print dc_motor1.state
# 
# print DC_Motor.state.__doc__ 
# # print dc_motor1.stop_commands
