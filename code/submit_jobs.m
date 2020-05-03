function submit_jobs( pa, n_jobs )
%Send jobs to the cluster

% Text wrappers
PBS        = '#!/bin/sh\n\nmodule load matlab/2019b\n';
script     = 'matlab -nodesktop -nodisplay -nojvm -nosplash -r ' ;
matlab_cmd = @( kk ) ['\"cd ' pa.codePath 'code/;' 'jadd_path; load(''' pa.pfj 'job_' num2str( kk, '%.4d') ''');process_job(''' pa.pfj 'job_' num2str(kk,'%.4d') ''', ''' pa.pfj 'ans_' num2str(kk,'%.4d') ''', ''' pa.pfj 'f.mat'');exit;\"\n'];

%Create scripts
for kk = 0 : n_jobs-1
    script_txt = [PBS script matlab_cmd(kk) ];
    script_filename = [ pa.pfj 'job_' num2str( kk, '%.4d') '.sh'];
    fid        = fopen(script_filename,'w');
    fprintf( fid, script_txt );
    fclose(fid);
    eval(['!chmod +x ' script_filename]);
end

if strfind(pa.pfj, "low") > 0
    jobname = 'mapLow';
elseif strfind(pa.pfj, "high") > 0
    jobname = 'mapHigh';
elseif strfind(pa.pfj, "post") > 0
    jobname = 'reduceHig';
end

%% create driver .sbatch file
fid = fopen([pa.pfj 'alignment.sbatch'], 'w');

if (length(strfind(pa.email_notification, '@')) == 1)
   fprintf(fid, '#!/bin/sh\n\n#SBATCH --partition=%s\n#SBATCH --job-name=%s\n#SBATCH --mail-type=ALL\n#SBATCH --mail-user=%s\n#SBATCH --array=0-%d\n#SBATCH --output=%s%%A_%%a.out\n#SBATCH --error=%s%%A_%%a.err\n', pa.slurm_partition, jobname, pa.email_notification, n_jobs-1, pa.pfj, pa.pfj);
 else
   fprintf(fid, '#!/bin/sh\n\n#SBATCH --partition=%s\n#SBATCH --job-name=%s\n#SBATCH --mail-type=ALL\n#SBATCH --array=0-%d\n#SBATCH --output=%s%%A_%%a.out\n--error=%s%%A_%%a.err\n', pa.slurm_partition, jobname, n_jobs-1, pa.pfj, pa.pfj);
end

fprintf(fid, '\nscriptID=`printf %%04d $SLURM_ARRAY_TASK_ID`\n');
fprintf(fid, ['srun -N1 -n1 -o ' pa.pfj 'stdout_$scriptID -e ' pa.pfj 'stderr_$scriptID ' pa.pfj 'job_$scriptID.sh\n']);
fclose(fid);

eval(['!sbatch -W ' pa.pfj 'alignment.sbatch']);
    
end
