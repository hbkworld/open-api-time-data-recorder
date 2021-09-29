function SetSynchronizationMode(ip,DefaultTimeout,HardwareType,Domain,ModuleNumber)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function sets the module PTP mode using the REST PUT command
% /rest/rec/syncmode based on the user selection from HardwareDropDown in
% the main app file.  Note that the command module is always assigned
% number 1 regardless of whether the setup uses a frame or switch hardware.

ModuleSyncModeSettings = struct;
ModuleSyncModeSettings.synchronization.mode = 'stand-alone';
ModuleSyncModeSettings.synchronization.preferredMaster = false;
webwrite(strcat(strcat("http://",ip),"/rest/rec/syncmode"),weboptions('RequestMethod','put','ContentType','json', 'Timeout', DefaultTimeout),ModuleSyncModeSettings); % Reset module to default if it was left in another state
SystemTimeUTC = FindCurrentSystemTimeUTC;
SetModuleTime(ip,DefaultTimeout,SystemTimeUTC);

if string(HardwareType) == "Switch" 
    
    if ModuleNumber == 1
        ModuleSyncModeSettings.synchronization.preferredMaster = true;
        ModuleSyncModeSettings.synchronization.settime = SystemTimeUTC;
        ModuleSyncModeSettings.synchronization.difftime = 0;
    end
       
    ModuleSyncModeSettings.synchronization.mode = 'ptp';
    ModuleSyncModeSettings.synchronization.domain = Domain;
    webwrite(strcat(strcat("http://",ip),"/rest/rec/syncmode"),weboptions('RequestMethod','put','ContentType','json', 'Timeout', DefaultTimeout),ModuleSyncModeSettings); % Send modified parameters to module
    
elseif string(HardwareType) == "Frame" 
    
    if ModuleNumber == 1
        ModuleSyncModeSettings.synchronization.settime = SystemTimeUTC;
        ModuleSyncModeSettings.synchronization.difftime = 0;
    end

    ModuleSyncModeSettings.synchronization.mode = 'stand-alone';
    ModuleSyncModeSettings.synchronization.usegps = false;
    webwrite(strcat(strcat("http://",ip),"/rest/rec/syncmode"),weboptions('RequestMethod','put','ContentType','json', 'Timeout', DefaultTimeout),ModuleSyncModeSettings); % Send modified parameters to module
    
end


end
