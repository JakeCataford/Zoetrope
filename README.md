# Zoetrope [![Build Status](https://travis-ci.org/JakeCataford/Zoetrope.svg)](https://travis-ci.org/JakeCataford/Zoetrope)

A website to create your own gifs from youtube videos.

## Installing Dependencies

Zoetrope uses ImageMagick and FFMpeg to perform video conversions and optimize gifs. You will need to install them as dependencies.

*OSX*

Use Homebrew:

`brew install imagemagick`
`brew install ffmpeg`

*Linux*

Imagemagick can be installed via apt-get

`sudo apt-get install imagemagick`

FFMpeg is only an official package in the latest ubuntu version, if you are using that you can install ffmpeg via apt-get, if you aren't, install it yourself:

```
wget http://ffmpeg.org/releases/ffmpeg-2.7.2.tar.bz2
tar -xvf ffmpeg-2.7.2.tar.bz2
cd ffmpeg-2.7.2
./configure
make && make install
```

If you run into problems, you might have to install some dependencies for ffmpeg, see https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu


