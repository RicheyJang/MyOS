%include	"pm.inc"	; 常量, 宏, 以及一些说明

org	0100h
	jmp	LABEL_BEGIN

[SECTION .gdt]
; GDT
;                            段基址,           段界限     , 属性
LABEL_GDT:             Descriptor 0,                 0, 0		   ;空描述符
LABEL_DESC_NORMAL:     Descriptor 0,            0ffffh, DA_DRW		   ;Normal描述符
LABEL_DESC_CODE32:     Descriptor 0,    SegCode32Len-1, DA_C+DA_32	   ;非一致,32
LABEL_DESC_DATA:       Descriptor 0,	     DataLen-1, DA_DRW             ;Data
LABEL_DESC_STACK:      Descriptor 0,        TopOfStack, DA_DRWA+DA_32	   ;Stack,32
LABEL_DESC_TSS0:       dw 0x0068,0x0000,0xE901,0x0000
LABEL_DESC_TSS1:	   dw 0x0068,0x0000,0xE901,0x0000
LABEL_DESC_TASKCODE0:  Descriptor 0,	SegCode32Len-1, DA_C+DA_32	   ;非一致,32
LABEL_DESC_TASKCODE1:  Descriptor 0,	SegCode32Len-1, DA_C+DA_32	   ;非一致,32
LABEL_DESC_VIDEO:      Descriptor 0B8000h,      0ffffh, DA_DRW+DA_DPL3

GdtLen		equ	$ - LABEL_GDT	; GDT长度
GdtPtr		dw	GdtLen - 1	; GDT界限
		dd	0		; GDT基地址

; GDT 选择子
SelectorNormal		equ	LABEL_DESC_NORMAL	- LABEL_GDT
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorData		equ	LABEL_DESC_DATA		- LABEL_GDT
SelectorStack		equ	LABEL_DESC_STACK	- LABEL_GDT
SelectorCode0		equ LABEL_DESC_TASKCODE0- LABEL_GDT
SelectorCode1		equ LABEL_DESC_TASKCODE1- LABEL_GDT
SelectorTSS0		equ	LABEL_DESC_TSS0		- LABEL_GDT
SelectorTSS1		equ	LABEL_DESC_TSS1		- LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT
; END of [SECTION .gdt]

[SECTION .data1]	 ; 数据段
ALIGN	32
[BITS	32]
LABEL_DATA:
SPValueInRealMode	dw	0
; 字符串
PMMessage:		db	"In Protect Mode now. ^-^", 0	; 进入保护模式后显示此字符串
OffsetPMMessage		equ	PMMessage - $$
StrTest:		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
OffsetStrTest		equ	StrTest - $$
DataLen			equ	$ - LABEL_DATA
; END of [SECTION .data1]


; 全局堆栈段
[SECTION .gs]
ALIGN	32
[BITS	32]
LABEL_STACK:
	times 512 db 0
TopOfStack	equ	$ - LABEL_STACK - 1
; END of [SECTION .gs]

; TSS ---------------------------------------------------------------------------------------------
[SECTION .tss0]
ALIGN	32
[BITS	32]
LABEL_TSS0:
		DD  0           ; Back
        DD  TopOfStack	; 0 级堆栈
        DD  SelectorStack; 
        DD  0           ; 1 级堆栈
        DD  0           ; 
        DD  0			; 2 级堆栈
        DD  0			; 
        DD  0           ; CR3
        DD  0           ; EIP
        DD  0           ; EFLAGS
        DD  0           ; EAX
        DD  0           ; ECX
        DD  0           ; EDX
        DD  0           ; EBX
        DD  0           ; ESP
        DD  0           ; EBP
        DD  0           ; ESI
        DD  0           ; EDI
        DD  0           ; ES
        DD	0			; CS
		DD	0			; SS
        DD  0           ; DS
        DD  0           ; FS
        DD  0           ; GS
        DD  0           ; LDT
        DW  0           ; 调试陷阱标志
        DW  $ - LABEL_TSS0 + 2   ; I/O位图基址
        DB  0ffh            ; I/O位图结束标志
