% dirs.data_root = '/Users/suliu/Dropbox/DATA/Pedro_data/data/neuralData';
% sbj_name = 'S18_127';
% project_name = 'Calculia_production';
% block_names = {'E18-706_0022', 'E18-706_0025', 'E18-706_0026'};

dirs.data_root = '/Users/suliu/Desktop/136/neuralData';
sbj_name = 'S19_136_AG';
project_name = 'MMR';
block_names = {'E19-320_0004'};
plot_params.blc = true;
data_all = ConcatenateAll(sbj_name,project_name,block_names,dirs,[],'HFB','stim', plot_params);