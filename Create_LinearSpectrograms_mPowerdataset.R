##################################################################################
# R code to generate linear-scale spectrogram images from the mPower audio files #
##################################################################################

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
trim_ends <- function(x, w=512, thr=0.5){
len <- length(x)
nseg <- floor(len/w)
ste <- numeric(nseg)
for(q in 1:nseg) ste[q] <- sum(x[((q-1)*w+1):(q*w)]^2)
env <- rep(ste, each=w)
check <- (env>thr)+0
rr <- rle(check)
if(length(rr$lengths)>1)
	{
	indmax <- which.max(rr$lengths * rr$values)
	if(indmax>1)
		{
		st <- sum(rr$lengths[1:(indmax-1)]) + 1
		en <- sum(rr$lengths[1:indmax])
		}
	if(indmax==1)
		{
		st <- 1
		en <- rr$lengths[1]
		}
	} else {st <- 1; en <- len} # apply when all the recording passes the threshold
return(c(st, en))
}

time.limit <- 1.5 # in seconds
ds <- 5 # dows-sampling rate
file_audio_path <- "path to where the wav files of PwPD or HC were saved"

# find the names of m4a files in the selected folder
fL <- list.files(path=file_audio_path, pattern=".m4a$")
# remove '.m4a' from the end of file names
fL <- gsub(fL, pattern=".m4a", replacement="")
# create a folder to save wav files
dir.create(path=paste(file_audio_path, "/wav", , sep=""))

# start a loop
for(file.name in fL){
	file <- paste(file_audio_path, "/", file.name, ".m4a", sep="")
	fileWAV <- paste(file_audio_path, "/wav/", file.name, ".wav", sep="")
	# convert m4a format to WAV
	av_audio_convert(file, fileWAV, channels=1, verbose=FALSE)
	train_audio <- readWave(fileWAV)
	audio.nor <- tuneR::normalize(train_audio, unit="32", pcm=FALSE)
	x <- audio.nor@left
	fs <- train_audio@samp.rate
	fs <- fs/ds
	x <- x[seq(1, length(x), by=ds)]
	x <- x[16500:(length(x)-10000)]
	ends <- trim_ends(x, w=512, thr=0.5)
	mp <- floor(mean(ends))
	if((ends[2] - ends[1]) < (fs*time.limit))
		{
		print(paste("File ", file.name, " is < ", time.limit," sec, skipped!", sep=""), quote=F)
		next
		} else x <- x[(mp-(fs*time.limit/2)):(mp+(fs*time.limit/2))]

	# create spectrogram
	# window size=1024, FFT size=1024, overlap=75%
	spec <- specgram(x=x, n=1024, Fs=fs, window=hanning(1024), overlap=768)
	P <- abs(spec$S)
	P <- P/max(P)
	P <- 10*log10(P)
	t <- spec$t
	
	# create one folder to save spectrogram images of one group (PwPD or HC)
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
