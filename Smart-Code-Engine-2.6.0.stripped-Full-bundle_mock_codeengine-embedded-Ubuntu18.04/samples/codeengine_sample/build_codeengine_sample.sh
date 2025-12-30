g++ codeengine_sample.cpp -O2 -std=c++11 -I ../../include -L ../../bin -l codeengine -o codeengine_sample  -Wl,-rpath,../../bin

# How to run
# LD_LIBRARY_PATH=../../bin ./codeengine_sample <image>
