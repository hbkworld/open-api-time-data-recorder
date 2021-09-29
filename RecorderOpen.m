function RecorderOpen(ip,DefaultTimeout,OpenParameters)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function opens the recorder on the module using the REST PUT command
% /rest/rec/open.  Note that after issuing the REST command it is necessary
% to wait for moduleState to be "RecorderOpened" before further commands
% are issued.

webwrite(strcat(strcat("http://",ip),"/rest/rec/open"),weboptions('RequestMethod','put','Timeout',DefaultTimeout),OpenParameters);
WaitForModuleState(ip,DefaultTimeout,"RecorderOpened");

end