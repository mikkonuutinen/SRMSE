function [srmse target_values] = srmse_analysis(data, th) 

%%%%%%%%%%%%%%%%%
% DESCRIPTION
% This script calculates subjective RMSE values and target values for
% image/video database.
%
% The measures are explained in detail in:
% "M. Nuutinen, T. Virtanen, J. Häkkinen, "New performance measure of image
% and video quality assessment algorithms: Subjective
% Root-Mean-Square-Error (SRMSE)", Journal of Electronic Imaging.

%%%%%%%%%%%%%%%%%%
% INPUT
% 
% (1) data: data should be presented in MATLAB .mat matrix including four 
% columns: 
% Column1 = subject number
% Column2 = Image content number
% Column3 = Image version
% Column4 = Score
% load 'CID_IS1.mat' % (matrix should be named as 'data')

% (2) th: threshold value is needed for target value computation.
% th=0.01;

%%%%%%%%%%%%%%%%%
% OUTPUT VALUES
%  (1) "srmse" matrix contains subjective RMSE values as a function of the 
%      number of subjects (columns) over image contents (rows)
%  (2) "target_values" vector contains target RMSE values (= performance of
%      ideal algorithm) for different contents
%  

%%%%%%%%%%%%%%%%
% USAGE
% Check 'example.m' script


%%%%%%%%%%%%%%%%%VERSION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Last modified:
% Mikko Nuutinen, 05.11.2015 (mikko.s.nuutinen@gmail.com)
%


% Minimum and maximum MOS values of the used scale (these values are needed
% when theoretical value of zero observer is calculated)
MOS_min=0;
MOS_max=100;

% Data is organized in three dimensional matrix 'data_matrix'. The size of
% the matrix is number of observers X number of image versions X number of
% image contents
for i=1:size(data,1);
    data_matrix(data(i,1),data(i,3),data(i,2))=data(i,4);
end

kh_nro=size(data_matrix,1); % Number of observers
image_nro=size(data_matrix,2); % Number of variations
cont_nro=size(data_matrix,3); % Number of contents

% initializing vectors for calculations
values_mos_rmse=zeros(kh_nro,image_nro,cont_nro);
values_mos=zeros(1000,kh_nro,image_nro,cont_nro);


% Calculating MOS values from data
for cont=1:cont_nro
   for video=1:image_nro 
        mos(video,cont)=mean(data_matrix(:,video,cont));
   end
end


% Calculating rmse values as a function of observer number and derivatives
% for the rmse functions. The target values are derived from the derivative
% values
for cont=1:cont_nro
   cont
   for video=1:image_nro 
        for n=1:kh_nro
            
            mos(video,cont)=mean(data_matrix(:,video,cont));

            for i=1:1000
                a=randperm(kh_nro);
                                
                for j=1:n;     
                    values(i,j)=data_matrix(a(j),video,cont);
                end
            end
                
            if (n==1)
                values_mos(:,1,video,cont)=values(:,1);
            else
                values_mos(:,n,video,cont)=mean(values')';
            end
          
            values_mos_rmse(n+1,video,cont) = mean(sqrt((values_mos(:,n,video,cont)-mos(video,cont)).^2));
            
            % Calculating derivatives of rmse values
            values_mos_rmse_ind(:,n+1,video,cont)=sqrt((values_mos(:,n,video,cont)-mos(video,cont)).^2);
            values_mos_rmse_der(n,video,cont) = mean(values_mos_rmse_ind(:,n,video,cont)-values_mos_rmse_ind(:,n+1,video,cont));
            
            values=[];
        end
   end
end


% Theoretical "zero" observers so we can estimate rmse values between 0 and
% 1 observers
for cont=1:cont_nro
   for video=1:image_nro 
        for i=1:1000
            random_score(i)=randperm(100,1);
        end
    values_mos_rmse(1,video,cont)= mean(sqrt((random_score(1,:)-mos(video,cont)).^2));
    values_mos_rmse_ind(:,1,video,cont)=sqrt((random_score(1,:)-mos(video,cont)).^2);
    values_mos_rmse_der(1,video,cont) = mean(values_mos_rmse_ind(:,1,video,cont)-values_mos_rmse_ind(:,2,video,cont));
   end
end


% Calculating mean derivatives
for i=1:size(values_mos_rmse_der,3)
    values_mos_rmse_der_mean(:,i)=mean(values_mos_rmse_der(:,:,i)')
end    
% Moving average filtering for derivatives
wts = [1/8;repmat(1/4,3,1);1/8];
for i=1:size(values_mos_rmse_der_mean,2)
    values_mos_rmse_der_mean_filt(:,i)=conv(values_mos_rmse_der_mean(:,i),wts,'valid');
end

% Calculating human saturation points from filtered derivatives
for i=1:size(values_mos_rmse_der_mean_filt,2)
    n=0;
    no_more=0;
    for j=1:size(values_mos_rmse_der_mean_filt,1)-1
        test(j,i)=n;
        
        if (values_mos_rmse_der_mean_filt(j,i)>=values_mos_rmse_der_mean_filt(j+1,i)+th && no_more==0)
            n=n+1;
        	obs_sat(i)=n;
        end
        if (values_mos_rmse_der_mean_filt(j,i)<values_mos_rmse_der_mean_filt(j+1,i)+th)
            no_more=1;
        end
    end
end

obs_sat=obs_sat+2 % combensating lacking values at beginging of the vector because of average filtering

% Example plotting
%plot(mean(values_mos_rmse(:,:,1)'));

% Calculating srmse values by averaging image content specific values
for k=1:cont_nro
    srmse(k,:)=mean(values_mos_rmse(:,:,k)');
end

% Calculating target RMSE values 
for k=1:cont_nro
    target_values(k,1)=srmse(k,obs_sat(k));
end

clear values;