%% read data from csv
clear all; close all; clc;
summary_file = 'D:\Anna\Myelin paper Spring 2022\origin_files\OCT_summary_del_NC.xlsx';
[mus_gm_AD, mus_gm_CTE, mus_gm_NC,...
            mus_wm_AD, mus_wm_CTE, mus_wm_NC,...
            ratio_gm_AD, ratio_gm_CTE, ratio_gm_NC,...
            ratio_wm_AD, ratio_wm_CTE, ratio_wm_NC, ...
            ret_gm_AD, ret_gm_CTE, ret_gm_NC, ...
            ret_wm_AD, ret_wm_CTE, ret_wm_NC] = find_stat(summary_file, 0);
% [mus_gm_AD_r, mus_gm_CTE_r, mus_gm_NC_r,...
%             mus_wm_AD_r, mus_wm_CTE_r, mus_wm_NC_r,...
%             ratio_gm_AD_r, ratio_gm_CTE_r, ratio_gm_NC_r,...
%             ratio_wm_AD_r, ratio_wm_CTE_r, ratio_wm_NC_r, ...
%             ret_gm_AD_r, ret_gm_CTE_r, ret_gm_NC_r, ...
%             ret_wm_AD_r, ret_wm_CTE_r, ret_wm_NC_r] = find_stat(summary_file, 1);

%% sulcus data GM
 show_stats(mus_gm_NC, mus_gm_AD, mus_gm_CTE);
show_stats(ratio_gm_NC, ratio_gm_AD, ratio_gm_CTE);
show_stats(ret_gm_NC, ret_gm_AD, ret_gm_CTE);

%% sulcus data WM
show_stats(mus_wm_NC, mus_wm_AD, mus_wm_CTE);
show_stats(ratio_wm_NC, ratio_wm_AD, ratio_wm_CTE);
show_stats(ret_wm_NC, ret_wm_AD, ret_wm_CTE);


%% show all stats for mub/mus ratio
% show_stats(ratio_gm_NC, ratio_gm_AD, ratio_gm_CTE);
% show_stats(ratio_wm_NC, ratio_wm_AD, ratio_wm_CTE);

% show_stats(ratio_gm_NC_r, ratio_gm_AD_r, ratio_gm_CTE_r);
% show_stats(ratio_wm_NC_r, ratio_wm_AD_r, ratio_wm_CTE_r);

%show_stats(ratio_gm_NC./ratio_gm_NC_r, ratio_gm_AD./ratio_gm_AD_r, ratio_gm_CTE./ratio_gm_CTE_r);
%show_stats(ratio_wm_NC./ratio_wm_NC_r, ratio_wm_AD./ratio_wm_AD_r, ratio_wm_CTE./ratio_wm_CTE_r);

%% show all stats for mus 
% show_stats(mus_gm_NC, mus_gm_AD, mus_gm_CTE);
% show_stats(mus_wm_NC, mus_wm_AD, mus_wm_CTE);
% 
% show_stats(mus_gm_NC_r, mus_gm_AD_r, mus_gm_CTE_r);
% show_stats(mus_wm_NC_r, mus_wm_AD_r, mus_wm_CTE_r);
% 
% show_stats(mus_gm_NC./mus_gm_NC_r, mus_gm_AD./mus_gm_AD_r, mus_gm_CTE./mus_gm_CTE_r);
% show_stats(mus_wm_NC./mus_wm_NC_r, mus_wm_AD./mus_wm_AD_r, mus_wm_CTE./mus_wm_CTE_r);

%% show all stats for ret 
% show_stats(ret_gm_NC, ret_gm_AD, ret_gm_CTE);
% show_stats(ret_wm_NC, ret_wm_AD, ret_wm_CTE);
% 
% show_stats(ret_gm_NC_r, ret_gm_AD_r, ret_gm_CTE_r);
% show_stats(ret_wm_NC_r, ret_wm_AD_r, ret_wm_CTE_r);
% 
% show_stats(ret_gm_NC./ret_gm_NC_r, ret_gm_AD./ret_gm_AD_r, ret_gm_CTE./ret_gm_CTE_r);
%  show_stats(ret_wm_NC./ret_wm_NC_r, ret_wm_AD./ret_wm_AD_r, ret_wm_CTE./ret_wm_CTE_r);




