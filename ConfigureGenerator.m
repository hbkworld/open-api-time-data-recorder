function ConfigureGenerator(ip,DefaultTimeout,GeneratorSetup)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function configures the generator on the module using the REST PUT
% command /rest/rec/generator/output

webwrite(strcat(strcat("http://",ip),"/rest/rec/generator/output"),weboptions('RequestMethod','put','Timeout',DefaultTimeout),GeneratorSetup);

end