dlmwrite(['kcl_rdk_shuyi_ppt_INTERMEDIATE_' , num2str(participantNumber), '_', datestr(now,'mmmm-dd-yyyy_HH-MM-SS AM'), '.txt'],respMat,'delimiter','\t') %#ok<*TNOW1,*DATST,*DLMWT>
save(['kcl_rdk_shuyi_ppt_INTERMEDIATE_' , num2str(participantNumber), '_', datestr(now,'mmmm-dd-yyyy_HH-MM-SS AM'), '.mat'],'respMat') %#ok<*DLMWT>
