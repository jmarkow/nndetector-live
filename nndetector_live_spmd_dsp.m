function nndetector_live_spmd_dsp(INPUT_DEVICE,INPUT_MAP,OUTPUT_DEVICE,OUTPUT_MAP,FS,...
    QUEUE_SIZE_INPUT,QUEUE_SIZE_OUTPUT,BUFFER_SIZE_INPUT,BUFFER_SIZE_OUTPUT)

%% SPMD DETAILS
lab_processor = 2;

%% STAGE: SETUP
samples_per_frame=round(BUFFER_SIZE_INPUT*FS);

%dsp_obj_file=dsp.AudioFileReader(TEST_FILE,'SamplesPerFrame',samples_per_frame); % for now assume left channel is audio data

fprintf('Setting up AudioRecorder on %s\n',INPUT_DEVICE);
dsp_obj_in=dsp.AudioRecorder('SampleRate',FS,'DeviceName',INPUT_DEVICE,'QueueDuration',QUEUE_SIZE_INPUT,...
  'OutputNumOverrunSamples',true,'SamplesPerFrame',samples_per_frame,'BufferSizeSource','Property',...
  'BufferSize',samples_per_frame,'NumChannels',1); %,'OutputDataType','single');

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

% send confirmation
if labSendReceive(lab_processor, lab_processor, 1) ~= 1
    fprintf('Setup failed\n');
    return
end

%% STAGE: LOOP
act = 0;
out_on = ones(round(BUFFER_SIZE_OUTPUT*FS), 1);
out_off = zeros(round(BUFFER_SIZE_OUTPUT*FS), 1);
while ~isDone(dsp_obj_in)
    if act
        underrun = step(dsp_obj_out, out_on);
    else
        underrun = step(dsp_obj_out, out_off);
    end
    [audio_data, noverrun] = step(dsp_obj_in);

    if underrun>0
        fprintf('Output underrun by %d samples (%s)\n',underrun,datestr(now));
    end

    if noverrun>0
        fprintf('Input overrun by %d samples (%s)\n',noverrun,datestr(now));
    end
    
    % new active indicator
    act = labSendReceive(lab_processor, lab_processor, audio_data);
end


end

