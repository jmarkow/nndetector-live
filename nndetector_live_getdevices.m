function [INPUT_DEVICE,OUTPUT_DEVICE,TEST_FILE]=nndetector_live_getdevices(INPUT_DEVICE,OUTPUT_DEVICE,TEST_FILE)
%
%
%

device_list=dspAudioDeviceInfo;

for i=1:length(device_list)
  if device_list(i).maxInputs==0
    device_list(i).input=false;
  else
    device_list(i).input=true;
  end

  if device_list(i).maxOutputs==0
    device_list(i).output=false;
  else
    device_list(i).output=true;
  end
end

inputs=find(cat(1,device_list(:).input));
outputs=find(cat(1,device_list(:).output));

fprintf('Discovered %i inputs and %i outputs\n',length(inputs),length(outputs));

if isempty(INPUT_DEVICE)

  % user menu with possible devices

  if isempty(inputs)
    error('No input devices.');
  end

  choice=menu('Choose input device',{device_list(inputs).name});
  INPUT_DEVICE=device_list(inputs(choice)).name;
  TEST_FILE=[];

elseif strcmp(INPUT_DEVICE,'simulate')
  if isempty(TEST_FILE)
    [test_filename,test_pathname]=uigetfile(pwd);
    TEST_FILE=fullfile(test_pathname,test_filename);
  end

end

if isempty(OUTPUT_DEVICE)
  choice=menu('Choose output device',{device_list(outputs).name});
  OUTPUT_DEVICE=device_list(outputs(choice)).name;
end

% strip core audio or anything else that seems to muck up the works

core_audio=regexp(INPUT_DEVICE,' \(Core Audio\)','start');

if ~isempty(core_audio)
  INPUT_DEVICE=INPUT_DEVICE(1:core_audio-1);
end

core_audio=regexp(OUTPUT_DEVICE,' \(Core Audio\)','start');

if ~isempty(core_audio)
  OUTPUT_DEVICE=OUTPUT_DEVICE(1:core_audio-1);
end
