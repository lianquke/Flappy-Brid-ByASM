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
hdcMem dd ?;内存DC,用来保存贴图，然后一次性贴到窗口上
hdcBird dd ?;内存DC,用来保存图片素材
SrcX dd ?;窗口居中X坐标
SrcY dd ?;窗口居中Y坐标
w dd ?;窗口宽
h dd ?;窗口高
n dd ?;地面和鸟的坐标
idTime dd ?;用来持续上升或下降
idTime2 dd ?;用来处理游戏结束
YButton1 dd ?;开始按钮的位置(按下和弹起)
YButton2 dd ?;分数排行按钮位置
Source dd ?;积分
nPillar dd ?;柱子数量(用来循环)
hPillar1 dd ?;第一根柱子的高度
hPillar2 dd ?;第二根柱子的高度
Count dd ?;积分的位数
RectBird RECT <>;小鸟的矩形(用来判断小鸟是否与柱子相撞)
hitRgn dd ?;用来计数矩形区域
index dd ?;鸟的坐标的数组
NumberOne dd ?;第一名的数组下标
Ranking dd ?;当前的排名
.data
cxPillar1 dd 358;第一根柱子初始X坐标
cxPillar2 dd 528;第二根柱子初始X坐标
cyi dd 3;上下移动的高度
cxBird dd 127;鸟的X坐标
cyBird dd 190;鸟的Y坐标，用来上下移动
ReDraw1 byte TRUE;是否重画柱子
ReDraw2 byte TRUE;第二根柱子
Begin byte FALSE;游戏是否开始
GameOver byte FALSE;游戏是否结束
Click byte FALSE;鼠标是否按下
Ready byte FALSE;游戏开始后是否点击了鼠标
Rank byte FALSE;是否点击了积分排行
Hit byte FALSE;是否撞到柱子
rect1 RECT <25,343,129,401>;开始按钮的矩形，声明结构体 (rect RECT <> 取结构体原初始值)
rect2 RECT <184,343,242,401>;积分排行按钮的知形
YBird dd 1032,464,34,24,1088,464,34,24,1144,464,34,24;黄鸟的坐标
RBird dd 0;红鸟的坐标
BBird dd 0;蓝鸟的坐标
Floor dd 584,0,288,111,592,0,288,111,600,0,288,111;地面的坐标
Result dd 992,120,24,36,1298,392,15,36,584,320,24,36,612,320,24,36,640,320,24,36,668,320,24,36,584,368,24,36,612,368,24,36,640,368,24,36,668,368,24,36;成绩(0到9的坐标)
Gold dd 1268,46,44,44,1250,388,44,44,1250,436,44,44,1268,0,44,41
hRgn dd 4 dup(0);柱子的区域,用来判断矩形是否相交
szSource db 10 dup(0)
Best dd 4 dup(0);得分排行
.const
IDB_BITMAP1 equ 101
IDI_ICON1 equ 102
ID_TIMER1 equ 201
ID_TIMER2 equ 202
ID_TIMER3 equ 203
IDM_ABOUT equ 301
rech equ 150 ;小鸟通过高度
szWndCls db 'Flappy',0
szWndCap db 'Flappy Bird',0
szAbout db '关于Flappy Bird',0
szText db 'Flappy Bird',0Dh,0Dh,'作者：逝去的风  (QQ:243303453)',0Dh,0Dh,'2014-09-21(开始制作)',0Dh,0Dh,'断断续续编写...',0Dh,0Dh,'2014-10-19(完成制作)',0
szCaption db '关于 Flappy Bird',0
szFontName db '楷体',0
szFormat db '%4d',0;用来输出分数
szBest db '%d,%d,%d,%d',0
.code
NumBer proc;计算数字的X坐标
	xor edx,edx
	mov eax,24;数字24
	mul Count;数字总长度
	mov ebx,eax
	mov eax,288;窗口长度
	sub eax,ebx;除去数字剩下长度
	mov ebx,2
	div ebx;第一个字要画的X坐标
	Ret
NumBer endp
;Rand_Number = (Rand_Seed * X + Y) mod Z 
Rnd proc uses ecx edx First:DWORD,Second:DWORD
	invoke GetTickCount;获得随机数种子
	mov ecx,23
	mul ecx
	add eax,7
	mov ecx,Second;上限
	sub ecx,First;上限-下限
	inc ecx
	xor edx,edx
	div ecx
	add edx,First
	mov eax,edx
	Ret
