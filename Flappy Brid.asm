.386
.model flat,stdcall
option casemap:none
include windows.inc
include user32.inc
includelib user32.lib
include gdi32.inc
includelib gdi32.lib
include kernel32.inc
includelib kernel32.lib
include msimg32.inc
includelib msimg32.lib
.data?
hInstance dd ?
hdcMem dd ?;�ڴ�DC,����������ͼ��Ȼ��һ��������������
hdcBird dd ?;�ڴ�DC,��������ͼƬ�ز�
SrcX dd ?;���ھ���X����
SrcY dd ?;���ھ���Y����
w dd ?;���ڿ�
h dd ?;���ڸ�
n dd ?;������������
idTime dd ?;���������������½�
idTime2 dd ?;����������Ϸ����
YButton1 dd ?;��ʼ��ť��λ��(���º͵���)
YButton2 dd ?;�������а�ťλ��
Source dd ?;����
nPillar dd ?;��������(����ѭ��)
hPillar1 dd ?;��һ�����ӵĸ߶�
hPillar2 dd ?;�ڶ������ӵĸ߶�
Count dd ?;���ֵ�λ��
RectBird RECT <>;С��ľ���(�����ж�С���Ƿ���������ײ)
hitRgn dd ?;����������������
index dd ?;������������
NumberOne dd ?;��һ���������±�
Ranking dd ?;��ǰ������
.data
cxPillar1 dd 358;��һ�����ӳ�ʼX����
cxPillar2 dd 528;�ڶ������ӳ�ʼX����
cyi dd 3;�����ƶ��ĸ߶�
cxBird dd 127;���X����
cyBird dd 190;���Y���꣬���������ƶ�
ReDraw1 byte TRUE;�Ƿ��ػ�����
ReDraw2 byte TRUE;�ڶ�������
Begin byte FALSE;��Ϸ�Ƿ�ʼ
GameOver byte FALSE;��Ϸ�Ƿ����
Click byte FALSE;����Ƿ���
Ready byte FALSE;��Ϸ��ʼ���Ƿ��������
Rank byte FALSE;�Ƿ����˻�������
Hit byte FALSE;�Ƿ�ײ������
rect1 RECT <25,343,129,401>;��ʼ��ť�ľ��Σ������ṹ�� (rect RECT <> ȡ�ṹ��ԭ��ʼֵ)
rect2 RECT <184,343,242,401>;�������а�ť��֪��
YBird dd 1032,464,34,24,1088,464,34,24,1144,464,34,24;���������
RBird dd 0;���������
BBird dd 0;���������
Floor dd 584,0,288,111,592,0,288,111,600,0,288,111;���������
Result dd 992,120,24,36,1298,392,15,36,584,320,24,36,612,320,24,36,640,320,24,36,668,320,24,36,584,368,24,36,612,368,24,36,640,368,24,36,668,368,24,36;�ɼ�(0��9������)
Gold dd 1268,46,44,44,1250,388,44,44,1250,436,44,44,1268,0,44,41
hRgn dd 4 dup(0);���ӵ�����,�����жϾ����Ƿ��ཻ
szSource db 10 dup(0)
Best dd 4 dup(0);�÷�����
.const
IDB_BITMAP1 equ 101
IDI_ICON1 equ 102
ID_TIMER1 equ 201
ID_TIMER2 equ 202
ID_TIMER3 equ 203
IDM_ABOUT equ 301
rech equ 150 ;С��ͨ���߶�
szWndCls db 'Flappy',0
szWndCap db 'Flappy Bird',0
szAbout db '����Flappy Bird',0
szText db 'Flappy Bird',0Dh,0Dh,'���ߣ���ȥ�ķ�  (QQ:243303453)',0Dh,0Dh,'2014-09-21(��ʼ����)',0Dh,0Dh,'�϶�������д...',0Dh,0Dh,'2014-10-19(�������)',0
szCaption db '���� Flappy Bird',0
szFontName db '����',0
szFormat db '%4d',0;�����������
szBest db '%d,%d,%d,%d',0
.code
NumBer proc;�������ֵ�X����
	xor edx,edx
	mov eax,24;����24
	mul Count;�����ܳ���
	mov ebx,eax
	mov eax,288;���ڳ���
	sub eax,ebx;��ȥ����ʣ�³���
	mov ebx,2
	div ebx;��һ����Ҫ����X����
	Ret
