
def_version equ 0
dont_do equ 0
change_timerc equ 0

        ifne def_version
        default 1
        opt X+
        else
        output 'C:\AUTO\BIG_Y.PRG'
;        output 'D:\DFUERUN\BIG_Y.PRG'
;        output 'D:\AUTO\BIG_Y.PRG'
        opt D-
        default 5
        endc

        >PART 'install I'

        movea.l 4(sp),a0
        movea.w #$0100,a5
        adda.l  $0c(a0),a5
        adda.l  $14(a0),a5
        adda.l  $1c(a0),a5
        clr.w   -(sp)
        move.l  a5,-(sp)
        move.w  #$31,-(sp)

        pea     install(pc)
        move.w  #38,-(sp)
        trap    #14
        addq.l  #6,sp

        move.w  #-1,-(sp)
        move.l  #screenmem+255,d0
        and.l   #$ffff00,d0
        move.l  d0,-(sp)
        move.l  d0,-(sp)
        move.w  #5,-(sp)
        trap    #14
        lea     12(sp),sp

        pea     copyright(pc)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp

        ifne def_version
        clr.w   -(sp)
        endc
        trap    #1

error_exit:
        pea     error_txt(pc)
        move.w  #9,-(sp)
        trap    #1

        lea     6+6+8(sp),sp    ;supexec+pline+ptermres

        clr.w   -(sp)
        trap    #1

        endpart

        >PART 'install II'

check_it:
        cmpi.l  #'XBRA',-12(a0)
        beq.s   check_it_
        rts
check_it_:
        cmpi.l  #'TFBY',-8(a0)
        beq.s   check_it__
        rts
check_it__:
        lea     4(sp),sp
        move.l  #error_exit,(sp)
        rts

install:
        movea.l $70.w,a0
        bsr.s   check_it
        movea.l $0118.w,a0
        bsr.s   check_it
        movea.l $0114.w,a0
        bsr.s   check_it

        lea     my_vbl(pc),a0
        move.l  $70.w,(a0)+
        move.l  a0,$70.w

        lea     my_ikbd(pc),a0
        move.l  $0118.w,(a0)+
        move.l  a0,$0118.w

        ifeq change_timerc
        lea     my_timerc(pc),a0
        move.l  $0114.w,(a0)+
        move.l  a0,$0114.w
        endc

        ifeq def_version+dont_do
        lea     my_trap2(pc),a0
        move.l  $88.w,(a0)+
        move.l  a0,$88.w
        endc

        ifne def_version
        move.w  #1,-(sp)
        trap    #1
        addq.l  #2,sp
        endc

        rts

        endpart

        >PART 'my vbl'

on_of_flag:dc.w 0
        dc.b 'XBRA'
        dc.b 'TFBY'
my_vbl: dc.l 0
        tst.w   on_of_flag
        bne.s   no_lower_border

        move    sr,-(sp)
        move    #$2700,sr
        clr.b   $fffffa1b.w
        andi.b  #%11111110,$fffffa0b.w
        ori.b   #%1,$fffffa07.w
        ori.b   #%1,$fffffa13.w
        move.b  #198,$fffffa21.w
        move.l  #my_timerb,$0120.w
        move.b  #8,$fffffa1b.w

        ifne def_version
        move.w  #$0700,$ffff8240.w
        endc

        move    (sp)+,sr
no_lower_border:
        move.l  my_vbl(pc),-(sp)
        rts

        endpart

        PART 'my timer b'
timerb_regs reg d0/a0

        dc.b 'XBRA'
        dc.b 'TFBY'
        dc.l 0
my_timerb:
        move    #$2700,sr
        movem.l timerb_regs,-(sp)
        clr.b   $fffffa1b.w
        andi.b  #%11111110,$fffffa07.w
        andi.b  #%11111110,$fffffa13.w
        lea     $ffff8209.w,a0
        moveq   #8,d0
        dbra    d0,*-2
        moveq   #0,d0
