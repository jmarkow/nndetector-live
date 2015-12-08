function nndetector_live_write_settings(LOGFILE,NETWORK,INPUT_DEVICE,OUTPUT_DEVICE,BOUNDARY)
%
%
%

exclude={'spec_params','layer_weights','layer_biases'};

fprintf(LOGFILE,'Input device: %s\n',INPUT_DEVICE);
fprintf(LOGFILE,'Output device: %s\n',OUTPUT_DEVICE);

spec_parameters=fieldnames(NETWORK.spec_params);
spec_parameters(strcmp(spec_parameters,'freq_range_ds'))=[];

for i=1:length(spec_parameters)
  if ischar(NETWORK.spec_params.(spec_parameters{i}))
    fprintf(LOGFILE,'%s: %s\n',spec_parameters{i},NETWORK.spec_params.(spec_parameters{i}));
  else
    fprintf(LOGFILE,'%s:',spec_parameters{i});
    for j=1:length(NETWORK.spec_params.(spec_parameters{i}))
      fprintf(LOGFILE,' %g',NETWORK.spec_params.(spec_parameters{i})(j));
    end
    fprintf(LOGFILE,'\n');
  end
end

net_parameters=fieldnames(NETWORK);

for i=1:length(exclude)
  net_parameters(strcmp(net_parameters,exclude{i}))=[];
end

for i=1:length(net_parameters)
  if iscell(NETWORK.(net_parameters{i}))
    for j=1:length(NETWORK.(net_parameters{i}))
      if ischar(NETWORK.(net_parameters{i}){j})
        fprintf(LOGFILE,'%s%i:  %s\n',net_parameters{i},j,NETWORK.(net_parameters{i}){j});
      end
    end
  else
    if ischar(NETWORK.(net_parameters{i}))
      fprintf(LOGFILE,'%s: %s\n',net_parameters{i},NETWORK.(net_parameters{i}));
    elseif ~isstruct(NETWORK.(net_parameters{i}))
      fprintf(LOGFILE,'%s:',net_parameters{i});
      for j=1:length(NETWORK.(net_parameters{i}))
        fprintf(LOGFILE,' %g',NETWORK.(net_parameters{i})(j));
      end
      fprintf(LOGFILE,'\n');
    end
  end
end

for i=1:length(NETWORK.layer_weights)
  [nunits,nweights]=size(NETWORK.layer_weights{i});
  fprintf(LOGFILE,'Layer%i n(units): %i\n',i,nunits);
  fprintf(LOGFILE,'Layer%i n(weights): %i\n',i,nweights);
end
