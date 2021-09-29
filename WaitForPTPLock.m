function WaitForPTPLock(ip,DefaultTimeout)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function runs a while loop until the REST GET command
% /rest/rec/onchange returns a ptpStatus of "Locked"

RecorderStatus = GetRecorderStatus(ip,DefaultTimeout);


if isempty(fieldnames(RecorderStatus)) % Keep issuing GET command until we get a proper result
    
    while isempty(fieldnames(RecorderStatus))
        
        RecorderStatus = GetRecorderStatus(ip,DefaultTimeout);
        
    end
    
end


while RecorderStatus.ptpStatus ~= "Locked"
    
    RecorderStatus = GetRecorderStatus(ip,DefaultTimeout);
    
    while isempty(fieldnames(RecorderStatus)) % Keep issuing GET command until we get a proper result
        
        RecorderStatus = GetRecorderStatus(ip,DefaultTimeout);
        
    end

end


end