NumBer endp
;Rand_Number = (Rand_Seed * X + Y) mod Z 
Rnd proc uses ecx edx First:DWORD,Second:DWORD
	invoke GetTickCount;������������
	mov ecx,23
	mul ecx
	add eax,7
	mov ecx,Second;����
	sub ecx,First;����-����
	inc ecx
	xor edx,edx
	div ecx
	add edx,First
	mov eax,edx
	Ret
Rnd endp
DrawSource proc;������
	local d1,d2,d3,d4
	xor edx,edx;��0�����˳�����
	mov eax,Source;��ǰ����
	mov ebx,1000;ǧλ(���Ұѻ�����������Ϊ9999)
	div ebx;�жϻ����Ƿ񳬹�1000
	.if eax>=1;������ִ���1000
		add Count,1;λ���ۼ�1
		mov d1,eax;ǧλ��ֵ
	.endif
	xor edx,edx
	mov eax,Source
	mov ebx,100;�жϻ����Ƿ񳬹�100
	div ebx
	.if eax>=1
		add Count,1;��λ��
		mov d2,eax;��λ��ֵ
	.endif
	xor edx,edx
	mov eax,Source
	mov ebx,10
	div ebx
	.if eax>=1
		add Count,1;��λ��
		mov d3,eax;ʮλ��ֵ
	.endif
	add Count,1;һλ��
	mov d4,edx;��λ����ֵ
	.if Count>=4;�����4λ��
		invoke NumBer;�����һ�����ֵ�X����
		mov ebx,eax
		mov eax,16
		mul d1;���ϡ����߹��ĸ�Ԫ�أ�ÿ��Ԫ��ռ4���ֽڣ�����*16������һ������
		invoke TransparentBlt,hdcMem,ebx,50,24,36,hdcBird,Result[eax],Result[eax+4],Result[eax+8],Result[eax+12],0FF0000h;��ǧλ��
	.endif
	.if Count>=3
		invoke NumBer
		push eax;����һ������ѹ��ջ
		xor edx,edx;��0,��������
		mov eax,d2;������
		mov ebx,10;����
		div ebx;����
		mov d2,edx;���������λ�����̴���10,������Ҫ��10������
		sub Count,3;����ǵ�nλ��������Ҫ�����ƶ�(n-1)*24������
		xor edx,edx;��0
		mov eax,24
		mul Count
		add Count,3;��ԭ
		pop ebx;ȡ����һ��X����
		add ebx,eax;�����nλ��X����
		mov eax,16
		mul d2
		invoke TransparentBlt,hdcMem,ebx,50,24,36,hdcBird,Result[eax],Result[eax+4],Result[eax+8],Result[eax+12],0FF0000h;����λ��
	.endif
	.if Count>=2
		invoke NumBer
		push eax;����һ������ѹ��ջ
		xor edx,edx;��0,��������
		mov eax,d3;������
		mov ebx,10;����
		div ebx;����
		mov d3,edx;���������λ�����̴���10,������Ҫ��10������
		sub Count,2;����ǵ�nλ��������Ҫ�����ƶ�(n-1)*24������
		xor edx,edx;��0
		mov eax,24
		mul Count
		add Count,2;��ԭ
		pop ebx;ȡ����һ��X����
		add ebx,eax;�����nλ��X����
		mov eax,16
		mul d3
		invoke TransparentBlt,hdcMem,ebx,50,24,36,hdcBird,Result[eax],Result[eax+4],Result[eax+8],Result[eax+12],0FF0000h;��ʮλ��
	.endif
	.if Count>=1
		invoke NumBer
		push eax;����һ������ѹ��ջ
		dec Count;����ǵ�nλ��������Ҫ�����ƶ�(n-1)*24������
		xor edx,edx;��0
		mov eax,24
		mul Count
		inc Count;��ԭ
		pop ebx;ȡ����һ��X����
		add ebx,eax;�����nλ��X����
		mov eax,16
		mul d4
		invoke TransparentBlt,hdcMem,ebx,50,24,36,hdcBird,Result[eax],Result[eax+4],Result[eax+8],Result[eax+12],0FF0000h;����λ��
	.endif
	mov Count,0
	Ret
