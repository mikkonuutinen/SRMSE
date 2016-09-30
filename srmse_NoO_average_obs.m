function n_est = srmse_NoO_average_obs(rmse,srmse)

% This function calculates performance value for IQA/VQA algorithm based on
% the scale of average observer

subj=srmse;
n_a=1;

for i=2:size(subj,2)
    if (rmse<subj(1,i))
        n_a=n_a+1;
    end
end
n_b=n_a+1;

    srmse_a=subj(1,n_a);
    srmse_b=subj(1,n_b);

n_est=n_b-(n_b-n_a)*((rmse-srmse_b)/(srmse_a-srmse_b))-1;

