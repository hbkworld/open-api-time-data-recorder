function ModuleInformation = GetModuleInformation(ip,DefaultTimeout)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function returns information about the module using the REST GET
% command /rest/rec/module/info

ModuleInformation = webread(strcat(strcat("http://",ip),"/rest/rec/module/info"),weboptions('RequestMethod','get','ContentType','json','Timeout',DefaultTimeout));

end