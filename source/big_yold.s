
test	equ 0
	ifne	test
	pea	start
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

start:
	rts

	endc

start:
	move.l	4(sp),a0
	move.l	#$100,d0
	add.l	$c(a0),d0
	add.l	$14(a0),d0
	add.l	$1c(a0),d0
	clr.w	-(sp)
	move.l	d0,-(sp)
	move.w	#$31,-(sp)

	pea	install
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	pea	copyright
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	trap	#1

install:
	move.l	$88.w,oldtrap2
	move.l	#mytrap2,$88.w
	rts

	dc.b	'XBRA'
	dc.b	'TFBY'
oldtrap2:
	dc.l	0

mytrap2:
	cmp.w	#$73,d0
	bne.s	normalvdi
	move.l	d1,a0
	move.l	12(a0),intout
	move.l	(a0),a0
	cmp.w	#1,(a0)
	bne.s	normalvdi
	move.l	2(sp),back
	move.l	#patch,2(sp)
normalvdi:
	move.l	oldtrap2,-(sp)
	rts

patch:
	move.w	#-1,-(sp)
	move.l	#screenmem+255,d0
	and.l	#$ffff00,d0
	move.l	d0,d1
	add.l	#24*160,d0
	move.l	d0,-(sp)
	move.l	d1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	dc.w	$a000
	move.w	-4(a0),d0
	cmp.w	#200,d0
	bne.s	must_be_high
	move.w	#224,d0
	move.w	d0,-4(a0)
	move.w	d0,-$2b2(a0)
intout equ *+2
	lea	$000000,a1
	move.w	d0,2(a1)
must_be_high:
back equ *+2
	pea	$000000
	rts

	section	data

copyright:
	dc.b	13,10,'Installing Big Y by the Fate of ULM',13,10
	dc.b	'Additional Code by Julian Reschke...',13,10
	dc.b	'Please install after GDOS',13,10,0

	section	bss
screenmem:
	ds.l	64
	ds.l	8192+24*40
	end
