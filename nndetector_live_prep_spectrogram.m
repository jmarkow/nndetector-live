function [SPECT_MAT,SIG_MAP,WIN_MULT,FFT_IDX]=nndetector_live_simulate(NSAMPLES,NWIN,NOVERLAP,NFFT)

ncols=fix((NSAMPLES-NOVERLAP)/(NWIN-NOVERLAP));

col_index=1+(0:(ncols-1))*(NWIN-NOVERLAP);
row_index=(1:NWIN)';

SPECT_MAT=zeros(NWIN,ncols);
SIG_MAP=row_index(:,ones(1,ncols))+col_index(ones(NWIN,1),:)-1;
WIN_MULT=repmat(hamming(NWIN),[1 ncols]);

if mod(NFFT,2)
  FFT_IDX = 1:(NFFT+1)/2;
else
  FFT_IDX = 1:NFFT/2+1;
end
