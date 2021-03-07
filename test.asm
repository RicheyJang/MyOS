%include	"pm.inc"	; 常量, 宏, 以及一些说明

org	0100h
jmp	LABEL_BEGIN

PageDirBase0		equ	200000h	; 页目录开始地址:	2M
PageTblBase0		equ	201000h	; 页表开始地址:		2M +  4K
PageDirBase1		equ	210000h	; 页目录开始地址:	2M + 64K
PageTblBase1		equ	211000h	; 页表开始地址:		2M + 64K + 4K

; GDT --------------------------------------------------------------------------------------
[SECTION .gdt]
;                            段基址,           段界限     , 属性
LABEL_GDT:             Descriptor 0,                 0, 0		   ;空描述符
LABEL_DESC_NORMAL:     Descriptor 0,            0ffffh, DA_DRW		   ;Normal描述符
LABEL_DESC_CODE32:     Descriptor 0,    SegCode32Len-1, DA_C+DA_32	   ;非一致,32
LABEL_DESC_DATA:       Descriptor 0,	     DataLen-1, DA_DRW			;Data
LABEL_DESC_VIDEO:      Descriptor 0B8000h,      0ffffh, DA_DRW+DA_DPL3
LABEL_DESC_FLAT_RW: Descriptor 0,        0fffffh, DA_DRW|DA_LIMIT_4K     ; 0~4G

LABEL_DESC_TSS0:       Descriptor 0,	TSSLen -1,    DA_386TSS			;TSS0描述符
LABEL_DESC_TSS1:	   Descriptor 0,	TSSLen -1,    DA_386TSS			;TSS1描述符
LABEL_DESC_STACK0:     Descriptor 0,    TopOfStack0, DA_DRWA+DA_32		;全局Stack0,32
LABEL_DESC_STACK1:     Descriptor 0,    TopOfStack1, DA_DRWA+DA_32		;全局Stack1,32
LABEL_DESC_LDT0:	   Descriptor 0,	LDT0Len - 1, DA_LDT				; LDT0
LABEL_DESC_LDT1:	   Descriptor 0,	LDT1Len - 1, DA_LDT				; LDT1

GdtLen		equ	$ - LABEL_GDT	; GDT长度
GdtPtr		dw	GdtLen - 1	; GDT界限
		dd	0		; GDT基地址

; GDT 选择子
SelectorNormal		equ	LABEL_DESC_NORMAL	- LABEL_GDT
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorData		equ	LABEL_DESC_DATA		- LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT
SelectorFlatRW		equ	LABEL_DESC_FLAT_RW	- LABEL_GDT
SelectorStack0		equ	LABEL_DESC_STACK0	- LABEL_GDT
SelectorStack1		equ	LABEL_DESC_STACK1	- LABEL_GDT
SelectorTSS0		equ	LABEL_DESC_TSS0		- LABEL_GDT
SelectorTSS1		equ	LABEL_DESC_TSS1		- LABEL_GDT
SelectorLDT0		equ	LABEL_DESC_LDT0		- LABEL_GDT
SelectorLDT1		equ	LABEL_DESC_LDT1		- LABEL_GDT
; END of [SECTION .gdt]

; 数据段 --------------------------------------------------------------------------------------
[SECTION .data1]	 
ALIGN	32
[BITS	32]
LABEL_DATA:
; 实模式下使用这些符号
_szMemChkTitle:			db	"BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0	; 进入保护模式后显示此字符串
_szRAMSize			db	"RAM size:", 0
_szReturn			db	0Ah, 0
; 变量
_dwMCRNumber:			dd	0	; Memory Check Result
_dwDispPos:			dd	(80 * 6 + 0) * 2	; 屏幕第 6 行, 第 0 列。
_dwMemSize:			dd	0
_ARDStruct:			; Address Range Descriptor Structure
	_dwBaseAddrLow:		dd	0
	_dwBaseAddrHigh:	dd	0
	_dwLengthLow:		dd	0
	_dwLengthHigh:		dd	0
	_dwType:		dd	0
