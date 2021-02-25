# 环境
1. bochs
2. nasm 并添加进环境变量
3. MyOS文件夹

# 执行步骤
1. 进入MyOS文件夹

2. 将.asm汇编成二进制文件
  
  ```shell
  nasm boot.asm -o boot.bin
  ```
  
3. 将二进制文件载入到虚拟软盘
  
  ```shell
  .\dd if=boot.bin of=myos.img bs=512 count=1 conv=notrunc
  ```
  
4. 执行bochsrc.bxrc