function nndetector_live(varargin)
%
%
%

net_file=[];
input_device=[];
output_device=[];
fs=44.1e3; % sampling rate
data_type=[];
test_file=[];
queue_duration_output=0; % queue to buffer (for simulation, irrelevant for output)
queue_duration_input=0;
buffer_size_output=.002;
buffer_size_input=.02;
manual_threshold=[];

% TODO: queue size, etc.

nparams=length(varargin);

if mod(nparams,2)>0
  error('Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
  switch lower(varargin{i})
    case 'net_file'
      net_file=varargin{i+1};
    case 'input_device'
      input_device=varargin{i+1};
    case 'fs'
      fs=varargin{i+1};
    case 'buffer_size_input'
      buffer_size_input=varargin{i+1};
    case 'buffer_size_output'
      buffer_size_output=varargin{i+1};
    case 'queue_duration_inpout'
      queue_duration_input=varargin{i+1};
    case 'queue_duration_output'
      queue_duration_output=varargin{i+1};
    case 'data_type'
      data_type=varargin{i+1};
    case 'test_file'
      test_file=varargin{i+1};
    case 'simulate'
      simulate=varargin{i+1};
    case 'manual_threshold'
      manual_threshold=varargin{i+1};
    otherwise
  end
end

% TODO: add script to stitch together training data into appropriate wav file for testing
% (input left channel, triggers on right channel)

disp('Polling audio devices...');
[input_device_id,output_device_id,dsp_file]=...
  nndetector_live_getdevices(input_device,output_device,test_file);

fprintf('Input device: %s\nOutput device: %s\n',input_device,output_device);

disp('Reading in network structure...')
if isempty(net_file)
  [filename,pathname]=uigetfile(pwd);
  net_file=fullfile(pathname,filename);
end

load(net_file,'net');
network=nndetector_live_convert_net(net);

if ~isempty(manual_threshold)
  fprintf('Setting network threshold: %g\n',manual_threshold);
  network.threshold=manual_threshold;
end

% now assume left channel of audio file is audio data, right channel include the hit points if we're testing
% otherwise poll live data

% set up activation functions, layers, etc.

if strcmp(input_device,'simulate')
  nndetector_live_simulate(input_device_id,output_device_id,dsp_file,fs,queue_duration_input,...
    queue_duration_output,buffer_size_input,buffer_size_output,network);
elseif strcmp(input_device,'test')
  nndetector_live_loop_test(input_device_id,output_device_id,fs,queue_duration_input,...
    queue_duration_output,buffer_size_input,buffer_size_output,network);
else
  nndetector_live_loop(input_device_id,output_device_id,fs,queue_duration_input,...
    queue_duration_output,buffer_size_input,buffer_size_output,network);
end

%%% live neural network based detector
