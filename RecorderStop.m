function RecorderStop(ip,DefaultTimeout)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function stops the streaming of samples to the destination using the
% REST PUT command /rest/rec/measurements/stop.  Note that after issuing
% the REST command it is necessary to wait for moduleState to be
% "RecorderStreaming" before further commands are issued.

webwrite(strcat(strcat("http://",ip),"/rest/rec/measurements/stop"),weboptions('RequestMethod','put','Timeout',DefaultTimeout));
WaitForModuleState(ip,DefaultTimeout,"RecorderStreaming");

end