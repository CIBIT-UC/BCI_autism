%% ========== DATA FOR LINEAR MIXED-EFFECTS MODEL: PRE-RESPONSE ===========

% Export data to spss to compare frequency power during pre-response
% between groups (non-autistic and autistic)

clear all
clc 
%%
dir = "C:\toolbox\Code_Speller_Reverse\data\";
age_sex = readtable('C:\toolbox\Code_Speller_Reverse\data\age_sex.xlsx');

group = ["S","P"];            % S = control; P = participante with ASD
%% Parameters
channels = [4,14];%4; %FCz e POz
freq_min = [4,8]; %Theta (4) and alpha (8)
prep_time = [-2.8 0];
inst_time = [0 2];
encod_time = [2 8];
periods = 3; % Preparation, instruction, encoding
%%
i = 1;
for g=1:length(group)
    for sub = [1:10]            %Subjects  

        if exist(char(strcat(dir, group(g), num2str(sub), '\online_data\epochs\7_preResponse.set')))

            preresp_5 = pop_loadset('filename', '5_preResponse.set', 'filepath', ...
                char(strcat(dir, group(g), num2str(sub), '\online_data\epochs\')));
            preresp_7 = pop_loadset('filename', '7_preResponse.set', 'filepath', ...
                char(strcat(dir, group(g), num2str(sub), '\online_data\epochs\')));
            
            prep5 = pop_epoch(preresp_5, {'5_cue', '5_cue_err'}, prep_time);
            prep7 = pop_epoch(preresp_7, {'7_cue', '7_cue_err'}, prep_time);
            
            inst5 = pop_epoch(preresp_5, {'5_cue', '5_cue_err'}, inst_time);
            inst7 = pop_epoch(preresp_7, {'7_cue', '7_cue_err'}, inst_time);

            encod5 = pop_epoch(preresp_5, {'5_cue', '5_cue_err'}, encod_time);
            encod7 = pop_epoch(preresp_7, {'7_cue', '7_cue_err'}, encod_time);
            
            urevent_5 = struct2table(preresp_5.event);
            urevent_7 = struct2table(preresp_7.event);
            
            events_time_5 = urevent_5.urevent(urevent_5.type == "5_cue" | urevent_5.type == "5_cue_err");
            events_time_7 = urevent_7.urevent(urevent_7.type == "7_cue" | urevent_7.type == "7_cue_err");
            events_time = sort([events_time_5' events_time_7']);
            
            trials_5 = find(ismember(events_time, events_time_5));
            trials_7 = find(ismember(events_time, events_time_7));

            for t = 1:preresp_5.trials+preresp_7.trials

                for p = 1:periods

                    if t<=preresp_5.trials
                        tt=t;
                        freq_power{i,1} = trials_5(tt);                %Trial number
                    else
                        t2=t-preresp_5.trials;
                        tt=t2;
                        freq_power{i,1} = trials_7(tt);
                    end

                    if freq_power{i,1}<6                   %Stage
                        freq_power{i,2} = 1;
                    elseif freq_power{i,1}<11
                        freq_power{i,2} = 2;
                    elseif freq_power{i,1}<16
                        freq_power{i,2} = 3;
                    else
                        freq_power{i,2} = 4;
                    end

                    freq_power{i,3} = g;                    %Group
                    freq_power{i,4} = (g-1)*10+sub;         %Participant id

                    freq_power{i,5} = age_sex.Age(find(age_sex.Participant_id==freq_power{i,4})); %Age
                    freq_power{i,6} = age_sex.Sex(find(age_sex.Participant_id==freq_power{i,4})); %Sex

                    if t<=preresp_5.trials
                        freq_power{i,7} = 1;                    %Cognitive load: 1 = 5-letter pseudoword; 2 = 7-letter pseudoword
                    else
                        freq_power{i,7} = 2;
                    end

                    if p == 1 && t<=preresp_5.trials
                        preResp = prep5;
                    elseif p == 1 && t>preresp_5.trials
                        preResp = prep7;
                    elseif p == 2 && t<=preresp_5.trials
                        preResp = inst5;
                    elseif p == 2 && t>preresp_5.trials
                        preResp = inst7;
                    elseif p == 3 && t<=preresp_5.trials
                        preResp = encod5;
                    else
                        preResp = encod7;
                    end

                    if preResp.event(tt).type == "5_cue" || preResp.event(tt).type == "7_cue" || ...
                            ((preResp.event(1).type == "5_imag" || preResp.event(1).type == "7_imag") && ...
                            freq_power{i-1,8} == 1)
                        freq_power{i,8} = 1;        %Performance: 1 = correct; 2 = error
                    else
                        freq_power{i,8} = 2; 
                    end
                    
                    freq_power{i,9} = p; % pre-response period
                    
                    col=10;
                    for f=freq_min
                        for ch = channels
                            freq_power{i,col} = freqPower(preResp, f, f+4, ch, tt); %Power
                            col=col+1;
                        end
                    end
                    
                    i = i+1;
                    
                end
            end                       
        end   
    end
end

%% Save file
freq_power_table = cell2table(freq_power, 'VariableNames', ...
    {'Trial'; 'Stage'; 'Group'; 'Participant'; 'Age'; 'Sex'; 'Cognitive_load'; ...
    'Performance'; 'Period'; 'Power_theta_FCz'; 'Power_theta_POz'; 'Power_alpha_FCz'; 'Power_alpha_POz'});

writetable(freq_power_table, ...
    'C:\toolbox\Code_Speller_Reverse\results\SPSS_data\preResponse_LMM.xlsx');
