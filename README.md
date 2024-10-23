# Acoustic-classification
A species classification example with acoustic characters using machine learning methods was presented.
## Flow chart
<img src="https://github.com/TK-CamBaz/Acoustic-classification/blob/main/contents/Flowchart.png" width="400">

## Acoustic data collection
Six common species of crickets (_Gryllodes sigillatus_, _Homoeoxipha lycoides_, _Loxoblemmus appendicularis_, _Tarbinskiellus portentosus_, _Teleogryllus mitratus_, and _T. occipitalis_) in Taiwan were selected because they are easy to collect and rear. The sound of the crickets was recorded using a smartphone (Samsung Galaxy A52) in an indoor environment to minimize noise interference. Audacity (https://audacityteam.org/), a free sound analysis software, was used to extract the chirps in the sound files. Partial chirps WAV files were provided in "exampledata".  

## Data inspection
The chirps were inspected by the spectrograms and oscillograms (see figure below). The spectrogram porvides a view of amplitude and frequency over time, and the oscillogram depicts the relationship between amplitude and time. Among these figures, the shape of sound waves and pattern of frequency distribution are distinct.

<img src="https://github.com/TK-CamBaz/Acoustic-classification/blob/main/contents/Spectrogram_oscillogram.png" width="400">

## MFCC extraction and visualization
To quantify the sound data, MFCC (Mel-scale Frequency Cepstral Coefficients) was used to extrat useful imformation for building classifiers. The function _melfcc()_ in package tuneR was implemented to calculate MFCC.  

The MFCC data were visualized to gain a comrehensive insight of the difference among the six species. Due to the high dimension of the data, Principal Component Analysis (PCA) and t-stochastic neighboring embedding (t-SNE) were used to reduce the complexity of data, helping to visualize the difference.

<img src="https://github.com/TK-CamBaz/Acoustic-classification/blob/main/contents/Visualization.png" width="400">

## Model training
Machine learning , as a popular technique in AI, has been introduced to various fields. Here, multinomial logistic regression (MLR), decesion tree (DT), random forest (RF), naive bayes classifier (NB) and support vector machine (SVM) were selected to build classifiers. 

## Performance evaluation
Results showed that SVM outperformed other classifiers with accuracy 100% in training, testing and mixed dataset. Based on this experiment, SVM and RF are suggested as recommended models.

<img src="https://github.com/TK-CamBaz/Acoustic-classification/blob/main/contents/Model_performance.png" width="400">

## Reference
https://www.wildlifeacoustics.com/resources/blog/oscillogram-vs-spectrogram-understanding-basic-sound-visualization-in-bioacoustics-research  
https://rug.mnhn.fr/seewave/  

