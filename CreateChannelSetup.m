function ChannelSetup = CreateChannelSetup(ChannelSetup,SystemFrequencyRange,ChannelInformationTableData)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function populates the channel setup structure that is passed to the
% module as a JSON with user inputs from the interface

for ii = 1:1:length(ChannelSetup.channels)
    
    ChannelSetup.channels(ii).bandwidth = SystemFrequencyRange; % sets the same sample rate on all channels to comply with hardware limitations
    
    ChannelSetup.channels(ii).destinations = {'socket'}; % replaces stream destination from default SD card to socket
    
    if string(ChannelInformationTableData{ii,3}) == "Yes"
        ChannelSetup.channels(ii).enabled = true; 
    else
        ChannelSetup.channels(ii).enabled = false;
    end
    
    ChannelSetup.channels(ii).filter = ChannelInformationTableData{ii,5};
    
    if string(ChannelInformationTableData{ii,6}) == "Yes"
        ChannelSetup.channels(ii).floating = true; 
    else
        ChannelSetup.channels(ii).floating = false;
    end
    
    ChannelSetup.channels(ii).name = ChannelInformationTableData{ii,7};
    
    ChannelSetup.channels(ii).transducer.requires200V = false;
    if string(ChannelInformationTableData{ii,8}) == "Yes"
        ChannelSetup.channels(ii).ccld = true;
        ChannelSetup.channels(ii).transducer.requiresCcld = true;
    else
        ChannelSetup.channels(ii).ccld = false;
        ChannelSetup.channels(ii).transducer.requiresCcld = false;
    end
    
    ChannelSetup.channels(ii).transducer.sensitivity = ChannelInformationTableData{ii,11};
    ChannelSetup.channels(ii).transducer.serialNumber = ChannelInformationTableData{ii,10};
    ChannelSetup.channels(ii).transducer.unit = ChannelInformationTableData{ii,12}(3:end);
    
end

end