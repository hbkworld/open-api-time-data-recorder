function RecorderDetectTransducers(ip,DefaultTimeout)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function performs TEDS detection using the REST POST command
% /rest/rec/channels/input/all/transducers/detect.  Note that after issuing
% the REST command it is necessary to wait for transducerDetectionActive to
% be false before further commands are issued.

webwrite(strcat(strcat("http://",ip),"/rest/rec/channels/input/all/transducers/detect"),weboptions('RequestMethod','post', 'Timeout', DefaultTimeout));
WaitForTEDSDetection(ip,DefaultTimeout);

end