Rnd endp
DrawSource proc;画积分
	local d1,d2,d3,d4
	xor edx,edx;清0用来乘除操作
	mov eax,Source;当前积分
	mov ebx,1000;千位(暂且把积分上限设置为9999)
	div ebx;判断积分是否超过1000
	.if eax>=1;如果积分大于1000
		add Count,1;位数累加1
		mov d1,eax;千位赋值
	.endif
	xor edx,edx
	mov eax,Source
	mov ebx,100;判断积分是否超过100
	div ebx
	.if eax>=1
		add Count,1;三位数
		mov d2,eax;百位赋值
	.endif
	xor edx,edx
	mov eax,Source
	mov ebx,10
	div ebx
	.if eax>=1
		add Count,1;两位数
		mov d3,eax;十位赋值
	.endif
	add Count,1;一位数
	mov d4,edx;个位数赋值
	.if Count>=4;如果是4位数
		invoke NumBer;计算第一个数字的X坐标
		mov ebx,eax
		mov eax,16
		mul d1;左、上、宽、高共四个元素，每个元素占4个字节，所以*16就是下一个数字
		invoke TransparentBlt,hdcMem,ebx,50,24,36,hdcBird,Result[eax],Result[eax+4],Result[eax+8],Result[eax+12],0FF0000h;画千位数
	.endif
	.if Count>=3
		invoke NumBer
		push eax;将第一个坐标压入栈
		xor edx,edx;清0,做除法用
		mov eax,d2;被除数
		mov ebx,10;除数
		div ebx;求商
		mov d2,edx;如果超过两位数则商大于10,所以需要求10的余数
		sub Count,3;如果是第n位数，则需要向右移动(n-1)*24个像素
		xor edx,edx;清0
		mov eax,24
		mul Count
		add Count,3;还原
		pop ebx;取出第一个X坐标
		add ebx,eax;计算第n位的X坐标
		mov eax,16
		mul d2
		invoke TransparentBlt,hdcMem,ebx,50,24,36,hdcBird,Result[eax],Result[eax+4],Result[eax+8],Result[eax+12],0FF0000h;画百位数
	.endif
	.if Count>=2
		invoke NumBer
		push eax;将第一个坐标压入栈
		xor edx,edx;清0,做除法用
		mov eax,d3;被除数
		mov ebx,10;除数
		div ebx;求商
		mov d3,edx;如果超过两位数则商大于10,所以需要求10的余数
		sub Count,2;如果是第n位数，则需要向右移动(n-1)*24个像素
		xor edx,edx;清0
		mov eax,24
		mul Count
		add Count,2;还原
		pop ebx;取出第一个X坐标
		add ebx,eax;计算第n位的X坐标
		mov eax,16
		mul d3
		invoke TransparentBlt,hdcMem,ebx,50,24,36,hdcBird,Result[eax],Result[eax+4],Result[eax+8],Result[eax+12],0FF0000h;画十位数
	.endif
	.if Count>=1
		invoke NumBer
		push eax;将第一个坐标压入栈
		dec Count;如果是第n位数，则需要向右移动(n-1)*24个像素
		xor edx,edx;清0
		mov eax,24
		mul Count
		inc Count;还原
		pop ebx;取出第一个X坐标
		add ebx,eax;计算第n位的X坐标
		mov eax,16
		mul d4
		invoke TransparentBlt,hdcMem,ebx,50,24,36,hdcBird,Result[eax],Result[eax+4],Result[eax+8],Result[eax+12],0FF0000h;画个位数
	.endif
	mov Count,0
	Ret
