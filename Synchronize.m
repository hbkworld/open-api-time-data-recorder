function Synchronize(ip,DefaultTimeout)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This command should be sent to all the PTP service modules before being
% issued to the command module. After this command is issued, the input
% state should change to Synchronized on all modules.

webwrite(strcat(strcat("http://",ip),"/rest/rec/synchronize"),weboptions('RequestMethod','put','Timeout',DefaultTimeout));

end