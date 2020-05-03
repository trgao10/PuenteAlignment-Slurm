# Puente Alignment -- Slurm
This is [Puente Alignment](https://github.com/trgao10/PuenteAlignment) backed by [Slurm Workload Manager](https://slurm.schedmd.com/overview.html) for cluster deployment. The R version of this alignment algorithm is known as [*auto3dgm*](https://stat.duke.edu/~sayan/auto3dgm/).

-----------
#### Parallel Execution with a Single MATLAB Command

1. Set paths and parameters in *PuenteAlignment-Slurm/code/jadd_path.m*. In particular, set `slurm_partition` based on your Slurm configuration, and set `email_notification` to be notified of the job status.

2. Launch `MATLAB` -- if your cluster is maintained using a module system, maybe first

        module load matlab/2019b


The specific `MATLAB` version shouldn't matter too much; to the best of our knowledge this package relies on standard `MATLAB` functionalities.

3. `cd` into the folder *PuenteAlignment-Slurm/code/*, type in `clusterDriver.m` and press `ENTER`. The `MATLAB` console will halt until the entire computational pipeline terminates.

-----------
#### Parallel Execution with Separate Stages
This variant of the workflow is essentially the same as parallel execution in [Puente Alignment](https://github.com/trgao10/PuenteAlignment). Technically this workflow is cumbersome but it is kept here for flexibility and debugging.

1. Get the current version of PuenteAlignment. Simply `cd` into your desired path, then type

        git clone https://github.com/trgao10/PuenteAlignment-Slurm/

2. Set paths and parameters in *PuenteAlignment-Slurm/code/jadd_path.m*. In particular, set `slurm_partition` based on your Slurm configuration, and set `email_notification` to be notified of the job status.
3. `cd` into the folder *PuenteAlignment-Slurm/code/*, type in `clusterPreprocess.m` then press `ENTER`. Check the status of the submitted jobs on Slurm using

        squeue -u <*YourUserName*>

4. After all jobs are completed, type in `clusterMapLowRes` then press `ENTER`.
5. After all jobs are completed, type in `clusterReduceLowRes` then press `ENTER`. This generates low-resolution alignment results under folder `outputPath` specified in `jadd_path.m`.
6. Type in `clusterMapHighRes` then press `ENTER` to submit high-resolution alignment jobs to the cluster. Use `squeue` to monitor job status.
7. After all jobs are completed, type in `clusterReduceHighRes` then press `ENTER`. This generates high-resolution alignment results under folder `outputPath` folder specified in ```jadd_path.m```.
8. After all jobs are completed, type in `clusterPostprocessing` then press `ENTER`.

-----------
#### Sequential Execution
The entry point is the script `code/main.m`; see comments at the top of that script for a quick introduction. 

-----------
#### WebGL-based Alignment Visualization
After the alignment process is completed, the result can be visualized using a javascript-based viewer located under the folder *viewer/*. See [here](http://www.math.duke.edu/~trgao10/research/auto3dgm.html) for an online demo.

1. Move all output files ending with "_aligned.obj" from the subfolder *aligned/* (under the output folder specified in *code/jaddpath.m*) to the subfolder *viewer/aligned_meshes/*.
2. Set up an HTTP server under the folder *viewer/*. 

   For Python 2.x: `cd viewer/` and 

        python -m SimpleHTTPServer 8000

     For Python 3.x: `cd viewer/` and 

        python -m http.server 8000

3. Launch a browser window and visit [http://localhost:8000/auto3dgm.html](http://localhost:8000/auto3dgm.html).

-----------
#### Mosek License File
You will need a mosek license for using the fast linear programming routine for pairwise alignments. If you have an academic/institutional email address, you are eligible for a [free academic license](https://www.mosek.com/resources/academic-license) from [mosek.com](https://www.mosek.com/). Upon receiving the mosek license, simply drop it under the folder `PuenteAlignment/software/mosek/`.

-----------
#### Please Cite:

Boyer, Doug M., et al. *A New Fully Automated Approach for Aligning and Comparing Shapes.* The Anatomical Record 298.1 (2015): 249-276.

Puente, Jesús. *Distances and Algorithms to Compare Sets of Shapes for Automated Biological Morphometrics.* PhD Thesis, Princeton University, 2013.