DrawSource endp
DrawPillar proc;画柱子
sub cxPillar1,5;每次柱子X坐标-5
	sub cxPillar2,5
	.if ReDraw1==TRUE;如果柱子到最左边需要重画
		invoke Rnd,100,250;产生50到300的随机数
		mov hPillar1,eax;第一根柱子的高度
		mov ReDraw1,FALSE;不重新计算柱子高度
	.endif
	.if ReDraw2==TRUE
		invoke Rnd,100,250
		mov hPillar2,eax
		mov ReDraw2,FALSE
	.endif
	mov ebx,448;128起始坐标+320高度
	sub ebx,hPillar1;获取起始坐标
	invoke TransparentBlt,hdcMem,cxPillar1,0,52,hPillar1,hdcBird,1138,ebx,52,hPillar1,0FF0000h;画上面第一根柱子
	mov eax,cxPillar1
	add eax,52
	invoke CreateRectRgn,cxPillar1,0,eax,hPillar1;创建第一个区域
	mov [hRgn],eax;将区域保存在数组
	mov eax,hPillar1
	add eax,rech;中间空出高让小鸟穿过
	mov ebx,401;总高度
	sub ebx,eax;下面柱子的高度
	pushad;保存参数
	invoke TransparentBlt,hdcMem,cxPillar1,eax,52,ebx,hdcBird,1194,128,52,ebx,0FF0000h;画下面第一根柱子
	popad;还原参数
	mov edx,cxPillar1
	add edx,52
	add ebx,eax
	invoke CreateRectRgn,cxPillar1,eax,edx,ebx;创建第二个区域
	mov [hRgn+4],eax;将区域保存在数组(类型是双字,也就是+4为下一元素)
	mov ebx,448
	sub ebx,hPillar2
	invoke TransparentBlt,hdcMem,cxPillar2,0,52,hPillar2,hdcBird,1138,ebx,52,hPillar2,0FF0000h;画上面第二根柱子
	mov eax,cxPillar2
	add eax,52
	invoke CreateRectRgn,cxPillar2,0,eax,hPillar2;创建第三个区域
	mov [hRgn+8],eax
	mov eax,hPillar2
	add eax,rech
	mov ebx,401
	sub ebx,eax
	pushad;保存参数
	invoke TransparentBlt,hdcMem,cxPillar2,eax,52,ebx,hdcBird,1194,128,52,ebx,0FF0000h;画下面第二根柱子
	popad;还原参数
	mov ecx,cxPillar2
	add ecx,52
	add ebx,eax
	invoke CreateRectRgn,cxPillar2,eax,ecx,ebx;创建第四个区域
	mov [hRgn+12],eax
	.if cxPillar1<=18 && cxPillar1>13 || cxPillar2<=18 && cxPillar2>13;如果第一、二根柱子过了鸟的位置,积分+1
		inc Source
	.endif
	.if cxPillar1>0FFFFh && cxPillar1<=-52;如果走完了继续从最右边开始
		mov cxPillar1,288;第一根柱子回到最右边
		mov ReDraw1,TRUE;重新计算柱子高
	.endif
	.if cxPillar2>0FFFFh && cxPillar2<=-52;
		mov cxPillar2,288
		mov ReDraw2,TRUE
	.endif
	Ret
