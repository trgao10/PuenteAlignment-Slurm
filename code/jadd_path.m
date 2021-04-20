%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% setup parameters in this section 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% "meshesPath" is where the orignal meshes are located

meshesPath = '/gpfs/scratch/nvitek/PT-small/';

%%%%% "outputPath" stores intermediate files, re-aligned meshes, and
%%%%% morphologika files
cluster_path = '/gpfs/scratch/tinggao/PT-small/cluster/';
outputPath = '/gpfs/scratch/tinggao/PT-small/output/';

%%%%% set parameters for the algorithm
restart = 1;

iniNumPts = 128;
finNumPts = 1024;
ssType = 'FPS';
type = 'MST';

use_cluster = 1;
n_jobs = 50; %%% more nodes, more failure (no hadoop!)
allow_reflection = 1; %%% if set to 0, no reflection will be allowed in
                      %%% the alignments
max_iter = 1000; %%% maximum number of iterations for each pairwise alignment
email_notification = 'gaotingran@gmail.com';
slurm_partition = 'extended-24core';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% NO NEED TO MODIFY ANYTHING OTHER THAN THIS FILE!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
codePath= [fileparts(pwd) filesep];
path(pathdef);
path(path, genpath([codePath 'software']));
setenv('MOSEKLM_LICENSE_FILE', [codePath 'software/mosek/mosek.lic'])