_PageTableNumber		dd	0

_MemChkBuf:	times	256	db	0

_currentTask:		dd		0

; 保护模式下使用这些符号
szMemChkTitle		equ	_szMemChkTitle	- $$
szRAMSize		equ	_szRAMSize	- $$
szReturn		equ	_szReturn	- $$
dwDispPos		equ	_dwDispPos	- $$
dwMemSize		equ	_dwMemSize	- $$
dwMCRNumber		equ	_dwMCRNumber	- $$
ARDStruct		equ	_ARDStruct	- $$
	dwBaseAddrLow	equ	_dwBaseAddrLow	- $$
	dwBaseAddrHigh	equ	_dwBaseAddrHigh	- $$
	dwLengthLow	equ	_dwLengthLow	- $$
	dwLengthHigh	equ	_dwLengthHigh	- $$
	dwType		equ	_dwType		- $$
MemChkBuf		equ	_MemChkBuf	- $$
PageTableNumber		equ	_PageTableNumber- $$
currentTask		equ	_currentTask - $$

DataLen			equ	$ - LABEL_DATA
; END of [SECTION .data1]

; IDT --------------------------------------------------------------------------------------
[SECTION .idt]
ALIGN	32
[BITS	32]
LABEL_IDT:
; 门				目标选择子,					偏移, DCount, 属性
%rep 32
			Gate	SelectorCode32, SpuriousHandler,      0, DA_386IGate
%endrep
.020h:		Gate	SelectorCode32,    ClockHandler,      0, DA_386IGate
%rep 95
			Gate	SelectorCode32, SpuriousHandler,      0, DA_386IGate
%endrep
.080h:		Gate	SelectorCode32,  UserIntHandler,      0, DA_386IGate

IdtLen		equ	$ - LABEL_IDT
IdtPtr		dw	IdtLen - 1	; 段界限
		dd	0		; 基地址
; END of [SECTION .idt]

; 全局堆栈段0 --------------------------------------------------------------------------------------
[SECTION .gs0]
ALIGN	32
[BITS	32]
LABEL_STACK0:
	times 512 db 0
TopOfStack0	equ	$ - LABEL_STACK0 - 1
; END of [SECTION .gs0]

; 全局堆栈段1 --------------------------------------------------------------------------------------
[SECTION .gs1]
ALIGN	32
[BITS	32]
LABEL_STACK1:
	times 512 db 0
TopOfStack1	equ	$ - LABEL_STACK1 - 1
; END of [SECTION .gs1]

; LDT0 --------------------------------------------------------------------------------------
[SECTION .ldt0]
ALIGN	32
LABEL_LDT0:
;                            段基址       段界限      属性
LABEL_LDT0_DESC_CODE:	Descriptor 0, LEN_TASK0 - 1, DA_C + DA_32 + DA_DPL3 ; Task0 Code, 32 位, ring 3
LABEL_LDT0_DESC_USER_STACK:	Descriptor 0,      TopOfUserStack0, DA_DRWA + DA_32 + DA_DPL3
LDT0Len		equ	$ - LABEL_LDT0

; LDT 选择子
SelectorLDT0Code	equ	LABEL_LDT0_DESC_CODE	- LABEL_LDT0 + SA_TIL + SA_RPL3
SelectorLDT0UserStack		equ	LABEL_LDT0_DESC_USER_STACK	- LABEL_LDT0+ SA_TIL + SA_RPL3
; END of [SECTION .ldt0]

; LDT1 --------------------------------------------------------------------------------------
[SECTION .ldt1]
ALIGN	32
LABEL_LDT1:
;                            段基址       段界限      属性
LABEL_LDT1_DESC_CODE: Descriptor 0, LEN_TASK1 - 1, DA_C + DA_32 + DA_DPL3; Task1 Code, 32 位
LABEL_LDT1_DESC_USER_STACK:	Descriptor 0,      TopOfUserStack1, DA_DRWA+DA_32 + DA_DPL3
LDT1Len		equ	$ - LABEL_LDT1

