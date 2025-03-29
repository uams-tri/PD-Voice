We have been exploring the use of voice spectra collected from people with Parkinson’s Disease (PwPD) and healthy controls (HC) to correctly diagnose PwPD.  This work is described in the following Nature Scientific Reports papers:

Iyer A, Kemp A, Rahmatallah Y, Pillai L, Glover A, Prior F, Larson-Prior L, Virmani T. A machine learning method to process voice samples for identification of Parkinson’s disease. Scientific reports. 2023 Nov 23;13(1):20615.

Rahmatallah Y, Kemp AS, Iyer A, Pillai L, Larson-Prior LJ, Virmani T, Prior F. Pre-trained convolutional neural networks identify Parkinson’s disease from spectrogram images of voice samples. Scientific Reports. 2025 Mar 1;15(1):7337.

Spectra are produced from voice recordings of study participants who enunciate a sustained vowel /a/. Participant voice recordings for data from the University of Arkansas for Medical Sciences are available from figshare as “Voice Samples for Patients with Parkinson’s Disease and Healthy controls”, https://doi.org/10.6084/m9.figshare.23849127. Institutional IRB and regulatory affairs decisions equate the spectrogram images created from these files to a voice print which is protected health information and cannot be publicly shared.  Voice recordings from the mPower study are available from https://www.synapse.org/Synapse:syn4993293/wiki/247860.

These recordings are preprocessed to produce spectra images using the R code available in this repository:
1.	Create_LineaSpectrograms_UAMSdataset.R: Read WAV files, create linear-scale spectrograms, save images in jpg file format.
2.	Create_LineaSpectrograms_mPowerdataset.R: Read m4a files, convert to WAV files, create linear-scale spectrograms, save images in jpg file format.
3.	Create_MelSpectrograms_UAMSdataset.R: Read WAV files, create mel-scale spectrograms, save images in jpg file format.
4.	Create_MelSpectrograms_mPowerdataset.R: Read m4a files, convert to WAV files, create mel-scale spectrograms, save images in jpg file format.
There are code lines that require inserting proper paths to where the audio files (WAV or m4a format) have been saved and to where to save the generated spectrogram images. 
 
Spectra images are analyzed using the Inception_pd_detection_voice Jupyter notebook.  An Inception V3 CNN pretrained on Imagenet is adapted to this problem of extracting features from spectra images and classifying the speaker as either a healthy control or a Parkinson's disease patient. The original classification stage of the Inception model was replaced with four custom layers: batch normalization, 2 dense layers (1024 nodes, relu activation)and a final dense layer (2 classes, softmax activation) to create a multi-layer perceptron classifier stage. This classifier was trained using the data cited above to implement transfer learning. It is important to organize the spectra images into the directory structure required by the Keras ImageDataGenerator class when using the class_mode- 'categorical' option, i.e., the data_path points to a directory with 2 sub directories, one with Healthy Control spectra and one with PwPD spectra. (see https://vijayabhaskar96.medium.com/tutorial-image-classification-with-keras-flow-from-directory-and-generators-95f75ebe5720). This code was written for a MacBook Pro with a 10 core M1 processor and 32 GB of memory. The associated Anaconda environment is provided for reference, environment.yaml.
 
A Jupyter notebook containing the code used to extract acoustic features using Parselmouth a package that runs Praat in Python, PD_Parselmouth_mPower is also included. Praat can be found here:  PraatScripts on GitHub.  Our notebook measures pitch, standard deviation of pitch, harmonics-to-noise ratio (HNR), jitter, shimmer, and formants from the original .wav files. 
(https://github.com/drfeinberg/PraatScripts)

Finally, at the request of readers of our papers we have included pretrained models based on Mel scale spectra: UAMSMeldata2.h5 which was trained on the data published on figshare and mPowerMelData2Best.h5 which was trained on mPower data.
