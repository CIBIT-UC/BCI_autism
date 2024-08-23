%% ======== DATA FOR LINEAR MIXED-EFFECTS MODEL: RESPONSE FEEDBACK ========

% Export data to spss to compare frequency power during response feedback
% between groups (non-autistic and autistic)

clear all;clc;close all
%% 
dir = "C:\toolbox\Code_Speller_Reverse\data\";
age_sex = readtable('C:\toolbox\Code_Speller_Reverse\data\age_sex.xlsx');

group = ["S","P"];            % S = non-autistic; P = autistic

channels = [4,14]; %FCz (4) e POz (14)
freq_min = [4,8];% Theta (4), alpha (8)
time = [0 1];
%%
i = 1;
for g=1:length(group)
    for sub = [1:10]            %Subjects  

        if exist(char(strcat(dir, group(g), num2str(sub), '\online_data\epochs\feedbackLetter_corr.set')))

            corr = pop_loadset('filename', 'feedbackLetter_corr.set', 'filepath', ...
                char(strcat(dir, group(g), num2str(sub), '\online_data\epochs\')));
            corr = pop_epoch(corr, {'5_Corr', '7_Corr'}, time);

            Serr = pop_loadset('filename', 'feedbackLetter_Serr.set', 'filepath', ...
                char(strcat(dir, group(g), num2str(sub), '\online_data\epochs\')));
            Serr = pop_epoch(Serr, {'5_Err_syst', '7_Err_syst'}, time);

            events_corr = struct2table(corr.event);
            events_Serr = struct2table(Serr.event);

            events_time_corr = events_corr.urevent(events_corr.type == "5_Corr" | events_corr.type == "7_Corr");
            events_time_Serr = events_Serr.urevent(events_Serr.type == "5_Err_syst" | events_Serr.type == "7_Err_syst");
            events_time = sort([events_time_corr' events_time_Serr']);

            conditions = [corr, Serr];

            if exist(char(strcat(dir, group(g), num2str(sub), '\online_data\epochs\feedbackLetter_Perr.set')))

                Perr = pop_loadset('filename', 'feedbackLetter_Perr.set', 'filepath', ...
                    char(strcat(dir, group(g), num2str(sub), '\online_data\epochs\')));
                Perr = pop_epoch(Perr, {'5_Err_part', '7_Err_part'}, time);

                events_Perr = struct2table(Perr.event);
                events_time_Perr = events_Perr.urevent(events_Perr.type == "5_Err_part" | events_Perr.type == "7_Err_part");
                events_time = sort([events_time events_time_Perr']);
                trials_Perr = find(ismember(events_time, events_time_Perr));

                conditions = [conditions, Perr];

            end

            trials_corr = find(ismember(events_time, events_time_corr));
            trials_Serr = find(ismember(events_time, events_time_Serr));

            for c = 1:length(conditions)

                events = struct2table(conditions(c).event);

                for t = 1:conditions(c).trials

                    %Trial id
                    if c==1
                        freq_power{i,1} = trials_corr(t);     
                    elseif c==2
                        freq_power{i,1} = trials_Serr(t); 
                    else
                        freq_power{i,1} = trials_Perr(t); 
                    end

                    if freq_power{i,1}<31                   %Stage
                        freq_power{i,2} = 1;
                    elseif freq_power{i,1}<61
                        freq_power{i,2} = 2;
                    elseif freq_power{i,1}<91
                        freq_power{i,2} = 3;
                    else
                        freq_power{i,2} = 4;
                    end

                    freq_power{i,3} = g;                    %Group
                    freq_power{i,4} = (g-1)*10+sub;         %Participant id

                    freq_power{i,5} = age_sex.Age(find(age_sex.Participant_id==freq_power{i,4})); %Age
                    freq_power{i,6} = age_sex.Sex(find(age_sex.Participant_id==freq_power{i,4})); %Sex

                    %Cognitive load: 1 = 5 letter-pseudowords; 2 = 7 letter-pseudowords
                    if any("epoch" == string(events.Properties.VariableNames))
                        if string(events.type(find(events.epoch==t,1))) == "5_Corr" || ...
                                string(events.type(find(events.epoch==t,1))) == "5_Err_syst" || ...
                                string(events.type(find(events.epoch==t,1))) == "5_Err_part"
                            freq_power{i,7} = 1;                
                        elseif string(events.type(find(events.epoch==t,1))) == "7_Corr" || ...
                                string(events.type(find(events.epoch==t,1))) == "7_Err_syst" || ...
                                string(events.type(find(events.epoch==t,1))) == "7_Err_part"
                            freq_power{i,7} = 2;               
                        end
                    else
                        if events.type == "5_Corr" || events.type == "5_Err_syst" || events.type == "5_Err_part"
                            freq_power{i,7} = 1;
                        elseif events.type == "7_Corr" || events.type == "7_Err_syst" || events.type == "7_Err_part"
                            freq_power{i,7} = 2;  
                        end
                    end

                    freq_power{i,8} = c;        %Performance: 1 = correct; 2 = system error; 3 = participant error
                    
                    col=9;
                    for f=freq_min
                        for ch = channels
                            freq_power{i,col} = freqPower(conditions(c), f, f+4, ch, t); %Power
                            col=col+1;
                        end
                    end

                    i=i+1;

                end
            end
        end   
    end
end

%% Save file
freq_power_table = cell2table(freq_power, 'VariableNames', ...
    {'Trial'; 'Stage'; 'Group'; 'Participant_id'; 'Age'; 'Sex'; 'Cognitive_load'; ...
    'Performance'; 'Power_theta_FCz'; 'Power_theta_POz'; 'Power_alpha_FCz'; 'Power_alpha_POz'});

writetable(freq_power_table, ...
    strcat('C:\toolbox\Code_Speller_Reverse\results\SPSS_data\feedbackLetter_LMM.xlsx'));
