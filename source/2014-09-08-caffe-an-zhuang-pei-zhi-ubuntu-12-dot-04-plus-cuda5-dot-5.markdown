---
layout: post
title: "Caffe安装配置（Ubuntu 12.04+Cuda5.5）"
date: 2014-09-8 15:14
comments: true
share: true
categories: tools
---
**1: 安装cuda5.5**  
需要通过.run文件安装，alt+ctrl_f1切换到命令行下，  
安装前先关闭xserver 否则会失败  
sudo /etc/init.d/lightdm stop  
跳过驱动安装过程否则安装会出错（driver installation is unable to locate the kernel source）  
**该部分参考：**  
http://pastebin.com/fDpqvSi5 （翻墙访问）  
https://devtalk.nvidia.com/default/topic/703506/problems-installing-cuda-5-5-deb-on-ubuntu-12-04-64-bit/  
https://devtalk.nvidia.com/default/topic/639607/cuda-setup-and-installation/whats-the-correct-repository-for-ubuntu-13-10-64-bit-with-cuda-5-5/post/4029405/#4029405   
改路径  
sudo gedit /etc/profile  
if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  export PATH=/usr/local/cuda/bin:$PATH #添加路径
  unset i
fi  
查看安装版本 nvcc -V  
测试cuda能够正常运行  
打开样例 NVIDIA_CUDA-5.5_Samples/NVIDIA_CUDA-5.5_Samples/1_Utilities/deviceQuery  
执行 make 命令 生产可执行文件  
执行文件./deviceQuery  
可以获得显卡信息  


**2：安装boost 1.55.0**
Installing Boost on Ubuntu with an example of using boost array:  
Install libboost-all-dev and aptitude  
sudo apt-get install libboost-all-dev  
sudo apt-get install aptitude  
aptitude search boost  
Then paste this into a C++ file called main.cpp:  

     #include <iostream>
	 #include <boost/array.hpp>
	 using namespace std;
	 int main(){
      boost::array<int, 4> arr = {{1,2,3,4}};
      cout << "hi" << arr[0];
      return 0;
      }  
Compile like this:  
g++ -o s main.cpp  
Run it like this:  
./s  
Program prints:  
hi1  
参考： http://stackoverflow.com/questions/12578499/how-to-install-boost-on-ubuntu   
3：opencv 2.4.9  
参考  
https://github.com/jayrambhia/Install-OpenCV/blob/master/Ubuntu/2.4/opencv2_4_9.sh  
测试程序
[cpp]

    #include <cv.h>    
    #include <highgui.h>    
      
    int main()    
    {    
        //请确定程序目录下有一张测试用的图片temp.png  
        const char *fileName = "temp.png";  
        const char *title = "Image" ;    
        IplImage *image = cvLoadImage(fileName, CV_LOAD_IMAGE_COLOR) ;    
      
        cvNamedWindow(title, CV_WINDOW_AUTOSIZE);    
        cvShowImage(title, image);    
        cvWaitKey(0);    
      
        cvReleaseImage(&image);    
        cvDestroyWindow(title);    
      
        return 0;    
      
    }  

保存为 test.cpp  
编译链接命令 g++ -L /usr/local/cuda/lib64/ test.cpp -o test `pkg-config --cflags --libs opencv`  
如果不添加 -L /usr/local/cuda/lib64/   
会出现如下错误，应该是编译用到以下cuda链接库  
/usr/bin/ld: cannot find -lcufft
/usr/bin/ld: cannot find -lnpps
/usr/bin/ld: cannot find -lnppi
/usr/bin/ld: cannot find -lnppc
/usr/bin/ld: cannot find -lcudart
collect2: ld returned 1 exit status
解决办法参考： http://stackoverflow.com/questions/24322466/makefile-opencv-stopped-working   

**4：安装其他库**  
 sudo apt-get install libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev   
对于glog gflag imdb安装官方指南如下，个人遇到较多问题，参加注意事项。  
 - # glog  
