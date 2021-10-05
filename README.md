# open-api-time-data-recorder
# Bruel & Kjaer LAN-XI Open Application Programming Interface
# MATLAB Simple Recorder GUI Version 1.0 (September 15, 2021)
# Developed in MATLAB R2021a with LAN-XI Firmware 2.10.0.501
## By Matthew Houtteman and Gert Nyrup
## +1 800-332-2040
## TechnicalSalesSupport.US@hbkworld.com



**Installing and Launching the Application**

1. Place the app file (HBKLANXIDAQ.mlapp) and all function files (.m extension) in the same directory
2. Create the following sub-directories (names must match these exactly, including case, for code to work)
    * Generator Input Files
    * Generator Setup Table Files
    * Input Channel Setup Table Files
    * Measurement Files
3. In MATLAB navigate to the directory that contains the app file
4. In the command window type ‘HBKLANXIDAQ’ and then hit enter


**Running the Application**

_Module IP Setup Tab_
1. Type in a numeric value for Number of Modules
2. Select Switch or Frame for Hardware if Number of Modules > 1
3. Enter IP addresses for each module in the setup, noting that the app forces the command module to be Module Number 1 the same as a B&K Frame would
4. Click Connect, all selections will be grayed out while the connection sequence executes

_DAQ Setup Tab_
1. Select a Frequency Range from the drop-down menu
2. Edit the properties of each channel as needed or load a previously saved input channel setup by clicking ‘Load Input Channel Setup Table’
3. Save input channel setup by clicking ‘Save Input Channel Setup Table’
4. Run TEDS detect as needed
    * TEDS detect occurs automatically during connection sequence and it is only necessary to rerun it if you change, add, or remove transducers after the connection sequence
    * Note that running TEDS detect will over-write manually entered data for TEDS transducers

_Generator Setup Tab_
1. Edit the properties of each generator channel as needed or load a previously saved generator channel setup by clicking ‘Load Generator Setup Table’
    * In the ‘Specify File Path for Inputs’ field
        * Enter the full file path to the generator waveform .mat file, e.g. ‘C:\HBK LAN-XI Open API\MATLAB Simple Recorder GUI\Generator Input Files\SineWave100Hz.mat’
        * Alternatively, click on ‘Load Generator Input Files’ and select a folder that contains generator waveform .mat files to create a drop-down menu of file options in the ‘Specify File Path for Inputs’ field
2. Save generator channel setup by clicking ‘Save Generator Setup Table’

_Collecting Data_
1. When setup is complete return to DAQ Setup tab and click ‘Arm DAQ’
2. Click ‘Save Directory’ to choose a folder to save measurement files in
3. Enter a recording name
    * No extension, the app will save in .mat format automatically
    * All MATLAB standard file naming rules apply, e.g. no spaces in filename
4. Click ‘Start DAQ’ when ready
5. Click Stop DAQ when you wish to end data collection
6. At this point you are free to make further recordings by specifying new filenames and/or directories

_Disarming, Disconnecting, and Rebooting_
1. To disarm the system click the ‘Disarm DAQ’ button.  Note that you must disarm the system to change the sample rate and/or modify the input or generator channel properties.
2. To disconnect the system go to the Module IP Setup tab and click ‘Disconnect’.  Note that disconnecting will reboot all modules in the setup.
3. Closing the app at any point will result in all modules being rebooted.  Allow adequate time for module to display an IP address on the green information panel before attempting to reconnect to module.

_Formatting Generator Waveform .mat Files_
1. In MATLAB create a cell named ‘Inputs1and2’ using the following command:  >>Inputs1and2 = {};
2. Within the cell create two 1x1 structs:
    * Inputs1and2{1,1} contains the properties for Input 1 of the mixer
    * Inputs1and2{2,1} contains the properties for Input 2 of the mixer
    * The result of mixing the two structs, or the cell Inputs1and2, is the waveform for the output channel
3.	Refer to the LAN-XI Open API User Guide for available waveforms and their associated properties and please note that these properties will be different depending on the type of waveform generated
4. Check the formatting of waveforms using the MATLAB function ‘jsonencode’ to convert the Inputs1and2 cell to a jsonstring:  >>jsonencode(Inputs1and2)
5. Several simple waveforms are included with the code as examples


**REST Command Chronology**

