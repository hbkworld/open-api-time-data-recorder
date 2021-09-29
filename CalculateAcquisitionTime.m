function ChannelAcquisitionTime = CalculateAcquisitionTime(SignalDataMessages,NumberOfModules,NumberOfActiveChannels)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function calculates how much time data has been collected for each
% channel in the setup

SignalDataMessages = sortrows(SignalDataMessages,{'Ticks','ModuleNumber','SignalId'},{'ascend','ascend','ascend'});

for ii=1:1:height(SignalDataMessages)
    TicksPerSecond = 2^double(SignalDataMessages.K(ii))*3^double(SignalDataMessages.L(ii))*5^double(SignalDataMessages.M(ii))*7^double(SignalDataMessages.N(ii));
    SignalDataMessages.TickSecondsRelativeTime(ii) = (1/TicksPerSecond)*double(SignalDataMessages.Ticks(ii));
end
SignalDataMessages.TickSecondsRelativeTime = SignalDataMessages.TickSecondsRelativeTime - min(SignalDataMessages.TickSecondsRelativeTime);

ChannelAcquisitionTime = zeros(sum(NumberOfActiveChannels),1);
kk = 1;
for ii = 1:1:NumberOfModules
    for jj = 1:1:NumberOfActiveChannels(ii)
        TableRowNumbers = SignalDataMessages.ModuleNumber == ii & SignalDataMessages.SignalId == jj;
        TempSignalDataMessages = SignalDataMessages(TableRowNumbers,:);
        ChannelAcquisitionTime(kk) = max(TempSignalDataMessages.TickSecondsRelativeTime);
        kk = kk + 1;
        clearvars TableRowNumbers TempSignalDataMessages
    end
end

end