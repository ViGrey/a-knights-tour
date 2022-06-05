; Copyright (C) 2020, Vi Grey
; All rights reserved.

LFSR:
  ldx #$03
LFSRRoundLoopStart:
  ldy #$08
  lda lfsr
LFSRLoop:
  lsr
  ror (lfsr + 1)
  ror (lfsr + 2)
  bcc LFSRLoopContinue
    eor #%11011000
LFSRLoopContinue:
  dey
  bne LFSRLoop
    sta lfsr
    dex
    bne LFSRRoundLoopStart
      lda (lfsr + 1)
      eor controller1D0
      eor (controller1D0 + 1)
      sta (lfsr + 1)
      rts

SetLFSR:
  lda PPU_STATUS
  lda #$20
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
  lda PPU_DATA
  lda PPU_DATA
  eor #$63
  sta lfsr
  lda PPU_DATA
  eor #$C8
  sta (lfsr + 1)
  lda #$16
  sta (lfsr + 2)
  rts
