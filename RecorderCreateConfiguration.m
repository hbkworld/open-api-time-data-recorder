function RecorderCreateConfiguration(ip,DefaultTimeout,ChannelSetup,NumberOfModules)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function creates the recorder configuration and applies the input
% channel configuration

webwrite(strcat(strcat("http://",ip),"/rest/rec/create"),weboptions('RequestMethod','put', 'Timeout', DefaultTimeout)); % Create new configuration
WaitForModuleState(ip,DefaultTimeout,"RecorderConfiguring"); % Wait for moduleState to be "RecorderConfiguring" before further commands are issued
webwrite(strcat(strcat("http://",ip),"/rest/rec/channels/input"),weboptions('RequestMethod','put','ContentType','json', 'Timeout', DefaultTimeout),ChannelSetup); % Apply desired input channel configuration to the module

% Wait for modules to settle (only required if using multiple modules)
if NumberOfModules ~= 1
    WaitForInputState(ip,DefaultTimeout,"Settled");
end

end