DrawPillar endp
TimerProc3 proc hwnd,msg,IdEvent,dwTime;游戏结束处理
	mov eax,IdEvent
	.if eax==ID_TIMER3
		add idTime2,1
		.if idTime2==1
			invoke TransparentBlt,hdcMem,55,120,192,42,hdcBird,790,118,192,42,0FF0000h;画GAME OVER
		.elseif idTime2==2
			invoke TransparentBlt,hdcMem,25,343,104,58,hdcBird,708,236,104,58,0FF0000h;画开始按钮
			invoke TransparentBlt,hdcMem,159,343,104,58,hdcBird,828,236,104,58,0FF0000h;画分数排名
			mov cyBird,190;还原小鸟的飞行高度
			mov cyi,3;恢复上下小幅度移动
		.elseif idTime2==3
			invoke TransparentBlt,hdcMem,31,182,226,115,hdcBird,1032,0,226,115,0FF0000h;画最终得分
		.elseif idTime2==4
			mov ecx,0;用来作循环计数用
			.while ecx<4
				mov eax,[Best+ecx*4];数组首地址(双字型是4字节,所以+4*n)
				.if Source>=eax
					mov Ranking,ecx;保存当前积分的名次,用来画奖牌
					mov Best[ecx*4+4],eax;如果当前得分是最高分,则把之前的最高分往后排
					mov eax,Source;获取分数
					mov Best[ecx*4],eax;分数与数组所有元素比较,求出最高分
					.if ecx==0
						mov NumberOne,ecx;第一名的数组下标
					.endif
					.break
				.else
					mov NumberOne,0;如果不比第一个元素大,则第一个元素就是最高分
				.endif
				inc ecx
			.endw
			xor edx,edx
			mov eax,16
			mul Ranking;当前排名所在的将牌
			invoke TransparentBlt,hdcMem,58,224,44,44,hdcBird,Gold[eax],Gold[eax+4],Gold[eax+8],Gold[eax+12],0FF0000h;画奖牌
		.elseif idTime2==5
			invoke wsprintf,offset szSource,offset szFormat,Source
			invoke TextOut,hdcMem,180,210,offset szSource,4;将分数画在窗体上
			mov eax,NumberOne;获取最高分数组下标
			invoke wsprintf,offset szSource,offset szFormat,[Best+eax]
			invoke TextOut,hdcMem,180,253,offset szSource,4;将最高分画在窗体上
			mov Source,0;分数清0
			mov idTime2,0;还原计时
			mov Ready,FALSE;取消准备
			mov Begin,FALSE;取消开始
			mov Click,FALSE;开始按钮可以点击
			mov GameOver,TRUE;标志游戏结束，可以点开始按钮了
			invoke KillTimer,hwnd,ID_TIMER3;停止游戏结束计时
		.endif
		invoke InvalidateRect,hwnd,NULL,FALSE;使窗口无效，会发送WM_PAINT消息到窗口
		invoke UpdateWindow,hwnd;更新窗口，立即发送一条WM_PAINT消息到窗口
	.endif
	Ret
TimerProc3 endp
TimerProc2 proc hwnd,msg,IdEvent,dwTime;小鸟下降
	mov eax,IdEvent
	.if eax==ID_TIMER2
		add idTime,1
		.if idTime==2
			mov idTime,0;重新计时
			mov cyi,15;可以下降
			invoke KillTimer,hwnd,IdEvent
		.endif
		sub cyBird,15;小鸟减少飞行高度
	.endif
	Ret
TimerProc2 endp
GameEnd proc hwnd
	invoke KillTimer,hwnd,ID_TIMER1;停止计时
	invoke RtlZeroMemory,offset hRgn,16;将区域清空，以免下次开始直接停住结束
	mov cxPillar1,358;第一根柱子还原初始位置
	mov cxPillar2,528;第二根柱子还原初始位置
	.if Hit==FALSE;如果不是撞到柱子则把鸟画在地面
		mov eax,index
		invoke TransparentBlt,hdcMem,cxBird,377,34,24,hdcBird,YBird[eax],YBird[eax+4],YBird[eax+8],YBird[eax+12],0FF0000h;将鸟正好画在地面上
	.endif
	mov Hit,FALSE
	invoke SetTimer,hwnd,ID_TIMER3,200,offset TimerProc3;游戏结束处理
	Ret
GameEnd endp
IsHit proc hwnd;鸟是否撞到柱子
	invoke RectInRegion,[hRgn],offset RectBird;矩形是否相交
	.if eax>0
		jmp s
	.endif
	invoke RectInRegion,[hRgn+4],offset RectBird;矩形是否相交
	.if eax>0
		jmp s
	.endif
	invoke RectInRegion,[hRgn+8],offset RectBird;矩形是否相交
	.if eax>0
		jmp s
	.endif
	invoke RectInRegion,[hRgn+12],offset RectBird;矩形是否相交
	.if eax>0
		jmp s
	.endif
	Ret
s:
	mov Hit,TRUE;表示已相撞
	invoke GameEnd,hwnd;游戏结束
	ret
