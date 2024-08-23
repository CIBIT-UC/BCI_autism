%% ====== DATA FOR LINEAR MIXED-EFFECTS MODEL: PARTICIPANTS' PERFORMANCE ======

% Export data to spss to compare participants' error rate between groups 
%(non-autistic and autistic) considering 2 cognitive/memory load levels 
% (5- and 7-letter pseudowords) and practice/learning stage (initial,
% intermidiate 1 and 2, and final).

clear all
clc 
%% 
file = readtable('C:\toolbox\Code_Speller_Reverse\results\behavioral_results.xlsx');
age_sex = readtable('C:\toolbox\Code_Speller_Reverse\data\age_sex.xlsx');
%% 
ii=1;
for group=["S","P"]
    for sub=1:10
        for cl = [5,7]
            for stage = 1:4 
                
                mixed_model{ii,1} = group;
                mixed_model{ii,2} = sub; % Subject
                mixed_model{ii,3} = cl;  % Cognitive load
                mixed_model{ii,4} = stage;  % Learning/Practice stage
                
                if stage == 1
                    trials=[2:6];
                elseif stage == 2
                    trials=[7:11];
                elseif stage == 3
                    trials=[12:16];
                else
                    trials = [17:21];
                end
                
                idx = find(file.Participant==sub & file.Group==group & file.Cog_load==cl & ismember(file.Trial,trials));
                
                mixed_model{ii,5} = mean(file.Part_err(idx)./file.Total_letters(idx));
                
                if group=="S"
                    mixed_model{ii,6} = age_sex.Age(find(age_sex.Participant_id==sub));
                    mixed_model{ii,7} = age_sex.Sex(find(age_sex.Participant_id==sub));
                else
                    mixed_model{ii,6} = age_sex.Age(find(age_sex.Participant_id==sub+10));
                    mixed_model{ii,7} = age_sex.Sex(find(age_sex.Participant_id==sub+10));
                end
                
                ii = ii+1;
                
            end
        end
        
    end
end
%% 
mixed_model = array2table(mixed_model, 'VariableNames',{'Group','Participant','Cog_load','Learning_stage','Error_rate','Age','Sex'});

writetable(mixed_model, ...
    'C:\toolbox\Code_Speller_Reverse\results\behavioral_results_mixed_model2.xlsx');

