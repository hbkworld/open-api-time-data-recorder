function [SignalId,DescriptorType,Reserved,ValueLength,ValDataType,ValScaleFactor,ValOffset,ValK,ValL,ValM,ValN,ValTimestamp,ValUnit,ValVectorLength] = MessageContentInterpretation(MessageData,LengthOfMessageContent)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function decodes interpretation messages received from the module

nByteIndex = 1; % Starting point of the Byte indexer

while nByteIndex < LengthOfMessageContent

    SignalId =  typecast(MessageData(nByteIndex:nByteIndex+1), 'int16');
    nByteIndex = nByteIndex + 2;
    DescriptorType = typecast(MessageData(nByteIndex:nByteIndex+1), 'int16');
    nByteIndex = nByteIndex + 2;
    Reserved = typecast(MessageData(nByteIndex:nByteIndex+1), 'int16');
    nByteIndex = nByteIndex + 2;
    ValueLength = typecast(MessageData(nByteIndex:nByteIndex+1), 'int16');
    nByteIndex = nByteIndex + 2;

    switch DescriptorType
        case 1 % DataType int16
            ValDataType = typecast(MessageData(nByteIndex:nByteIndex+1), 'int16');
            nByteIndex = nByteIndex + 4; %Padding to match 32 bit
        case 2 % ScaleFactor double
            ValScaleFactor = typecast(MessageData(nByteIndex:nByteIndex + 7), 'double');
            nByteIndex = nByteIndex + 8; %Padding to match 32 bit
        case 3 % Offset double
            ValOffset = typecast(MessageData(nByteIndex:nByteIndex + 7), 'double');
            nByteIndex = nByteIndex + 8; %Padding to match 32 bit
        case 4 % PeriodTime TimeStamp 12 bytes
            ValK = typecast(MessageData(nByteIndex), 'uint8');
            nByteIndex = nByteIndex + 1;
            ValL = typecast(MessageData(nByteIndex), 'uint8');
            nByteIndex = nByteIndex + 1;
            ValM = typecast(MessageData(nByteIndex), 'uint8');
            nByteIndex = nByteIndex + 1;
            ValN = typecast(MessageData(nByteIndex), 'uint8');
            nByteIndex = nByteIndex + 1;
            ValTimestamp = typecast(MessageData(nByteIndex:nByteIndex+7), 'int64');
            nByteIndex = nByteIndex + 8;
        case 5 % Unit
            SizeUnit = typecast(MessageData(nByteIndex:nByteIndex+1), 'int16');
            nByteIndex = nByteIndex + 2;
            ValUnit = char('');
            for c = 1:SizeUnit
                ValUnit = strcat(ValUnit, char(MessageData(nByteIndex)));
                nByteIndex = nByteIndex + 1;
            end
        case 6 % VectorLength
            ValVectorLength = typecast(MessageData(9:10), 'int16');
            nByteIndex = nByteIndex + 4; %Padding to match 32 bit
        otherwise % Unhandled
    end
end    
end