function PrepareGenerator(ip,DefaultTimeout,GeneratorStartParameters)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This command will start the clock if not started already. For the outputs
% mentioned in the JSON command, the signal generation will be stopped. The
% input selector will be reset, so it is ready for a different waveform.

webwrite(strcat(strcat("http://",ip),"/rest/rec/generator/prepare"),weboptions('RequestMethod','put','Timeout',DefaultTimeout),GeneratorStartParameters);

end