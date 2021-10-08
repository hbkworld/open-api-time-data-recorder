classdef HBKLANXIDAQ < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure  matlab.ui.Figure
        TabGroup                       matlab.ui.container.TabGroup
        ModuleIPSetupTab               matlab.ui.container.Tab
        GridLayout2                    matlab.ui.container.GridLayout
        HardwareDropDown               matlab.ui.control.DropDown
        HardwareDropDownLabel          matlab.ui.control.Label
        ModuleIPTable                  matlab.ui.control.Table
        NumberofModulesEditField       matlab.ui.control.NumericEditField
        NumberofModulesEditFieldLabel  matlab.ui.control.Label
        ConnectButton                  matlab.ui.control.Button
        DAQSetupTab                    matlab.ui.container.Tab
        GridLayout                     matlab.ui.container.GridLayout
        SaveDirectory                  matlab.ui.control.Button
        LoadChannelInformationTable    matlab.ui.control.Button
        SaveChannelInformationTable    matlab.ui.control.Button
        ChannelInformationTable        matlab.ui.control.Table
        SaveDirectoryEditField         matlab.ui.control.EditField
        RecordingNameEditField         matlab.ui.control.EditField
        RecordingNameEditFieldLabel    matlab.ui.control.Label
        FrequencyRangeDropDown         matlab.ui.control.DropDown
        FrequencyRangeDropDownLabel    matlab.ui.control.Label
        ArmDAQButton                   matlab.ui.control.Button
        DetectTEDSButton               matlab.ui.control.Button
        StartDAQButton                 matlab.ui.control.Button
        GeneratorSetupTab              matlab.ui.container.Tab
        GridLayout3                    matlab.ui.container.GridLayout
        SaveGeneratorSetupTable        matlab.ui.control.Button
        LoadGeneratorSetupTable        matlab.ui.control.Button
        LoadGeneratorInputFiles        matlab.ui.control.Button
        GeneratorInformationTable      matlab.ui.control.Table
    end

    % Bruel & Kjaer LAN-XI Open Application Programming Interface
    % MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
    % By Matthew Houtteman and Gert Nyrup
    % +1 800-332-2040
    % TechnicalSalesSupport.US@hbkworld.com
    % Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501
    
    properties (Access = private)

        ActiveDAQ = false;
        AcquisitionTime = 0;
        BinaryStream = {};
        ChannelSetup = {};
        DefaultTimeout = 60;
        Domain = 45;
        GeneratorInputFileFullPath = {};
        GeneratorPresent = false;
        GeneratorSetup = {};
        GeneratorStartAndStopParameters = {};
        InterpretationMessages = table;
        DAQLoopControl = true;
        ModuleInformation = {};
        NumberOfSignalDataMessagesReceived = 0;
        OpenParameters = struct;
        RecorderPort = {};
        SampleRate = 0;
        SignalDataMessages = table;
        SignalDataMessagesRequiredToExitWhileLoop = 0;
        StabilizationTime = 1; % seconds
        TransducerInformation = {};

    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            % Module IP Setup Tab defaults
            app.NumberofModulesEditField.Enable = 'on';
            app.ModuleIPTable.Enable = 'on';
            app.ConnectButton.Enable = true;
            app.HardwareDropDown.Enable = 'off';
            app.HardwareDropDown.Items = {'Single Module'};
            app.HardwareDropDown.Value = 'Single Module';
            
            % DAQ Setup Tab defaults
            app.FrequencyRangeDropDown.Enable = false;
            app.DetectTEDSButton.Enable = false;
            app.LoadChannelInformationTable.Enable = false;
            app.SaveChannelInformationTable.Enable = false;
            app.ArmDAQButton.Enable = false;
            app.SaveDirectory.Enable = false;
            app.SaveDirectoryEditField.Enable = false;
            app.RecordingNameEditField.Enable = false;
            app.StartDAQButton.Enable = false;
            app.ChannelInformationTable.Enable = 'off';
            
            % Generator Setup Tab defaults
            app.LoadGeneratorInputFiles.Enable = false;
            app.LoadGeneratorSetupTable.Enable = false;
            app.SaveGeneratorSetupTable.Enable = false;
            app.GeneratorInformationTable.Enable = 'off';
            
            %Initialize ModuleIPTable with defaults
            [app.ModuleIPTable.ColumnFormat,app.ModuleIPTable.Data] = InitializeModuleIPTable(length(app.ModuleIPTable.ColumnName),app.NumberofModulesEditField.Value,app.HardwareDropDown.Value);
            
        end

        % Button pushed function: ConnectButton
        function ConnectButtonPushed(app, event)

            if app.ConnectButton.Text == "Connect" % Executes the code for connecting the LAN-XI setup
                
                % Disables Module IP Setup Tab UI while connection sequence executes
                app.NumberofModulesEditField.Enable = 'off';
                app.ModuleIPTable.Enable = 'off';
                app.ConnectButton.Enable = false;
                app.HardwareDropDown.Enable = 'off';
                drawnow
                
                % Reset the recorder on all modules before configuration is attempted (precautionary measure to prevent a module attempting configuration in an invalid state)
                for ii = app.NumberofModulesEditField.Value:-1:1
                    RecorderStatus = GetRecorderStatus(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    if RecorderStatus.moduleState == "RecorderConfiguring" || RecorderStatus.moduleState == "RecorderOpened"
                        RecorderClose(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    elseif RecorderStatus.moduleState == "RecorderStreaming"
                        RecorderFinish(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                        RecorderClose(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);                    
                    elseif RecorderStatus.moduleState == "RecorderRecording"
                        RecorderStop(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                        RecorderFinish(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                        RecorderClose(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    end
                    ReturnModuleToDefaultSynchronizationState(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                end
                
                % Retrieve module information for all modules (module call sequence does not matter for this command)
                for ii = 1:1:app.NumberofModulesEditField.Value
                    app.ModuleInformation{ii,1} = GetModuleInformation(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                end
                
                % Set synchronization mode on command module first then on service modules
                for ii = 1:1:app.NumberofModulesEditField.Value
                    SetSynchronizationMode(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout,app.HardwareDropDown.Value,app.Domain,ii);
                end
                
                % Halt connect event sequence advancement until ptpStatus = "Locked" (module call sequence does not matter for this command)        
                for ii = 1:1:app.NumberofModulesEditField.Value
                    WaitForPTPLock(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                end
                
                % Define recorder open parameters and generator start parameters
                app.OpenParameters = DefineOpenParameters(app.OpenParameters,app.NumberofModulesEditField.Value);
                for ii = 1:1:app.NumberofModulesEditField.Value
                    if app.ModuleInformation{ii,1}.numberOfOutputChannels ~= 0
                        app.GeneratorStartAndStopParameters{ii,1} = DefineGeneratorStartAndStopParameters(app.ModuleInformation{ii,1}.numberOfOutputChannels);
                        app.GeneratorPresent = true;
                    end
                end
                
                % Open recorder on service modules first then command module
                for ii = app.NumberofModulesEditField.Value:-1:1
                    RecorderOpen(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout,app.OpenParameters);
                end                
                
                % Prepare generator on service modules first then command module
                for ii = app.NumberofModulesEditField.Value:-1:1
                    if app.ModuleInformation{ii,1}.numberOfOutputChannels ~= 0
                        PrepareGenerator(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout,app.GeneratorStartAndStopParameters{ii,1});
                    end
                end
         
                % Get default channel setup for all modules (module call sequence does not matter for this command)
                for ii = 1:1:app.NumberofModulesEditField.Value
                    app.ChannelSetup{ii,1} = GetDefaultChannelSetup(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                end
                
                % Get default generator setup for all modules (module call sequence does not matter for this command)
                for ii = 1:1:app.NumberofModulesEditField.Value
                    if app.ModuleInformation{ii,1}.numberOfOutputChannels ~= 0
                        app.GeneratorSetup{ii,1} = GetDefaultGeneratorSetup(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    end
                end
                                
                % Detect TEDS on service modules first then command module               
                for ii = app.NumberofModulesEditField.Value:-1:1
                    RecorderDetectTransducers(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    app.TransducerInformation{ii,1} = GetRecorderTransducers(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);                    
                end
                
                % Update tables in UI
                app.FrequencyRangeDropDown.Items = FrequencyRangeOptions(app.ModuleInformation{1,1});  % Populate frequency range drop down using command module
                for ii = 1:1:app.NumberofModulesEditField.Value
                    NewChannelInformationTableData = DefaultChannelInformationTableData(length(app.ChannelInformationTable.ColumnName),ii,app.ModuleInformation{ii,1},app.TransducerInformation{ii,1},app.ChannelSetup{ii,1});
                    app.ChannelInformationTable.Data = [app.ChannelInformationTable.Data;NewChannelInformationTableData];
                    app.ChannelInformationTable.ColumnFormat = FormatChannelInformationTableColumns(app.ModuleInformation{ii,1});
                    if app.ModuleInformation{ii,1}.numberOfOutputChannels ~= 0
                        NewGeneratorInformationTableData = DefaultGeneratorInformationTableData(length(app.GeneratorInformationTable.ColumnName),ii,app.ModuleInformation{ii,1},app.GeneratorSetup{ii,1});
                        app.GeneratorInformationTable.Data = [app.GeneratorInformationTable.Data;NewGeneratorInformationTableData];
                        app.GeneratorInformationTable.ColumnFormat = FormatGeneratorInformationTableColumns;
                    end
                end
                
                % Enables UI after connection sequence completes
                app.ConnectButton.Enable = true;
                app.ConnectButton.Text = "Disconnect";
                app.FrequencyRangeDropDown.Enable = true;
                app.DetectTEDSButton.Enable = true;
                app.LoadChannelInformationTable.Enable = true;
                app.SaveChannelInformationTable.Enable = true;
                app.ArmDAQButton.Enable = true;
                app.ChannelInformationTable.Enable = 'on';
                if app.GeneratorPresent
                    app.LoadGeneratorInputFiles.Enable = true;
                    app.LoadGeneratorSetupTable.Enable = true;
                    app.SaveGeneratorSetupTable.Enable = true;
                    app.GeneratorInformationTable.Enable = 'on';
                end
                drawnow
                
            else % Executes the appropriate code for disconnecting the LAN-XI setup
                
                % Deletes data from ChannelInformationTable and GeneratorInformationTable
                app.ChannelInformationTable.Data = {};
                app.GeneratorInformationTable.Data = {};
                
                % Resets UI to reflect modules being disconnected
                app.ConnectButton.Enable = false;
                app.ConnectButton.Text = "Connect";
                app.FrequencyRangeDropDown.Enable = false;
                app.DetectTEDSButton.Enable = false;
                app.LoadChannelInformationTable.Enable = false;
                app.SaveChannelInformationTable.Enable = false;
                app.ArmDAQButton.Enable = false;
                app.ChannelInformationTable.Enable = 'off';
                app.LoadGeneratorInputFiles.Enable = false;
                app.LoadGeneratorSetupTable.Enable = false;
                app.SaveGeneratorSetupTable.Enable = false;
                app.GeneratorInformationTable.Enable = 'off';
                drawnow
                
                % Reset the recorder on all modules then reboot modules before configuration is attempted (precautionary measure to prevent a module attempting configuration in an invalid state)    
                for ii = app.NumberofModulesEditField.Value:-1:1
                    RecorderStatus = GetRecorderStatus(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    if RecorderStatus.moduleState == "RecorderConfiguring" || RecorderStatus.moduleState == "RecorderOpened"
                        RecorderClose(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    elseif RecorderStatus.moduleState == "RecorderStreaming"
                        RecorderFinish(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                        RecorderClose(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);                    
                    elseif RecorderStatus.moduleState == "RecorderRecording"
                        RecorderStop(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                        RecorderFinish(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                        RecorderClose(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    end
                    ReturnModuleToDefaultSynchronizationState(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    RebootModule(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                end
                
                % Enable Module IP Setup tab
                app.NumberofModulesEditField.Enable = 'on';
                app.ModuleIPTable.Enable = 'on';
                app.ConnectButton.Enable = true;
                app.HardwareDropDown.Enable = 'off';
                
                % Reset all variables to defaults
                app.ActiveDAQ = false;
                app.BinaryStream = {};
                app.ChannelSetup = {};
                app.DefaultTimeout = 60;
                app.Domain = 45;
                app.GeneratorInputFileFullPath = {};
                app.GeneratorPresent = false;
                app.GeneratorSetup = {};
                app.GeneratorStartAndStopParameters = {};
                app.InterpretationMessages = table;
                app.DAQLoopControl = true;
                app.ModuleInformation = {};
                app.NumberOfSignalDataMessagesReceived = 0;
                app.OpenParameters = struct;
                app.RecorderPort = {};
                app.SampleRate = 0;
                app.SignalDataMessages = table;
                app.SignalDataMessagesRequiredToExitWhileLoop = 0;
                app.StabilizationTime = 1; %seconds
                app.TransducerInformation = {};

                drawnow
                
            end
            
        end

        % Button pushed function: ArmDAQButton
        function ArmDAQButtonPushed(app, event)
                   
            if app.ArmDAQButton.Text == "Arm DAQ" % Executes the code for arming the LAN-XI
                
                % Disables UI while arming sequence executes
                app.ConnectButton.Enable = false;
                app.FrequencyRangeDropDown.Enable = false;
                app.DetectTEDSButton.Enable = false;
                app.LoadChannelInformationTable.Enable = false;
                app.SaveChannelInformationTable.Enable = false;
                app.ArmDAQButton.Enable = false;
                app.ChannelInformationTable.Enable = 'off';
                app.LoadGeneratorInputFiles.Enable = false;
                app.LoadGeneratorSetupTable.Enable = false;
                app.SaveGeneratorSetupTable.Enable = false;
                app.GeneratorInformationTable.Enable = 'off';
                drawnow
                
                % Populate ChannelSetup with user inputs from interface
                ChannelInformationTableRowIndex = 1;
                for ii=1:1:app.NumberofModulesEditField.Value
                    app.ChannelSetup{ii,1} = CreateChannelSetup(app.ChannelSetup{ii,1},app.FrequencyRangeDropDown.Value,app.ChannelInformationTable.Data(ChannelInformationTableRowIndex:1:(ChannelInformationTableRowIndex-1+app.ModuleInformation{ii,1}.numberOfInputChannels),:));
                    ChannelInformationTableRowIndex = ChannelInformationTableRowIndex + app.ModuleInformation{ii,1}.numberOfInputChannels;
                end
                
                % Populate GeneratorSetup with user inputs from interface
                GeneratorInformationTableRowIndex = 1;
                for ii=1:1:app.NumberofModulesEditField.Value
                    if app.ModuleInformation{ii,1}.numberOfOutputChannels ~= 0
                        app.GeneratorSetup{ii,1} = CreateGeneratorSetup(app.GeneratorSetup{ii,1},app.GeneratorInformationTable.Data(GeneratorInformationTableRowIndex:1:(GeneratorInformationTableRowIndex-1+app.ModuleInformation{ii,1}.numberOfOutputChannels),:));
                        GeneratorInformationTableRowIndex = GeneratorInformationTableRowIndex + app.ModuleInformation{ii,1}.numberOfOutputChannels;
                    end
                end
                
                % Configure generator on service modules first then command module
                for ii = app.NumberofModulesEditField.Value:-1:1
                    if app.ModuleInformation{ii,1}.numberOfOutputChannels ~= 0
                        ConfigureGenerator(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout,app.GeneratorSetup{ii,1});
                    end
                end
                
                % Start generator on service modules first then command module
                for ii = app.NumberofModulesEditField.Value:-1:1
                    if app.ModuleInformation{ii,1}.numberOfOutputChannels ~= 0
                        StartGenerator(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout,app.GeneratorStartAndStopParameters{ii,1});
                    end
                end
                
                % Start generators synchronized (this step is only required for multiple module systems)
                if app.NumberofModulesEditField.Value > 1
                    StartGeneratorsSynchronized(app.ModuleIPTable.Data{1,3},app.DefaultTimeout);
                end
                
                % Create recorder configuration on service modules first then command module
                for ii = app.NumberofModulesEditField.Value:-1:1
                    RecorderCreateConfiguration(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout,app.ChannelSetup{ii,1},app.NumberofModulesEditField.Value);
                end
                
                % Synchronize service modules first then command module
                if app.NumberofModulesEditField.Value ~= 1
                    for ii = app.NumberofModulesEditField.Value:-1:1
                        Synchronize(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    end
                    for ii = app.NumberofModulesEditField.Value:-1:1
                        WaitForInputState(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout,"Synchronized"); % Wait for all modules to be synchronized before proceeding
                    end   
                end
                
                % Start internal streaming on service modules first then command module
                if app.NumberofModulesEditField.Value ~= 1
                    for ii = app.NumberofModulesEditField.Value:-1:1
                        StartInternalStreaming(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    end
                end
                
                % Get socket port for each module
                for ii = 1:1:app.NumberofModulesEditField.Value
                    app.RecorderPort{ii,1} = GetRecorderDestinationSocketPort(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    if app.RecorderPort{ii,1}.tcpPort <= 0
                        app.RecorderPort{ii,1}.tcpPort = 1536;
                    end
                end
                
                % Find sample rate from user selection in UI
                [~,SampleRateIndex] = find(string(app.FrequencyRangeDropDown.Items) == string(app.FrequencyRangeDropDown.Value));
                app.SampleRate = app.ModuleInformation{1,1}.supportedSampleRates(SampleRateIndex);
                
                pause(app.StabilizationTime); % Allow LAN-XI to stabilize after applying power to all channels.  Stabilization time is a function of filter selection.
                
                % Enables UI after arming sequence completes
                app.ArmDAQButton.Enable = true;
                app.ArmDAQButton.Text = "Disarm DAQ";
                app.SaveDirectory.Enable = true;
                app.SaveDirectoryEditField.Enable = true;
                app.RecordingNameEditField.Enable = true;
                app.StartDAQButton.Enable = true;
                drawnow
                
            else % Executes the code for disarming the LAN-XI
                
                % Disables UI while disarming sequence executes
                app.ArmDAQButton.Enable = false;
                app.SaveDirectory.Enable = false;
                app.SaveDirectoryEditField.Enable = false;
                app.RecordingNameEditField.Enable = false;
                app.StartDAQButton.Enable = false;
                drawnow
                
                % Stop the generator on all modules before we attempt to reconfigure 
                for ii = 1:1:app.NumberofModulesEditField.Value
                    if app.ModuleInformation{ii,1}.numberOfOutputChannels ~= 0
                        StopGenerator(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout,app.GeneratorStartAndStopParameters{ii,1});
                    end
                end
                
                % Reset the recorder on all modules before we attempt to reconfigure     
                for ii = 1:1:app.NumberofModulesEditField.Value
                    RecorderFinish(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                end
                
                % Resets the values of RecorderPort and SampleRate to defaults
                app.RecorderPort = {};
                app.SampleRate = 0;
                
                % Enables UI after disarming sequence completes
                app.ArmDAQButton.Text = "Arm DAQ";
                app.ConnectButton.Enable = true;
                app.FrequencyRangeDropDown.Enable = true;
                app.DetectTEDSButton.Enable = true;
                app.LoadChannelInformationTable.Enable = true;
                app.SaveChannelInformationTable.Enable = true;
                app.ArmDAQButton.Enable = true;
                app.ChannelInformationTable.Enable = 'on';
                if app.GeneratorPresent
                    app.LoadGeneratorInputFiles.Enable = true;
                    app.LoadGeneratorSetupTable.Enable = true;
                    app.SaveGeneratorSetupTable.Enable = true;
                    app.GeneratorInformationTable.Enable = 'on';
                end
                drawnow
                
            end
            
        end

        % Button pushed function: StartDAQButton
        function StartDAQButtonPushed(app, event)
                    
            if app.StartDAQButton.Text == "Start DAQ" % Executes the code for data collection
                
                tic % Starts clock for time elapsed between user hitting start and stop button
                
                % Disables every element of UI except Stop DAQ button
                app.StartDAQButton.Text = 'Stop DAQ';
                app.StartDAQButton.BackgroundColor = [1 0 0];
                app.StartDAQButton.FontColor = [1 1 1];
                app.ArmDAQButton.Enable = false;
                app.SaveDirectory.Enable = false;
                app.SaveDirectoryEditField.Enable = false;
                app.RecordingNameEditField.Enable = false;
                drawnow
                
                % Determines the total number of active input channels for each module in the setup
                NumberOfActiveChannels = zeros(app.NumberofModulesEditField.Value,1);
                for ii = 1:1:app.NumberofModulesEditField.Value
                    for jj = 1:1:length(app.ChannelSetup{ii,1}.channels)
                        if app.ChannelSetup{ii,1}.channels(jj).enabled == true
                            NumberOfActiveChannels(ii) = NumberOfActiveChannels(ii) + 1;
                        end
                    end
                end
                
                % Begins binary streaming of samples from modules
                for ii = app.NumberofModulesEditField.Value:-1:1
                    RecorderMeasure(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    app.BinaryStream{ii,1} = tcpclient(app.ModuleIPTable.Data{ii,3},app.RecorderPort{ii,1}.tcpPort);
                end
                
                % Master binary stream data decoder loop
                app.ActiveDAQ = true; % sets loop control variable to true until user intervention changes value to false
                [app.InterpretationMessages,app.SignalDataMessages] = InterpretationandSignalDataTableSetup;
                LoopCounter = 1; % tracks total number of messages received from module
                InterpretationMessageCounter = 1; % tracks number of interpretation messages received from module
                SignalDataMessageCounter = 1; % tracks number of signal data messages received from module  
                while app.DAQLoopControl == true
                    if app.ActiveDAQ == true % data acquisition is active
                        for ii = app.NumberofModulesEditField.Value:-1:1
                            for jj = 1:1:NumberOfActiveChannels(ii)
                                [app.InterpretationMessages,app.SignalDataMessages,InterpretationMessageCounter,SignalDataMessageCounter] = MasterMessageDecoder(app.BinaryStream{ii,1},ii,LoopCounter,app.InterpretationMessages,app.SignalDataMessages,InterpretationMessageCounter,SignalDataMessageCounter);
                                LoopCounter = LoopCounter + 1;
                            end
                        end
                        drawnow
                    else % user has hit Stop DAQ button and stack is being drained     
                        for ii = app.NumberofModulesEditField.Value:-1:1
                            for jj = 1:1:NumberOfActiveChannels(ii)
                                [app.InterpretationMessages,app.SignalDataMessages,InterpretationMessageCounter,SignalDataMessageCounter] = MasterMessageDecoder(app.BinaryStream{ii,1},ii,LoopCounter,app.InterpretationMessages,app.SignalDataMessages,InterpretationMessageCounter,SignalDataMessageCounter);
                                LoopCounter = LoopCounter + 1;
                            end
                        end
                        ChannelAcquisitionTime = CalculateAcquisitionTime(app.SignalDataMessages,app.NumberofModulesEditField.Value,NumberOfActiveChannels); 
                        if min(ChannelAcquisitionTime) < app.AcquisitionTime % stack will continue to drain until all channels have at least as much time data as has elapsed between user hitting start and stop button
                            app.DAQLoopControl = true;
                        else
                            app.DAQLoopControl = false; % loop escape
                        end
                        drawnow
                    end
                end
                drawnow
                
                % Recorder is stopped and stack is cleared
                for ii = 1:1:app.NumberofModulesEditField.Value
                    RecorderStop(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    clear app.BinaryStream{ii,1}
                end
                
                % Recording data is saved to file
                app.NumberOfSignalDataMessagesReceived = SignalDataMessagesReceived(app.InterpretationMessages,app.SignalDataMessages);
                SaveRecording(app.SaveDirectoryEditField.Value,app.RecordingNameEditField.Value,app.ModuleInformation,app.TransducerInformation,app.ChannelSetup,app.GeneratorSetup,app.InterpretationMessages,app.SignalDataMessages,app.SampleRate,app.NumberOfSignalDataMessagesReceived);               
                
                % Enables UI after data is saved allowing user to start collecting data for another recording
                app.StartDAQButton.Text = 'Start DAQ';
                app.StartDAQButton.BackgroundColor = [0 1 0];
                app.StartDAQButton.FontColor = [0 0 0];
                app.ArmDAQButton.Enable = true;
                app.SaveDirectory.Enable = true;
                app.SaveDirectoryEditField.Enable = true;
                app.RecordingNameEditField.Enable = true;
                app.StartDAQButton.Enable = true;
                app.DAQLoopControl = true;
                drawnow
                
            else
                
                app.AcquisitionTime = toc; % Stops clock for time elapsed between user hitting start and stop button
                app.StartDAQButton.Enable = false; % Disables UI while stack is drained and data is saved
                app.ActiveDAQ = false; % Engages logic condition that drains stack in master binary stream data decoder loop
                drawnow
                
            end
                
     
        end

        % Close request function: 
        % BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure
        function BruelKjaerLANXIOpenAPITimeDataRecorderUIFigureCloseRequest(app, event)
         
            % Reset the recorder on all modules then reboot modules when app is closed (precautionary measure to prevent a module from being left in an invalid state)    
            if app.ConnectButton.Text == "Disconnect"
                for ii = app.NumberofModulesEditField.Value:-1:1
                    RecorderStatus = GetRecorderStatus(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    if RecorderStatus.moduleState == "RecorderConfiguring" || RecorderStatus.moduleState == "RecorderOpened"
                        RecorderClose(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    elseif RecorderStatus.moduleState == "RecorderStreaming"
                        RecorderFinish(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                        RecorderClose(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);                    
                    elseif RecorderStatus.moduleState == "RecorderRecording"
                        RecorderStop(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                        RecorderFinish(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                        RecorderClose(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    end
                    ReturnModuleToDefaultSynchronizationState(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                    RebootModule(app.ModuleIPTable.Data{ii,3},app.DefaultTimeout);
                end
            end
            
            delete(app)
            
        end

        % Button pushed function: DetectTEDSButton
        function DetectTEDSButtonPushed(app, event)
            
            % Disables UI while TEDS detect sequence executes
            app.ConnectButton.Enable = false;
            app.FrequencyRangeDropDown.Enable = false;
            app.DetectTEDSButton.Enable = false;
            app.LoadChannelInformationTable.Enable = false;
            app.SaveChannelInformationTable.Enable = false;
            app.ArmDAQButton.Enable = false;
            app.ChannelInformationTable.Enable = 'off';
            app.LoadGeneratorInputFiles.Enable = false;
            app.LoadGeneratorSetupTable.Enable = false;
            app.SaveGeneratorSetupTable.Enable = false;
            app.GeneratorInformationTable.Enable = 'off';
            drawnow
            
            for ii = 1:1:app.NumberofModulesEditField.Value

                % Detect TEDS on service modules first then command module               
                for jj = app.NumberofModulesEditField.Value:-1:1
                    RecorderDetectTransducers(app.ModuleIPTable.Data{jj,3},app.DefaultTimeout);
                    app.TransducerInformation{jj,1} = GetRecorderTransducers(app.ModuleIPTable.Data{jj,3},app.DefaultTimeout);                    
                end
                
                % Update UI
                ChannelInformationTableRowIndex = 1;
                for jj = 1:1:app.NumberofModulesEditField.Value
                    app.ChannelInformationTable.Data(ChannelInformationTableRowIndex:1:(ChannelInformationTableRowIndex-1+app.ModuleInformation{jj,1}.numberOfInputChannels),:) = TEDSOverride(app.ModuleInformation{jj,1},app.TransducerInformation{jj,1},app.ChannelInformationTable.Data(ChannelInformationTableRowIndex:1:(ChannelInformationTableRowIndex-1+app.ModuleInformation{jj,1}.numberOfInputChannels),:));
                    ChannelInformationTableRowIndex = ChannelInformationTableRowIndex + app.ModuleInformation{jj,1}.numberOfInputChannels;
                end
                
            end
            
            % Enable UI after TEDS detect is finished
            app.ConnectButton.Enable = true;
            app.FrequencyRangeDropDown.Enable = true;
            app.DetectTEDSButton.Enable = true;
            app.LoadChannelInformationTable.Enable = true;
            app.SaveChannelInformationTable.Enable = true;
            app.ArmDAQButton.Enable = true;
            app.ChannelInformationTable.Enable = 'on';
            if app.GeneratorPresent
                app.LoadGeneratorInputFiles.Enable = true;
                app.LoadGeneratorSetupTable.Enable = true;
                app.SaveGeneratorSetupTable.Enable = true;
                app.GeneratorInformationTable.Enable = 'on';
            end
            drawnow
                
        end

        % Value changed function: NumberofModulesEditField
        function NumberofModulesEditFieldValueChanged(app, event)
                       
            if app.NumberofModulesEditField.Value == 1
                app.HardwareDropDown.Enable = 'off';
                app.HardwareDropDown.Items = {'Single Module'};
                app.HardwareDropDown.Value = 'Single Module';
            else
                app.HardwareDropDown.Enable = 'on';
                app.HardwareDropDown.Items = {'Switch', 'Frame'};
            end
            
             [app.ModuleIPTable.ColumnFormat,app.ModuleIPTable.Data] = InitializeModuleIPTable(length(app.ModuleIPTable.ColumnName),app.NumberofModulesEditField.Value,app.HardwareDropDown.Value);
            
        end

        % Value changed function: HardwareDropDown
        function HardwareDropDownValueChanged(app, event)
           
            [app.ModuleIPTable.ColumnFormat,app.ModuleIPTable.Data] = InitializeModuleIPTable(length(app.ModuleIPTable.ColumnName),app.NumberofModulesEditField.Value,app.HardwareDropDown.Value);
            
        end

        % Button pushed function: LoadChannelInformationTable
        function LoadChannelInformationTableButtonPushed(app, event)
            
            [ChannelInformationTableFile,ChannelInformationTableDirectory] = uigetfile('*.mat');
            drawnow
            figure(app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure)
            if ChannelInformationTableFile == 0 % user pressed cancel
                return
            else
                load(fullfile(ChannelInformationTableDirectory,ChannelInformationTableFile),'ChannelInformationTableData');
                app.ChannelInformationTable.Data = ChannelInformationTableData;
            end
            
        end

        % Button pushed function: SaveChannelInformationTable
        function SaveChannelInformationTableButtonPushed(app, event)
                        
            [ChannelInformationTableFile,ChannelInformationTableDirectory] = uiputfile('*.mat');
            drawnow
            figure(app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure)            
            if ChannelInformationTableFile == 0 % user pressed cancel
                return
            else
                ChannelInformationTableData = app.ChannelInformationTable.Data;
                save(fullfile(ChannelInformationTableDirectory,ChannelInformationTableFile),'ChannelInformationTableData');
            end
            
        end

        % Button pushed function: LoadGeneratorInputFiles
        function LoadGeneratorInputFilesButtonPushed(app, event)
            
            GeneratorInputFilesDirectory = uigetdir;
            drawnow
            figure(app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure)            
            if GeneratorInputFilesDirectory == 0 % user pressed cancel
                return
            else
                GeneratorInputFiles = dir(fullfile(GeneratorInputFilesDirectory, '*.mat'));
                for ii = 1:1:length(GeneratorInputFiles)
                    app.GeneratorInputFileFullPath{ii,1} = [GeneratorInputFiles(ii).folder '\' GeneratorInputFiles(ii).name];
                end
                app.GeneratorInformationTable.ColumnFormat{1,5} = transpose(app.GeneratorInputFileFullPath);
            end
            
        end

        % Button pushed function: LoadGeneratorSetupTable
        function LoadGeneratorSetupTablePushed(app, event)
            
            [GeneratorSetupTableFile,GeneratorSetupTableDirectory] = uigetfile('*.mat');
            drawnow
            figure(app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure)
            if GeneratorSetupTableFile == 0 % user pressed cancel
                return
            else
                load(fullfile(GeneratorSetupTableDirectory,GeneratorSetupTableFile),'GeneratorInformationTableData');
                app.GeneratorInformationTable.Data = GeneratorInformationTableData;
            end
            
        end

        % Button pushed function: SaveGeneratorSetupTable
        function SaveGeneratorSetupTablePushed(app, event)
                 
            [GeneratorSetupTableFile,GeneratorSetupTableDirectory] = uiputfile('*.mat');
            drawnow
            figure(app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure)
            if GeneratorSetupTableFile == 0 % user pressed cancel
                return
            else
                GeneratorInformationTableData = app.GeneratorInformationTable.Data;
                save(fullfile(GeneratorSetupTableDirectory,GeneratorSetupTableFile),'GeneratorInformationTableData');
            end
            
        end

        % Button pushed function: SaveDirectory
        function SaveDirectoryButtonPushed(app, event)
            
            MeasurementSaveDirectory = uigetdir;
            drawnow
            figure(app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure)
            if MeasurementSaveDirectory == 0
                return
            else
                app.SaveDirectoryEditField.Value = MeasurementSaveDirectory;
            end
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure and hide until all components are created
            app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure = uifigure('Visible', 'off');
            app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure.Position = [100 100 1166 557];
            app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure.Name = 'Bruel & Kjaer LAN-XI Open API Time Data Recorder';
            app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure.CloseRequestFcn = createCallbackFcn(app, @BruelKjaerLANXIOpenAPITimeDataRecorderUIFigureCloseRequest, true);

            % Create TabGroup
            app.TabGroup = uitabgroup(app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure);
            app.TabGroup.Position = [1 0 1167 558];

            % Create ModuleIPSetupTab
            app.ModuleIPSetupTab = uitab(app.TabGroup);
            app.ModuleIPSetupTab.Title = 'Module IP Setup';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.ModuleIPSetupTab);
            app.GridLayout2.ColumnWidth = {'fit', 'fit', '1x'};
            app.GridLayout2.RowHeight = {'fit', 'fit', 'fit', '13.69x'};

            % Create ConnectButton
            app.ConnectButton = uibutton(app.GridLayout2, 'push');
            app.ConnectButton.ButtonPushedFcn = createCallbackFcn(app, @ConnectButtonPushed, true);
            app.ConnectButton.BackgroundColor = [0.9608 0.9608 0.9608];
            app.ConnectButton.FontWeight = 'bold';
            app.ConnectButton.Layout.Row = 3;
            app.ConnectButton.Layout.Column = [1 3];
            app.ConnectButton.Text = 'Connect';

            % Create NumberofModulesEditFieldLabel
            app.NumberofModulesEditFieldLabel = uilabel(app.GridLayout2);
            app.NumberofModulesEditFieldLabel.HorizontalAlignment = 'center';
            app.NumberofModulesEditFieldLabel.FontWeight = 'bold';
            app.NumberofModulesEditFieldLabel.Layout.Row = 1;
            app.NumberofModulesEditFieldLabel.Layout.Column = 1;
            app.NumberofModulesEditFieldLabel.Text = 'Number of Modules';

            % Create NumberofModulesEditField
            app.NumberofModulesEditField = uieditfield(app.GridLayout2, 'numeric');
            app.NumberofModulesEditField.Limits = [1 Inf];
            app.NumberofModulesEditField.ValueChangedFcn = createCallbackFcn(app, @NumberofModulesEditFieldValueChanged, true);
            app.NumberofModulesEditField.HorizontalAlignment = 'center';
            app.NumberofModulesEditField.FontWeight = 'bold';
            app.NumberofModulesEditField.Layout.Row = 1;
            app.NumberofModulesEditField.Layout.Column = 2;
            app.NumberofModulesEditField.Value = 1;

            % Create ModuleIPTable
            app.ModuleIPTable = uitable(app.GridLayout2);
            app.ModuleIPTable.ColumnName = {'Module Number'; 'Type'; 'IP Address'};
            app.ModuleIPTable.RowName = {};
            app.ModuleIPTable.ColumnEditable = [false false true];
            app.ModuleIPTable.Layout.Row = 4;
            app.ModuleIPTable.Layout.Column = [1 3];

            % Create HardwareDropDownLabel
            app.HardwareDropDownLabel = uilabel(app.GridLayout2);
            app.HardwareDropDownLabel.HorizontalAlignment = 'center';
            app.HardwareDropDownLabel.FontWeight = 'bold';
            app.HardwareDropDownLabel.Layout.Row = 2;
            app.HardwareDropDownLabel.Layout.Column = 1;
            app.HardwareDropDownLabel.Text = 'Hardware';

            % Create HardwareDropDown
            app.HardwareDropDown = uidropdown(app.GridLayout2);
            app.HardwareDropDown.Items = {'Single Module', 'Switch', 'Frame'};
            app.HardwareDropDown.ValueChangedFcn = createCallbackFcn(app, @HardwareDropDownValueChanged, true);
            app.HardwareDropDown.Layout.Row = 2;
            app.HardwareDropDown.Layout.Column = 2;
            app.HardwareDropDown.Value = 'Single Module';

            % Create DAQSetupTab
            app.DAQSetupTab = uitab(app.TabGroup);
            app.DAQSetupTab.Title = 'DAQ Setup';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.DAQSetupTab);
            app.GridLayout.ColumnWidth = {'fit', '1x', 'fit', '6x'};
            app.GridLayout.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', '1x'};
            app.GridLayout.ColumnSpacing = 4.88888888888889;
            app.GridLayout.RowSpacing = 12.75;
            app.GridLayout.Padding = [4.88888888888889 12.75 4.88888888888889 12.75];

            % Create StartDAQButton
            app.StartDAQButton = uibutton(app.GridLayout, 'push');
            app.StartDAQButton.ButtonPushedFcn = createCallbackFcn(app, @StartDAQButtonPushed, true);
            app.StartDAQButton.BackgroundColor = [0 1 0];
            app.StartDAQButton.FontWeight = 'bold';
            app.StartDAQButton.Layout.Row = 7;
            app.StartDAQButton.Layout.Column = [1 4];
            app.StartDAQButton.Text = 'Start DAQ';

            % Create DetectTEDSButton
            app.DetectTEDSButton = uibutton(app.GridLayout, 'push');
            app.DetectTEDSButton.ButtonPushedFcn = createCallbackFcn(app, @DetectTEDSButtonPushed, true);
            app.DetectTEDSButton.FontWeight = 'bold';
            app.DetectTEDSButton.Layout.Row = 1;
            app.DetectTEDSButton.Layout.Column = 3;
            app.DetectTEDSButton.Text = 'Detect TEDS';

            % Create ArmDAQButton
            app.ArmDAQButton = uibutton(app.GridLayout, 'push');
            app.ArmDAQButton.ButtonPushedFcn = createCallbackFcn(app, @ArmDAQButtonPushed, true);
            app.ArmDAQButton.FontWeight = 'bold';
            app.ArmDAQButton.Layout.Row = 4;
            app.ArmDAQButton.Layout.Column = [1 4];
            app.ArmDAQButton.Text = 'Arm DAQ';

            % Create FrequencyRangeDropDownLabel
            app.FrequencyRangeDropDownLabel = uilabel(app.GridLayout);
            app.FrequencyRangeDropDownLabel.HorizontalAlignment = 'center';
            app.FrequencyRangeDropDownLabel.FontWeight = 'bold';
            app.FrequencyRangeDropDownLabel.Layout.Row = 1;
            app.FrequencyRangeDropDownLabel.Layout.Column = 1;
            app.FrequencyRangeDropDownLabel.Text = 'Frequency Range';

            % Create FrequencyRangeDropDown
            app.FrequencyRangeDropDown = uidropdown(app.GridLayout);
            app.FrequencyRangeDropDown.Items = {};
            app.FrequencyRangeDropDown.Editable = 'on';
            app.FrequencyRangeDropDown.BackgroundColor = [1 1 1];
            app.FrequencyRangeDropDown.Layout.Row = 1;
            app.FrequencyRangeDropDown.Layout.Column = 2;
            app.FrequencyRangeDropDown.Value = {};

            % Create RecordingNameEditFieldLabel
            app.RecordingNameEditFieldLabel = uilabel(app.GridLayout);
            app.RecordingNameEditFieldLabel.HorizontalAlignment = 'center';
            app.RecordingNameEditFieldLabel.FontWeight = 'bold';
            app.RecordingNameEditFieldLabel.Layout.Row = 6;
            app.RecordingNameEditFieldLabel.Layout.Column = 1;
            app.RecordingNameEditFieldLabel.Text = 'Recording Name';

            % Create RecordingNameEditField
            app.RecordingNameEditField = uieditfield(app.GridLayout, 'text');
            app.RecordingNameEditField.Layout.Row = 6;
            app.RecordingNameEditField.Layout.Column = [2 4];

            % Create SaveDirectoryEditField
            app.SaveDirectoryEditField = uieditfield(app.GridLayout, 'text');
            app.SaveDirectoryEditField.Layout.Row = 5;
            app.SaveDirectoryEditField.Layout.Column = [2 4];

            % Create ChannelInformationTable
            app.ChannelInformationTable = uitable(app.GridLayout);
            app.ChannelInformationTable.ColumnName = {'Module Number'; 'Channel Number'; 'Enabled'; 'Range'; 'Filter'; 'Floating'; 'Name'; 'CCLD'; 'Transducer Model'; 'Transducer Serial Number'; 'Sensitivity'; 'Units'};
            app.ChannelInformationTable.RowName = {};
            app.ChannelInformationTable.ColumnEditable = [false false true true true true true true true true true true];
            app.ChannelInformationTable.Layout.Row = 8;
            app.ChannelInformationTable.Layout.Column = [1 4];

            % Create SaveChannelInformationTable
            app.SaveChannelInformationTable = uibutton(app.GridLayout, 'push');
            app.SaveChannelInformationTable.ButtonPushedFcn = createCallbackFcn(app, @SaveChannelInformationTableButtonPushed, true);
            app.SaveChannelInformationTable.FontWeight = 'bold';
            app.SaveChannelInformationTable.Layout.Row = 3;
            app.SaveChannelInformationTable.Layout.Column = 1;
            app.SaveChannelInformationTable.Text = 'Save Input Channel Setup Table';

            % Create LoadChannelInformationTable
            app.LoadChannelInformationTable = uibutton(app.GridLayout, 'push');
            app.LoadChannelInformationTable.ButtonPushedFcn = createCallbackFcn(app, @LoadChannelInformationTableButtonPushed, true);
            app.LoadChannelInformationTable.FontWeight = 'bold';
            app.LoadChannelInformationTable.Layout.Row = 2;
            app.LoadChannelInformationTable.Layout.Column = 1;
            app.LoadChannelInformationTable.Text = 'Load Input Channel Setup Table';

            % Create SaveDirectory
            app.SaveDirectory = uibutton(app.GridLayout, 'push');
            app.SaveDirectory.ButtonPushedFcn = createCallbackFcn(app, @SaveDirectoryButtonPushed, true);
            app.SaveDirectory.FontWeight = 'bold';
            app.SaveDirectory.Layout.Row = 5;
            app.SaveDirectory.Layout.Column = 1;
            app.SaveDirectory.Text = 'Save Directory';

            % Create GeneratorSetupTab
            app.GeneratorSetupTab = uitab(app.TabGroup);
            app.GeneratorSetupTab.Title = 'Generator Setup';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GeneratorSetupTab);
            app.GridLayout3.ColumnWidth = {'fit', '1x'};
            app.GridLayout3.RowHeight = {'fit', 'fit', 'fit', '1x'};

            % Create GeneratorInformationTable
            app.GeneratorInformationTable = uitable(app.GridLayout3);
            app.GeneratorInformationTable.ColumnName = {'Module Number'; 'Output Number'; 'Floating'; 'Gain'; 'Specify File Path for Inputs'; 'Mix Function'; 'Offset'};
            app.GeneratorInformationTable.RowName = {};
            app.GeneratorInformationTable.ColumnEditable = [false false true true true true true];
            app.GeneratorInformationTable.Layout.Row = 4;
            app.GeneratorInformationTable.Layout.Column = [1 2];

            % Create LoadGeneratorInputFiles
            app.LoadGeneratorInputFiles = uibutton(app.GridLayout3, 'push');
            app.LoadGeneratorInputFiles.ButtonPushedFcn = createCallbackFcn(app, @LoadGeneratorInputFilesButtonPushed, true);
            app.LoadGeneratorInputFiles.FontWeight = 'bold';
            app.LoadGeneratorInputFiles.Layout.Row = 1;
            app.LoadGeneratorInputFiles.Layout.Column = 1;
            app.LoadGeneratorInputFiles.Text = 'Load Generator Input Files';

            % Create LoadGeneratorSetupTable
            app.LoadGeneratorSetupTable = uibutton(app.GridLayout3, 'push');
            app.LoadGeneratorSetupTable.ButtonPushedFcn = createCallbackFcn(app, @LoadGeneratorSetupTablePushed, true);
            app.LoadGeneratorSetupTable.FontWeight = 'bold';
            app.LoadGeneratorSetupTable.Layout.Row = 2;
            app.LoadGeneratorSetupTable.Layout.Column = 1;
            app.LoadGeneratorSetupTable.Text = 'Load Generator Setup Table';

            % Create SaveGeneratorSetupTable
            app.SaveGeneratorSetupTable = uibutton(app.GridLayout3, 'push');
            app.SaveGeneratorSetupTable.ButtonPushedFcn = createCallbackFcn(app, @SaveGeneratorSetupTablePushed, true);
            app.SaveGeneratorSetupTable.FontWeight = 'bold';
            app.SaveGeneratorSetupTable.Layout.Row = 3;
            app.SaveGeneratorSetupTable.Layout.Column = 1;
            app.SaveGeneratorSetupTable.Text = 'Save Generator Setup Table';

            % Show the figure after all components are created
            app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = HBKLANXIDAQ

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.BruelKjaerLANXIOpenAPITimeDataRecorderUIFigure)
        end
    end
end