function NumberOfSignalDataMessagesReceived = SignalDataMessagesReceived(InterpretationMessages,SignalDataMessages)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function calculates how many signal data messages have been received
% for each channel in the setup

NumberOfModules = max(InterpretationMessages.ModuleNumber);
TotalNumberOfActiveChannels = 0;
for ii = 1:1:NumberOfModules
   TotalNumberOfActiveChannels = TotalNumberOfActiveChannels + height(InterpretationMessages(InterpretationMessages.ModuleNumber == ii,:));
end

NumberOfSignalDataMessagesReceived = zeros(TotalNumberOfActiveChannels,1);
LoopCounter = 1;
for ii = 1:1:NumberOfModules
    ModuleNumberOfActiveChannels = height(InterpretationMessages(InterpretationMessages.ModuleNumber == ii,:));
    for jj = 1:1:ModuleNumberOfActiveChannels
        NumberOfSignalDataMessagesReceived(LoopCounter,1) = height(SignalDataMessages(SignalDataMessages.ModuleNumber == ii & SignalDataMessages.SignalId == jj,:));
        LoopCounter = LoopCounter + 1;
    end
end

end