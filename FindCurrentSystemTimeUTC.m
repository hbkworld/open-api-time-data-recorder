function SystemTimeUTC = FindCurrentSystemTimeUTC

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function finds the current time and day for the time zone the
% computer is operating in and converts it to UTC

SystemTimeUTC = convertTo(datetime('now','TimeZone','UTC'),'epochtime','Epoch','1970-01-01','TicksPerSecond',1000);

end