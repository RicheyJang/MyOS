org 07c00h
mov ax,cs                      ; 告诉编译器程序加载到7c00处
mov ds,ax
mov es,ax
call DispStr                   ; 调用显示字符串例程
jmp $
DispStr:
mov ax,BootMessage
mov bp,ax                    ; es:bp = 串地址
mov cx,16                    ; cx = 串长度
mov ax,01301h                ; ah = 13,al = 01h
mov bx,000ch                 ; 页号为0(bh=0) 黑底红字(b1=0ch,高亮)
mov dl,0
int 10h                      ; 10h号中断
ret
BootMessage:  db  "Hello,OS world!"
times 510-($-$$)  db  0      ; 填充剩下的空间,使生成的二进制代码恰好为512字节
dw 0xaa55                    ; 结束标志