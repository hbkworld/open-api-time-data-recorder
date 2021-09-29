function StartGeneratorsSynchronized(ip,DefaultTimeout)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% Only used in a multi-module system. Multi-module systems can consist of a
% single frame (housing multiple modules), multiple frames (PTP) and/or
% several single modules (PTP). Send this command to the Trigger Master
% module. This module will then send a trigger on the PTP system and/or the
% frame trigger bus. Now, all generators will start synchronized.

webwrite(strcat(strcat("http://",ip),"/rest/rec/apply"),weboptions('RequestMethod','put','Timeout',DefaultTimeout));

end