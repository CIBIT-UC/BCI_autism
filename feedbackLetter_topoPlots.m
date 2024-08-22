%% Topographic maps of power distribution - Response feedback

clear all; clc; close all

group = "S";            % S = control; P = participante with ASD

dir = "C:\toolbox\Code_Speller_Reverse\data\";

%% 
time=[0 1]; % Epochs
topo_plots_lim = [0 5.5]; %Theta: [0 5.5]; Alpha: [0 4].
freqmin=4; %Min freq. Theta: 4 Hz; Alpha: 8 Hz
freqmax=8; %Max freq. Theta: 8 Hz; Alpha: 13 Hz

%% 
theta_Corr=[];
theta_Serr=[];
theta_Perr=[];

trials_corr = [];
trials_Perr = [];
trials_Serr = [];

for sub = [1:10]           %Subjects
    
    if ~exist(char(strcat(dir, group, num2str(sub), '\online_data\epochs\feedbackLetter_corr.set')))
        
        %Load data
        eeg = pop_loadset('filename', 'interp.set', 'filepath', ...
            char(strcat(dir, group, num2str(sub), '\online_data\data_preprocessed\')));
        eeg = pop_rmbase(eeg, [0 2000]);
        
        % Correct/Erroneous letters
        corr = pop_epoch(eeg, {'5_Corr', '7_Corr'}, time);
        Serr = pop_epoch(eeg, {'5_Err_syst', '7_Err_syst'}, ...
            time); %System error
        conditions = [corr, Serr];
        cond_names = ["corr", "Serr"];
        if sum(contains(string(char(eeg.event.type)),"Err_part"))
            Perr = pop_epoch(eeg, {'5_Err_part', '7_Err_part'}, time); %Participant error
            conditions = [conditions, Perr];
            cond_names = [cond_names, "Perr"];
        end
        
        %Create directory to save dataset in file
        if ~exist(strcat(dir, group, num2str(sub), '\online_data\epochs\'))
           mkdir(strcat(dir, group, num2str(sub), '\online_data\epochs\'))
        end

        for i=1:length(conditions)
  
            %Epochs rejection
            EEG_epochs = pop_eegthresh(conditions(i), 1, [2:length(eeg.chanlocs)], ...
                -100, 100, -1, 1, 0, 0);
            fprintf('Epochs rejected automatically: ');
            disp(find(EEG_epochs.reject.rejthresh == 1));
            pop_eegplot(EEG_epochs, 1, 1, 0);
            epochs_rej = input("Which epochs do you want to reject? If none, enter 0");
            if epochs_rej ~= 0
                EEG_epochs = pop_rejepoch(EEG_epochs, epochs_rej, 0);
            end

            %Save dataset in file
            EEG_epochs = pop_saveset(EEG_epochs, 'filename', ...
                char(strcat('feedbackLetter_', cond_names(i))), 'filepath', ...
                char(strcat(dir, group, num2str(sub), '\online_data\epochs\')));
            disp(cond_names(i))
            if i==1
                corr=EEG_epochs;
            elseif i==2
                Serr=EEG_epochs;
            elseif cond_names(i)=="Perr"
                Perr=EEG_epochs;
            end
            
        end
    else
        
        % Load epochs
        corr = pop_loadset('filename', 'feedbackLetter_corr.set', 'filepath', ...
            char(strcat(dir, group, num2str(sub), '\online_data\epochs\')));
        Serr = pop_loadset('filename', 'feedbackLetter_Serr.set', 'filepath', ...
            char(strcat(dir, group, num2str(sub), '\online_data\epochs\')));
        conditions = [corr, Serr];
        cond_names = ["corr", "Serr"];
        if exist(char(strcat(dir, group, num2str(sub), '\online_data\epochs\feedbackLetter_Perr.set')))
            Perr = pop_loadset('filename', 'feedbackLetter_Perr.set', 'filepath', ...
                char(strcat(dir, group, num2str(sub), '\online_data\epochs\')));
            conditions = [conditions, Perr];
            cond_names = [cond_names, "Perr"];
        end
    end

    % Power computation
    theta_Corr_sub = freqPower(corr,freqmin,freqmax,[2:corr.nbchan],[1:corr.trials]);
    theta_Corr = [theta_Corr, theta_Corr_sub];
    trials_corr = [trials_corr, corr.trials];
    
    theta_Serr_sub = freqPower(Serr,freqmin,freqmax,[2:Serr.nbchan],[1:Serr.trials]);
    theta_Serr = [theta_Serr, theta_Serr_sub];
    trials_Serr = [trials_Serr, Serr.trials];
    
    if length(conditions)>2
        
        if ismember("Perr", cond_names) && ~(sub==9 && group=="P")
            theta_Perr_sub = freqPower(Perr,freqmin,freqmax,[2:Perr.nbchan],[1:Perr.trials]);
            theta_Perr = [theta_Perr, theta_Perr_sub];
            trials_Perr = [trials_Perr, Perr.trials];
        end
        
    end                
end

%% Estimated marginal means
theta_Corr = mean(trials_corr.*theta_Corr,2)/mean(trials_corr);
theta_Serr = mean(trials_Serr.*theta_Serr,2)/mean(trials_Serr);
theta_Perr = mean(trials_Perr.*theta_Perr,2)/mean(trials_Perr);
%% Topographic plots

figure
if exist('Perr')
    subplot(1,3,1)
else
    subplot(1,2,1)
end
topoplot(mean(theta_Corr,2), corr.chanlocs(2:16), 'maplimits',topo_plots_lim, 'plotrad', 0.53)
title('Correct letters','FontSize', 24)
cbarHandle = colorbar;
set(get(cbarHandle, 'title'), 'string', '(dB)')
if exist('Perr') 
    subplot(1,3,2)
else
    subplot(1,2,2)
end
topoplot(mean(theta_Serr,2), Serr.chanlocs(2:16), 'maplimits',topo_plots_lim, 'plotrad', 0.53)
title('System errors','FontSize', 24)
cbarHandle = colorbar;
set(get(cbarHandle, 'title'), 'string', '(dB)')
if exist('Perr')
    subplot(1,3,3)
    topoplot(mean(theta_Perr,2), Perr.chanlocs(2:16), 'maplimits',topo_plots_lim, 'plotrad', 0.53)
    title('Participant errors','FontSize', 24)
    cbarHandle = colorbar;
    set(get(cbarHandle, 'title'), 'string', '(dB)')
end
if group == "S"
    sgtitle('Non-autistic','FontSize', 20);
else
    sgtitle('Autistic','FontSize', 20);
end