wait_border1:
        move.b  (a0),d0
        cmp.b   (a0),d0
        bne.s   wait_border1
        rept 20
        cmp.b   (a0),d0
        bne.s   border_over
        endr
        bra.s   exit_timerb
border_over:

wait_end_line:
        tst.b   (a0)

        bne.s   wait_end_line
        not.w   $ffff8240.w
        not.w   $ffff8240.w
        move.b  #0,$ffff820a.w


        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        move.b  #2,$ffff820a.w


        ifeq 1
        move.b  (a0),d0
        neg.w   d0
        add.w   #31,d0
        lsl.w   d0,d0
        moveq   #12-2,d0
        dbra    d0,*-2
        nop
        nop
        nop
        nop
        nop

        nop
        nop
        nop
        not.w   $ffff8240.w
        not.w   $ffff8240.w
        move.b  #2,$ffff820a.w

        endc

        ifne def_version
        not.w   $ffff8240.w
        endc

exit_timerb:
        movem.l (sp)+,timerb_regs
        andi.b  #%11111110,$fffffa0f.w
        rte

        endpart

        >PART 'my timer c'

        ifeq change_timerc
on_of_flag2:dc.w 0
        dc.b 'XBRA'
        dc.b 'TFBY'
my_timerc:dc.l 0
        tst.w   on_of_flag2
        bne.s   no_lower_border2

        move.b  $fffffa13.w,oldfa13
        move.b  $fffffa15.w,oldfa15
        move.b  #1,$fffffa13.w
        move.b  #0,$fffffa15.w
        move    #$2500,sr
        pea     back_timerc(pc)
        move.w  #$2500,-(sp)

no_lower_border2:
        move.l  my_timerc(pc),-(sp)
        rts
back_timerc:
oldfa13 equ *+3
        move.b  #0,$fffffa13.w
oldfa15 equ *+3
        move.b  #0,$fffffa15.w
        rte
        endc

        endpart

        >PART 'my ikbd'

on_of_flag3:dc.w 0
        dc.b 'XBRA'
        dc.b 'TFBY'
my_ikbd:dc.l 0
        tst.w   on_of_flag3
        bne.s   no_lower_border3

        move.b  $fffffa13.w,oldfa13_2
        move.b  $fffffa15.w,oldfa15_2
        move.b  #1,$fffffa13.w
        move.b  #0,$fffffa15.w
        move    #$2500,sr
        pea     back_ikbd(pc)
        move.w  #$2500,-(sp)

no_lower_border3:
        move.l  my_ikbd(pc),-(sp)
        rts
back_ikbd:
oldfa13_2 equ *+3
        move.b  #0,$fffffa13.w
oldfa15_2 equ *+3
        move.b  #0,$fffffa15.w
        rte

        endpart

        >PART 'my trap 2'

        dc.b 'XBRA'
        dc.b 'TFBY'
my_trap2:dc.l 0
        cmp.w   #$73,d0
        bne.s   normalvdi
        movea.l d1,a0
        move.l  12(a0),intout
        movea.l (a0),a0
        cmpi.w  #1,(a0)
        bne.s   normalvdi
        move.l  2(sp),back
        move.l  #patch,2(sp)
normalvdi:
        move.l  my_trap2(pc),-(sp)
        rts

        endpart

        >PART 'the patch'

patch:
        dc.w $a000
        move.w  #30-1,-$2a(a0)
        move.w  #240+16,d0      ;new y size of screen
        move.w  d0,-4(a0)
        move.w  d0,-$02b2(a0)
intout  equ *+2
        lea     $00,a1
        move.w  d0,2(a1)
back    equ *+2
        pea     $00
        rts

        endpart

        data

        >PART 'texts'

copyright:
        dc.b 27,'HBig Y by Christian Limpach installed.',13,10
        dc.b 'New screen memory in use.      +16 lines',13,10,10,0

error_txt:
        dc.b 7,'Big Y already installed...',13,10,10,0
        even

        endpart

        bss

        >PART 'new screen'
screenmem:
        ds.l 64
        ds.b 32000+50*160+16*160 ; GK hat mehr
        endpart

        end
