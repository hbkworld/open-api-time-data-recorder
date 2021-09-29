function ResultsValidationSingleModule(ResultsFilename)

load(ResultsFilename);

Module1ReceiverGeneratorOutput1 = RecordingData.SignalData{1,1};
ReceiverGeneratorOutput2 = RecordingData.SignalData{2,1};
MicrophoneSignal = RecordingData.SignalData{3,1};
AccelerometerSignal = RecordingData.SignalData{4,1};


%% Generator 1 Voltage
    
% Inputs
SampleRate = 1/(RelativeTime(2)-RelativeTime(1));
OverlapPercentage = 90;
WindowCorrectionFactor = 2;
FFTlines = SampleRate;
WindowVector = hann(FFTlines);
VoltageGraphLimits = [-10 10];
VoltageFFTvsTimeGraphFrequencyLimits = [380 400];
VoltageColorbarVector = [0 1 2 3 4 5 6 7 8 9 10];

VoltageSignalRMS = Module1ReceiverGeneratorOutput1./sqrt(2);
[VoltageSTFTValues,VoltageSTFTfrequency,VoltageSTFTtime] = stft(VoltageSignalRMS,SampleRate,'Window',WindowVector,'OverlapLength',OverlapPercentage,'FFTLength',FFTlines,'Centered',false);
VoltageSTFTValues = WindowCorrectionFactor.*(VoltageSTFTValues./(FFTlines/2));
VoltageSTFTmagnitude = abs(VoltageSTFTValues);

figure(1)
plot(RelativeTime,VoltageSignalRMS)
xlabel('Relative Time (s)')
ylabel('Voltage RMS (V)')
title('Generator 1 Signal vs. Time')
xlim([0 max(RelativeTime)])
ylim(VoltageGraphLimits)

figure(2)
imagesc(VoltageSTFTtime,VoltageSTFTfrequency,VoltageSTFTmagnitude)
set(gca,'YDir','normal')
ylim(VoltageFFTvsTimeGraphFrequencyLimits)
caxis([0 max(VoltageGraphLimits)])
FrequencySpectrogramColorbar = colorbar('Ticks',VoltageColorbarVector,'TickLabels',VoltageColorbarVector);
FrequencySpectrogramColorbar.Label.String = "Voltage RMS (V)";
colormap jet
xlabel('Relative time (s)')
ylabel('Frequency (Hz)')
title('Generator 1 FFT vs. Time')


%% Generator 2 Voltage (2550 Hz Square Wave)

VoltageFFTvsTimeGraphFrequencyLimits = [2540 2560];

VoltageSignalRMS = ReceiverGeneratorOutput2./sqrt(2);
[VoltageSTFTValues,VoltageSTFTfrequency,VoltageSTFTtime] = stft(VoltageSignalRMS,SampleRate,'Window',WindowVector,'OverlapLength',OverlapPercentage,'FFTLength',FFTlines,'Centered',false);
VoltageSTFTValues = WindowCorrectionFactor.*(VoltageSTFTValues./(FFTlines/2));
VoltageSTFTmagnitude = abs(VoltageSTFTValues);

figure(3)
plot(RelativeTime,VoltageSignalRMS)
xlabel('Relative Time (s)')
ylabel('Voltage RMS (V)')
title('Generator 2 Signal vs. Time')
xlim([0 max(RelativeTime)])
ylim(VoltageGraphLimits)

figure(4)
imagesc(VoltageSTFTtime,VoltageSTFTfrequency,VoltageSTFTmagnitude)
set(gca,'YDir','normal')
ylim(VoltageFFTvsTimeGraphFrequencyLimits)
caxis([0 max(VoltageGraphLimits)])
FrequencySpectrogramColorbar = colorbar('Ticks',VoltageColorbarVector,'TickLabels',VoltageColorbarVector);
FrequencySpectrogramColorbar.Label.String = "Voltage RMS (V)";
colormap jet
xlabel('Relative time (s)')
ylabel('Frequency (Hz)')
title('Generator 2 FFT vs. Time')


