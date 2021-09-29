function RecorderFinish(ip,DefaultTimeout)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function ends the current recording session and returns the recorder
% to the opened state using the REST PUT command /rest/rec/finish.  Note
% that after issuing the REST command it is necessary to wait for
% moduleState to be "RecorderOpened" before further commands are issued.

webwrite(strcat(strcat("http://",ip),"/rest/rec/finish"),weboptions('RequestMethod','put','Timeout',DefaultTimeout));
WaitForModuleState(ip,DefaultTimeout,"RecorderOpened");

end