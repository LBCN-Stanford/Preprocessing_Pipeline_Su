% List of open inputs
% Filter: File Name - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\parvizilab\Codes\codes\ECoG_preprocessing_SPM\Filter_NKnew_SPM_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Filter: File Name - cfg_files
end
spm('defaults', 'EEG');
spm_jobman('run', jobs, inputs{:});
