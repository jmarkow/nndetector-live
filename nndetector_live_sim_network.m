function [ACTIVATION,TRIGGER]=nndetector_live_sim_network(INPUT,NETWORK)
%
%
%
%

% first layer

INPUT=NETWORK.input_normalize(INPUT);
ACTIVATION=(NETWORK.transfer_function{1}(NETWORK.layer_weights{1}*INPUT+NETWORK.layer_biases{1}));

% propagate through additional layers

for i=2:length(NETWORK.layer_weights)
  ACTIVATION=NETWORK.transfer_function{i}(NETWORK.layer_weights{i}*ACTIVATION+NETWORK.layer_biases{i});
end

ACTIVATION=NETWORK.output_normalize(ACTIVATION);
TRIGGER=ACTIVATION>=NETWORK.threshold;
