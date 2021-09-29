function [ModuleIPTableColumnFormat,ModuleIPTableData] = InitializeModuleIPTable(NumberOfModuleIPTableColumns,NumberOfModules,HardwareType)

% Bruel & Kjaer LAN-XI Open Application Programming Interface
% MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
% By Matthew Houtteman and Gert Nyrup
% +1 800-332-2040
% TechnicalSalesSupport.US@hbkworld.com
% Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501

% This function populates data and formats columns of ModuleIPTable based
% on the user selections from HardwareDropDown and NumberofModulesEditField
% in the main app file.  Note that the command module is always assigned
% number 1 regardless of whether the setup uses a frame or switch hardware.

ModuleIPTableData = cell(NumberOfModules,NumberOfModuleIPTableColumns);

if string(HardwareType) == "Frame" 
    
    for ii = 1:1:NumberOfModules

        if ii == 1
            ModuleIPTableData(ii,:) = {ii 'Command' []};
        else
            ModuleIPTableData(ii,:) = {ii 'Service' []};
        end

    end

    ModuleIPTableColumnFormat = ({[] ...
        {'Command' 'Service'} ...
        []});
    
elseif string(HardwareType) == "Switch" 
    
    for ii = 1:1:NumberOfModules

        if ii == 1
            ModuleIPTableData(ii,:) = {ii 'Command' []};
        else
            ModuleIPTableData(ii,:) = {ii 'Service' []};
        end

    end

    ModuleIPTableColumnFormat = ({[] ...
        {'Command' 'Service'} ...
        []});
    
else
    
    ModuleIPTableData(1,:) = {1 'Stand-alone' []};
    ModuleIPTableColumnFormat = ({[] ...
        {'Stand-alone'} ...
        []});
    
end

end