DrawSource endp
DrawPillar proc;������
sub cxPillar1,5;ÿ������X����-5
	sub cxPillar2,5
	.if ReDraw1==TRUE;������ӵ��������Ҫ�ػ�
		invoke Rnd,100,250;����50��300�������
		mov hPillar1,eax;��һ�����ӵĸ߶�
		mov ReDraw1,FALSE;�����¼������Ӹ߶�
	.endif
	.if ReDraw2==TRUE
		invoke Rnd,100,250
		mov hPillar2,eax
		mov ReDraw2,FALSE
	.endif
	mov ebx,448;128��ʼ����+320�߶�
	sub ebx,hPillar1;��ȡ��ʼ����
	invoke TransparentBlt,hdcMem,cxPillar1,0,52,hPillar1,hdcBird,1138,ebx,52,hPillar1,0FF0000h;�������һ������
	mov eax,cxPillar1
	add eax,52
	invoke CreateRectRgn,cxPillar1,0,eax,hPillar1;������һ������
	mov [hRgn],eax;�����򱣴�������
	mov eax,hPillar1
	add eax,rech;�м�ճ�����С�񴩹�
	mov ebx,401;�ܸ߶�
	sub ebx,eax;�������ӵĸ߶�
	pushad;�������
	invoke TransparentBlt,hdcMem,cxPillar1,eax,52,ebx,hdcBird,1194,128,52,ebx,0FF0000h;�������һ������
	popad;��ԭ����
	mov edx,cxPillar1
	add edx,52
	add ebx,eax
	invoke CreateRectRgn,cxPillar1,eax,edx,ebx;�����ڶ�������
	mov [hRgn+4],eax;�����򱣴�������(������˫��,Ҳ����+4Ϊ��һԪ��)
	mov ebx,448
	sub ebx,hPillar2
	invoke TransparentBlt,hdcMem,cxPillar2,0,52,hPillar2,hdcBird,1138,ebx,52,hPillar2,0FF0000h;������ڶ�������
	mov eax,cxPillar2
	add eax,52
	invoke CreateRectRgn,cxPillar2,0,eax,hPillar2;��������������
	mov [hRgn+8],eax
	mov eax,hPillar2
	add eax,rech
	mov ebx,401
	sub ebx,eax
	pushad;�������
	invoke TransparentBlt,hdcMem,cxPillar2,eax,52,ebx,hdcBird,1194,128,52,ebx,0FF0000h;������ڶ�������
	popad;��ԭ����
	mov ecx,cxPillar2
	add ecx,52
	add ebx,eax
	invoke CreateRectRgn,cxPillar2,eax,ecx,ebx;�������ĸ�����
	mov [hRgn+12],eax
	.if cxPillar1<=18 && cxPillar1>13 || cxPillar2<=18 && cxPillar2>13;�����һ���������ӹ������λ��,����+1
		inc Source
	.endif
	.if cxPillar1>0FFFFh && cxPillar1<=-52;��������˼��������ұ߿�ʼ
		mov cxPillar1,288;��һ�����ӻص����ұ�
		mov ReDraw1,TRUE;���¼������Ӹ�
	.endif
	.if cxPillar2>0FFFFh && cxPillar2<=-52;
		mov cxPillar2,288
		mov ReDraw2,TRUE
	.endif
	Ret
