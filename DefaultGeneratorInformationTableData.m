function GeneratorInformationTableData = DefaultGeneratorInformationTableData(NumberOfGeneratorInformationTableColumns,ModuleNumber,ModuleInformation,GeneratorSetup)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function populates default data in GeneratorInformationTable

GeneratorInformationTableData = cell(ModuleInformation.numberOfOutputChannels,NumberOfGeneratorInformationTableColumns);        
for ii = 1:1:ModuleInformation.numberOfOutputChannels
    
    if GeneratorSetup.outputs(ii).floating == true
            Floating = 'Yes';
    else
            Floating = 'No';
    end
    
    if GeneratorSetup.outputs(ii).mixfunction == 'sum'
            MixFunction = 'Summation';
    else
            MixFunction = 'Multiplication';
    end
    
        GeneratorInformationTableData(ii,:) = {ModuleNumber GeneratorSetup.outputs(ii).number Floating GeneratorSetup.outputs(ii).gain [] MixFunction GeneratorSetup.outputs(ii).offset};

end

end