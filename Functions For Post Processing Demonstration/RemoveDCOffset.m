function DCFreeSignal = RemoveDCOffset(Signal)

Signal = fft(Signal);
Signal(1) = 0;
DCFreeSignal = real(ifft(Signal));

end