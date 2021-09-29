function Timestamp = FrontEndClock(K,L,M,N,Ticks)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function converts message data values to a time stamp

TicksPerSecond = 2^double(K)*3^double(L)*5^double(M)*7^double(N);
TickMilliseconds = (1/TicksPerSecond)*double(Ticks)*1000;
Timestamp = datetime(TickMilliseconds,'ConvertFrom','epochtime','TicksPerSecond',1000,'TimeZone','UTC','Format','yyyy-MM-dd HH:mm:ss.SSSSSSSSS');
Timestamp.TimeZone = 'local';

end