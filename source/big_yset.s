
def_version equ 0
no_text equ 10

        ifne def_version
        opt X+
        else
        output 'E:\UTILITYS\BIG_YSET.TOS'
        output 'D:\SYSTEM\BIG_YSET.TOS'
        opt D-
        default 5
        endc

        >PART 'install I'

        pea     install(pc)
        move.w  #38,-(sp)
        trap    #14
        addq.l  #6,sp

        ifeq no_text
        pea     copyright(pc)
print_text:
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp

        endc

        ifne no_text
print_text:
        endc

        clr.w   -(sp)
        trap    #1

error_exit:
        addq.l  #6,sp
        ifeq no_text
        pea     error_txt(pc)
        endc
        bra.s   print_text

        endpart

        >PART 'install II'

check_it:
        cmpi.l  #'XBRA',-12(a0)
        bne.s   error
        cmpi.l  #'TFBY',-8(a0)
        bne.s   error
        rts
error:
        lea     4(sp),sp
        move.l  #error_exit,(sp)
        rts

install:
        movea.l $70.w,a0
        bsr.s   check_it
        movea.l $0114.w,a0
        bsr.s   check_it
        movea.l $0118.w,a0
        bsr.s   check_it

        movea.l $0118.w,a0
        eori.w  #$ffff,-14(a0)
        movea.l $0114.w,a0
        eori.w  #$ffff,-14(a0)
        movea.l $70.w,a0
        eori.w  #$ffff,-14(a0)
        tst.w   -14(a0)
        beq.s   patch
        bra.s   patch_back
patch_return:
        rts

        endpart

        >PART 'the patch'

patch:
        dc.w $a000
        move.w  #30-1,-$2a(a0)
        move.w  #240,d0         ;new y size of screen
        move.w  d0,-4(a0)
        move.w  d0,-$02b2(a0)
        bra.s   patch_return

        endpart

        >PART 'the patch back'

patch_back:
        dc.w $a000
        move.w  #25-1,-$2a(a0)
        move.w  #200,d0         ;new y size of screen
        move.w  d0,-4(a0)
        move.w  d0,-$02b2(a0)
        cmpi.w  #200,-$0258(a0)
        blt.s   mouse_pos_ok1
        move.w  #180,-$0258(a0)
        move.b  #-1,-$0154(a0)
mouse_pos_ok1:
        cmpi.w  #200,-$0156(a0)
        blt.s   mouse_pos_ok2
        move.w  #180,-$0156(a0)
        move.b  #-1,-$0154(a0)
mouse_pos_ok2:
        bra.s   patch_return

        endpart

        data

        >PART 'texts'

copyright:
        dc.b 'screensize changed...',13,10,10,0

error_txt:
        dc.b 7,'ERROR!!! Big Y may not be installed...',13,10,10,0
        even

        endpart

        bss

        end