DrawPillar endp
TimerProc3 proc hwnd,msg,IdEvent,dwTime;��Ϸ��������
	mov eax,IdEvent
	.if eax==ID_TIMER3
		add idTime2,1
		.if idTime2==1
			invoke TransparentBlt,hdcMem,55,120,192,42,hdcBird,790,118,192,42,0FF0000h;��GAME OVER
		.elseif idTime2==2
			invoke TransparentBlt,hdcMem,25,343,104,58,hdcBird,708,236,104,58,0FF0000h;����ʼ��ť
			invoke TransparentBlt,hdcMem,159,343,104,58,hdcBird,828,236,104,58,0FF0000h;����������
			mov cyBird,190;��ԭС��ķ��и߶�
			mov cyi,3;�ָ�����С�����ƶ�
		.elseif idTime2==3
			invoke TransparentBlt,hdcMem,31,182,226,115,hdcBird,1032,0,226,115,0FF0000h;�����յ÷�
		.elseif idTime2==4
			mov ecx,0;������ѭ��������
			.while ecx<4
				mov eax,[Best+ecx*4];�����׵�ַ(˫������4�ֽ�,����+4*n)
				.if Source>=eax
					mov Ranking,ecx;���浱ǰ���ֵ�����,����������
					mov Best[ecx*4+4],eax;�����ǰ�÷�����߷�,���֮ǰ����߷�������
					mov eax,Source;��ȡ����
					mov Best[ecx*4],eax;��������������Ԫ�رȽ�,�����߷�
					.if ecx==0
						mov NumberOne,ecx;��һ���������±�
					.endif
					.break
				.else
					mov NumberOne,0;������ȵ�һ��Ԫ�ش�,���һ��Ԫ�ؾ�����߷�
				.endif
				inc ecx
			.endw
			xor edx,edx
			mov eax,16
			mul Ranking;��ǰ�������ڵĽ���
			invoke TransparentBlt,hdcMem,58,224,44,44,hdcBird,Gold[eax],Gold[eax+4],Gold[eax+8],Gold[eax+12],0FF0000h;������
		.elseif idTime2==5
			invoke wsprintf,offset szSource,offset szFormat,Source
			invoke TextOut,hdcMem,180,210,offset szSource,4;���������ڴ�����
			mov eax,NumberOne;��ȡ��߷������±�
			invoke wsprintf,offset szSource,offset szFormat,[Best+eax]
			invoke TextOut,hdcMem,180,253,offset szSource,4;����߷ֻ��ڴ�����
			mov Source,0;������0
			mov idTime2,0;��ԭ��ʱ
			mov Ready,FALSE;ȡ��׼��
			mov Begin,FALSE;ȡ����ʼ
			mov Click,FALSE;��ʼ��ť���Ե��
			mov GameOver,TRUE;��־��Ϸ���������Ե㿪ʼ��ť��
			invoke KillTimer,hwnd,ID_TIMER3;ֹͣ��Ϸ������ʱ
		.endif
		invoke InvalidateRect,hwnd,NULL,FALSE;ʹ������Ч���ᷢ��WM_PAINT��Ϣ������
		invoke UpdateWindow,hwnd;���´��ڣ���������һ��WM_PAINT��Ϣ������
	.endif
	Ret
TimerProc3 endp
TimerProc2 proc hwnd,msg,IdEvent,dwTime;С���½�
	mov eax,IdEvent
	.if eax==ID_TIMER2
		add idTime,1
		.if idTime==2
			mov idTime,0;���¼�ʱ
			mov cyi,15;�����½�
			invoke KillTimer,hwnd,IdEvent
		.endif
		sub cyBird,15;С����ٷ��и߶�
	.endif
	Ret
TimerProc2 endp
GameEnd proc hwnd
	invoke KillTimer,hwnd,ID_TIMER1;ֹͣ��ʱ
	invoke RtlZeroMemory,offset hRgn,16;��������գ������´ο�ʼֱ��ͣס����
	mov cxPillar1,358;��һ�����ӻ�ԭ��ʼλ��
	mov cxPillar2,528;�ڶ������ӻ�ԭ��ʼλ��
	.if Hit==FALSE;�������ײ������������ڵ���
		mov eax,index
		invoke TransparentBlt,hdcMem,cxBird,377,34,24,hdcBird,YBird[eax],YBird[eax+4],YBird[eax+8],YBird[eax+12],0FF0000h;�������û��ڵ�����
	.endif
	mov Hit,FALSE
	invoke SetTimer,hwnd,ID_TIMER3,200,offset TimerProc3;��Ϸ��������
	Ret
