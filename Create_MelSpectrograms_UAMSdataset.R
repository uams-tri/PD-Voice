#############################################################################
# R code to generate Mel-scale spectrogram images from the UAMS audio files #
#############################################################################

# Copyright (C) 2024 University of Arkansas for Medical Sciences
# Author: Yasir Rahmatallah, yrahmatallah@uams.edu
# Licensed under the Apache License, Version 2.0

# Code was tested using R version 4.1.2, and the following package versions:
# av_0.8.3, tuneR_1.4.0, oce_1.7-8, signal_0.7-7, viridis_0.6.2, torchaudio_0.3.1                    

library(av)
library(tuneR)
library(oce)
library(signal)
library(viridis)
library(torchaudio)

# function to trim silence parts in the UAMS audi files
trim_ends <- function(x, w=512, thr=0.5){
len <- length(x)
env <- numeric(length=len-w)
for(k in 1:(len-w))
	{
	env[k] <- sum(x[k:(k+w)]^2)
	}
ind <- which(env > thr)
st <- ind[1]
en <- tail(ind, n=1)
return(c(st, en))
}

which.group <- "PwPD" # one of "PwPD" or "HC"
time.limit <- 1.5 # in seconds
file_audio_path <- "path to where the wav files of PwPD or HC were saved"

# find the names of wav files in the selected folder
fL <- list.files(path=file_audio_path, pattern=".wav$")
# remove '.wav' from the end of file names
fL <- gsub(fL, pattern=".wav", replacement="")

# start a loop
for(file.name in fL){
file <- paste(file_audio_path, file.name, ".wav", sep="")
train_audio <- readWave(file)
audio.nor <- tuneR::normalize(train_audio, unit="32", pcm=FALSE)
x <- audio.nor@left
fs <- train_audio@samp.rate
duration <- length(x) / fs

ends <- trim_ends(x, w=100, thr=1)
if((ends[2] - ends[1]) < (fs*time.limit))
	{
	print(paste("File ", file.name, " is < ", time.limit," sec, skipped!", sep=""), quote=F)
	next
	} else x <- x[ends[1]:(ends[1]+fs*time.limit)]

	audio.nor@left <- x
	audio.nor@samp.rate <- fs

	sample_mp3 <- transform_to_tensor(audio.nor)
	# window size=512, FFT size=1024, overlap=90%, number of mel bands=256
	mel_specgram2 <- transform_mel_spectrogram(sample_rate=sample_mp3[[2]],
	n_fft = 1024, win_length = 512, hop_length = (512*0.1),
	f_min = 0, f_max = 4000, pad = 0, n_mels = 256,
	window_fn = torch::torch_hann_window,
	power = 2, normalized = FALSE)(sample_mp3[[1]])
	specgram_as_array2 <- as.array(mel_specgram2$log2()[1]$t())

# create one folder to save spectrogram images of one group (PwPD or HC)
dir.create(path=paste("path to where you save spectrogram image", 
"_", which.group, , sep=""))
fileJPG <- paste("path to the created folder earlier", "/", 
file.name, ".jpg", sep="")

# plot one spectrogram image in a jpeg file
# image is 2-by-2 inches with 300 dpi resolution
jpeg(filename=fileJPG, res=300, width=2, height=2, units="in", pointsize=1, quality=100)
par(mfrow=c(1,1), mar=c(0,0,0,0))
image(specgram_as_array2[,1:ncol(specgram_as_array2)], 
col=oce.colorsViridis(256), xaxt="n", yaxt="n")
dev.off()

} # end of loop
