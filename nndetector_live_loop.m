function nndetector_live_loop(INPUT_DEVICE,INPUT_MAP,OUTPUT_DEVICE,OUTPUT_MAP,FS,QUEUE_SIZE_INPUT,...
  QUEUE_SIZE_OUTPUT,BUFFER_SIZE_INPUT,BUFFER_SIZE_OUTPUT,NETWORK,LOGFILE)
% standard simulation setup, nothing connected to line in,
% put out detector and actual hits on left/right channels for line out

NETWORK.spec_params.win_overlap=NETWORK.spec_params.win_size-NETWORK.spec_params.fft_time_shift;
ring_buffer_size=...
  NETWORK.spec_params.win_size+(NETWORK.spec_params.fft_time_shift*NETWORK.spec_params.time_window_steps-1);

% how long does it take to process?, read in this many samples per cycle

samples_per_frame=round(BUFFER_SIZE_INPUT*FS);

%dsp_obj_file=dsp.AudioFileReader(TEST_FILE,'SamplesPerFrame',samples_per_frame); % for now assume left channel is audio data

fprintf('Setting up AudioRecorder on %s\n',INPUT_DEVICE);
dsp_obj_in=dsp.AudioRecorder('SampleRate',FS,'DeviceName',INPUT_DEVICE,'QueueDuration',QUEUE_SIZE_INPUT,...
  'OutputNumOverrunSamples',true,'SamplesPerFrame',samples_per_frame,'BufferSizeSource','Property',...
  'BufferSize',samples_per_frame,'NumChannels',1);

if ~isempty(INPUT_MAP)
  dsp_obj_in.ChannelMappingSource='property';
  dsp_obj_in.ChannelMapping=INPUT_MAP;
end

fprintf('Setting up AudioPlayer on %s\n',OUTPUT_DEVICE);
dsp_obj_out=dsp.AudioPlayer('SampleRate',FS,'DeviceName',OUTPUT_DEVICE,'QueueDuration',QUEUE_SIZE_OUTPUT,...
  'OutputNumUnderrunSamples',true,'BufferSizeSource','Property','BufferSize',round(BUFFER_SIZE_OUTPUT*FS));

if ~isempty(OUTPUT_MAP)
  dsp_obj_out.ChannelMappingSource='property';
  dsp_obj_out.ChannelMapping=OUTPUT_MAP;
end

% while condition, step through, process data, etc.

fprintf('Entering main detector loop...\n');

% validate frequency and time indices (maybe preflight function?)

freq_idx=NETWORK.spec_params.freq_range_ds(1):NETWORK.spec_params.freq_range_ds(end);
layer0_size=size(NETWORK.layer_weights{1},2);

[spect_mat,spect_map,win_mult,fft_idx]=nndetector_live_prep_spectrogram(ring_buffer_size,...
  NETWORK.spec_params.win_size,NETWORK.spec_params.win_overlap,NETWORK.spec_params.fft_size);

hit=ones(round(BUFFER_SIZE_OUTPUT*FS),1);
ringbuffer=zeros(ring_buffer_size,1);
trigger=0;

while ~isDone(dsp_obj_in)

  outdata=hit*trigger;
  underrun=step(dsp_obj_out,outdata);
  [audio_data,noverrun]=step(dsp_obj_in);

  if underrun>0
    fprintf('Output underrun by %d samples (%s)\n',underrun,datestr(now));
  end

  if noverrun>0
    fprintf('Input overrun by %d samples (%s)\n',noverrun,datestr(now));
  end

  ringbuffer=[ ringbuffer(samples_per_frame+1:ring_buffer_size);audio_data(:,1) ];
  %s=spectrogram(ringbuffer,NETWORK.spec_params.win_size,NETWORK.spec_params.win_overlap,NETWORK.spec_params.fft_size);

  s=fft(ringbuffer(spect_map).*win_mult);

  % scale spectrogram

  s=abs(s(freq_idx,:));

  switch lower(NETWORK.spec_params.amp_scaling)
    case 'db'
      s=20*log10(s);
    case 'log'
      s=log(s);
  end

  s=reshape(s,layer0_size,1);
  s=zscore(s);

  % flow activation

  [activation,trigger]=nndetector_live_sim_network(s,NETWORK);

end


% separate function for net?
