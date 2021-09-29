function ChannelInformationTableData = TEDSOverride(ModuleInformation,TransducerInformation,ChannelInformationTableData)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function overwrites data entered by the user into
% ChannelInformationTable based on transducer information obtained from
% subsequent TEDS detection event

for ii=1:1:ModuleInformation.numberOfInputChannels
    if (string(class(TransducerInformation)) ~= "double" && string(class(TransducerInformation)) ~= "char") && string(class(TransducerInformation{ii,1})) == "struct"
        
        if TransducerInformation{ii,1}.requiresCcld == 1
            CCLD = 'Yes';
        else
            CCLD = 'No';
        end
        
        ChannelInformationTableData(ii,:) = {ChannelInformationTableData{ii,1} ChannelInformationTableData{ii,2} ChannelInformationTableData{ii,3} ChannelInformationTableData{ii,4} ChannelInformationTableData{ii,5} ChannelInformationTableData{ii,6} ChannelInformationTableData{ii,7} CCLD [TransducerInformation{ii,1}.type.prefix '-' TransducerInformation{ii,1}.type.number '-' TransducerInformation{ii,1}.type.model '-' TransducerInformation{ii,1}.type.variant] TransducerInformation{ii,1}.serialNumber TransducerInformation{ii,1}.sensitivity ['V/' TransducerInformation{ii,1}.unit]};

    else
    
        ChannelInformationTableData(ii,:) = ChannelInformationTableData(ii,:);
        
    end
end

end