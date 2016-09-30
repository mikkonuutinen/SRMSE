
clear all

% subjective_data_file: data should be presented in MATLAB .mat matrix 
% including four columns: 
% Column1 = subject number
% Column2 = Image content number
% Column3 = Image version
% Column4 = Score
% (matrix should be named as 'data')
% see the example files 'CID_ISx.mat'

load 'CID_IS1.mat' % CID2013 subjective scores of image set1
%load 'CID_IS2.mat' % CID2013 subjective scores of image set2
%load 'CID_IS3.mat' % CID2013 subjective scores of image set3
%load 'CID_IS4.mat' % CID2013 subjective scores of image set4
%load 'CID_IS5.mat' % CID2013 subjective scores of image set5
%load 'CID_IS6.mat' % CID2013 subjective scores of image set6

% th: threshold value is needed for target value computation (see the
% paper*)
th = 0.1;

% OUTPUT VALUES
%  (1) "srmse" matrix contains subjective RMSE values as a function of the 
%      number of subjects (columns) over image contents (rows)
%  (2) "target_values" vector contains target RMSE values (= performance of
%      ideal algorithm) for different contents
[srmse target_values] = srmse_analysis(data, th)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PERFORMANCE OF IQA/VQA ALGORITHMS: numbers of observers (n_est)

% Example rmse values of IQA/VQA algorithm (see Eq. (1) in paper*)
rmse = [9.95 10.86 11.73 10.19 14.03 10.72];
% The result of SRMSE performance measure (n_est) indicates the extent to
% which the algorithm can replace the subjective experiment (as the number
% of oservers)
n_est = srmse_NoO_average_obs(rmse,srmse)

% *"M. Nuutinen, T. Virtanen, J. Häkkinen, "New performance measure of image
% and video quality assessment algorithms: Subjective
% Root-Mean-Square-Error (SRMSE)", Journal of Electronic Imaging.
