%% EEG preprocessing
% Append words, filter, remove bad channels, remove bad ICA components, 
% interpolation of bad channels.

clear all
clc

%% 
for group = ["S", "P"]         % S = non-autistic; P = autistic
    for sub = [1:10]             %Subject
        
        dir = strcat('dados/',group,num2str(sub),'/online_data/');

        while ~isfile(strcat(dir,'data_preprocessed/filtered_channeLoc.set'))

            %%%%%%%%%%%%%%%%%%%% loading data and append words

            eeg = [];   
            for j = 1:22 % word number
                if exist(strcat(dir,'eeg_data/eeg_word',num2str(j),'.mat'))
                    disp(j)
                    word = pop_importdata('dataformat','matlab','data',...
                        strcat(dir,'eeg_data/eeg_word',num2str(j),'.mat'), 'srate',256);
                    ev = load(strcat(dir,'events/eeg_events_word',num2str(j),'.mat'));
                    word = pop_importevent(word, 'event', ev.events, 'fields', ...
                        {'type', 'latency'}, 'timeunit', NaN);
                    %Clean datasets
                    word = pop_select(word, 'time', ...
                        [double(word.event(1).latency/256-5) double(word.event(end).latency/256)]);
                    if ~(sub == 7 && group == "P")
                        if j==1
                            eeg = word;
                        else
                            eeg = pop_mergeset(eeg, word);
                        end
                    else
                        if j==2
                            eeg = word;
                        else
                            eeg = pop_mergeset(eeg, word);
                        end
                    end
                end
            end

            %Save dataset in file
            if ~exist(strcat(dir,'data_preprocessed/'))
               mkdir(strcat(dir,'data_preprocessed/'))
            end
            eeg = pop_saveset(eeg, 'filename', 'merged_words', 'filepath', ...
                char(strcat(dir,'data_preprocessed/')));

            %%%%%%%%%%%%%%%%%%%% filtering data and adding channel locations

            %Zero phase-shift filter: notch (47.5-52.5Hz) + band-pass (0.5-45Hz)
            eeg = pop_eegfiltnew(eeg, 'locutoff', 47.5, 'hicutoff',52.5, 'revfilt', 1);
            eeg = pop_eegfiltnew(eeg, 'locutoff', 0.5);
            eeg = pop_eegfiltnew(eeg, 'hicutoff', 45);

            %Add channel locations
            loc_dir = 'channel_locations.ced';
            eeg.chanlocs = readlocs(loc_dir);
            orig_locs = eeg.chanlocs;
            save('orig_locs.mat', 'orig_locs');

            %Save dataset in file
            eeg = pop_saveset(eeg, 'filename', 'filtered_channeLoc', 'filepath', ...
                char(strcat(dir,'data_preprocessed/')));
        end

        %% %%%%%%%%%%%%%%%%%%%% Removing bad channels 

        while ~isfile(strcat(dir,'data_preprocessed/without_badChannels.set'))

            eeg = pop_loadset('filename', 'filtered_channeLoc.set', 'filepath', ...
                char(strcat(dir,'data_preprocessed/')));

%             Bad channels
            pop_eegplot(eeg, 1, 0, 0)
            bad_channels = input("Which channels do you want to mark as BAD?" + ...
            "\n0=None\n1=FPZ\n2=FZ\n3=FC1\n4=FCZ\n5=FC2\n6=C3\n7=CZ\n8=C4\n9=CPZ" + ...
            "\n10=P3\n11=PZ\n12=P4\n13=P07\n14=POZ\n15=PO8\n16=OZ");
            bad_channels = 0;
            fprintf("bad_channels: ");
            disp(bad_channels);
            save(strcat(dir,'data_preprocessed/bad_channels.mat'), 'bad_channels');

            %Remove bad channels
            if bad_channels ~= 0
                eeg = pop_select(eeg, 'nochannel', bad_channels);
            end

            %Save dataset in file
            eeg = pop_saveset(eeg, 'filename', 'without_badChannels', 'filepath', ...
                char(strcat(dir,'data_preprocessed/')));

        end

        %% %%%%%%%%%%%%%%%%%%%% Running ICA

        while ~isfile(strcat(dir,'data_preprocessed/ICA.set'))

            eeg = pop_loadset('filename', 'without_badChannels.set', 'filepath', ...
                char(strcat(dir,'data_preprocessed/')));
            load(strcat(dir,'data_preprocessed/bad_channels.mat'));

            %ICA
            eeg = pop_runica(eeg, 'chanind', [2:eeg.nbchan], 'icatype', 'runica', ...
                'extended', 1); 

            %Save dataset in file
            eeg = pop_saveset(eeg, 'filename', 'ICA', 'filepath', ...
                char(strcat(dir,'data_preprocessed/')));

        end

        %% Remove bad ICA components (to remove artifacts/blinks)
        
        while ~isfile(strcat(dir,'data_preprocessed/ICA_clean.set'))
        
            eeg = pop_loadset('filename', 'ICA.set', 'filepath', ...
                char(strcat(dir,'data_preprocessed/')));
        
            %Reject bad ICA components
            eeg = pop_selectcomps(eeg, [1:15]); %[1:16]
            pop_eegplot(eeg, 0, 0, 0);
            pop_eegplot(eeg, 1, 0, 0)
            comp_rej = input("Which components do you want to reject?" +...
                " If none, enter 0");
            if comp_rej ~= 0
                eeg = pop_subcomp(eeg, comp_rej, 1, [0]);
            end
        
             %Save dataset in file
            eeg = pop_saveset(eeg, 'filename', 'ICA_clean', 'filepath', ...
                char(strcat(dir,'data_preprocessed/')));
        
        end
        %% %%%%%%%%%%%%%%%%%%%% Interpolate bad channels
        
        while ~isfile(strcat(dir,'data_preprocessed/interp.set'))
        
            eeg = pop_loadset('filename', 'ICA_clean.set', 'filepath', ...
                char(strcat(dir,'data_preprocessed/')));
        
            load(strcat(dir, 'data_preprocessed/bad_channels.mat'));
            load("orig_locs.mat");
        
            %Interpolation of previously removed channels
            if bad_channels ~= 0
                eeg = interpol(eeg, orig_locs, 'spherical');
            end
        
            %Save dataset in file
            eeg = pop_saveset(eeg, 'filename', 'interp', 'filepath', ...
                char(strcat(dir,'data_preprocessed/')));
        
        end
    end
end
