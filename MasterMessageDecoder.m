function [InterpretationMessages,SignalDataMessages,InterpretationMessageCounter,SignalDataMessageCounter] = MasterMessageDecoder(BinaryStream,ModuleNumber,LoopCounter,InterpretationMessages,SignalDataMessages,InterpretationMessageCounter,SignalDataMessageCounter)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function calls the message header decoding function which determines
% the MessageType.  Based on the value of MessageType received it then
% decodes either an interpretation message or a signal data message and
% returns the results to the main app.

[~,~,MessageType,~,~,K,L,M,N,Ticks,LengthOfMessageContent,MessageData] = MessageHeader(BinaryStream);

if MessageType == 8 % Interpretation Message

    [SignalId,DescriptorType,Reserved,ValueLength,ValDataType,ValScaleFactor,ValOffset,ValK,ValL,ValM,ValN,ValTimestamp,ValUnit,ValVectorLength] = MessageContentInterpretation(MessageData,LengthOfMessageContent);
    InterpretationMessages(InterpretationMessageCounter,:) = table(LoopCounter,InterpretationMessageCounter,ModuleNumber,K,L,M,N,Ticks,SignalId,DescriptorType,Reserved,ValueLength,ValDataType,ValScaleFactor,ValOffset,ValK,ValL,ValM,ValN,ValTimestamp,string(ValUnit),ValVectorLength);
    InterpretationMessageCounter = InterpretationMessageCounter+1;

elseif MessageType == 1 %SignalData
    
    [NewSignalDataMessages,SignalDataMessageCounter] = MessageContentSignalData(MessageData,LengthOfMessageContent,InterpretationMessages(InterpretationMessages.ModuleNumber == ModuleNumber,:),K,L,M,N,Ticks,LoopCounter,SignalDataMessageCounter,ModuleNumber); 
    
    for ii = 1:1:height(NewSignalDataMessages)
        SignalDataMessages(NewSignalDataMessages.SignalDataMessageNumber(ii),:) = NewSignalDataMessages(ii,:);
    end

end

end