org 07c00h
mov ax,cs                      ; ���߱�����������ص�7c00��
mov ds,ax
mov es,ax
call DispStr                   ; ������ʾ�ַ�������
jmp $
DispStr:
mov ax,BootMessage
mov bp,ax                    ; es:bp = ����ַ
mov cx,16                    ; cx = ������
mov ax,01301h                ; ah = 13,al = 01h
mov bx,000ch                 ; ҳ��Ϊ0(bh=0) �ڵ׺���(b1=0ch,����)
mov dl,0
int 10h                      ; 10h���ж�
ret
BootMessage:  db  "Hello,OS world!"
times 510-($-$$)  db  0      ; ���ʣ�µĿռ�,ʹ���ɵĶ����ƴ���ǡ��Ϊ512�ֽ�
dw 0xaa55                    ; ������־