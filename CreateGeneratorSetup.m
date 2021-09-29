function GeneratorSetup = CreateGeneratorSetup(GeneratorSetup,GeneratorInformationTableData)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function populates the generator setup structure that is passed to
% the module as a JSON with user inputs from the interface

for ii = 1:1:length(GeneratorSetup.outputs)

    if string(GeneratorInformationTableData{ii,3}) == "Yes"
        GeneratorSetup.outputs(ii).floating = true;
    else
        GeneratorSetup.outputs(ii).floating = false;
    end
    
    if GeneratorInformationTableData{ii,4} < 0
        GeneratorSetup.outputs(ii).gain = 0;
    elseif GeneratorInformationTableData{ii,4} > 1
        GeneratorSetup.outputs(ii).gain = 1;
    else
        GeneratorSetup.outputs(ii).gain = GeneratorInformationTableData{ii,4};
    end

    if string(GeneratorInformationTableData{ii,5}) ~= ""
        load(string(GeneratorInformationTableData{ii,5}),'Inputs1and2');
        GeneratorSetup.outputs(ii).inputs = Inputs1and2; 
        clear Inputs1and2
    else
        Inputs1and2 = {};
        Inputs1and2{1,1}.frequency = 0;
        Inputs1and2{1,1}.gain = 0;
        Inputs1and2{1,1}.number = 1;
        Inputs1and2{1,1}.offset = 0;
        Inputs1and2{1,1}.phase = 0;
        Inputs1and2{1,1}.signalType = 'sine';        
        Inputs1and2{2,1}.number = 2;
        Inputs1and2{2,1}.signalType = 'none';
        GeneratorSetup.outputs(ii).inputs = Inputs1and2; 
        clear Inputs1and2
    end
    
    if string(GeneratorInformationTableData{ii,6}) == "Summation"
        GeneratorSetup.outputs(ii).mixfunction = 'sum';
    else
        GeneratorSetup.outputs(ii).mixfunction = 'mul';
    end
    
    if GeneratorInformationTableData{ii,7} < -1
        GeneratorSetup.outputs(ii).offset = -1;
    elseif GeneratorInformationTableData{ii,7} > 1
        GeneratorSetup.outputs(ii).offset = 1;
    else
        GeneratorSetup.outputs(ii).offset = GeneratorInformationTableData{ii,7};
    end
    
end