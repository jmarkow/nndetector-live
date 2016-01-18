function nndetector_live_spmd(INPUT_DEVICE,INPUT_MAP,OUTPUT_DEVICE,OUTPUT_MAP,FS,QUEUE_SIZE_INPUT,...
  QUEUE_SIZE_OUTPUT,BUFFER_SIZE_INPUT,BUFFER_SIZE_OUTPUT,NETWORK,LOGFILE)
% standard simulation setup, nothing connected to line in,
% put out detector and actual hits on left/right channels for line out

NETWORK.spec_params.win_overlap=NETWORK.spec_params.win_size-NETWORK.spec_params.fft_time_shift;

% how long does it take to process?, read in this many samples per cycle

parpool('local', 3);
spmd(2)
    if 1 == labindex
        nndetector_live_spmd_dsp(INPUT_DEVICE,INPUT_MAP,OUTPUT_DEVICE,OUTPUT_MAP,FS,QUEUE_SIZE_INPUT,...
            QUEUE_SIZE_OUTPUT,BUFFER_SIZE_INPUT,BUFFER_SIZE_OUTPUT);
    else
        nndetector_live_spmd_proc(NETWORK);
    end
end
poolobj = gcp('nocreate');
delete(poolobj);