IsHit endp
TimerProc proc hwnd,msg,IdEvent,dwTime
	mov eax,IdEvent
	.if eax==ID_TIMER1
		invoke TransparentBlt,hdcMem,0,0,288,512,hdcBird,0,0,288,512,0FF0000h;画背景
		mov eax,16;总共4个坐标(X,Y,宽,高),每个坐标4个字节,因此每一组16字节
		mul n;多少组
		mov index,eax
		invoke TransparentBlt,hdcMem,0,401,335,111,hdcBird,Floor[eax],Floor[eax+4],Floor[eax+8],Floor[eax+12],0FF0000h;画地面
		.if Begin==TRUE
			.if Ready==FALSE
				invoke TransparentBlt,hdcMem,55,120,177,47,hdcBird,590,118,184,50,0FF0000h;画Get Ready
				invoke TransparentBlt,hdcMem,87,190,114,98,hdcBird,584,182,114,98,0FF0000h;画操作示图
			.else
				invoke DrawPillar;画柱子
			.endif
			invoke DrawSource;画积分
		.else
			invoke TransparentBlt,hdcMem,25,YButton1,104,58,hdcBird,708,236,104,58,0FF0000h;画开始按钮
			invoke TransparentBlt,hdcMem,159,YButton2,104,58,hdcBird,828,236,104,58,0FF0000h;画分数排名
			invoke TransparentBlt,hdcMem,55,120,177,47,hdcBird,702,182,177,47,0FF0000h;画FlappyBird
			invoke TransparentBlt,hdcMem,83,421,122,10,hdcBird,886,184,122,10,0FF0000h;画(c) .GAROS 2013
		.endif
		.if Ready==FALSE;如果游戏开始后未点击窗口
			mov eax,cyi
			add cyBird,eax
		.else;开始飞行后持续往下掉
			mov eax,cyi;一次下降的高度
			add cyBird,eax;小鸟的Y坐标增加，相当于下降
		.endif
		mov eax,index
		.if cyBird<375;如果没有撞到地面
			invoke TransparentBlt,hdcMem,cxBird,cyBird,34,24,hdcBird,YBird[eax],YBird[eax+4],YBird[eax+8],YBird[eax+12],0FF0000h;画黄鸟(每个数组4字节)
			mov eax,cxBird;矩形左边X坐标加矩形宽就是矩形右边X坐标
			add eax,34
			mov ebx,cyBird
			add ebx,24
			invoke SetRect,offset RectBird,cxBird,cyBird,eax,ebx;设置鸟的矩形
			invoke IsHit,hwnd;矩形是否相交
		.endif
		add n,1
		.if n==3
			mov n,0
			.if Ready==FALSE;未开始飞行时上下移动保持位置
				mov eax,cyi
				mov ebx,-1
				mul ebx
				mov cyi,eax;上下移动，通过改变值的正负来改变
			.endif
		.endif
		.if cyBird<512
			.if cyBird>=375;如果撞到地面
				invoke GameEnd,hwnd;游戏结束的处理
			.endif
		.endif
		invoke InvalidateRect,hwnd,NULL,FALSE;使窗口无效，会发送WM_PAINT消息到窗口
		invoke UpdateWindow,hwnd;更新窗口，立即发送一条WM_PAINT消息到窗口
	.endif
	Ret
