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

WORKDIR /work/ffmpeg
ENV PKG_CONFIG_PATH=/opt/cvision/lib/pkgconfig/
RUN ./configure --prefix=/opt/cvision --enable-libfreetype --enable-libx264 --enable-libx265 --enable-openssl --enable-gpl --enable-nonfree
RUN make && make install

FROM oraclelinux:8 as encoder
RUN dnf install -y freetype openssl wget
COPY --from=builder /opt/cvision /opt/cvision
COPY files/cvision.conf /etc/ld.so.conf.d
COPY files/test.sh /test.sh
RUN chmod +x /test.sh
ENV PATH="/opt/cvision/bin:${PATH}"
RUN ldconfig /


