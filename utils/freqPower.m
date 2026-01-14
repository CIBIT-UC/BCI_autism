%Computation of frequency power

function freqPow = freqPower(EEG, freqLow, freqHigh, channels, trials)

    [spectra,freqs] = std_spec(EEG, 'channels', {EEG.chanlocs(1:EEG.nbchan).labels}, ...
                'specmode', 'psd', 'recompute', 'on', 'trialindices', trials);
    freqPow = zeros(length(channels),1);
    freqLowIdx = find(round(freqs)>=freqLow);
    freqLowIdx = freqLowIdx(1);
    freqHighIdx = find(round(freqs)<=freqHigh);
    freqHighIdx = freqHighIdx(end);
    for chanIdx = 1:length(channels)
        freqPow(chanIdx) = mean(spectra(channels(chanIdx),freqLowIdx:freqHighIdx));
    end
    
end
