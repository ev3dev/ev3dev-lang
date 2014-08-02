#!/usr/bin/lua

require 'ev3dev'

MotorControl = class()

MotorControl.ninetyDegrees = 250

MotorControl.left = -1
MotorControl.right = 1

MotorControl.idle = 0
MotorControl.driving = 1
MotorControl.turning = 2

function MotorControl:init()
	self._leftMotor  = Motor(Motor.Large, 2)
	self._rightMotor = Motor(Motor.Large, 3)
	self._state      = MotorControl.idle
end

function MotorControl:initialized()
  return (self._leftMotor:connected() and self._rightMotor:connected())
end

function MotorControl:state()
  return self._state
end

function MotorControl:turn(direction)
  if (self._state ~= MotorControl.idle) then
    self:stop()
  end

  self._leftMotor:setRunMode(Motor.RunModePosition)
  --self._leftMotor:setPositionMode(Motor.PositionModeRelative)
  self._leftMotor:setPosition(0)
  --self._leftMotor:setRegulationMode(Motor.ModeOn)
  self._leftMotor:setDutyCycleSetpoint(50)

  self._rightMotor:setRunMode(Motor.RunModePosition)
  --self._rightMotor:setPositionMode(Motor.PositionModeRelative)
  self._rightMotor:setPosition(0)
  --self._rightMotor:setRegulationMode(Motor.ModeOn)
  self._rightMotor:setDutyCycleSetpoint(50)

  if (direction > 0) then
    self._leftMotor:setPositionSetpoint(MotorControl.ninetyDegrees)
    self._rightMotor:setPositionSetpoint(-MotorControl.ninetyDegrees)
    
  elseif (direction < 0) then
    self._leftMotor:setPositionSetpoint(-MotorControl.ninetyDegrees)
    self._rightMotor:setPositionSetpoint(MotorControl.ninetyDegrees)
  
  else
    return
  end
  
  self._state = MotorControl.turning
  self._leftMotor:run()  
  self._rightMotor:run()
  
  while (self._leftMotor:running()) do
    
  end
  
  self._state = MotorControl.idle
end

function MotorControl:drive(speed)
  self._leftMotor:setRunMode(Motor.RunModeForever)
  self._leftMotor:setDutyCycleSetpoint(-speed)

  self._rightMotor:setRunMode(Motor.RunModeForever)
  self._rightMotor:setDutyCycleSetpoint(-speed)

  self._state = MotorControl.driving
  self._leftMotor:run()  
  self._rightMotor:run()  
end

function MotorControl:stop()
  self._leftMotor:stop()  
  self._rightMotor:stop()  
  self._state = MotorControl.idle
end

function MotorControl:reset()
  self._leftMotor:reset()  
  self._rightMotor:reset()  
  self._state = MotorControl.idle
end

mc = MotorControl()

if (not mc:initialized()) then
  print("error: large motors on ports B and C needed!")
  return
end

d = InfraredSensor()
d:setMode(InfraredSensor.ModeProximity)

if (not d:connected()) then
  print("error: no infrared sensor found!")
  return
end


function run()
  
  while (d:value() > 20) do
    if (mc:state() ~= mc.driving) then
      mc:drive(75)
    end
  end

  mc:stop()
  mc:turn(mc.right)

end
