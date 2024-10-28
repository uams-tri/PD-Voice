We have been exploring the use of voice spectra collected from people with Parkinson’s Disease (PwPD) and healthy controls (HC) to correctly diagnose PwPD.  This work is described in the following Nature Scientific Reports paper:

Iyer A, Kemp A, Rahmatallah Y, Pillai L, Glover A, Prior F, Larson-Prior L, Virmani T. A machine learning method to process voice samples for identification of Parkinson’s disease. Scientific reports. 2023 Nov 23;13(1):20615.

Spectra are produced from voice recordings of study participants who enunciate a sustained vowel /a/. These recordings are preprocessed to produce spectra images using the R packages available in this repository:
1.	Create_LineaSpectrograms_UAMSdataset.R: Read WAV files, create linear-scale spectrograms, save images in jpg file format.
2.	Create_LineaSpectrograms_mPowerdataset.R: Read m4a files, convert to WAV files, create linear-scale spectrograms, save images in jpg file format.
3.	Create_MelSpectrograms_UAMSdataset.R: Read WAV files, create mel-scale spectrograms, save images in jpg file format.
4.	Create_MelSpectrograms_mPowerdataset.R: Read m4a files, convert to WAV files, create mel-scale spectrograms, save images in jpg file format.
There are code lines that require inserting proper paths to where the audio files (WAV or m4a format) have been saved or to where to save the generated spectrogram images. Audio files of the UAMS dataset are available at https://doi.org/10.6084/m9.figshare.23849127. Audio files of the mPower dataset can be downloaded from the Synapse database at https://www.synapse.org/Synapse:syn4993293/wiki/247860 after applying for access.
 
Spectra images are analyzed using the Inception_pd_detection_voice Jupyter notebook.  An Inception V3 CNN pretrained on Imagenet is adapted to this problem of extracting features from spectra images using transfer learning. It is important to organize the spectra images into the file structure required by Keras ImageDataGenerator class, i.e., the data_path points to a directory with 2 sub directories, one with Healthy Control spectra and one with PwPD spectra. (see https://vijayabhaskar96.medium.com/tutorial-image-classification-with-keras-flow-from-directory-and-generators-95f75ebe5720)  A classifier stage was added to replace the one that comes with the Keras module.  This code was written for a MacBook Pro with a 10 core M1 processor and 32 GB of memory. The associated Anaconda environment is provided for reference, environment.yaml.
 
The final component of this software package is a Jupyter notebook containing the code used to extract acoustic features using Parselmouth a package that runs Praat in Python, PD_Parselmouth_mPower. Praat can be found here:  PraatScripts on GitHub.  Our notebook measures pitch, standard deviation of pitch, harmonics-to-noise ratio (HNR), jitter, shimmer, and formants from the original .wav files. 
(https://github.com/user-attachments/assets/9dfdce11-ef61-4e2f-a5be-5e4f04c0f148)
