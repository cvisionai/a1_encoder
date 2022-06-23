#!/bin/bash

mkdir /scratch
cd /scratch
wget http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4
ffmpeg -i ForBiggerBlazes.mp4 -c:v libx264 -vf scale=-2:2160 -crf 23 libx264.mp4
ffmpeg -i ForBiggerBlazes.mp4 -c:v libx265 -vf scale=-2:2160 -crf 23 libx265.mp4

echo "Video files are in '/scratch'"
du -hs /scratch/*.mp4