; LDT 选择子
SelectorLDT1Code	equ	LABEL_LDT1_DESC_CODE	- LABEL_LDT1 + SA_TIL + SA_RPL3
SelectorLDT1UserStack		equ	LABEL_LDT1_DESC_USER_STACK	- LABEL_LDT1 + SA_TIL + SA_RPL3
; END of [SECTION .ldt1]

; TSS0 ---------------------------------------------------------------------------------------------
[SECTION .tss0]
ALIGN	32
[BITS	32]
LABEL_TSS0:
		DD  0           ; Back
        DD  TopOfStack0	; 0 级堆栈
        DD  SelectorStack0; 
        DD  0           ; 1 级堆栈
        DD  0           ; 
        DD  0			; 2 级堆栈
        DD  0			; 
        DD  PageDirBase0; CR3
        DD  0           ; EIP
        DD  0           ; EFLAGS
        DD  0           ; EAX
        DD  0           ; ECX
        DD  0           ; EDX
        DD  0           ; EBX
        DD  TopOfUserStack0; ESP
        DD  0           ; EBP
        DD  0           ; ESI
        DD  0      ; EDI     
        DD  0           ; ES
        DD	SelectorLDT0Code		; CS
		DD	SelectorLDT0UserStack	; SS
        DD  0           ; DS
        DD  0           ; FS
        DD  0           ; GS
        DD  SelectorLDT0; LDT
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
		DD	TopOfStack1		; 0 级堆栈
		DD	SelectorStack1		; 
		DD	0			; 1 级堆栈
		DD	0			; 
		DD	0			; 2 级堆栈
		DD	0			; 
		DD	PageDirBase1; CR3
		DD	0			; EIP
		DD	0			; EFLAGS
		DD	0			; EAX
		DD	0			; ECX
		DD	0			; EDX
		DD	0			; EBX
		DD	TopOfUserStack1; ESP
		DD	0			; EBP
		DD	0			; ESI
		DD	0			; EDI
		DD	0			; ES
		DD	SelectorLDT1Code		; CS
		DD	SelectorLDT1UserStack	; SS
		DD	0			; DS
		DD	0			; FS
		DD	0			; GS
		DD	SelectorLDT1; LDT
		DW  0           ; 调试陷阱标志
        DW  $ - LABEL_TSS1 + 2   ; I/O位图基址
        DB  0ffh            ; I/O位图结束标志
; TSS ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; 用户堆栈段0 --------------------------------------------------------------------------------------
[SECTION .ls0]
ALIGN	32
[BITS	32]
LABEL_USER_STACK0:
	times 512 db 0
TopOfUserStack0	equ	$ - LABEL_USER_STACK0 - 1
; END of [SECTION .ls0]

; 用户堆栈段1 --------------------------------------------------------------------------------------
[SECTION .ls1]
ALIGN	32
[BITS	32]
LABEL_USER_STACK1:
	times 512 db 0
TopOfUserStack1	equ	$ - LABEL_USER_STACK1 - 1
; END of [SECTION .ls1]

[SECTION .s16]
[BITS	16]
FUNC_SETDESC:	; ebx:source edx:desc
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, ebx
	mov	word [edx + 2], ax
	shr	eax, 16
	mov	byte [edx + 4], al
	mov	byte [edx + 7], ah
	ret

LABEL_BEGIN:
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0100h
	
	; 15h中断 得到内存数
	mov	ebx, 0
	mov	di, _MemChkBuf
.loop:
	mov	eax, 0E820h
	mov	ecx, 20
	mov	edx, 0534D4150h
	int	15h
	jc	LABEL_MEM_CHK_FAIL
	add	di, 20
	inc	dword [_dwMCRNumber]
	cmp	ebx, 0
	jne	.loop
	jmp	LABEL_MEM_CHK_OK
LABEL_MEM_CHK_FAIL:
	mov	dword [_dwMCRNumber], 0
