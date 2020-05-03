function pa = compute_alignment( pa, f, n_jobs, use_cluster )
% Computes optimal rotation and permutation for true entries of A
% al must contain a sparse matrix A indicating which entries are to be
% computed
% al must also implement a function save()
% f must take two integers and return [d,R,P,gamma]

% n          = size( pa.A , 2 );

map( pa, f, n_jobs ); % Save n_jobs files to be processed

if( use_cluster == 0 )
   for kk = 0 : n_jobs - 1
      process_job([pa.pfj 'job_' num2str(kk,'%.4d') '.mat'], [ pa.pfj 'ans_' num2str(kk,'%.4d') '.mat'], [pa.pfj 'f.mat']);
   end
else
    %Write script files and submit them
    submit_jobs( pa , n_jobs );
end

end
    

