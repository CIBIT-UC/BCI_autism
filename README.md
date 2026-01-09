Code repository for data analysis used in the study [“A role for preparatory midfrontal theta in autism as revealed by a high executive load brain–computer interface reverse spelling task.”](https://www.nature.com/articles/s41598-025-00670-7).

**Behavioural and BCI feasibility analysis**
- partErrorRate_mixedModel.m: Export data to a file to compare participants' error rate between groups considering cognitive load and practice/learning effects.
- BCIsystem_errorRate.m: Export data to a file to compare BCI system error rate between groups considering practice/learning effects.

**EEG preprocessing**
- eeg_preprocessing.m: EEG data pre-processing. **Requirements**: EEGLAB.

**EEG data analysis**
- preResponse_epochs_topoPlots.m: Create EEG epochs and generate topographic maps of power distribution during pre-response.
- feedbackLetter_epochs_topoPlots.m: Create EEG epochs and generate topographic maps of power distribution following response feedback.
- preResponse_mixedModel.m: Export data to compare frequency power during pre-response between groups considering performance, cognitive load, practice/learning effects and distinct task periods.
- feedbackLetter_mixedModel.m: Export data to compare frequency power during pre-response between groups considering performance and practice/learning effects.
