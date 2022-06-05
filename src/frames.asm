; Copyright (C) 2020, Vi Grey
; All rights reserved.

WaitForNewFrame:
  lda frames
WaitForNewFrameLoop:
  cmp frames 
  beq WaitForNewFrameLoop
    rts

WaitForNewFrameDisableDraw:
  ; TODO look into swapping order of needDraw set 0 and frame wait
  jsr WaitForNewFrame
  lda #$00
  sta needDraw
  rts

DecTimer:
  lda frames
  cmp fps
  bne DecTimerDone
    lda #$00
    sta frames
    dec timer
DecTimerDone:
  rts
