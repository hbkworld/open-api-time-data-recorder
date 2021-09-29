function OpenParameters = DefineOpenParameters(OpenParameters,NumberOfModules)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function defines the recorder open parameters

if NumberOfModules > 1

        OpenParameters.performTransducerDetection = true;
        OpenParameters.singleModule = false;

else

        OpenParameters.performTransducerDetection = true;
        OpenParameters.singleModule = true;

end


end