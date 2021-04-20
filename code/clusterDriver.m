% Executes cluster analysis major steps
% This script should be run as a cluster job

jadd_path;

if (restart == 1)
    system("rm -rf "+cluster_path);
    fprintf('%s removed\n', cluster_path);
    system("rm -rf "+outputPath);
    fprintf('%s removed\n', outputPath);
end

cluster_output_path = fullfile(cluster_path, 'output');
cluster_error_path = fullfile(cluster_path, 'error');
cluster_script_path = fullfile(cluster_path, 'script');

fprintf('Creating %s...\n', cluster_output_path);
touch(cluster_output_path);
fprintf('%s created\n', cluster_output_path);

fprintf('Creating %s...\n', cluster_error_path);
touch(cluster_error_path);
fprintf('%s created\n', cluster_error_path);

fprintf('Creating %s...\n', cluster_script_path);
touch(cluster_script_path);
fprintf('%s created\n', cluster_script_path);

delete(fullfile(cluster_output_path, '*'));
delete(fullfile(cluster_error_path, '*'));
delete(fullfile(cluster_script_path, '*'));


funcArg = {'clusterPreprocess', 'clusterMapLowRes',...
    'clusterReduceLowRes', 'clusterMapHighRes',...
    'clusterReduceHighRes', 'clusterPostprocessing'};

PBS        = '#!/bin/sh\n\nmodule load matlab/2019a\n';
script     = 'matlab -nodesktop -nodisplay -nosplash -r ' ;
matlab_call = @(n) ['\"cd ' pwd '; ' funcArg{n} '; exit;\"\n'];

%Create scripts
for kk = 1:length(funcArg)
    script_txt = [PBS script matlab_call(kk) ];
    script_filename = fullfile(cluster_script_path, [funcArg{kk} '.sh']);
    fid        = fopen(script_filename, 'w');
    fprintf( fid, script_txt );
    fclose(fid);
    eval(['!chmod +x ' script_filename]);
end

%% create driver .sh file
fid = fopen(fullfile(cluster_script_path, 'clusterrun.sh'), 'w');
fprintf(fid, '#!/bin/bash\n\n');

%if (length(strfind(email_notification, '@')) == 1)
%    for j=1:length(funcArg)
%       if j==1
%	    fprintf(fid, 'JOBID=$(sbatch --partition=%s --mail-type=ALL --mail-user=%s --job-name=%s --output=%s/%%j.out --error=%s/%%j.error %s/%s.sh | cut -f 4 -d'' '')\n\necho $JOBID\n\n', slurm_partition, email_notification, strrep(strrep(funcArg{j},'cluster',''),'Res',''), cluster_output_path, cluster_error_path, cluster_script_path, funcArg{j});
%       else
%	 fprintf(fid, 'JOBID=$(sbatch --partition=%s --mail-type=ALL --mail-user=%s --dependency=afterok:$JOBID --job-name=%s --output=%s/%%j.out --error=%s/%%j.error %s/%s.sh | cut -f 4 -d'' '')\n\necho $JOBID\n\n', slurm_partition, email_notification, strrep(strrep(funcArg{j},'cluster',''),'Res',''), cluster_output_path, cluster_error_path, cluster_script_path, funcArg{j});
%       end
%    end
% else
%    for j=1:length(funcArg)
%       if j==1
%	    fprintf(fid, 'JOBID=$(sbatch --partition=%s --job-name=%s --output=%s/%%j.out --error=%s/%%j.error %s/%s.sh | cut -f 4 -d'' '')\n\necho $JOBID\n\n', slurm_partition, strrep(strrep(funcArg{j},'cluster',''),'Res',''), cluster_output_path, cluster_error_path, cluster_script_path, funcArg{j});
%       else
%	 fprintf(fid, 'JOBID=$(sbatch --partition=%s --dependency=afterok:$JOBID --job-name=%s --output=%s/%%j.out --error=%s/%%j.error %s/%s.sh | cut -f 4 -d'' '')\n\necho $JOBID\n\n', slurm_partition, strrep(strrep(funcArg{j},'cluster',''),'Res',''), cluster_output_path, cluster_error_path, cluster_script_path, funcArg{j});
%       end
%    end
%end

for j=1:length(funcArg)
   if j==1
	fprintf(fid, 'JOBID%d=$(sbatch -W --partition=%s --job-name=%s --output=%s/%%j.out --error=%s/%%j.error %s/%s.sh | cut -f 4 -d'' '')\n\necho [$JOBID%d] %s DONE\n\n', j, slurm_partition, strrep(strrep(funcArg{j},'cluster',''),'Res',''), cluster_output_path, cluster_error_path, cluster_script_path, funcArg{j}, j, funcArg{j});
   elseif (j==3 || j==length(funcArg))
       if (length(strfind(email_notification, '@')) == 1)
           fprintf(fid, 'JOBID%d=$(sbatch -W --mail-type=ALL --mail-user=%s --partition=%s --dependency=afterok:$JOBID%d --job-name=%s --output=%s/%%j.out --error=%s/%%j.error %s/%s.sh | cut -f 4 -d'' '')\n\necho [$JOBID%d] %s DONE\n\n', j, email_notification, slurm_partition, j-1, strrep(strrep(funcArg{j},'cluster',''),'Res',''), cluster_output_path, cluster_error_path, cluster_script_path, funcArg{j}, j, funcArg{j});
       else
           fprintf(fid, 'JOBID%d=$(sbatch -W --partition=%s --dependency=afterok:$JOBID%d --job-name=%s --output=%s/%%j.out --error=%s/%%j.error %s/%s.sh | cut -f 4 -d'' '')\n\necho [$JOBID%d] %s DONE\n\n', j, slurm_partition, j-1, strrep(strrep(funcArg{j},'cluster',''),'Res',''), cluster_output_path, cluster_error_path, cluster_script_path, funcArg{j}, j, funcArg{j});
       end
   else
       fprintf(fid, 'JOBID%d=$(sbatch -W --partition=%s --dependency=afterok:$JOBID%d --job-name=%s --output=%s/%%j.out --error=%s/%%j.error %s/%s.sh | cut -f 4 -d'' '')\n\necho [$JOBID%d] %s DONE\n\n', j, slurm_partition, j-1, strrep(strrep(funcArg{j},'cluster',''),'Res',''), cluster_output_path, cluster_error_path, cluster_script_path, funcArg{j}, j, funcArg{j});
   end
end

fclose(fid);

eval(['!chmod +x ' fullfile(cluster_script_path, 'clusterrun.sh')]);
eval(['!' fullfile(cluster_script_path, 'clusterrun.sh')]);

