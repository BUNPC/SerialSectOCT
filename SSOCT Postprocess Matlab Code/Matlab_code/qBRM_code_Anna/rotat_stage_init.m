
function device = rotat_stage_init(serial_num)

% Install Kinesis before running the code
% (https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=10285)

%Load assemblies
%Point to appropriate directory/folder if the driver is installed on a
%different location

NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.IntegratedStepperMotorsCLI.dll');

%Initialize Device List
import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.*
import Thorlabs.MotionControl.IntegratedStepperMotorsCLI.*

%Initialize Device List
DeviceManagerCLI.BuildDeviceList();
DeviceManagerCLI.GetDeviceListSize();

%Set up device and configuration
device = Thorlabs.MotionControl.IntegratedStepperMotorsCLI.CageRotator.CreateCageRotator(serial_num);
device.Connect(serial_num);
%Settings should be initialized as soon as the channel is connected. 
device.WaitForSettingsInitialized(5000);
device.StartPolling(250);
%Load Settings to the controller
device.LoadMotorConfiguration(serial_num);
%Enable the device and start sending commands
device.EnableDevice();
pause(1); %wait to make sure the cube is enabled

device.Home(30000);

end