%mean_std('AD', mus_gm_AD./ mus_gm_AD_r);
%mean_std('CTE', mus_gm_CTE./mus_gm_CTE_r);
%mean_std('NC', mus_gm_NC./mus_gm_NC_r);
% 
% mean_std('AD', mus_wm_AD./mus_wm_AD_r);
% mean_std('CTE', mus_wm_CTE./mus_wm_CTE_r);
% mean_std('NC', mus_wm_NC./mus_wm_NC_r);
% 
% mean_std('AD', ratio_gm_AD./ratio_gm_AD_r);
% mean_std('CTE', ratio_gm_CTE./ratio_gm_CTE_r);
% mean_std('NC', ratio_gm_NC./ratio_gm_NC_r);
% 
% mean_std('AD', ratio_wm_AD./ratio_wm_AD_r);
% mean_std('CTE', ratio_wm_CTE./ratio_wm_CTE_r);
% mean_std('NC', ratio_wm_NC./ratio_wm_NC_r);
% 
%mean_std('AD', ret_gm_AD./ret_gm_AD_r);
%mean_std('CTE', ret_gm_CTE./ret_gm_CTE_r);
%mean_std('NC', ret_gm_NC./ret_gm_NC_r);

%mean_std('AD', ret_wm_AD./ret_wm_AD_r);
%mean_std('CTE', ret_wm_CTE./ret_wm_CTE_r);
%mean_std('NC', ret_wm_NC./ret_wm_NC_r);



% mean_std('AD', mus_gm_AD);
% mean_std('CTE', mus_gm_CTE);
% mean_std('NC', mus_gm_NC);

% mean_std('AD', mus_wm_AD);
% mean_std('CTE', mus_wm_CTE);
% mean_std('NC', mus_wm_NC);
% 
% mean_std('AD', ratio_gm_AD);
% mean_std('CTE', ratio_gm_CTE);
% mean_std('NC', ratio_gm_NC);

% mean_std('AD', ratio_gm_AD_r);
% mean_std('CTE', ratio_gm_CTE_r);
% mean_std('NC', ratio_gm_NC_r);
% 
% mean_std('AD', ratio_wm_AD);
% mean_std('CTE', ratio_wm_CTE);
% mean_std('NC', ratio_wm_NC);
% mean_std('AD', ratio_wm_AD_r);
% mean_std('CTE', ratio_wm_CTE_r);
% mean_std('NC', ratio_wm_NC_r);
% 
% mean_std('AD', ret_gm_AD);
% mean_std('CTE', ret_gm_CTE);
% mean_std('NC', ret_gm_NC);

% mean_std('AD', ret_wm_AD_r);
% mean_std('CTE', ret_wm_CTE_r);
% mean_std('NC', ret_wm_NC_r);


function [mus_gm_AD, mus_gm_CTE, mus_gm_NC,...
            mus_wm_AD, mus_wm_CTE, mus_wm_NC,...
            ratio_gm_AD, ratio_gm_CTE, ratio_gm_NC,...
            ratio_wm_AD, ratio_wm_CTE, ratio_wm_NC, ...
            ret_gm_AD, ret_gm_CTE, ret_gm_NC, ...
            ret_wm_AD, ret_wm_CTE, ret_wm_NC] = find_stat(summary_file, type)

