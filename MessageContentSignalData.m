function [SignalDataMessages,SignalDataMessageCounter] = MessageContentSignalData(MessageData,LengthOfMessageContent,InterpretationMessages,K,L,M,N,Ticks,LoopCounter,SignalDataMessageCounter,ModuleNumber) 

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function decodes signal data messages received from the module

varNames = ["LoopIterations","SignalDataMessageNumber","ModuleNumber","K","L","M","N","Ticks","NumberOfSignals","Reserved","SignalId","NumberOfValues","Values"];
varTypes = ["double","double","double","uint8","uint8","uint8","uint8","int64","int16","int16","int16","int16","cell"];
SignalDataMessages = table('Size',[1 13],'VariableTypes',varTypes,'VariableNames',varNames);

NumberOfSignals = typecast(MessageData(1:2), 'int16');
Reserved = typecast(MessageData(3:4),'int16');
nByteIndex = 5;

ii = 1;
while nByteIndex < LengthOfMessageContent
    
    SignalDataMessages.NumberOfSignals(ii) = NumberOfSignals;
    SignalDataMessages.Reserved(ii) = Reserved;
    SignalDataMessages.K(ii) = K;
    SignalDataMessages.L(ii) = L;
    SignalDataMessages.M(ii) = M;
    SignalDataMessages.N(ii) = N;
    SignalDataMessages.Ticks(ii) = Ticks;
    SignalDataMessages.LoopIterations(ii) = LoopCounter;
    SignalDataMessages.SignalDataMessageNumber(ii) = SignalDataMessageCounter;
    SignalDataMessages.ModuleNumber(ii) = ModuleNumber;

    SignalDataMessages.SignalId(ii) = typecast(MessageData(nByteIndex:nByteIndex+1), 'int16');
    nByteIndex = nByteIndex +2;
    SignalDataMessages.NumberOfValues(ii) = typecast(MessageData(nByteIndex:nByteIndex+1), 'int16');
    nByteIndex = nByteIndex +2;
    ValScaleFactor = InterpretationMessages.ValScaleFactor(InterpretationMessages.SignalId == SignalDataMessages.SignalId(ii));    
    dFactor = 1.0 / 2147483648.0;

    Values = double(zeros(SignalDataMessages.NumberOfValues(ii), 1));
    for d = 1:SignalDataMessages.NumberOfValues(ii)

        tmpVal = uint8(zeros(4, 1)); %temporary 4 byte value
        tmpVal(2) = MessageData(nByteIndex);
        tmpVal(3) = MessageData(nByteIndex+1);
        tmpVal(4) = MessageData(nByteIndex+2);
        tmpVal = typecast(tmpVal(1:4), 'int32');

        Values(d) = double(tmpVal) * dFactor * ValScaleFactor;

        nByteIndex = nByteIndex + 3; %Move to the next 3 bytes

    end
    
    SignalDataMessages.Values(ii) = {Values};
    SignalDataMessageCounter = SignalDataMessageCounter +1;
    ii = ii + 1;

end
        
end