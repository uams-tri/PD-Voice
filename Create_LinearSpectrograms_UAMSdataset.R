################################################################################
# R code to generate linear-scale spectrogram images from the UAMS audio files #
################################################################################

# Copyright (C) 2024 University of Arkansas for Medical Sciences
# Author: Yasir Rahmatallah, yrahmatallah@uams.edu
# Licensed under the Apache License, Version 2.0
# you may not use this file except in compliance with the License
# You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

# Code was tested using R version 4.1.2, and the following package versions:
# av_0.8.3, tuneR_1.4.0, oce_1.7-8, signal_0.7-7, viridis_0.6.2                    

library(av)
library(tuneR)
library(oce)
library(signal)
library(viridis)

# function to trim silence parts in the UAMS audi files
trim_ends <- function(x, w=100, thr=1){
len <- length(x)
env <- numeric(length=len-w)
for(k in 1:(len-w))
	{
	env[k] <- sum(x[k:(k+w)]^2)
	}
ind <- which(env > thr)
#rr <- rle((env > 1)+0)
st <- ind[1]
en <- tail(ind, n=1)
return(c(st, en))
}

time.limit <- 1.5 # in seconds
file_audio_path <- "path to where the wav files of PwPD or HC were saved"

# find the names of wav files in the selected folder
fL <- list.files(path=file_audio_path, pattern=".wav$")
# remove '.wav' from the end of file names
fL <- gsub(fL, pattern=".wav", replacement="")

# start a loop
for(file.name in fL){
	file <- paste(file_audio_path, "/", file.name, ".wav", sep="")
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
	
	# create spectrogram
	# window size=1024, FFT size=1024, overlap=75%
	spec <- specgram(x=x, n=1024, Fs=fs, window=hanning(1024), overlap=768)
	P <- abs(spec$S)
	P <- P/max(P)
	P <- 10*log10(P)
	t <- spec$t
	
	# create one folder to save spectrogram images
	dir.create(path=paste("path to where you save spectrogram image", 
	"/linearSpec", sep=""))
	fileJPG <- paste("path to the created folder earlier", "/", 
	file.name, ".jpg", sep="")
	
	# plot one spectrogram image in a jpeg file
	# image is 2-by-2 inches with 300 dpi resolution
	jpeg(filename=fileJPG, res=300, width=2, height=2, units="in", pointsize=1, quality=100)
	imagep(x=t, y=spec$f, z=t(P), col=oce.colorsViridis(256), ylim=c(0,4000), 
	axes=FALSE, ylab="", xlab="", drawPalette=F, decimate=F, mar=c(0,0,0,0))
	dev.off()
	} # end of loop