% type = 0 - sulci, type=1 - crest
    ratio_wm_sul = readmatrix(summary_file,'Sheet','ratio','Range','C4:O27');
    mus_wm_sul = readmatrix(summary_file,'Sheet','mus','Range','C4:O27');
    ret_wm_sul = readmatrix(summary_file,'Sheet','ret','Range','C4:O27');
    
    ratio_wm_ref = readmatrix(summary_file,'Sheet','ratio','Range','C29:O52');
    mus_wm_ref = readmatrix(summary_file,'Sheet','mus','Range','C29:O52');
    ret_wm_ref = readmatrix(summary_file,'Sheet','ret','Range','C29:Q52');
    
    ratio_gm_sul = readmatrix(summary_file,'Sheet','ratio','Range','C54:O77');
    mus_gm_sul = readmatrix(summary_file,'Sheet','mus','Range','C54:O77');
    ret_gm_sul = readmatrix(summary_file,'Sheet','ret','Range','C54:O77');
    
    ratio_gm_ref = readmatrix(summary_file,'Sheet','ratio','Range','C79:O102');
    mus_gm_ref = readmatrix(summary_file,'Sheet','mus','Range','C79:O102');
    ret_gm_ref = readmatrix(summary_file,'Sheet','ret','Range','C79:O102');
    %% normalize GM sul and WM sul by GM ref and WM ref
    % ratio_wm = ratio_wm_sul./ratio_wm_ref;
    % mus_wm = mus_wm_sul./mus_wm_ref;
    % ret_wm = ret_wm_sul./ret_wm_ref;
    % 
    % ratio_gm = ratio_gm_sul./ratio_gm_ref;
    % mus_gm = mus_gm_sul./mus_gm_ref;
    % ret_gm = ret_gm_sul./ret_gm_ref;
    
    % !!!!!! change to ratio_wm_sul for sulcus and to ratio_wm_ref for crest
    % !!!!!
    if type == 0
        disp('Sulci')
        ratio_wm = ratio_wm_sul;
        mus_wm = mus_wm_sul;
        ret_wm = ret_wm_sul;
        
        ratio_gm = ratio_gm_sul;
        mus_gm = mus_gm_sul;
        ret_gm = ret_gm_sul;
    elseif type == 1
        disp('Crest')
        ratio_wm = ratio_wm_ref;
        mus_wm = mus_wm_ref;
        ret_wm = ret_wm_ref;
        
        ratio_gm = ratio_gm_ref;
        mus_gm = mus_gm_ref;
        ret_gm = ret_gm_ref;
    end

    %% concatenate ratio data
    ratio_wm_AD = ratio_wm(:,1:5);
    ratio_wm_CTE = ratio_wm(:,6:10);
    ratio_wm_NC = ratio_wm(:,11:13);
    
    ratio_gm_AD = ratio_gm(:,1:5);
    ratio_gm_CTE = ratio_gm(:,6:10);
    ratio_gm_NC = ratio_gm(:,11:13);
    
    % reshape mubmus to form a vector
    ratio_wm_CTE = reshape(ratio_wm_CTE, [size(ratio_wm_CTE,1)*size(ratio_wm_CTE,2) 1]);
    ratio_wm_AD = reshape(ratio_wm_AD, [size(ratio_wm_AD,1)*size(ratio_wm_AD,2) 1]);
    ratio_wm_NC = reshape(ratio_wm_NC, [size(ratio_wm_NC,1)*size(ratio_wm_NC,2) 1]);
    
    ratio_gm_CTE = reshape(ratio_gm_CTE, [size(ratio_gm_CTE,1)*size(ratio_gm_CTE,2) 1]);
    ratio_gm_AD = reshape(ratio_gm_AD, [size(ratio_gm_AD,1)*size(ratio_gm_AD,2) 1]);
    ratio_gm_NC = reshape(ratio_gm_NC, [size(ratio_gm_NC,1)*size(ratio_gm_NC,2) 1]);
    
    ratio_wm_CTE(isnan(ratio_wm_CTE(:)))=[];
    ratio_wm_AD(isnan(ratio_wm_AD(:)))=[];
    ratio_wm_NC(isnan(ratio_wm_NC(:)))=[];
    
    ratio_gm_CTE(isnan(ratio_gm_CTE(:)))=[];
    ratio_gm_AD(isnan(ratio_gm_AD(:)))=[];
    ratio_gm_NC(isnan(ratio_gm_NC(:)))=[];
    
    %% concatenate retardance data
    ret_wm_AD = ret_wm(:,1:5);
    ret_wm_CTE = ret_wm(:,6:10);
    ret_wm_NC = ret_wm(:,11:13);
    
    ret_gm_AD = ret_gm(:,1:5);
    ret_gm_CTE = ret_gm(:,6:10);
    ret_gm_NC = ret_gm(:,11:13);
    
    % reshape retardance to form a vector
    ret_wm_CTE = reshape(ret_wm_CTE, [size(ret_wm_CTE,1)*size(ret_wm_CTE,2) 1]);
    ret_wm_AD = reshape(ret_wm_AD, [size(ret_wm_AD,1)*size(ret_wm_AD,2) 1]);
    ret_wm_NC = reshape(ret_wm_NC, [size(ret_wm_NC,1)*size(ret_wm_NC,2) 1]);
    
    ret_gm_CTE = reshape(ret_gm_CTE, [size(ret_gm_CTE,1)*size(ret_gm_CTE,2) 1]);
    ret_gm_AD = reshape(ret_gm_AD, [size(ret_gm_AD,1)*size(ret_gm_AD,2) 1]);
    ret_gm_NC = reshape(ret_gm_NC, [size(ret_gm_NC,1)*size(ret_gm_NC,2) 1]);
    
    ret_wm_CTE(isnan(ret_wm_CTE(:)))=[];
    ret_wm_AD(isnan(ret_wm_AD(:)))=[];
    ret_wm_NC(isnan(ret_wm_NC(:)))=[];
    
    ret_gm_CTE(isnan(ret_gm_CTE(:)))=[];
    ret_gm_AD(isnan(ret_gm_AD(:)))=[];
    ret_gm_NC(isnan(ret_gm_NC(:)))=[];
    
    %% concatenate scattering data
    mus_wm_AD = mus_wm(:,1:5);
    mus_wm_CTE = mus_wm(:,6:10);
    mus_wm_NC = mus_wm(:,11:13);
    
    mus_gm_AD = mus_gm(:,1:5);
    mus_gm_CTE = mus_gm(:,6:10);
    mus_gm_NC = mus_gm(:,11:13);
    
    % reshape mubmus to form a vector
    mus_wm_CTE = reshape(mus_wm_CTE, [size(mus_wm_CTE,1)*size(mus_wm_CTE,2) 1]);
    mus_wm_AD = reshape(mus_wm_AD, [size(mus_wm_AD,1)*size(mus_wm_AD,2) 1]);
    mus_wm_NC = reshape(mus_wm_NC, [size(mus_wm_NC,1)*size(mus_wm_NC,2) 1]);
    
    mus_gm_CTE = reshape(mus_gm_CTE, [size(mus_gm_CTE,1)*size(mus_gm_CTE,2) 1]);
    mus_gm_AD = reshape(mus_gm_AD, [size(mus_gm_AD,1)*size(mus_gm_AD,2) 1]);
    mus_gm_NC = reshape(mus_gm_NC, [size(mus_gm_NC,1)*size(mus_gm_NC,2) 1]);
    
    mus_wm_CTE(isnan(mus_wm_CTE(:)))=[];
    mus_wm_AD(isnan(mus_wm_AD(:)))=[];
    mus_wm_NC(isnan(mus_wm_NC(:)))=[];
    
    mus_gm_CTE(isnan(mus_gm_CTE(:)))=[];
    mus_gm_AD(isnan(mus_gm_AD(:)))=[];
    mus_gm_NC(isnan(mus_gm_NC(:)))=[];

    
