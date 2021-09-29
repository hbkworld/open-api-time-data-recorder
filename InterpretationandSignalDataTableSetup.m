function [InterpretationMessages,SignalDataMessages] = InterpretationandSignalDataTableSetup

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function creates tables to store Interpretation and Signal Data
% messages received from the module

varNames = ["LoopIterations","InterpretationMessageNumber","ModuleNumber","K","L","M","N","Ticks","SignalId","DescriptorType","Reserved","ValueLength","ValDataType","ValScaleFactor","ValOffset","ValK","ValL","ValM","ValN","ValTimestamp","ValUnit","ValVectorLength"];
varTypes = ["double","double","double","uint8","uint8","uint8","uint8","int64","int16","int16","int16","int16","int16","double","double","uint8","uint8","uint8","uint8","int64","string","int16"];
InterpretationMessages = table('Size',[1 22],'VariableTypes',varTypes,'VariableNames',varNames);
varNames = ["LoopIterations","SignalDataMessageNumber","ModuleNumber","K","L","M","N","Ticks","NumberOfSignals","Reserved","SignalId","NumberOfValues","Values"];
varTypes = ["double","double","double","uint8","uint8","uint8","uint8","int64","int16","int16","int16","int16","cell"];
SignalDataMessages = table('Size',[1 13],'VariableTypes',varTypes,'VariableNames',varNames);

end