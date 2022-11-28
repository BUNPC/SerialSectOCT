
function [channel_1, channel_2] = motor_init(serial_num)

% Install Kinesis before running the code
% (https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=10285)

%Load assemblies
%Point to appropriate directory/folder if the driver is installed on a
%different location

NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.dll ');

%Initialize Device List
import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.*

%Initialize Device List
DeviceManagerCLI.BuildDeviceList();
DeviceManagerCLI.GetDeviceListSize();


%Set up device and configuration
device = Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.BenchtopBrushlessMotor.CreateBenchtopBrushlessMotor(serial_num);
device.Connect(serial_num);

% configure the stage
channel_1 = device.GetChannel(1);
channel_2 = device.GetChannel(2);
%Settings should be initialized as soon as the channel is connected. 
channel_1.WaitForSettingsInitialized(5000);
channel_2.WaitForSettingsInitialized(5000);
channel_1.StartPolling(250);
channel_2.StartPolling(250);
%Load Settings to the controller
channel_1.LoadMotorConfiguration(channel_1.DeviceID);
channel_2.LoadMotorConfiguration(channel_2.DeviceID);
%Enable the device and start sending commands
channel_1.EnableDevice();
channel_2.EnableDevice();
pause(1); %wait to make sure device is enabled

channel_1.Home(60000);
channel_2.Home(60000);

end

