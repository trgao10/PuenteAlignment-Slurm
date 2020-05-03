%% set path and preparation
jadd_path;

if (restart == 1)
    system(['rm -rf ' outputPath]);
    system(['mkdir ' outputPath]);
end

touch([outputPath 'original/']);
touch([outputPath 'subsampled/']);
touch([outputPath 'aligned/']);
touch([outputPath 'jobs/']);

set(0,'RecursionLimit',1500);
rng('shuffle');

%% information and parameters
ds.N       = [iniNumPts, finNumPts];  % Number of points to spread
ds.dataset = ''; % Used for pulling the files containing the meshes
ds.run     = '';     % Used for writing output and intermediate files
[ds.names, suffix] = getFileNames(meshesPath);
ds.ids     = arrayfun(@(x) sprintf('%03d', x), 1:length(ds.names), 'UniformOutput', 0);
disp('Copying files over...');
cellfun(@(a,b) copyfile(a,b),...
    cellfun(@(x) [meshesPath x suffix], ds.names, 'UniformOutput', 0),...
    cellfun(@(x) [outputPath 'original/' x suffix], ds.ids, 'UniformOutput', 0));
disp('Done')

%% paths to be passed as global constants
ds.n                = length( ds.ids ); %Number of shapes
ds.K                = length( ds.N ); %Number of levels
ds.msc.mesh_dir     = meshesPath;
ds.msc.output_dir   = outputPath;
ds.msc.mesh_aligned_dir = [outputPath 'aligned/'];

%% subsample meshes (locally or on cluster)
if use_cluster == 0
    for ii = 1:ds.n            
        fprintf('Getting Subsampled Mesh %s......', ds.names{ii});
        get_subsampled_shape( outputPath, ds.ids{ii}, ds.N( ds.K ), ssType );
        fprintf('DONE\n');
    end
else
    PBS = '#!/bin/sh\n\nmodule load matlab/2019b\n';
    script = 'matlab -nodesktop -nodisplay -nojvm -nosplash -r ' ;
    matlab_cmd = @( kk ) ['\"cd ' codePath 'code/; ' 'jadd_path; get_subsampled_shape(''' outputPath ''', ' ds.ids{kk} ', ' num2str(ds.N(ds.K)) ', ''' ssType '''); exit;\"\n'];
    pfj = [ds.msc.output_dir 'jobs/prep/'];
    touch(pfj);
    
    for ii = 1:ds.n
        script_txt = [ PBS script matlab_cmd(ii) ];
        script_filename = [ pfj 'job_' num2str( ii, '%.4d') '.sh'];
        fid        = fopen(script_filename, 'w');
        fprintf(fid, script_txt);
        fclose(fid);
        eval(['!chmod +x ' script_filename]);
    end

    %% create driver .sbatch file
    fid = fopen([pfj 'prep.sbatch'], 'w');

    if (length(strfind(email_notification, '@')) == 1)
      fprintf(fid, '#!/bin/sh\n\n#SBATCH --partition=%s\n#SBATCH --job-name=prep\n#SBATCH --mail-type=ALL\n#SBATCH --mail-user=%s\n#SBATCH --array=1-%d\n#SBATCH --output=%s%%A_%%a.out\n#SBATCH --error=%s%%A_%%a.err\n', slurm_partition, email_notification, ds.n, pfj, pfj);
    else
      fprintf(fid, '#!/bin/sh\n\n#SBATCH --partition=%s\n#SBATCH --job-name=prep\n#SBATCH --mail-type=ALL\n#SBATCH --array=1-%d\n#SBATCH --output=%s%%A_%%a.out\n#SBATCH --error=%s%%A_%%a.err\n', slurm_partition, ds.n, pfj, pfj);
    end
    
    fprintf(fid, '\nscriptID=`printf %%04d $SLURM_ARRAY_TASK_ID`\n');
    fprintf(fid, ['srun -N1 -n1 ' pfj 'job_$scriptID.sh\n']);
    %%% fprintf(fid, ['srun -N1 -n1 -o ' pfj 'stdout_$scriptID -e ' pfj 'stderr_$scriptID ' pfj 'job_$scriptID.sh\n']);
    fclose(fid);
    
    eval(['!sbatch -W ' pfj 'prep.sbatch']);
end

%% save intermediate results
disp(['Saving current workspace at ' outputPath 'session_low.mat...']);
save([outputPath 'session_low.mat'], '-v7.3');
disp('Saved!');