TimerProc endp
InitGame proc hwnd;初始化游戏
	local hdc:HDC,hMenu:HMENU,hFont:HFONT,LogFont:LOGFONT
	invoke GetDC,hwnd;获取窗口环境设备
	mov hdc,eax
	invoke CreateCompatibleDC,hdc;创建兼容内存DC,用来保存图片
	mov hdcBird,eax
	invoke CreateCompatibleDC,hdc;创建兼容DC，用来保存窗口界面
	mov hdcMem,eax
	invoke CreateCompatibleBitmap,hdc,288,512;创建兼容位图，用来填充内存DC，否则内存DC的大小为1，只有黑白
	push eax
	invoke SelectObject,hdcMem,eax;将位图选入内存DC
	pop eax
	invoke DeleteObject,eax;删除位图
	invoke SetBkMode,hdcMem,TRANSPARENT;将填充背景设置为透明
	invoke SetTextColor,hdcMem,0CAC04Eh;设置字体为白色
	invoke RtlZeroMemory,addr LogFont,sizeof LogFont;初始化字体结构
	invoke RtlMoveMemory,addr LogFont.lfFaceName,offset szFontName,sizeof szFontName;字体名
	mov LogFont.lfHeight,30;字体大小
	mov LogFont.lfWeight,700;粗体(正常为400,粗体为700)
	invoke CreateFontIndirect,addr LogFont;创建字体
	invoke SelectObject,hdcMem,eax;将字体选入内存DC
	invoke LoadImage,hInstance,IDB_BITMAP1,IMAGE_BITMAP,0,0,0;加载图片
	push eax
	invoke SelectObject,hdcBird,eax;将图片选入内存DC
	pop eax
	invoke DeleteObject,eax;删除加载的图片，释放内存
	invoke ReleaseDC,hwnd,hdc;释放窗口DC
	invoke GetSystemMenu,hwnd,FALSE;获取系统菜单
	mov hMenu,eax
	invoke AppendMenu,hMenu,MF_STRING,IDM_ABOUT,offset szAbout;添加系统菜单项(关于)
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
			and eax,0FFFFh;低位为X坐标
			mov pt.x,eax
			mov edx,0
			mov eax,lparam
			mov ebx,010000h;高位为Y坐标,相当于右移16位
			div ebx
			mov pt.y,eax
			invoke PtInRect,offset rect1,pt.x,pt.y;检测鼠标是否在开始按钮矩形处点击
			.if eax==TRUE
				mov YButton1,345;开始按钮被按下
				mov Click,TRUE
			.endif
			invoke PtInRect,offset rect2,pt.x,pt.y
			.if eax==TRUE
				mov YButton2,345;积分排行按钮被按下
				mov Click,TRUE
				mov Rank,TRUE
			.endif
		.else
			mov Ready,TRUE;小鸟开始飞行
			.if cyBird<0FFFFh;如果没有飞过顶(负数会用补码来代替，如果用if xx<0是永远都不会满足条件的)
				mov cyi,0;小鸟不可以下降(因为要上升)
				sub cyBird,15;为了响应一点就会上升(Timer回调函数里面要执行100ms，会延时)
				invoke SetTimer,hwnd,ID_TIMER2,80,offset TimerProc2
			.else
				mov cyBird,0;如果飞过顶了拉它下来- -!
			.endif
		.endif
	.elseif eax==WM_LBUTTONUP
		.if Begin==FALSE;如果游戏未开始
			.if Click==TRUE;如果点击了按钮
				.if Rank==TRUE;如果点了积分排行
					mov YButton2,343
					mov Rank,FALSE
				.else
					mov YButton1,344;开始按钮弹起
					mov cxBird,70
					mov Begin,TRUE
					.if GameOver==TRUE
						mov GameOver,FALSE
						invoke SetTimer,hwnd,ID_TIMER1,80,offset TimerProc;如果游戏结束了，则开始游戏
					.endif
				.endif
			.endif
		.endif
	.elseif eax==WM_SYSCOMMAND;系统菜单要响应WM_SYSCOMMAND
		mov eax,wparam
		and eax,0ffffh
		.if eax==IDM_ABOUT
			invoke MessageBox,hwnd,offset szText,offset szCaption,MB_OK
		.else
			invoke DefWindowProc,hwnd,msg,wparam,lparam;不要的消息发到默认窗口过程，不然会无响应
			ret
		.endif
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hwnd
		invoke PostQuitMessage,0
	.elseif eax==WM_CREATE
		invoke InitGame,hwnd;游戏初始化
		mov YButton1,343;开始按钮的Y坐标
		mov YButton2,343;积分排行按钮的Y坐标
		invoke SetTimer,hwnd,ID_TIMER1,80,offset TimerProc;开始计时器
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
	mov h,512;游戏窗口的宽和高
	mov w,288
	invoke GetSystemMetrics,SM_CXDLGFRAME;对话框的宽度
		add eax,eax;两边的宽度
		add w,eax
	invoke GetSystemMetrics,SM_CYDLGFRAME;对话框的高度
		add eax,eax
		add h,eax
	invoke GetSystemMetrics,SM_CYCAPTION;获取标题高度
		add h,eax
	invoke GetSystemMetrics,SM_CXSCREEN;屏幕的宽度
		mov edx,0;除数是32位的，所以被除数还包含了edx，因此要清空edx的值，不然会出错
		sub eax,w
		mov ebx,2
		div ebx
		mov SrcX,eax;窗口居中的X
	invoke GetSystemMetrics,SM_CYSCREEN;屏幕的高度
		mov edx,0
		sub eax,h
		mov ebx,2
		div ebx
		mov SrcY,eax;窗口居中的Y坐标
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