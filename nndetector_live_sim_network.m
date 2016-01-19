function [ACTIVATION,TRIGGER]=nndetector_live_sim_network(INPUT,NETWORK)
%
%
%
%

% first layer
% removed all anonymous functions, took a HUGE performance hit using them

if ~isempty(NETWORK.input_normalize)
  switch NETWORK.input_normalize
    case 'mapstd'
      INPUT=mapstd.apply(INPUT,NETWORK.input_normalize_settings);
    case 'mapminmax'
      INPUT=mapminmax.apply(INPUT,NETWORK.input_normalize_settings);
  end
end

tmp=NETWORK.layer_weights{1}*INPUT+NETWORK.layer_biases{1};

switch NETWORK.transfer_function{1}
  case 'logsig'
    ACTIVATION=logsig(tmp);
  case 'tansig'
    ACTIVATION=tansig(tmp);
  case 'purelin'
    ACTIVATION=purelin(tmp);
  case 'satlin'
    ACTIVATION=satlin(tmp);
end

% propagate through additional layers

for i=2:length(NETWORK.layer_weights)
  tmp=NETWORK.layer_weights{i}*ACTIVATION+NETWORK.layer_biases{i};
  switch NETWORK.transfer_function{1}
    case 'logsig'
      ACTIVATION=logsig(tmp);
    case 'tansig'
      ACTIVATION=tansig(tmp);
    case 'purelin'
      ACTIVATION=purelin(tmp);
    case 'satlin'
      ACTIVATION=satlin(tmp);
  end
end

if ~isempty(NETWORK.output_normalize)
  switch NETWORK.output_normalize
    case 'mapstd'
      ACTIVATION=mapstd.reverse(ACTIVATION,NETWORK.output_normalize_settings);
    case 'mapminmax'
      ACTIVATION=mapminmax.reverse(ACTIVATION,NETWORK.output_normalize_settings);
  end
end

TRIGGER=ACTIVATION>=NETWORK.threshold;
