function NETWORK=nndetector_live_convert_net(NET)
% take MATLAB network structure and convert to something easier
% to work with in a live setting (i.e. boil down to the math)
%
% TODO: proper error-checking

spec_params={'win_size','fft_size','fft_time_shift','amp_scaling',...
  'freq_range','freq_range_ds','time_window','time_window_steps','inp_scaling'};

for i=1:length(spec_params)
  NETWORK.spec_params.(spec_params{i})=NET.userdata.(spec_params{i});
end

% map input normalization

if ~isempty(NET.inputs{1}.processFcns)
    for i=1:length(NET.inputs{1}.processFcns)
      NETWORK.input_normalize=NET.inputs{1}.processFcns{i};
      NETWORK.input_normalize_settings=NET.inputs{1}.processSettings{i};
    end

else
  NETWORK.input_normalize=[];
end

if ~isempty(NET.outputs{end}.processFcns)
    for i=1:length(NET.outputs{end}.processFcns)
      NETWORK.output_normalize=NET.outputs{end}.processFcns{i};
      NETWORK.output_normalize_settings=NET.outputs{end}.processSettings{i};
    end
else
  NETWORK.output_normalize=[];
end

% setup weights

[to,from]=find(~cellfun(@isempty,NET.lw));
NETWORK.layer_weights=cell(1,length(from)+1);
NETWORK.layer_weights{1}=NET.IW{1,1};

for i=1:length(from)
  NETWORK.layer_weights{i+1}=NET.lw{to(i),from(i)};
end

% get biases and transfer functions

for i=1:length(NETWORK.layer_weights)
  NETWORK.layer_biases{i}=NET.b{i};
  NETWORK.transfer_function{i}=NET.layers{i}.transferFcn;
end

% finally threshold

NETWORK.threshold=NET.userdata.trigger_thresholds;
