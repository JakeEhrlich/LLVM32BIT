#!/bin/bash

# Make the 32-bit build using the release compiler built into the image
cd 32bit
cmake -G Ninja -DCMAKE_C_COMPILER=/llvm/release/bin/clang \
               -DCMAKE_CXX_COMPILER=/llvm/release/bin/clang++ \
               -DCMAKE_BUILD_TYPE=MinSizeRel \
               -DLLVM_ENABLE_THREADS=OFF \
               -DLLVM_BUILD_32_BITS=ON \
               -DLLVM_ENABLE_WERROR=ON \
               /llvmtot/llvm
# Now actully build it
ninja
