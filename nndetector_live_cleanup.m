function nndetector_live_cleanup(LOGFILE,BOUNDARY)
%
%
%

fprintf(LOGFILE,'Stopped detector at:  %s\n',datestr(now));
fprintf(LOGFILE,'%s\n%s\n',BOUNDARY,BOUNDARY);
fclose(LOGFILE);