%% Microphone with TYPE 4231 Calibrator

% Inputs
FFTlines = SampleRate;
WindowVector = hann(FFTlines);
MicrophoneGraphLimits = [-1 1];
MicrophoneFFTvsTimeGraphFrequencyLimits = [990 1010];
MicrophoneColorbarVector = [0 10 20 30 40 50 60 70 80 90 100 110 120];

MicrophoneSignalRMS = MicrophoneSignal./sqrt(2);
[MicrophoneSTFTvalues,MicrophoneSTFTfrequency,MicrophoneSTFTtime] = stft(MicrophoneSignalRMS,SampleRate,'Window',WindowVector,'OverlapLength',OverlapPercentage,'FFTLength',FFTlines,'Centered',false);
MicrophoneSTFTvalues = WindowCorrectionFactor.*(MicrophoneSTFTvalues./(FFTlines/2));
MicrophoneSTFTmagnitude_dB = 20.*log10(abs(MicrophoneSTFTvalues)./2e-5);

figure(5)
plot(RelativeTime,MicrophoneSignalRMS)
xlabel('Relative Time (s)')
ylabel('Sound Pressure Level RMS (Pa)')
title('Microphone Signal vs. Time')
xlim([0 max(RelativeTime)])
ylim(MicrophoneGraphLimits)

figure(6)
imagesc(MicrophoneSTFTtime,MicrophoneSTFTfrequency,MicrophoneSTFTmagnitude_dB)
set(gca,'YDir','normal')
ylim(MicrophoneFFTvsTimeGraphFrequencyLimits)
caxis([0 max(MicrophoneColorbarVector)])
FrequencySpectrogramColorbar = colorbar('Ticks',MicrophoneColorbarVector,'TickLabels',MicrophoneColorbarVector);
FrequencySpectrogramColorbar.Label.String = "Sound Pressure Level RMS (dB/20\mu Pa)";
colormap jet
xlabel('Relative time (s)')
ylabel('Frequency (Hz)')
title('Microphone FFT vs. Time')


%% Accelerometer with TYPE 4294 Calibrator

% Inputs
FFTlines = SampleRate;
WindowVector = hann(FFTlines);
AccelerometerGraphLimits = [-12 12];
AccelerometerFFTvsTimeGraphFrequencyLimits = [150 170];
AccelerometerColorbarVector = [0 1 2 3 4 5 6 7 8 9 10 11 12];

AccelerometerSignalRMS = AccelerometerSignal./sqrt(2);
[AccelerometerSTFTvalues,AccelerometerSTFTfrequency,AccelerometerSTFTtime] = stft(AccelerometerSignalRMS,SampleRate,'Window',WindowVector,'OverlapLength',OverlapPercentage,'FFTLength',FFTlines,'Centered',false);
AccelerometerSTFTvalues = WindowCorrectionFactor.*(AccelerometerSTFTvalues./(FFTlines/2));
AccelerometerSTFTmagnitude = abs(AccelerometerSTFTvalues);

figure(7)
plot(RelativeTime,AccelerometerSignalRMS)
xlabel('Relative Time (s)')
ylabel('Acceleration RMS (m/s^2)')
title('Accelerometer Signal vs. Time')
xlim([0 max(RelativeTime)])
ylim(AccelerometerGraphLimits)

figure(8)
imagesc(AccelerometerSTFTtime,AccelerometerSTFTfrequency,AccelerometerSTFTmagnitude)
set(gca,'YDir','normal')
ylim(AccelerometerFFTvsTimeGraphFrequencyLimits)
caxis([0 max(AccelerometerColorbarVector)])
FrequencySpectrogramColorbar = colorbar('Ticks',AccelerometerColorbarVector,'TickLabels',AccelerometerColorbarVector);
FrequencySpectrogramColorbar.Label.String = "Acceleration RMS (m/s^2)";
colormap jet
xlabel('Relative time (s)')
ylabel('Frequency (Hz)')
title('Accelerometer FFT vs. Time')

end

