%% ================= BCI system error rate =================

% Export file to perform a mixed-ANOVA using spss to evaluate the impact of
% group (non-autistic and autistic), practice/learning stage (initial,
% intermidiate 1 and 2, and final), and respective interaction on BCI error
% rate.

clear all
clc 
%% 
file = readtable('C:\toolbox\Code_Speller_Reverse\results\behavioral_results.xlsx');
age_sex = readtable('C:\toolbox\Code_Speller_Reverse\data\age_sex.xlsx');
%% 
ii=1;
for group=["S","P"]
    
    for sub=1:10
        
        spss_file{ii,1} = group;
        
        for stage = 1:4 
            
            if stage == 1
                trials=[2:6];
            elseif stage == 2
                trials=[7:11];
            elseif stage == 3
                trials=[12:16];
            else
                trials = [17:21];
            end
            
            idx = find(file.Participant==sub & file.Group==group & ismember(file.Trial,trials));
            spss_file{ii,1+stage} = mean(file.Syst_err(idx)./file.Total_letters(idx));
            
        end
        
        if group=="S"
            spss_file{ii,6} = age_sex.Age(find(age_sex.Participant_id==sub));
            spss_file{ii,7} = age_sex.Sex(find(age_sex.Participant_id==sub));
        else
            spss_file{ii,6} = age_sex.Age(find(age_sex.Participant_id==sub+10));
            spss_file{ii,7} = age_sex.Sex(find(age_sex.Participant_id==sub+10));
        end
        
        ii=ii+1;
        
    end
    
end
%% 
spss_file = array2table(spss_file, 'VariableNames',{'Group','Syst_1','Syst_2','Syst_3','Syst_4','Age','Sex'});

writetable(spss_file, ...
    'C:\toolbox\Code_Speller_Reverse\results\BCI_errorRate.xlsx');