_Connecting Sequence (Idle → Connected)_
1. Read module information using GET command - /rest/rec/module/info
2. Set module time using PUT command - /rest/rec/module/time
    * Send to command module first then service modules
3. Set synchronization mode using PUT command - /rest/rec/syncmode
    * Send to command module first then service modules
4. Wait for ptpStatus of “Locked” using GET command - /rest/rec/onchange
5. Open recorder application using PUT command - /rest/rec/open
    * Send to service modules first then command module
    * Wait for moduleState to be “RecorderOpened” using GET command - /rest/rec/onchange
6. Prepare signal generators using PUT command - /rest/rec/generator/prepare
    * Send to service modules first then command module
7. Get default set-up for all input channels using GET command - /rest/rec/channels/input/default 
8. Get default set-up for all signal generators using GET command - /rest/rec/generator/output

_TEDS Detection (module must be in ‘Connected’ state)_
1. Run TEDS detection using POST command - /rest/rec/channels/input/all/transducers/detect
    * Send to service modules first then command module
    * Wait for transducerDetectionActive to be “false” using GET command - /rest/rec/onchange
2. Obtain transducer information using GET command - /rest/rec/channels/input/all/transducers
    * Send to service modules first then command module

_Arming Sequence (Connected → Armed)_
1. Configure generator using PUT command - /rest/rec/generator/output
    * Send to service modules first then command module
2. Start generator using PUT command - /rest/rec/generator/start
    * Send to service modules first then command module
3. Synchronize generators using PUT command (this step required only for multi-module systems)  - /rest/rec/apply
    * Send only to command module
4. Create new configuration using PUT command - rest/rec/create
    * Send to service modules first then command module
    * Wait for moduleState to be “RecorderConfiguring” using GET command - /rest/rec/onchange
    * Apply desired input channel configuration to module using PUT command - rest/rec/channels/input
    * Wait for inputStatus to be “Settled” using GET command (this step required only for multi-module systems)  - /rest/rec/onchange
5. Synchronize modules using PUT command (this step required only for multi-module systems)  - /rest/rec/synchronize
    * Send to service modules first then command module
    * Wait for inputStatus to be “Synchronized” using GET command - /rest/rec/onchange
6. Start internal streaming (multi-module systems only) using PUT command – rest/rec/startstreaming
    * Send to service modules first then command module
7. Get streaming socket using GET command - /rest/rec/destination/socket

_Measuring (Armed → Recording)_
1. Start streaming using POST command - /rest/rec/measurements
    * Send to service modules first then command module
    * Wait for moduleState to be “RecorderRecording” using GET command - /rest/rec/onchange
2. Subscribe to binary data stream then run while loop and decode messages until data collection is finished → LAN-XI TCP/IP streaming sequence is as follows
    * Message format is header then payload
    * Header contains
        * Message type
        * Time
        * Length of message content
        * Message data
    * Depending on the value received for message type in the header the message is either an interpretation message or a signal data message
        * Interpretation messages contain a scale factor to apply to signal data, each channel has its own separate interpretation message
        * Signal data messages contain signal data that needs to be scaled
    * Example chronology of messages received for DAQ using three channels
        * Interpretation message Channel 1
        * Interpretation message Channel 2
        * Interpretation message Channel 3
        * Signal data message Channel 1
        * Signal data message Channel 2
        * Signal data message Channel 3
        * Signal data message Channel 1
        * Signal data message Channel 2
        * Signal data message Channel 3
        * and so on...

_Stop Measuring (Recording → Armed)_
1. Stop streaming using PUT command - /rest/rec/measurements/stop
    * Wait for moduleState to be “RecorderStreaming” using GET command - /rest/rec/onchange

_Disarming Sequence (Armed → Connected)_
1. Stop generator using PUT command - rest/rec/generator/stop
2. End current recording session using PUT command - rest/rec/finish
    * Wait for moduleState to be “RecorderOpened” using GET command - /rest/rec/onchange

_Disconnecting Sequence (Connected → Idle)_
1. Close recorder application using PUT command - /rest/rec/close
    * Send to service modules first then command module
    * Wait for moduleState to be “Idle” using GET command - /rest/rec/onchange
2. Set synchronization mode back to defaults using PUT command - /rest/rec/syncmode
    * Send to service modules first then command module

_Rebooting_
1. Reboot module using PUT command - rest/rec/reboot
    * Send to service modules first then command module