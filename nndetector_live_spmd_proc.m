function nndetector_live_spmd_proc(NETWORK)

%% SPMD DETAILS
lab_dsp = 1;

%% STAGE: SETUP
freq_idx=NETWORK.spec_params.freq_range_ds(1):NETWORK.spec_params.freq_range_ds(end);
layer0_size=size(NETWORK.layer_weights{1},2);

% send confirmation
if labSendReceive(lab_dsp, lab_dsp, 1) ~= 1
    return
end

[~,spect_map,win_mult,~]=nndetector_live_prep_spectrogram(ring_buffer_size,...
  NETWORK.spec_params.win_size,NETWORK.spec_params.win_overlap,NETWORK.spec_params.fft_size);

ringbuffer=zeros(ring_buffer_size,1);

%% STAGE: LOOP
while true
    %s=spectrogram(ringbuffer,NETWORK.spec_params.win_size,NETWORK.spec_params.win_overlap,NETWORK.spec_params.fft_size);
    s = fft(ringbuffer(spect_map) .* win_mult);

    % scale spectrogram
    s=abs(s(freq_idx,:));

    switch NETWORK.spec_params.amp_scaling
        case 'db'
            s=20*log10(s);
        case 'log'
            s=log(s);
    end

    s = reshape(s,layer0_size,1);
    % equivalent of normc
    s = bsxfun(@rdivide, s, sqrt(sum(xi.^2,1)));

    % flow activation
    [~, act]=nndetector_live_sim_network(s,NETWORK);
    
    % get audio data
    audio_data = labSendReceive(lab_dsp, lab_dsp, act);
    
    % update ring buffer
    ringbuffer = [ringbuffer(samples_per_frame+1:ring_buffer_size); audio_data(:,1)];
end

end

