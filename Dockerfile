FROM oraclelinux:8 AS builder
RUN dnf install -y git gcc-c++ make cmake freetype-devel openssl-devel

WORKDIR /work
RUN git clone https://code.videolan.org/videolan/x264.git
RUN git clone --depth=1 https://github.com/FFmpeg/FFmpeg ffmpeg
RUN git clone https://bitbucket.org/multicoreware/x265_git.git x265

WORKDIR /work/x264
RUN ./configure --prefix=/opt/cvision --enable-shared
RUN make
RUN make install

WORKDIR /work/x265/linux_build
RUN cmake ../source -DCMAKE_INSTALL_PREFIX=/opt/cvision
RUN make
RUN make install

COPY files/cvision.conf /etc/ld.so.conf.d
RUN ldconfig

# SVT libraries
WORKDIR /work
RUN git clone https://github.com/OpenVisualCloud/SVT-HEVC
RUN git clone https://github.com/OpenVisualCloud/SVT-AV1


WORKDIR /work/SVT-AV1/Build
RUN cmake .. -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/cvision
RUN make && make install

WORKDIR /work/ffmpeg
ENV PKG_CONFIG_PATH=/opt/cvision/lib/pkgconfig/:/opt/cvision/lib64/pkgconfig/

# Setup a temporary username for git am to run
RUN git config --global user.name DOCKER_BUILD && git config --global user.email info@cvisionai.com

# Apply SVT patches for HEVC and AV1
RUN git am ../SVT-HEVC/ffmpeg_plugin/master-0001-lavc-svt_hevc-add-libsvt-hevc-encoder-wrapper.patch

RUN ./configure --prefix=/opt/cvision --enable-libsvtav1 --enable-libfreetype --enable-libx264 --enable-libx265 --enable-openssl --enable-gpl --enable-nonfree
RUN make && make install

# Add bento4 to transcoder image
WORKDIR /working
RUN git clone https://github.com/axiomatic-systems/Bento4.git
WORKDIR /working/Bento4/cmakebuild
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/cvision
RUN make
RUN make install

FROM oraclelinux:8 as encoder
RUN dnf install -y freetype openssl wget
COPY --from=builder /opt/cvision /opt/cvision
COPY files/cvision.conf /etc/ld.so.conf.d
COPY files/test.sh /test.sh
RUN chmod +x /test.sh
ENV PATH="/opt/cvision/bin:${PATH}"
RUN ldconfig /


