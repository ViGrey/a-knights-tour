; Copyright (C) 2020, Vi Grey
; All rights reserved.

IncScore:
  ldx #$03
IncScoreLoop:
  inc score, X
  lda score, X
  cmp #$0A
  bcs IncScoreLoopContinue
    rts
IncScoreLoopContinue:
  cpx #$00
  beq IncScoreLoopMaxScore
    lda #$00
    sta score, X
    dex
    bpl IncScoreLoop
      rts
IncScoreLoopMaxScore:
  ldy #$03
  lda #$09
IncScoreLoopMaxScoreLoop:
  sta score, Y
  dey
  bpl IncScoreLoopMaxScoreLoop
    rts

IncCurrentBoardScore:
  ldx #$01
IncCurrentBoardScoreLoop:
  inc currentBoardScore, X
  lda currentBoardScore, X
  cmp #$0A
  bcs IncCurrentBoardScoreLoopContinue
    rts
IncCurrentBoardScoreLoopContinue:
  lda #$00
  sta currentBoardScore, X
  dex
  bpl IncCurrentBoardScoreLoop
    rts

UpdateTopScore:
  ldy #$00
UpdateTopScoreLoop:
  lda score, Y
  cmp topscoreTmp, Y
  bcc UpdateTopScoreDone
    bne UpdateTopScoreToScoreUpdate
      iny
      cpy #$04
      bne UpdateTopScoreLoop
        rts
UpdateTopScoreToScoreUpdate:
  ldy #$03
UpdateTopScoreToScoreUpdateLoop:
  lda score, Y
  sta topscoreTmp, Y
  dey
  bpl UpdateTopScoreToScoreUpdateLoop
UpdateTopScoreDone:
  rts

SetTopScoreToTopScoreTmp:
  ldy #$03
SetTopScoreToTopScoreTmpLoop:
  lda topscore, Y
  sta topscoreTmp, Y
  dey
  bpl SetTopScoreToTopScoreTmpLoop
    rts

SetTopScoreTmpToTopScore:
  ldy #$03
SetTopScoreTmpToTopScoreLoop:
  lda topscoreTmp, Y
  sta topscore, Y
  dey
  bpl SetTopScoreTmpToTopScoreLoop
    rts

DrawScore:
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
  lda #$B3
  sta graphics, X
  inx
  lda #"S"
  sta graphics, X
  inx
  lda #"C"
  sta graphics, X
  inx
  lda #"O"
  sta graphics, X
  inx
  lda #"R"
  sta graphics, X
  inx
  lda #"E"
  sta graphics, X
  inx
  lda #$3A
  sta graphics, X
  inx
  ldy #$00
DrawScoreLoop:
  lda score, Y
  clc
  adc #$30
  sta graphics, X
  inx
  iny
  cpy #$04
  bne DrawScoreLoop
    stx graphicsPointer
    rts

DrawTopScore:
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
  lda #$75
  sta graphics, X
  inx
  sta PPU_ADDR
  lda #"T"
  sta graphics, X
  inx
  lda #"O"
  sta graphics, X
  inx
  lda #"P"
  sta graphics, X
  inx
  lda #$3A
  sta graphics, X
  inx
  ldy #$00
DrawTopScoreLoop:
  lda topscoreTmp, Y
  clc
  adc #$30
  sta graphics, X
  inx
  iny
  cpy #$04
  bne DrawTopScoreLoop
    stx graphicsPointer
    rts
