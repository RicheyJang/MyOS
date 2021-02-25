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

3. 可挂载目录/mnt/floppy

  ```shell
  sudo mkdir -p /mnt/floppy
  ```

4. MyOS文件夹

# 执行步骤
1. 进入MyOS文件夹

2. 执行Makefile的命令
  
  ```shell
  make
  ```

会执行：nasm二进制文件、将引导区boot写入软盘myos.img、将主程序以文件格式写入软盘myos.img

3. 执行bochsrc

  ```shell
  bochs -f bochsrc
  ```