GameEnd endp
IsHit proc hwnd;���Ƿ�ײ������
	invoke RectInRegion,[hRgn],offset RectBird;�����Ƿ��ཻ
	.if eax>0
		jmp s
	.endif
	invoke RectInRegion,[hRgn+4],offset RectBird;�����Ƿ��ཻ
	.if eax>0
		jmp s
	.endif
	invoke RectInRegion,[hRgn+8],offset RectBird;�����Ƿ��ཻ
	.if eax>0
		jmp s
	.endif
	invoke RectInRegion,[hRgn+12],offset RectBird;�����Ƿ��ཻ
	.if eax>0
		jmp s
	.endif
	Ret
s:
	mov Hit,TRUE;��ʾ����ײ
	invoke GameEnd,hwnd;��Ϸ����
	ret
IsHit endp
TimerProc proc hwnd,msg,IdEvent,dwTime
	mov eax,IdEvent
	.if eax==ID_TIMER1
		invoke TransparentBlt,hdcMem,0,0,288,512,hdcBird,0,0,288,512,0FF0000h;������
		mov eax,16;�ܹ�4������(X,Y,��,��),ÿ������4���ֽ�,���ÿһ��16�ֽ�
		mul n;������
		mov index,eax
		invoke TransparentBlt,hdcMem,0,401,335,111,hdcBird,Floor[eax],Floor[eax+4],Floor[eax+8],Floor[eax+12],0FF0000h;������
		.if Begin==TRUE
			.if Ready==FALSE
				invoke TransparentBlt,hdcMem,55,120,177,47,hdcBird,590,118,184,50,0FF0000h;��Get Ready
				invoke TransparentBlt,hdcMem,87,190,114,98,hdcBird,584,182,114,98,0FF0000h;������ʾͼ
			.else
				invoke DrawPillar;������
			.endif
			invoke DrawSource;������
		.else
			invoke TransparentBlt,hdcMem,25,YButton1,104,58,hdcBird,708,236,104,58,0FF0000h;����ʼ��ť
			invoke TransparentBlt,hdcMem,159,YButton2,104,58,hdcBird,828,236,104,58,0FF0000h;����������
			invoke TransparentBlt,hdcMem,55,120,177,47,hdcBird,702,182,177,47,0FF0000h;��FlappyBird
			invoke TransparentBlt,hdcMem,83,421,122,10,hdcBird,886,184,122,10,0FF0000h;��(c) .GAROS 2013
		.endif
		.if Ready==FALSE;�����Ϸ��ʼ��δ�������
			mov eax,cyi
			add cyBird,eax
		.else;��ʼ���к�������µ�
			mov eax,cyi;һ���½��ĸ߶�
			add cyBird,eax;С���Y�������ӣ��൱���½�
		.endif
		mov eax,index
		.if cyBird<375;���û��ײ������
			invoke TransparentBlt,hdcMem,cxBird,cyBird,34,24,hdcBird,YBird[eax],YBird[eax+4],YBird[eax+8],YBird[eax+12],0FF0000h;������(ÿ������4�ֽ�)
			mov eax,cxBird;�������X����Ӿ��ο���Ǿ����ұ�X����
			add eax,34
			mov ebx,cyBird
			add ebx,24
			invoke SetRect,offset RectBird,cxBird,cyBird,eax,ebx;������ľ���
			invoke IsHit,hwnd;�����Ƿ��ཻ
		.endif
		add n,1
		.if n==3
			mov n,0
			.if Ready==FALSE;δ��ʼ����ʱ�����ƶ�����λ��
				mov eax,cyi
				mov ebx,-1
				mul ebx
				mov cyi,eax;�����ƶ���ͨ���ı�ֵ���������ı�
			.endif
		.endif
		.if cyBird<512
			.if cyBird>=375;���ײ������
				invoke GameEnd,hwnd;��Ϸ�����Ĵ���
			.endif
		.endif
		invoke InvalidateRect,hwnd,NULL,FALSE;ʹ������Ч���ᷢ��WM_PAINT��Ϣ������
		invoke UpdateWindow,hwnd;���´��ڣ���������һ��WM_PAINT��Ϣ������
	.endif
	Ret
