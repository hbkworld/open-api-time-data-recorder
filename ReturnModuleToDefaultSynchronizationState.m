function ReturnModuleToDefaultSynchronizationState(ip,DefaultTimeout)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function resets the module PTP mode to defaults using the REST PUT
% command /rest/rec/syncmode

ModuleSyncModeSettings = struct;
ModuleSyncModeSettings.synchronization.mode = 'stand-alone';
ModuleSyncModeSettings.synchronization.preferredMaster = false;
webwrite(strcat(strcat("http://",ip),"/rest/rec/syncmode"),weboptions('RequestMethod','put','ContentType','json', 'Timeout', DefaultTimeout),ModuleSyncModeSettings);

end