LABEL_MEM_CHK_OK:

	; 初始化 32 位代码段描述符
	mov ebx, LABEL_SEG_CODE32
	mov edx, LABEL_DESC_CODE32
	call FUNC_SETDESC

	; 初始化数据段描述符
	mov ebx, LABEL_DATA
	mov edx, LABEL_DESC_DATA
	call FUNC_SETDESC

	; 初始化全局堆栈段描述符
	mov ebx, LABEL_STACK0
	mov edx, LABEL_DESC_STACK0
	call FUNC_SETDESC
	
	mov ebx, LABEL_STACK1
	mov edx, LABEL_DESC_STACK1
	call FUNC_SETDESC
	
	; 初始化 LDT 在 GDT 中的描述符
	mov ebx, LABEL_LDT0
	mov edx, LABEL_DESC_LDT0
	call FUNC_SETDESC
	
	mov ebx, LABEL_LDT1
	mov edx, LABEL_DESC_LDT1
	call FUNC_SETDESC

	; 初始化 LDT 中的描述符
	mov ebx, LABEL_TASK0
	mov edx, LABEL_LDT0_DESC_CODE
	call FUNC_SETDESC
	
	mov ebx, LABEL_TASK1
	mov edx, LABEL_LDT1_DESC_CODE
	call FUNC_SETDESC
	
	mov ebx, LABEL_USER_STACK0
	mov edx, LABEL_LDT0_DESC_USER_STACK
	call FUNC_SETDESC
	
	mov ebx, LABEL_USER_STACK1
	mov edx, LABEL_LDT1_DESC_USER_STACK
	call FUNC_SETDESC

	; 初始化 TSS 描述符
	mov ebx, LABEL_TSS0
	mov edx, LABEL_DESC_TSS0
	call FUNC_SETDESC
	
	mov ebx, LABEL_TSS1
	mov edx, LABEL_DESC_TSS1
	call FUNC_SETDESC

	; 为加载 GDTR 作准备
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt 基地址
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt 基地址
	
	; 为加载 IDTR 作准备
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_IDT		; eax <- idt 基地址
	mov	dword [IdtPtr + 2], eax	; [IdtPtr + 2] <- idt 基地址
 
	; 加载 GDTR
	lgdt	[GdtPtr]

	; 关中断
	;cli
	
	; 加载 IDTR
	lidt	[IdtPtr]

	; 打开地址线A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	; 切换到保护模式
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	; 进入32位代码段
	jmp	dword SelectorCode32:0

[SECTION .s32]; 32 位代码段.
[BITS	32]

LABEL_SEG_CODE32:
	mov ax, SelectorTSS0
	ltr ax
	mov	ax, SelectorLDT0
	lldt	ax
	
	mov	ax, SelectorData
	mov	ds, ax			; 数据段选择子
	mov	es, ax			; 数据段选择子
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子
	mov	ax, SelectorStack0
	mov	ss, ax			; 堆栈段选择子
	mov	esp, TopOfStack0
	
	call	Init8259A	; 启动外部中断
	
	push	szMemChkTitle;显示内存信息标题
	call	DispStr
	add	esp, 4
	call	DispMemSize		; 显示内存信息
	
	call	SetupPaging		; 启动页表0和1
	
	;jmp SelectorLDT0Code:0	;进入task0
	push	SelectorLDT0UserStack
	push	TopOfUserStack0
	push	SelectorLDT0Code
	push	0
	sti
	retf

	jmp $

; Task0
LABEL_TASK0:
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子(目的)

	mov	edi, (80 * 1 + 50) * 2	; 屏幕第 1 行, 第 50 列。
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'A'
	mov	[gs:edi], ax

	int 20h
	jmp LABEL_TASK0
	
LEN_TASK0 equ $-LABEL_TASK0

; Task1
LABEL_TASK1:
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子(目的)

	mov	edi, (80 * 1 + 50) * 2	; 屏幕第 1 行, 第 50 列。
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'B'
	mov	[gs:edi], ax

	int 20h
	jmp LABEL_TASK1
	
