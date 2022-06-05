; Copyright (C) 2020, Vi Grey
; All rights reserved.

IncTimer: 
  ldx #$02
  inc timeFrame
  lda timeFrame
  cmp fps
  bcc IncTimerDone
    lda #$00
    sta timeFrame
IncTimerLoop:
  inc time, X
  lda time, X
  cmp #$0A
  bcc IncTimerDone
    lda #$00
    sta time, X
    dex
    bpl IncTimerLoop
      lda #$09
      sta time
      sta (time + 1)
      sta (time + 2)
IncTimerDone:
  rts

DecTime:
  ldx #$02
  inc timeFrame
  lda timeFrame
  cmp fps
  bcc DecTimeDone
    lda #$00
    sta timeFrame
DecTimeLoop:
  dec time, X
  lda time, X
  bpl DecTimeDone
    lda #$09
    sta time, X
    dex
    bpl DecTimeLoop
      lda #$00
      sta time
      sta (time + 1)
      sta (time + 2)
DecTimeDone:
  rts

CheckTimer000:
  lda time
  ora (time + 1)
  ora (time + 2)
  bne CheckTimer000Done
    lda #$01
    sta end
CheckTimer000Done:
  rts

DrawTimer:
  ldx graphicsPointer
  lda #$00
  sta graphics, X
  inx
  lda #$FE
  sta graphics, X
  inx
  lda #$20
  sta graphics, X
  inx
  lda #$A3
  sta graphics, X
  inx
  lda #"T"
  sta graphics, X
  inx
  lda #"I"
  sta graphics, X
  inx
  lda #"M"
  sta graphics, X
  inx
  lda #"E"
  sta graphics, X
  inx
  lda #$3A
  sta graphics, X
  inx
  ldy #$00
DrawTimerLoop:
  lda time, Y
  clc
  adc #$30
  sta graphics, X
  inx
  iny
  cpy #$03
  bne DrawTimerLoop
    stx graphicsPointer
    rts

IncTimerByTimeInc:
  ldx #$02
IncTimerByTimeIncLoop:
  lda time, X
  clc
  adc timeInc, X
  sta time, X
  dex
  bpl IncTimerByTimeIncLoop
    ldx #$02
IncTimerByTimeIncNormalizeTimer:
  lda time, X
  cmp #$0A
  bcc IncTimerByTimeIncNormalizeContinue
    sec
    sbc #$0A
    sta time, X
    dex
    inc time, X
    inx
IncTimerByTimeIncNormalizeContinue:
  dex
  bne IncTimerByTimeIncNormalizeTimer
IncTimerByTimeIncCheckMaxTime:
  lda time
  cmp #$0A
  bcc IncTimerByTimeIncDone
    lda #$09
    sta time
    sta (time + 1)
    sta (time + 2)
IncTimerByTimeIncDone:
  rts
