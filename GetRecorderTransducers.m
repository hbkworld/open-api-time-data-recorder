function TransducerInformation = GetRecorderTransducers(ip,DefaultTimeout)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function returns information about the transducers connected to the
% module using the REST GET command
% /rest/rec/channels/input/all/transducers

TransducerInformation = webread(strcat(strcat("http://",ip),"/rest/rec/channels/input/all/transducers"),weboptions('RequestMethod','get','ContentType','json', 'Timeout', DefaultTimeout));

end