TimerProc endp
InitGame proc hwnd;��ʼ����Ϸ
	local hdc:HDC,hMenu:HMENU,hFont:HFONT,LogFont:LOGFONT
	invoke GetDC,hwnd;��ȡ���ڻ����豸
	mov hdc,eax
	invoke CreateCompatibleDC,hdc;���������ڴ�DC,��������ͼƬ
	mov hdcBird,eax
	invoke CreateCompatibleDC,hdc;��������DC���������洰�ڽ���
	mov hdcMem,eax
	invoke CreateCompatibleBitmap,hdc,288,512;��������λͼ����������ڴ�DC�������ڴ�DC�Ĵ�СΪ1��ֻ�кڰ�
	push eax
	invoke SelectObject,hdcMem,eax;��λͼѡ���ڴ�DC
	pop eax
	invoke DeleteObject,eax;ɾ��λͼ
	invoke SetBkMode,hdcMem,TRANSPARENT;����䱳������Ϊ͸��
	invoke SetTextColor,hdcMem,0CAC04Eh;��������Ϊ��ɫ
	invoke RtlZeroMemory,addr LogFont,sizeof LogFont;��ʼ������ṹ
	invoke RtlMoveMemory,addr LogFont.lfFaceName,offset szFontName,sizeof szFontName;������
	mov LogFont.lfHeight,30;�����С
	mov LogFont.lfWeight,700;����(����Ϊ400,����Ϊ700)
	invoke CreateFontIndirect,addr LogFont;��������
	invoke SelectObject,hdcMem,eax;������ѡ���ڴ�DC
	invoke LoadImage,hInstance,IDB_BITMAP1,IMAGE_BITMAP,0,0,0;����ͼƬ
	push eax
	invoke SelectObject,hdcBird,eax;��ͼƬѡ���ڴ�DC
	pop eax
	invoke DeleteObject,eax;ɾ�����ص�ͼƬ���ͷ��ڴ�
	invoke ReleaseDC,hwnd,hdc;�ͷŴ���DC
	invoke GetSystemMenu,hwnd,FALSE;��ȡϵͳ�˵�
	mov hMenu,eax
	invoke AppendMenu,hMenu,MF_STRING,IDM_ABOUT,offset szAbout;���ϵͳ�˵���(����)
	Ret
