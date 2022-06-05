; Copyright (C) 2020, Vi Grey
; All rights reserved.

RESET:
  sei
  cld
  ldx #$40
  stx APU_FRAME_COUNTER
  ldx #$FF
  txs
  inx
  lda #%00000110
  sta PPU_MASK
  lda #%00000000
  sta PPU_CTRL
  stx $4010
  ldy #$00

InitialVWait:
  lda regionTmp
  sta region
  ldy #$00
  lda PPU_STATUS
  bpl InitialVWait
InitialVWait2:
  inx
  bne InitialVWait2NotIncY
    iny
InitialVWait2NotIncY:
  lda PPU_STATUS
  bpl InitialVWait2
    ldx #$00
    cpy #$09
    bne NotNTSC
      lda #60
      inx
      jmp InitialVWaitDone
NotNTSC:
  lda #50
  cpy #$0A
  bne NotPAL
    jmp InitialVWaitDone
NotPAL:
  cpy #$0B
  bne NotDendy
    ldx #$02
    jmp InitialVWaitDone
NotDendy:
  ldx #$03
InitialVWaitDone:
  sta fps
  stx regionTmp
  cpx region
  bne InitialVWait

InitializeRAM:
  jsr CheckResetCheck
  sta wasReset
  ldx #$00
InitializeRAMLoop:
  lda #$00
  cpx #wasReset
  beq InitilizeRAMLoop0100 
    cpx #topscore
    beq InitilizeRAMLoop0100 
      cpx #(topscore + 1)
      beq InitilizeRAMLoop0100 
        cpx #(topscore + 2)
        beq InitilizeRAMLoop0100 
          cpx #(topscore + 3)
          beq InitilizeRAMLoop0100 
            cpx #fps
            beq InitilizeRAMLoop0100 
              cpx #region
              beq InitilizeRAMLoop0100 
                cpx #regionTmp
                beq InitilizeRAMLoop0100 
                  cpx #lfsr
                  beq InitilizeRAMLoop0100 
                    cpx #(lfsr + 1)
                    beq InitilizeRAMLoop0100 
                      cpx #(lfsr + 2)
                      beq InitilizeRAMLoop0100 
                        cpx #leftHanded
                        beq InitilizeRAMLoop0100 
                          cpx #canFall
                          beq InitilizeRAMLoop0100 
                            cpx #invisibleCracks
                            beq InitilizeRAMLoop0100 
                              cpx #invisibleGuides
                              beq InitilizeRAMLoop0100 
                                cpx #endPositionOption
                                beq InitilizeRAMLoop0100 
InitilizeRAMLoop0000:
  sta $0000, x
InitilizeRAMLoop0100:
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$FE
  sta $0200, x
  inx
  bne InitializeRAMLoop
    lda wasReset
    bne InitializeRAMReset
      jsr DefaultOptions
      lda #$00
      sta topscore
      sta (topscore + 1)
      sta (topscore + 2)
      sta (topscore + 3)
      jsr SetLFSR
InitializeRAMReset:
  lda #$0F
  ; TODO - Consider a situation where titleOption and pointer are the same
  sta titleOption
  jsr SetTopScoreToTopScoreTmp
  jsr SetResetCheck
  lda #SCREEN_TITLE
  sta screen

  jsr ResetGraphics
  jsr BlankPalette
  lda #$01
  sta needDraw
  jsr ResetScroll
  jsr StartTitleScreen

Forever:
  jmp Forever



NMI:
  pha
  txa
  pha
  tya
  pha
  lda #$00
  sta PPU_OAM_ADDR
  lda #$02
  sta OAM_DMA
  inc frames
  lda regionCheck
  bne NMIDone
NMINotRegionCheck:
  jsr UpdateDone
  lda needDraw
  beq NMISkipDraw
NMIProgramStarted:
  lda PPU_STATUS
  jsr Draw
  jsr ReadThenResetGraphics
  jsr ResetScroll
NMISkipDraw:
NMIContinue:
  lda updateDisabled
  bne NMISkipUpdate
    jsr Update
NMISkipUpdate:
NMIDone:
  pla
  tay
  pla
  tax
  pla
  rti

.include "draw.asm"
.include "controller.asm"
.include "position.asm"
.include "knight.asm"
.include "board.asm"
.include "score.asm"
.include "time.asm"
.include "reset.asm"
.include "mouse.asm"
.include "rng.asm"
.include "powerpad.asm"
.include "title.asm"
.include "options.asm"

.include "graphics.asm"
;.include "screen.asm"
.include "frames.asm"
.include "update.asm"
.include "math.asm"
