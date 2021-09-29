function ChannelInformationTableData = DefaultChannelInformationTableData(NumberOfChannelInformationTableColumns,ModuleNumber,ModuleInformation,TransducerInformation,ChannelSetup)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function populates data of ChannelInformationTable based on
% transducer information from initial TEDS detection

ChannelInformationTableData = cell(ModuleInformation.numberOfInputChannels,NumberOfChannelInformationTableColumns);        
for ii = 1:1:ModuleInformation.numberOfInputChannels
    if (string(class(TransducerInformation)) ~= "double" && string(class(TransducerInformation)) ~= "char") && string(class(TransducerInformation{ii,1})) == "struct"
        
        if TransducerInformation{ii,1}.requiresCcld == 1
            CCLD = 'Yes';
        else
            CCLD = 'No';
        end
        
        if ChannelSetup.channels(ii).floating == true
            Floating = 'Yes';
        else
            Floating = 'No';
        end
        
        ChannelInformationTableData(ii,:) = {ModuleNumber ii 'Yes' ChannelSetup.channels(ii).range ChannelSetup.channels(ii).filter Floating ['Module ' num2str(ModuleNumber) ' ' ChannelSetup.channels(ii).name] CCLD [TransducerInformation{ii,1}.type.prefix '-' TransducerInformation{ii,1}.type.number '-' TransducerInformation{ii,1}.type.model '-' TransducerInformation{ii,1}.type.variant] TransducerInformation{ii,1}.serialNumber TransducerInformation{ii,1}.sensitivity ['V/' TransducerInformation{ii,1}.unit]};
   
    else
        
        CCLD = 'No';
        Floating = 'No';
        
        ChannelInformationTableData(ii,:) = { ModuleNumber ii 'No' ChannelSetup.channels(ii).range ChannelSetup.channels(ii).filter Floating ['Module ' num2str(ModuleNumber) ' ' ChannelSetup.channels(ii).name] CCLD ChannelSetup.channels(ii).transducer.type.number [] ChannelSetup.channels(ii).transducer.sensitivity ['V/' ChannelSetup.channels(ii).transducer.unit]};
        
    end
end

end