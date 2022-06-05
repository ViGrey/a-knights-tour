; Copyright (C) 2020, Vi Grey
; All rights reserved.

SetResetCheck:
  ldx #$05
SetResetCheckLoop:
  lda KNIGHTWord, X
  sta $00FA, X
  sta $03FA, X
  sta $04FA, X
  sta $05FA, X
  sta $06FA, X
  sta $07FA, X
  dex
  bpl SetResetCheckLoop 
    rts

CheckResetCheck:
  lda #$FA
  sta tmp
  ldy #$05
CheckResetCheckLoopStart:
  lda #$00
  sta (tmp + 1)
CheckResetCheckLoop:
  lda (tmp), Y
  cmp (KNIGHTWord), Y
  bne CheckResetWasReset
    lda (tmp + 1)
    bne CheckResetCheckLoopTmp2Not0
      inc (tmp + 1)
      inc (tmp + 1)
CheckResetCheckLoopTmp2Not0:
  inc (tmp + 1)
  lda (tmp + 1)
  cmp #$08
  bne CheckResetCheckLoop
    dey
    bmi CheckResetCheckDone
      jmp CheckResetCheckLoopStart
CheckResetWasReset:
  lda #$00
  rts
CheckResetCheckDone:
  lda #$01
  rts

KNIGHTWord:
  .byte "KNIGHT"
