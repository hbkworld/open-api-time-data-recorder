function SupportedFrequencyRanges = FrequencyRangeOptions(ModuleInfo)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function converts the supportedSampleRates from the command module
% strings to display in the UI drop down selection

SupportedFrequencyRanges = cell(1,length(ModuleInfo.supportedSampleRates));
for ii = 1:1:length(ModuleInfo.supportedSampleRates)
    
    SupportedFrequencyRanges{ii} = strcat(num2str((ModuleInfo.supportedSampleRates(ii)/2.56)/1000,'%.1f'),' kHz');
    
    if SupportedFrequencyRanges{ii}(1) == ' '
        
        SupportedFrequencyRanges{ii} = SupportedFrequencyRanges{ii}(2:end);
        
    end
    
end

end