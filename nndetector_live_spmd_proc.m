function nndetector_live_spmd_proc(NETWORK)

%% SPMD DETAILS
lab_dsp = 1;

%% STAGE: SETUP
freq_idx = NETWORK.spec_params.freq_range_ds;
layer0_size = size(NETWORK.layer_weights{1},2);

fft_size = NETWORK.spec_params.fft_size;
win_size = NETWORK.spec_params.win_size;
win = hamming(win_size);
if NETWORK.spec_params.win_overlap > 0
    overlap = NETWORK.spec_params.win_overlap;
    gap = 0;
else
    overlap = 0;
    gap = 0 - NETWORK.spec_params.win_overlap;
end

buffer_audio = [];
buffer_fft = [];

% send confirmation
if labSendReceive(lab_dsp, lab_dsp, 1) ~= 1
    return
end

%% STAGE: LOOP
while true
    % has enough audio data
    while length(buffer_audio) >= win_size
        % calculate FFT
        s = fft(buffer_audio((1 + gap):(win_size + gap)) .* win);
        
        % perform scaling
        s = abs(s(freq_idx));

        switch NETWORK.spec_params.amp_scaling
            case 'db'
                s=20*log10(s);
            case 'log'
                s=log(s);
        end
        
        % append to fft buffer (inefficient)
        buffer_fft = [buffer_fft s];
        
        % remove from audio buffer (really inefficient)
        buffer_audio = buffer_audio((1 + gap + win_size - overlap):end);
    end
    
    % has enough fft data
    act = 0;
    while length(buffer_fft) >= layer0_size
        % only run until first detection (minor optimization)
        if ~act
            % get input data
            in = buffer_fft(1:layer0_size);

            % perform scaling (normc or zscore)
            switch NETWORK.spec_params.inp_scaling
                case 'zscore'
                    in = zscore(in);
                case 'normc'
                    % equivalent of normc for our purposes
                    in = bsxfun(@rdivide, in, sqrt(sum(in .^ 2)));
            end

            % flow activation
            [~, act]=nndetector_live_sim_network(in, NETWORK);
        end
        
        % remove from audio buffer (really inefficient)
        buffer_fft = buffer_fft((1 + length(freq_idx)):end);
    end
    
    % get audio data
    audio_data = labSendReceive(lab_dsp, lab_dsp, act);
end

end

