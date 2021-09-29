function StartGenerator(ip,DefaultTimeout,GeneratorStartParameters)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function starts the generators in sync using the REST PUT command
% /rest/rec/generator/start

webwrite(strcat(strcat("http://",ip),"/rest/rec/generator/start"),weboptions('RequestMethod','put','Timeout',DefaultTimeout),GeneratorStartParameters);

end