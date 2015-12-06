function [ACTIVATION,TRIGGER]=nndetector_live_sim_network(INPUT,NETWORK)
%
%
%
%

% first layer

ACTIVATION=(NETWORK.transfer_function{1}(INPUT'*NETWORK.layer_weights{1}'+NETWORK.layer_biases{1}'));

% propagate through additional layers

for i=2:length(NETWORK.layer_weights)
  ACTIVATION=NETWORK.transfer_function{i}(ACTIVATION*NETWORK.layer_weights{i}'+NETWORK.layer_biases{i}');
end

TRIGGER=ACTIVATION>=NETWORK.threshold;