end


function mean_std(state, var)
    disp(state)
    mean_val = mean(var)
    error_val = std(var)/sqrt(length(var))
end

function [p, tbl, stats] = one_way_ANOVA_3gr(grAD, grCTE, grNC)
     %% one-way ANOVA
    hogg = [grAD;grCTE;grNC];
    group1 = repmat({'AD'},length(grAD),1);
    group2 = repmat({'CTE'},length(grCTE),1);
    group3 = repmat({'NC'},length(grNC),1);
    Group = [group1;group2;group3];
    [p, tbl, stats] = anova1(hogg, Group);
    p
    boxplot(hogg, Group, 'Notch', 'off');
    set(gca, 'FontSize', 24);
    %ylim([0.01 0.25]);
    %yticks([10 12.5 15 17.5 20]);
    ylim([3.5*10^(-4) 6.5*10^(-4)]);
    %%
    %[c,~,~,gnames] = multcompare(stats);
end

function [p, tbl, stats] = one_way_ANOVA(grNC, grD, name_NC, name_D)
     %% one-way ANOVA
    hogg = [grNC; grD];
    group1 = repmat({name_NC},length(grNC),1);
    group2 = repmat({name_D},length(grD),1);
    Group = [group1;group2];
    [p, tbl, stats] = anova1(hogg, Group);
    p
    boxplot(hogg, Group, 'Notch', 'off');
    set(gca, 'FontSize', 24);
    

    %%
    %[c,~,~,gnames] = multcompare(stats);
end

function show_stats(NC, AD, CTE)
%     disp('NC vs AD');
%     [p, tbl, stats] = one_way_ANOVA(NC, AD, 'NC', 'AD');
%     disp('NC vs CTE');
%     [p, tbl, stats] = one_way_ANOVA(NC, CTE, 'NC', 'CTE');
%     disp('AD vs CTE');
%     [p, tbl, stats] = one_way_ANOVA(AD, CTE, 'AD', 'CTE');
    disp('NC vs AD vs CTE');
    [p, tbl, stats] = one_way_ANOVA_3gr(AD, CTE, NC);
end