TSSLen		equ	$ - LABEL_TSS0
; TSS ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; TSS1 ---------------------------------------------------------------------------------------------
[SECTION .tss1]
ALIGN	32
[BITS	32]
LABEL_TSS1:
		DD	0			; Back
		DD	TopOfStack		; 0 级堆栈
		DD	SelectorStack		; 
		DD	0			; 1 级堆栈
		DD	0			; 
		DD	0			; 2 级堆栈
		DD	0			; 
		DD	0			; CR3
		DD	0		; EIP
		DD	0			; EFLAGS
		DD	0			; EAX
		DD	0			; ECX
		DD	0			; EDX
		DD	0			; EBX
		DD	0			; ESP
		DD	0			; EBP
		DD	0			; ESI
		DD	0			; EDI
		DD	0			; ES
		DD	SelectorCode1			; CS
		DD	SelectorStack			; SS
		DD	0			; DS
		DD	0			; FS
		DD	0			; GS
		DD	0			; LDT
		DW  0           ; 调试陷阱标志
        DW  $ - LABEL_TSS1 + 2   ; I/O位图基址
        DB  0ffh            ; I/O位图结束标志
; TSS ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

[SECTION .s16]
[BITS	16]
LABEL_BEGIN:
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0100h

	mov	[SPValueInRealMode], sp

	; 初始化 32 位代码段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE32
	mov	word [LABEL_DESC_CODE32 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE32 + 4], al
	mov	byte [LABEL_DESC_CODE32 + 7], ah

	; 初始化数据段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_DATA
	mov	word [LABEL_DESC_DATA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_DATA + 4], al
	mov	byte [LABEL_DESC_DATA + 7], ah

	; 初始化堆栈段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK
	mov	word [LABEL_DESC_STACK + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK + 4], al
	mov	byte [LABEL_DESC_STACK + 7], ah

	; 初始化 TSS 描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_TSS0
	mov	word [LABEL_DESC_TSS0 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_TSS0 + 4], al
	mov	byte [LABEL_DESC_TSS0 + 7], ah
	
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_TSS1
	mov	word [LABEL_DESC_TSS1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_TSS1 + 4], al
	mov	byte [LABEL_DESC_TSS1 + 7], ah
	
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_TASK0
	mov	word [LABEL_DESC_TASKCODE0 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_TASKCODE0 + 4], al
	mov	byte [LABEL_DESC_TASKCODE0 + 7], ah
	
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_TASK1
	mov	word [LABEL_DESC_TASKCODE1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_TASKCODE1 + 4], al
	mov	byte [LABEL_DESC_TASKCODE1 + 7], ah

	; 为加载 GDTR 作准备
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt 基地址
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt 基地址
 
	; 加载 GDTR
	lgdt	[GdtPtr]

	; 关中断
	cli

	; 打开地址线A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	; 准备切换到保护模式
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	; 真正进入保护模式
	jmp	dword SelectorCode32:0	; 执行这一句会把 SelectorCode32 装入 cs, 并跳转到 Code32Selector:0  处

[SECTION .s32]; 32 位代码段. 由实模式跳入.
[BITS	32]

LABEL_SEG_CODE32:
	mov ax, SelectorTSS0	;dif
	ltr ax
	
	mov	ax, SelectorData
	mov	ds, ax			; 数据段选择子
	mov	es, ax			; 数据段选择子
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子

	mov	ax, SelectorStack
	mov	ss, ax			; 堆栈段选择子

	mov	esp, TopOfStack				;dif end
	
	jmp SelectorTSS1:0
	jmp SelectorCode0:0

	jmp $

LABEL_TASK0:
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子(目的)

	mov	edi, (80 * 1 + 50) * 2	; 屏幕第 1 行, 第 50 列。
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'A'
	mov	[gs:edi], ax

	jmp SelectorTSS1:0
	jmp SelectorCode0:0
	
POS_TASK0 equ LABEL_TASK0-$$

LABEL_TASK1:
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子(目的)

	mov	edi, (80 * 1 + 50) * 2	; 屏幕第 1 行, 第 50 列。
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'B'
	mov	[gs:edi], ax

	jmp SelectorTSS0:0
	jmp SelectorCode1:0
	
POS_TASK1 equ LABEL_TASK1-$$

SegCode32Len	equ	$ - LABEL_SEG_CODE32
; END of [SECTION .s32]

