function RecorderMeasure(ip,DefaultTimeout)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% Starts the streaming of samples to the destination. Streaming starts as
% soon as the command is received and processed, and data needs to be
% consumed by the client before buffers overflow. Sent to service modules
% first, then the command module. Note that after issuing the REST command
% it is necessary to wait for moduleState to be "RecorderRecording" before
% further commands are issued.

webwrite(strcat(strcat("http://",ip),"/rest/rec/measurements"),weboptions('RequestMethod','post','Timeout',DefaultTimeout));
WaitForModuleState(ip,DefaultTimeout,"RecorderRecording");

end