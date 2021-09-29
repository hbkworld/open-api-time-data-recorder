function [Magic,HeaderLength,MessageType,Reserved1,Reserved2,K,L,M,N,Ticks,LengthOfMessageContent,MessageData] = MessageHeader(BinaryStream)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function decodes the message header

HeaderData = uint8(read(BinaryStream, 28));

Magic = strcat(HeaderData(1),HeaderData(2));
HeaderLength = typecast(HeaderData(3:4), 'int16');
MessageType = typecast(HeaderData(5:6), 'int16');
Reserved1 = typecast(HeaderData(7:8), 'int16');
Reserved2 = typecast(HeaderData(9:12), 'int32');

%Extract Time Stamp parameters 12 bytes in total
K = typecast(HeaderData(13), 'uint8');
L = typecast(HeaderData(14), 'uint8');
M = typecast(HeaderData(15), 'uint8');
N = typecast(HeaderData(16), 'uint8');
Ticks = typecast(HeaderData(17:24), 'int64');

LengthOfMessageContent = typecast(HeaderData(25:28), 'int32');
MessageData = uint8(read(BinaryStream, double(LengthOfMessageContent)));

end