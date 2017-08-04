FROM i686/ubuntu

# First install some basic things we need to build things
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y git
RUN apt-get install -y python
RUN apt-get install -y binutils
RUN apt-get install -y g++-multilib

# Download, compile, and install the latest cmake
RUN mkdir /cmake
WORKDIR /cmake
ADD https://cmake.org/files/v3.9/cmake-3.9.0.tar.gz .
RUN tar -xvf cmake-3.9.0.tar.gz
RUN cd cmake-3.9.0
WORKDIR /cmake/cmake-3.9.0
ENV CXX g++
ENV CC gcc
ENV LD ld
RUN ./configure
RUN make
RUN make install

# Download, compile, and install the latest ninja
WORKDIR /
RUN mkdir /ninja
RUN git clone https://github.com/ninja-build/ninja.git
WORKDIR /ninja
RUN ./configure.py --bootstrap
RUN cp ninja /usr/sbin/ninja

# Make sure we have llvm source in the image so we can build from it
# git keeps hanging so instead I just download a specific version of the src
WORKDIR /
RUN mkdir /llvm
WORKDIR /llvm
ADD http://releases.llvm.org/4.0.1/llvm-4.0.1.src.tar.xz .
ADD http://releases.llvm.org/4.0.1/cfe-4.0.1.src.tar.xz .
RUN tar -xvf llvm-4.0.1.src.tar.xz
RUN mv llvm-4.0.1.src llvm
RUN tar -xvf cfe-4.0.1.src.tar.xz -C llvm/tools/
RUN mv llvm/tools/cfe-4.0.1.src llvm/tools/clang
RUN rm cfe-4.0.1.src.tar.xz
RUN rm llvm-4.0.1.src.tar.xz

# Build a release mode compiler into the image using GCC
WORKDIR /llvm/release
RUN cmake -G Ninja -DCMAKE_BUILD_TYPE=MinSizeRel -DLLVM_BUILD_32_BITS=ON ../llvm
RUN ninja

# Now we want to be able to quickly run 32-bit builds on this system but using
# source code from a volume so that we can run it using our host code
VOLUME /llvmtot
WORKDIR /llvm
RUN mkdir 32bit
ADD build.sh build.sh
CMD ["bash", "build.sh"]
