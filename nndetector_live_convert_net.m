function NETWORK=nndetector_live_convert_net(NET)
% take MATLAB network structure and convert to something easier
% to work with in a live setting (i.e. boil down to the math)
%
% TODO: proper error-checking

spec_params={'win_size','fft_size','fft_time_shift','amp_scaling',...
  'freq_range','freq_range_ds','time_window','time_steps'};

for i=1:length(spec_params)
  NETWORK.spec_params.(spec_params{i})=NET.userdata.(spec_params{i});
end

% map input normalization

if ~isempty(NET.inputs{1}.processFcns)
    for i=1:length(NET.inputs{1}.processFcns)
      if strcmp(NET.inputs{1}.processFcns{i},'mapminmax')
        NETWORK.input_normalize=@(x) mapminmax('apply',x,NET.inputs{1}.processSettings{i});
      elseif strcmp(NET.inputs{1}.processFcns{i},'mapstd')
        NETWORK.input_normalize=@(x) mapstd('apply',x,NET.inputs{1}.processSettings{i});
      end
    end
else
  NETWORK.input_normalize=@(x) x;
end

if ~isempty(NET.outputs{end}.processFcns)
    for i=1:length(NET.outputs{end}.processFcns)
      if strcmp(NET.outputs{end}.processFcns{i},'mapminmax')
        NETWORK.output_normalize=@(x) mapminmax('reverse',x,NET.outputs{end}.processSettings{i});
      elseif strcmp(NET.outputs{end}.processFcns{i},'mapstd')
        NETWORK.output_normalize=@(x) mapstd('reverse',x,NET.outputs{end}.processSettings{i});
      end
    end
else
  NETWORK.output_normalize=@(x) x;
end


% setup weights

[to,from]=find(~cellfun(@isempty,NET.lw));
NETWORK.layer_weights=cell(1,length(from)+1);
NETWORK.layer_weights{i}=NET.IW{1,1};

for i=1:length(from)
  NETWORK.layer_weights{i+1}=NET.lw{to(i),from(i)};
end

% get biases and transfer functions

for i=1:length(NETWORK.layer_weights)
  NETWORK.layer_biases{i}=NET.b{i};

  switch lower(NET.layers{i}.transferFcn)
    case 'logsig'
      NETWORK.transfer_function{i}=@(x) logsig(x,NET.layers{i}.transferParam);
    case 'tansig'
      NETWORK.transfer_function{i}=@(x) tansig(x,NET.layers{i}.transferParam);
    case 'purelin'
      NETWORK.transfer_function{i}=@(x) purelin(x,NET.layers{i}.transferParam);
    case 'satlin'
      NETWORK.transfer_function{i}=@(x) satlin(x,NET.layers{i}.transferParam);
  end
end

switch lower(NET.userdata.amp_scaling)
  case 'lin'
      NETWORK.amp_scaling_fun=@(x) x;
  case 'log'
      NETWORK.amp_scaling_fun=@(x) log(x);
  case 'db'
      NETWORK.amp_scaling_fun=@(x) 20*log10(x);
end

% finally threshold

NETWORK.threshold=NET.userdata.threshold;