LEN_TASK1 equ $-LABEL_TASK1

; 中断处理程序 ---------------------------------------------------------------
_ClockHandler:		; int 20h 由8259A-IRQ0产生
ClockHandler	equ	_ClockHandler - $$
	mov	ax, SelectorData
	mov	es, ax 
	mov eax, [es:currentTask]
	cmp eax,0
	je	short IFEQZERO
IFEQONE:
	mov eax,0
	mov dword [es:currentTask],eax
	mov	al, 20h
	out	20h, al				; 发送 EOI
	call io_delay
	jmp SelectorTSS0:0
	jmp short IFFINISH
IFEQZERO:
	mov eax,1
	mov dword [es:currentTask],eax
	mov	al, 20h
	out	20h, al				; 发送 EOI
	call io_delay
	jmp SelectorTSS1:0
IFFINISH:
	iretd

_UserIntHandler:	; int 80h
UserIntHandler	equ	_UserIntHandler - $$
	mov	ah, 0Ch				; 0000: 黑底    1100: 红字
	mov	al, 'I'
	mov	[gs:((80 * 0 + 70) * 2)], ax	; 屏幕第 0 行, 第 70 列。
	iretd

_SpuriousHandler:	; int 其它
SpuriousHandler	equ	_SpuriousHandler - $$
	mov	ah, 0Ch				; 0000: 黑底    1100: 红字
	mov	al, '!'
	mov	[gs:((80 * 0 + 75) * 2)], ax	; 屏幕第 0 行, 第 75 列。
	jmp	$
	iretd
; 中断处理程序end ---------------------------------------------------------------------------

; 初始化8259A ---------------------------------------------------------------------------------------------
Init8259A:
	mov	al, 011h
	out	020h, al	; 主8259, ICW1.
	call	io_delay

	out	0A0h, al	; 从8259, ICW1.
	call	io_delay

	mov	al, 020h	; IRQ0 对应中断向量 0x20
	out	021h, al	; 主8259, ICW2.
	call	io_delay

	mov	al, 028h	; IRQ8 对应中断向量 0x28
	out	0A1h, al	; 从8259, ICW2.
	call	io_delay

	mov	al, 004h	; IR2 对应从8259
	out	021h, al	; 主8259, ICW3.
	call	io_delay

	mov	al, 002h	; 对应主8259的 IR2
	out	0A1h, al	; 从8259, ICW3.
	call	io_delay

	mov	al, 001h
	out	021h, al	; 主8259, ICW4.
	call	io_delay

	out	0A1h, al	; 从8259, ICW4.
	call	io_delay

	;mov	al, 11111111b	; 屏蔽主8259所有中断
	mov	al, 11111110b	; 仅仅开启定时器中断
	out	021h, al	; 主8259, OCW1.
	call	io_delay

	mov	al, 11111111b	; 屏蔽从8259所有中断
	out	0A1h, al	; 从8259, OCW1.
	call	io_delay

	ret
	
io_delay:
	nop
	nop
	nop
	nop
	ret
; 初始化8259A完毕 ---------------------------------------------------------------------------------------------

; 显示内存信息 --------------------------------------------------------------
DispMemSize:
	push	esi
	push	edi
	push	ecx

	mov	esi, MemChkBuf
	mov	ecx, [dwMCRNumber]	;for(int i=0;i<[MCRNumber];i++) // 每次得到一个ARDS(Address Range Descriptor Structure)结构
