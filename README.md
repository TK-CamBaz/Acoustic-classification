# Acoustic-classification
A species classification example with acoustic characters using machine learning methods was presented. This approch can be apply to other creatures or soundscape analysis.
## Flow chart
![](https://github.com/TK-CamBaz/Acoustic-classification/blob/main/flowchart.png =250x250)
## Materials and Methods
### Acoustic data collection
Chirps of six species of crickets (_Gryllodes sigillatus_, _Homoeoxipha lycoides_, _Loxoblemmus appendicularis_, _Tarbinskiellus portentosus_, _Teleogryllus mitratus_ and _T. occipitalis_) were selected because they are common and easy to find and collect. Sound recording was conducted using a smartphone (Samsung Galaxy A52), and Audacity (https://audacityteam.org/), a free sound analysis software was used to check if files were corrupted.
### Data preprocessing
To quantify the sound data, MFCC (Mel-scale Frequency Cepstral Coefficients) was used to extrat useful imformation for building classifiers. The function _melfcc()_ in package tuneR was implemented to calculate MFCC. Due to the high dimension of processed data, PCA (Principal Component Analysis) was used to reduce the complexity of data, helping to visualize the difference of sound among six crickets.
![image](https://github.com/TK-CamBaz/Acoustic-classification/blob/main/PCA%20plot.png)
### Model training

### Performance comparison
