%% Save epochs and generate topographic maps of power distribution - Pre-response

clear all
clc

group = ["S","P"];            % S = non-autistic; P = autistic
dir = "C:\toolbox\Code_Speller_Reverse\data\";

%% Parameters
cond_names = ['5', '7'];
epochs_time = [-2.8 8]; 
prep_time = [-2.8 0];
inst_time = [0 2];
encod_time = [2 8];
topo_plots_lim = [0 4]; %dB
freqmin=4; % Min frequency (theta: 4 Hz, alpha: 8 Hz)
freqmax=8; % Max frequency (theta: 8 Hz, alpha: 12 Hz)
%%
power_a=[];
power_na=[];
trials_a=[];
trials_na=[];

power_prep_na = [];
power_inst_na = [];
power_encod_na = [];
power_prep_a = [];
power_inst_a = [];
power_encod_a = [];
%% 
for g=group
    for sub = 1:10            %Subjects

        if exist(char(strcat(dir, g, num2str(sub), '\online_data\data_preprocessed\interp.set'))) %&&...
            
            % Create epochs
            if ~exist(char(strcat(dir, g, num2str(sub), '\online_data\epochs\7_preResponse.set')))

                %Load data
                eeg = pop_loadset('filename', 'interp.set', 'filepath', ...
                    char(strcat(dir, g, num2str(sub), '\online_data\data_preprocessed\')));

                word_eval = find(contains(string(char(eeg.event.type)),"finalWord"));
                cue = find(contains(string(char(eeg.event.type)),"cue"));

                %Distinguish between pre-response time for correct (correct + system
                %errors) and incorrect words (participant errors) for each condition
                for i=1:length(word_eval)
                    if contains(eeg.event(word_eval(i)).type, "errP") || ...
                            contains(eeg.event(word_eval(i)).type, "errPS")
                        eeg.event(cue(i)).type = char(strcat(eeg.event(cue(i)).type, "_err"));
                    end
                end

                %Pre-response time after reading the word cue
                preResp_5 = pop_epoch(eeg, {'5_cue', '5_cue_err'}, epochs_time); % 5-letter pseudowords
%                 preResp_5 = pop_rmbase(preResp_5, baseline); % Remove baseline
                preResp_7 = pop_epoch(eeg, {'7_cue', '7_cue_err'}, epochs_time); % 7-letter pseudowords
%                 preResp_7 = pop_rmbase(preResp_7, baseline); % Remove baseline

                %Create directory to save dataset in file
                if ~exist(strcat(dir, g, num2str(sub), '\online_data\epochs\'))
                   mkdir(strcat(dir, g, num2str(sub), '\online_data\epochs\'))
                end

                conditions = [preResp_5, preResp_7];

                for i=1:length(conditions)

                    %Epochs rejection
                    EEG_epochs = pop_eegthresh(conditions(i), 1, [2:length(eeg.chanlocs)], ...
                        -100, 100, -3, 8, 0, 0);
                    fprintf('Epochs rejected automatically: ');
                    disp(find(EEG_epochs.reject.rejthresh == 1));
                    pop_eegplot(EEG_epochs, 1, 1, 0);
                    epochs_rej = input("Which epochs do you want to reject? If none, enter 0");
                    if epochs_rej ~= 0
                        EEG_epochs = pop_rejepoch(EEG_epochs, epochs_rej, 0);
                    end

                    %Save dataset in file
                    EEG_epochs = pop_saveset(EEG_epochs, 'filename', ...
                        char(strcat(cond_names(i), '_preResponse')), 'filepath', ...
                        char(strcat(dir, g, num2str(sub), '\online_data\epochs\')));
                    if i==1
                        preResp_5 = EEG_epochs;
                    elseif i==2
                        preResp_7 = EEG_epochs;
                    end
                end
            else
                
                % Load already existing epochs
                preResp_5 = pop_loadset('filename', '5_preResponse.set', 'filepath', ...
                    char(strcat(dir, g, num2str(sub), '\online_data\epochs\')));
                preResp_7 = pop_loadset('filename', '7_preResponse.set', 'filepath', ...
                    char(strcat(dir, g, num2str(sub), '\online_data\epochs\')));

                preResp = pop_mergeset(preResp_5, preResp_7);
                power_sub = freqPower(preResp, freqmin, freqmax,[2:preResp.nbchan],[1:preResp.trials]);
                
                % Comparison between groups
                
                if g=="S"
                    power_na = [power_na, power_sub];
                    trials_na = [trials_na, preResp.trials];
                else
                    power_a = [power_a, power_sub];
                    trials_a = [trials_a, preResp.trials];
                end
                
                % Pre-response periods (preparation, instruction, encoding)
                prep = pop_epoch(preResp, ...
                   {'5_cue', '5_cue_err', '7_cue', '7_cue_err'}, prep_time);
                inst = pop_epoch(preResp, ...
                   {'5_cue', '5_cue_err', '7_cue', '7_cue_err'}, inst_time);
                encod = pop_epoch(preResp, ...
                   {'5_cue', '5_cue_err', '7_cue', '7_cue_err'}, encod_time);
               
                power_prep_sub = freqPower(prep, freqmin, freqmax, ...
                    [2:preResp.nbchan],[1:preResp.trials]);
                power_inst_sub = freqPower(inst, freqmin, freqmax, ...
                    [2:preResp.nbchan],[1:preResp.trials]);
                power_encod_sub = freqPower(encod, freqmin, freqmax, ...
                    [2:preResp.nbchan],[1:preResp.trials]);
                
                if g=="S"
                    power_prep_na = [power_prep_na, power_prep_sub];
                    power_inst_na = [power_inst_na, power_inst_sub];
                    power_encod_na = [power_encod_na, power_encod_sub];
                else
                    power_prep_a = [power_prep_a, power_prep_sub];
                    power_inst_a = [power_inst_a, power_inst_sub];
                    power_encod_a = [power_encod_a, power_encod_sub];
                end
                
            end
        end
    end
end
%% Estimated marginal means
power_na = mean(trials_na.*power_na,2)/mean(trials_na);
power_a = mean(trials_a.*power_a,2)/mean(trials_a);

power_prep_na = mean(trials_na.*power_prep_na,2)/mean(trials_na);
power_inst_na = mean(trials_na.*power_inst_na,2)/mean(trials_na);
power_encod_na = mean(trials_na.*power_encod_na,2)/mean(trials_na);

power_prep_a = mean(trials_a.*power_prep_a,2)/mean(trials_a);
power_inst_a = mean(trials_a.*power_inst_a,2)/mean(trials_a);
power_encod_a = mean(trials_a.*power_encod_a,2)/mean(trials_a);

%% Topographic plots

% Groups
figure
subplot(1,2,1)
topoplot(mean(power_na,2), preResp.chanlocs(2:16),'maplimits',topo_plots_lim, 'plotrad', 0.53)
title('Non-autistic','FontSize', 16)
cbarHandle = colorbar;
set(get(cbarHandle, 'title'), 'string', '(dB)')
subplot(1,2,2)
topoplot(mean(power_a,2), preResp.chanlocs(2:16),'maplimits',topo_plots_lim, 'plotrad', 0.53)
title('Autistic','FontSize', 16)
cbarHandle = colorbar;
set(get(cbarHandle, 'title'), 'string', '(dB)')

% Pre-response periods - non-autistic group
figure
subplot(1,3,1)
topoplot(power_prep_na, preResp.chanlocs(2:16), ...
    'maplimits',topo_plots_lim, 'plotrad', 0.53)
title('Preparation','FontSize', 16)
cbarHandle = colorbar;
set(get(cbarHandle, 'title'), 'string', '(dB)')
subplot(1,3,2)
topoplot(power_inst_na, preResp.chanlocs(2:16), ...
    'maplimits',topo_plots_lim, 'plotrad', 0.53)
title('Instruction','FontSize', 16)
cbarHandle = colorbar;
set(get(cbarHandle, 'title'), 'string', '(dB)')
subplot(1,3,3)
topoplot(power_encod_na, preResp.chanlocs(2:16), ...
    'maplimits',topo_plots_lim, 'plotrad', 0.53)
title('Encoding','FontSize', 16)
cbarHandle = colorbar;
set(get(cbarHandle, 'title'), 'string', '(dB)')

% Pre-response periods - autistic group
figure
subplot(1,3,1)
topoplot(power_prep_a, preResp.chanlocs(2:16), ...
    'maplimits',topo_plots_lim, 'plotrad', 0.53)
title('Preparation','FontSize', 16)
cbarHandle = colorbar;
set(get(cbarHandle, 'title'), 'string', '(dB)')
subplot(1,3,2)
topoplot(power_inst_a, preResp.chanlocs(2:16), ...
    'maplimits',topo_plots_lim, 'plotrad', 0.53)
title('Instruction','FontSize', 16)
cbarHandle = colorbar;
set(get(cbarHandle, 'title'), 'string', '(dB)')
subplot(1,3,3)
topoplot(power_encod_a, preResp.chanlocs(2:16), ...
    'maplimits',topo_plots_lim, 'plotrad', 0.53)
title('Encoding','FontSize', 16)
cbarHandle = colorbar;
set(get(cbarHandle, 'title'), 'string', '(dB)')
