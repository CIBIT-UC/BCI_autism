Code repository for data analysis used in the study [A role for preparatory midfrontal theta in autism as revealed by a high executive load brain–computer interface reverse spelling task](https://www.nature.com/articles/s41598-025-00670-7).

Language: MATLAB R2018b

# Folders

**Behavioural and BCI feasibility analysis (Feasibility_analysis)**
- partErrorRate_mixedModel.m: Export data to a file to compare participants' error rate between groups considering cognitive load and practice/learning effects.
- BCIsystem_errorRate.m: Export data to a file to compare BCI system error rate between groups considering practice/learning effects.

**EEG preprocessing (EEG_preprocessing)**
- eeg_preprocessing.m: EEG data pre-processing. **Requirements**: EEGLAB.

**EEG data analysis (EEG_data_analysis)**
- preResponse_epochs_topoPlots.m: Create EEG epochs and generate topographic maps of power distribution during pre-response.
- feedbackLetter_epochs_topoPlots.m: Create EEG epochs and generate topographic maps of power distribution following response feedback.
- preResponse_mixedModel.m: Export data to compare frequency power during pre-response between groups considering performance, cognitive load, practice/learning effects and distinct task periods.
- feedbackLetter_mixedModel.m: Export data to compare frequency power during pre-response between groups considering performance and practice/learning effects.

**Statistical analysis (stats_SPSS)**
- partErrorRate_stats.sps: 
- preResponse_thetaFCz_stats.sps:
- preResponse_thetaPOz_stats.sps:
- preResponse_alphaFCz_stats.sps:
- preResponse_alphaPOz_stats.sps:
- feedback_thetaFCz_stats.sps:
- feedback_thetaPOz_stats.sps:
- feedback_alphaFCz_stats.sps:
- feedback_alphaPOz_stats.sps:
**Requirements**: SPSS V27.
