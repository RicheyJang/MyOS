# ����
1. bochs
2. nasm ����ӽ���������
3. MyOS�ļ���

# ִ�в���
1. ����MyOS�ļ���

2. ��.asm���ɶ������ļ�
  
  ```shell
  nasm boot.asm -o boot.bin
  ```
  
3. ���������ļ����뵽��������
  
  ```shell
  .\dd if=boot.bin of=myos.img bs=512 count=1 conv=notrunc
  ```
  
4. ִ��bochsrc.bxrc