InitGame endp
WndProc proc hwnd,msg,wparam,lparam
	local hdc:HDC,ps:PAINTSTRUCT,pt:POINT
	mov eax,msg
	.if eax==WM_PAINT
		invoke BeginPaint,hwnd,addr ps
		mov hdc,eax
		invoke TransparentBlt,hdc,0,0,288,511,hdcMem,0,0,288,511,0ff0000h
		invoke EndPaint,hwnd,addr ps
	.elseif eax==WM_LBUTTONDOWN
		.if Begin==FALSE
			mov eax,lparam
			and eax,0FFFFh;��λΪX����
			mov pt.x,eax
			mov edx,0
			mov eax,lparam
			mov ebx,010000h;��λΪY����,�൱������16λ
			div ebx
			mov pt.y,eax
			invoke PtInRect,offset rect1,pt.x,pt.y;�������Ƿ��ڿ�ʼ��ť���δ����
			.if eax==TRUE
				mov YButton1,345;��ʼ��ť������
				mov Click,TRUE
			.endif
			invoke PtInRect,offset rect2,pt.x,pt.y
			.if eax==TRUE
				mov YButton2,345;�������а�ť������
				mov Click,TRUE
				mov Rank,TRUE
			.endif
		.else
			mov Ready,TRUE;С��ʼ����
			.if cyBird<0FFFFh;���û�зɹ���(�������ò��������棬�����if xx<0����Զ����������������)
				mov cyi,0;С�񲻿����½�(��ΪҪ����)
				sub cyBird,15;Ϊ����Ӧһ��ͻ�����(Timer�ص���������Ҫִ��100ms������ʱ)
				invoke SetTimer,hwnd,ID_TIMER2,80,offset TimerProc2
			.else
				mov cyBird,0;����ɹ�������������- -!
			.endif
		.endif
	.elseif eax==WM_LBUTTONUP
		.if Begin==FALSE;�����Ϸδ��ʼ
			.if Click==TRUE;�������˰�ť
				.if Rank==TRUE;������˻�������
					mov YButton2,343
					mov Rank,FALSE
				.else
					mov YButton1,344;��ʼ��ť����
					mov cxBird,70
					mov Begin,TRUE
					.if GameOver==TRUE
						mov GameOver,FALSE
						invoke SetTimer,hwnd,ID_TIMER1,80,offset TimerProc;�����Ϸ�����ˣ���ʼ��Ϸ
					.endif
				.endif
			.endif
		.endif
	.elseif eax==WM_SYSCOMMAND;ϵͳ�˵�Ҫ��ӦWM_SYSCOMMAND
		mov eax,wparam
		and eax,0ffffh
		.if eax==IDM_ABOUT
			invoke MessageBox,hwnd,offset szText,offset szCaption,MB_OK
		.else
			invoke DefWindowProc,hwnd,msg,wparam,lparam;��Ҫ����Ϣ����Ĭ�ϴ��ڹ��̣���Ȼ������Ӧ
			ret
		.endif
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hwnd
		invoke PostQuitMessage,0
	.elseif eax==WM_CREATE
		invoke InitGame,hwnd;��Ϸ��ʼ��
		mov YButton1,343;��ʼ��ť��Y����
		mov YButton2,343;�������а�ť��Y����
		invoke SetTimer,hwnd,ID_TIMER1,80,offset TimerProc;��ʼ��ʱ��
	.else
		invoke DefWindowProc,hwnd,msg,wparam,lparam
		ret
	.endif
	Ret
WndProc endp
WinMain proc
	local hwnd:HWND,msg:MSG,wndclass:WNDCLASS
	invoke RtlZeroMemory,addr wndclass,sizeof wndclass
	invoke GetModuleHandle,NULL
	mov hInstance,eax
	mov wndclass.hInstance,eax
	invoke CreateSolidBrush,0c89632h
	mov wndclass.hbrBackground,eax
	invoke LoadIcon,hInstance,IDI_ICON1
	mov wndclass.hIcon,eax
	mov wndclass.lpfnWndProc,offset WndProc
	mov wndclass.lpszClassName,offset szWndCls
	mov wndclass.style,CS_HREDRAW or CS_VREDRAW
	invoke RegisterClass,addr wndclass
	mov h,512;��Ϸ���ڵĿ�͸�
	mov w,288
	invoke GetSystemMetrics,SM_CXDLGFRAME;�Ի���Ŀ��
		add eax,eax;���ߵĿ��
		add w,eax
	invoke GetSystemMetrics,SM_CYDLGFRAME;�Ի���ĸ߶�
		add eax,eax
		add h,eax
	invoke GetSystemMetrics,SM_CYCAPTION;��ȡ����߶�
		add h,eax
	invoke GetSystemMetrics,SM_CXSCREEN;��Ļ�Ŀ��
		mov edx,0;������32λ�ģ����Ա�������������edx�����Ҫ���edx��ֵ����Ȼ�����
		sub eax,w
		mov ebx,2
		div ebx
		mov SrcX,eax;���ھ��е�X
	invoke GetSystemMetrics,SM_CYSCREEN;��Ļ�ĸ߶�
		mov edx,0
		sub eax,h
		mov ebx,2
		div ebx
		mov SrcY,eax;���ھ��е�Y����
	invoke CreateWindowEx,0,offset szWndCls,offset szWndCap,WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX,SrcX,SrcY,w,h,0,0,hInstance,0
	mov hwnd,eax
	invoke ShowWindow,hwnd,SW_SHOW
	invoke UpdateWindow,hwnd
	.while TRUE
		invoke GetMessage,addr msg,0,0,0
		.break .if eax==0
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	Ret
WinMain endp
start:
	call WinMain
	invoke ExitProcess,0
end start