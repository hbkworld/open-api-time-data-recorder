function SaveRecording(SaveDirectory,RecordingName,ModuleInformation,TransducerInformation,ChannelSetup,GeneratorSetup,InterpretationMessages,SignalDataMessages,SampleRate,NumberOfSignalDataMessagesReceived)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function saves the measurements as a .mat file

SignalDataMessagesPerChannel = min(NumberOfSignalDataMessagesReceived);
InterpretationMessages = sortrows(InterpretationMessages,{'ModuleNumber','SignalId'},{'ascend','ascend'});
SignalDataMessages = sortrows(SignalDataMessages,{'ModuleNumber','SignalId','Ticks'},{'ascend','ascend','ascend'});

for ii=1:1:height(SignalDataMessages)
    TicksPerSecond = 2^double(SignalDataMessages.K(ii))*3^double(SignalDataMessages.L(ii))*5^double(SignalDataMessages.M(ii))*7^double(SignalDataMessages.N(ii));
    SignalDataMessages.TickSecondsRelativeTime(ii) = (1/TicksPerSecond)*double(SignalDataMessages.Ticks(ii));
end
SignalDataMessages.TickSecondsRelativeTime = SignalDataMessages.TickSecondsRelativeTime - min(SignalDataMessages.TickSecondsRelativeTime);

varNames = ["ModuleNumber","ChannelNumber","ChannelName","t0","SignalData","Units"];
varTypes = ["double","double","string","datetime","cell","string"];
RecordingData = table('Size',[length(InterpretationMessages.SignalId) 6],'VariableTypes',varTypes,'VariableNames',varNames);

for ii=1:1:length(InterpretationMessages.SignalId)
    
    RecordingData.ModuleNumber(ii) = double(InterpretationMessages.ModuleNumber(ii)); 
    RecordingData.ChannelNumber(ii) = double(InterpretationMessages.SignalId(ii));    
    RecordingData.ChannelName(ii) = string(ChannelSetup{RecordingData.ModuleNumber(ii),1}.channels(RecordingData.ChannelNumber(ii)).name);
    TableRowNumbers = SignalDataMessages.ModuleNumber == RecordingData.ModuleNumber(ii) & SignalDataMessages.SignalId == RecordingData.ChannelNumber(ii);
    TempSignalDataMessages = SignalDataMessages(TableRowNumbers,:);
    TempSignalDataMessages = TempSignalDataMessages(1:SignalDataMessagesPerChannel,:); %this line ensures the same number of signal data messages for all measurement channels    
    RecordingData.t0(ii) = string(FrontEndClock(TempSignalDataMessages.K(1),TempSignalDataMessages.L(1),TempSignalDataMessages.M(1),TempSignalDataMessages.N(1),TempSignalDataMessages.Ticks(1)));
    Signal = zeros(length(TempSignalDataMessages.Values{1,1})*height(TempSignalDataMessages),1);
    DataIndex = 1;
    for jj = 1:1:height(TempSignalDataMessages)
        Signal(DataIndex:1:(length(TempSignalDataMessages.Values{1,1})+DataIndex-1),1) = TempSignalDataMessages.Values{jj,1};
        DataIndex = DataIndex + length(TempSignalDataMessages.Values{1,1});
    end
    RecordingData.SignalData{ii} = Signal;
    RecordingData.Units(ii) = string(ChannelSetup{RecordingData.ModuleNumber(ii),1}.channels(RecordingData.ChannelNumber(ii)).transducer.unit);
    clearvars Signal DataIndex
        
end

RelativeTime = 0:1/SampleRate:(length(RecordingData.SignalData{1,1})-1)/SampleRate;
FrequencyRange = SampleRate / 2.56; % usable frequency span in units of Hz

save(strcat(SaveDirectory,"\",RecordingName,".mat"),'ModuleInformation','TransducerInformation','ChannelSetup','GeneratorSetup','RecordingData','RelativeTime','SampleRate','FrequencyRange','-v7.3','-nocompression'); % optionally add in the following variables if desired for learning/development purposes:  'InterpretationMessages','SignalDataMessages','NumberOfSignalDataMessagesReceived','SignalDataMessagesPerChannel'
end