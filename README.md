# 环境
1. bochs

   ```shell
   sudo apt-get install build-essential xorg-dev libgtk2.0-dev
   wget https://sourceforge.net/projects/bochs/files/bochs/2.6.11/bochs-2.6.11.tar.gz
   tar vxzf bochs-2.6.11.tar.gz
   cd bochs-2.6.11
   ./configure --enable-debugger --enable-disasm --enable-iodebug --enable-x86-debugger --with-x --with-x11 LDFLAGS='-pthread' LIBS='-lX11'
   make
   sudo make install
   ```

2. nasm

   ```shell
   wget https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.gz
   tar zxvf nasm-2.15.05.tar.gz
   cd nasm-2.15.05
   ./configure
   make
   sudo make install
   ```

3. MyOS文件夹

# 执行步骤
1. 进入MyOS文件夹

2. 将.asm汇编成二进制文件
  
  ```shell
  nasm boot.asm -o boot.bin
  ```
  
3. 将二进制文件载入到虚拟软盘
  
  ```shell
  dd if=boot.bin of=myos.img bs=512 count=1 conv=notrunc
  ```
  
4. 执行bochsrc

  ```shell
  bochs -f bochsrc
  ```