.loop:					;{
	mov	edx, 5			;	for(int j=0;j<5;j++)	// 每次得到一个ARDS中的成员，共5个成员
	mov	edi, ARDStruct		;	{			// 依次显示：BaseAddrLow，BaseAddrHigh，LengthLow，LengthHigh，Type
.1:					;
	push	dword [esi]		;
	call	DispInt			;		DispInt(MemChkBuf[j*4]); // 显示一个成员
	pop	eax			;
	stosd				;		ARDStruct[j*4] = MemChkBuf[j*4];
	add	esi, 4			;
	dec	edx			;
	cmp	edx, 0			;
	jnz	.1			;	}
	call	DispReturn		;	printf("\n");
	cmp	dword [dwType], 1	;	if(Type == AddressRangeMemory) // AddressRangeMemory : 1, AddressRangeReserved : 2
	jne	.2			;	{
	mov	eax, [dwBaseAddrLow]	;
	add	eax, [dwLengthLow]	;
	cmp	eax, [dwMemSize]	;		if(BaseAddrLow + LengthLow > MemSize)
	jb	.2			;
	mov	[dwMemSize], eax	;			MemSize = BaseAddrLow + LengthLow;
.2:					;	}
	loop	.loop			;}
					;
	call	DispReturn		;printf("\n");
	push	szRAMSize		;
	call	DispStr			;printf("RAM size:");
	add	esp, 4			;
					;
	push	dword [dwMemSize]	;
	call	DispInt			;DispInt(MemSize);
	add	esp, 4			;

	pop	ecx
	pop	edi
	pop	esi
	ret
; ---------------------------------------------------------------------------

; 启动分页机制 --------------------------------------------------------------
SetupPaging:
	; 根据内存大小计算应初始化多少PDE以及多少页表
	xor	edx, edx
	mov	eax, [dwMemSize]
	mov	ebx, 400000h	; 400000h = 4M = 4096 * 1024, 一个页表对应的内存大小
	div	ebx
	mov	ecx, eax	; 此时 ecx 为页表的个数，也即 PDE 应该的个数
	test	edx, edx
	jz	.no_remainder
	inc	ecx		; 如果余数不为 0 就需增加一个页表
.no_remainder:
	mov	[PageTableNumber], ecx	; 暂存页表个数

	; 为简化处理, 所有线性地址对应相等的物理地址. 并且不考虑内存空洞.

	; 首先初始化页目录0
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov	edi, PageDirBase0	; 此段首地址为 PageDirBase0
	xor	eax, eax
	mov	eax, PageTblBase0 | PG_P  | PG_USU | PG_RWW
.1:
	stosd
	add	eax, 4096		; 为了简化, 所有页表在内存中是连续的.
	loop	.1

	; 再初始化所有页表
	mov	eax, [PageTableNumber]	; 页表个数
	mov	ebx, 1024		; 每个页表 1024 个 PTE
	mul	ebx
	mov	ecx, eax		; PTE个数 = 页表个数 * 1024
	mov	edi, PageTblBase0	; 此段首地址为 PageTblBase0
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; 每一页指向 4K 的空间
	loop	.2
	
	; 首先初始化页目录1
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov	edi, PageDirBase1	; 此段首地址为 PageDirBase1
	xor	eax, eax
	mov	eax, PageTblBase1 | PG_P  | PG_USU | PG_RWW
	mov	ecx, [PageTableNumber]
.3:
	stosd
	add	eax, 4096		; 为了简化, 所有页表在内存中是连续的.
	loop	.3

	; 再初始化所有页表
	mov	eax, [PageTableNumber]	; 页表个数
	mov	ebx, 1024		; 每个页表 1024 个 PTE
	mul	ebx
	mov	ecx, eax		; PTE个数 = 页表个数 * 1024
	mov	edi, PageTblBase1	; 此段首地址为 PageTblBase1
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.4:
	stosd
	add	eax, 4096		; 每一页指向 4K 的空间
	loop	.4
	
	mov	eax, PageDirBase0
	mov	cr3, eax
	mov	eax, cr0
	or	eax, 80000000h
	mov	cr0, eax
	jmp	short .5
.5:
	nop

	ret
; 分页机制启动完毕 ----------------------------------------------------------

%include	"lib.inc"	; 库函数

SegCode32Len	equ	$ - LABEL_SEG_CODE32
; END of [SECTION .s32]