wget https://google-glog.googlecode.com/files/glog-0.3.3.tar.gz
tar zxvf glog-0.3.3.tar.gz
cd glog-0.3.3
./configure
make && make install
 - # gflags  
	wget https://github.com/schuhschuh/gflags/archive/master.zip
	unzip master.zip
	cd gflags-master
	mkdir build && cd build
	export CXXFLAGS="-fPIC" && cmake .. && make VERBOSE=1
	make && make install
 - # lmdb  
git clone git://gitorious.org/mdb/mdb.git
cd mdb/libraries/liblmdb
make && make install
Note that glog does not compile with the most recent gflags version (2.1), so before that is resolved you will need to build with glog first.


----------


**注意事项：**  
1: 根据提醒，要安装glog，如果已经安装gflag需要先把gflag卸载掉 sudo apt-get remove gflags  
否则会出现gflag文件相关错误。  
2：gflag安装是基于cmake完成的，需要先安装cmake，否则会报错。  
gflag上述安装有问题，  
make all 时候遇到错误如下  
/usr/local/lib/libgflags.a: could not read symbols: Bad value  
collect2: error: ld returned 1 exit statu  
重新安装gflags解决,   
参考https://code.google.com/p/google-glog/issues/detail?id=201  
$ tar -xvf gflags-2.1.1.tar.gz  
$ cd gflags-2.1.1 && mkdir build && cd build  
$ CXXFLAGS="-fPIC" cmake .. -DGFLAGS_NAMESPACE=google  
$ sudo make install  
**5: 编译caffe**  
make all  
make test  
make runtest  
出现以下问题  
找不到lcudart.so  
找不到libmkl_rt.so  
将cuda和mkl添加进链接库路径即可  
具体方法： sudo gedit /etc/ld.so.conf 进行编辑 添加以下两行  
/usr/local/cuda/lib64  
/opt/intel/mkl/lib/intel64  
保存之后，进行生成才会生效，sudo ldconfig /etc/ld.so.conf。（可以通过观察ld.so.cache 生成时间看上述过程是否生效）  

make all 时候遇到错误如下  
/usr/local/lib/libgflags.a: could not read symbols: Bad value  
collect2: error: ld returned 1 exit statu  
重新安装gflags解决,   
参考https://code.google.com/p/google-glog/issues/detail?id=201  
Same issue on Ubuntu 14.04, 64 bit, g++ 4.8.2, glibc 2.19  
Solved by compiling gflags-2.1.1 with -fPIC:  

$ tar -xvf gflags-2.1.1.tar.gz  
$ cd gflags-2.1.1 && mkdir build && cd build  
$ CXXFLAGS="-fPIC" cmake .. -DGFLAGS_NAMESPACE=google  
$ sudo make install  
之后又make all 时候遇到错误如下  
undefined reference to `gflags::ParseCommandLineFlags‘  
解决办法参考：http://blog.itpub.net/16582684/viewspace-1256380/  
修改Makefile.config, 注释CPU_ONLY := 1, 同时修改CUSTOM_CXX := g++-4.6  
sudo apt-get install gcc-4.6 g++-4.6 gcc-4.6-multilib g++-4.6-multilib  
修改这两个文件  
vi src/caffe/common.cpp  
vi tools/caffe.cpp  
使用google替代gflags  
make clean  
make  
**6：minist 测试**  
首先下载并生产数据集  
cd $CAFFE_ROOT/data/mnist  
./get_mnist.sh  
cd $CAFFE_ROOT/examples/mnist  
./create_mnist.sh  
训练模型：  
cd $CAFFE_ROOT/examples/mnist  
./train_lenet.sh  
**7：其他相关**  
matlab 接口编译  
修改config文件  
gedit Makefile.config  
\# This is required only if you will compile the matlab interface.  
\# MATLAB directory should contain the mex binary in /bin.  
MATLAB_DIR := /usr/local  
MATLAB_DIR := /usr/local/MATLAB/MATLAB_Production_Server/R2013a  
重新编译   
sudo make clean  
make  



