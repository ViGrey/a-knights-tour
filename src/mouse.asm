; Copyright (C) 2020, Vi Grey
; All rights reserved.

SetMouseSensitivity:
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  bne SetMouseSensitivityDone
    lda snesMouseReady
    bne SetMouseSensitivityDone
      lda (controller1D0LastFrame + 1)
      and #%00110000
      lsr
      lsr
      lsr
      lsr
      tax
SetMouseSensitivityLoop:
  lda CONTROLLER1
  inx
  cpx #$03
  bne SetMouseSensitivityLoop
    lda #$01
    sta snesMouseReady
    jsr DrawCursor
SetMouseSensitivityDone:
  rts

MoveCursor:
  lda snesMouseReady
  cmp #$01
  beq MoveCursorVertical
    rts
MoveCursorVertical:
  jsr CheckMouseVertical
  cpy #$00
  beq MoveCursorDown
MoveCursorUp:
  lda tmp
  dec CURSOR
  lda CURSOR
  sec
  sbc tmp
  sta CURSOR
  bcs MoveCursorHorizontal
    lda #$00
    sta CURSOR
    jmp MoveCursorHorizontal
MoveCursorDown:
  dec CURSOR
  lda CURSOR
  clc
  adc tmp
  sta CURSOR
  bcs MoveCursorDownReset
    cmp #$ED
    bcc MoveCursorHorizontal
MoveCursorDownReset:
  lda #$ED
  sta CURSOR
MoveCursorHorizontal:
  jsr CheckMouseHorizontal
  cpy #$00
  beq MoveCursorRight
MoveCursorLeft:
  lda (CURSOR + 3)
  sec
  sbc tmp
  sta (CURSOR + 3)
  bcs MoveCursorDone
    lda #$00
    sta (CURSOR + 3)
    jmp MoveCursorDone
MoveCursorRight:
  lda (CURSOR + 3)
  clc
  adc tmp
  sta (CURSOR + 3)
  bcc MoveCursorDone
    lda #$FF
    sta (CURSOR + 3)
MoveCursorDone:
  inc CURSOR
  rts

CheckMouseVertical:
  lda (controller1D0 + 2)
  and #%10000000
  tay
  lda (controller1D0 + 2)
  and #%01111111
  sta tmp
  rts

CheckMouseHorizontal:
  lda (controller1D0 + 3)
  and #%10000000
  tay
  lda (controller1D0 + 3)
  and #%01111111
  sta tmp
  rts

DrawCursor:
  lda #$77
  lda #$1B
  sta CURSOR
  lda #$10
  sta (CURSOR + 1)
  lda #%00000000
  sta (CURSOR + 2)
  lda #$E8
  sta (CURSOR + 3)
  rts

EraseCursor:
  lda #$FE
  sta CURSOR
  rts

DetermineCursorOverPosition:
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  beq DetermineCursorOverPositionSNESCheck
    rts
DetermineCursorOverPositionSNESCheck:
  ldx #$00
  ldy #$00
DetermineCursorOverPositionLoop:
  lda (CURSOR), Y
  sec
  sbc (KNIGHT_TL), Y
  bcc DetermineCursorOverPositionsCursorLess
    cmp #$10
    bcs DetermineCursorOverPositionsCursorMore
      jmp DetermineCursorOverPositionInvalid
DetermineCursorOverPositionsCursorLess:
  lsr
  lsr
  lsr
  lsr
  eor #%11111111
  and #%00001111
  ora #%10000000
  sta tmp, X
  jmp DetermineCursorOverPositionLoopLessMoreDone
DetermineCursorOverPositionsCursorMore:
  sbc #$10
  lsr
  lsr
  lsr
  lsr
  and #%00001111
  sta tmp, X
DetermineCursorOverPositionLoopLessMoreDone:
  lda tmp, X
  and #%00001111
  cmp #$02
  bcc DetermineCursorOverPositionLoopDone
    jmp DetermineCursorOverPositionInvalid
DetermineCursorOverPositionLoopDone:
  iny
  iny
  iny
  inx
  cpx #$02
  bne DetermineCursorOverPositionLoop
    jmp DetermineCursorOverPositionContinue
DetermineCursorOverPositionContinue:
  lda tmp
  and #%00000001
  tay
  eor (tmp + 1)
  and #%00000001
  bne DetermineCursorOverPositionContinueNotOverflow
    jmp DetermineCursorOverPositionInvalid
DetermineCursorOverPositionContinueNotOverflow:
  lda (tmp + 1)
  lsr
  ora tmp
  and #%11000000
  clc
  rol
  rol
  rol
  tax
  cpx #$04
  bcc DetermineCursorOverPositionGetPosition
    jmp DetermineCursorOverPositionInvalid
DetermineCursorOverPositionGetPosition:
  lda CursorOffsetToPosition, X
  cpy #$01
  bne DetermineCursorOverPositionNotShift
    lsr
    lsr
    lsr
    lsr
DetermineCursorOverPositionNotShift:
  and #%00000111
  sta tmp
  jsr CheckAPositionAvailable
  bne DetermineCursorOverPositionValid
    jmp DetermineCursorOverPositionInvalid
DetermineCursorOverPositionValid:
  lda cursorPosition
  cmp #$08
  bne DetermineCursorOverPositionDone
    lda #$00
    sta positionFrame
DetermineCursorOverPositionDone:
  lda tmp
  sta cursorPosition
  sta position
  rts
DetermineCursorOverPositionInvalid:
  lda #$08
  sta cursorPosition
  lda #$00
  sta positionFrame
  rts

CheckLeftClick:
  lda (controller1D0Final + 1)
  and #LEFT_CLICK
  bne CheckLeftClickContinue
    rts
CheckLeftClickContinue:
  lda cursorPosition 
  bne CheckLeftClickPositionNot0
    lda knightPosition
    sec
    sbc #$11
    sta knightPositionNew
    jmp CheckLeftClickDraw
CheckLeftClickPositionNot0:
  cmp #$01
  bne CheckLeftClickPositionNot1
    lda knightPosition
    sec
    sbc #$0F
    sta knightPositionNew
    jmp CheckLeftClickDraw
CheckLeftClickPositionNot1:
  cmp #$02
  bne CheckLeftClickPositionNot2
    lda knightPosition
    sec
    sbc #$06
    sta knightPositionNew
    jmp CheckLeftClickDraw
CheckLeftClickPositionNot2:
  cmp #$03
  bne CheckLeftClickPositionNot3
    lda knightPosition
    clc
    adc #$0A
    sta knightPositionNew
    jmp CheckLeftClickDraw
CheckLeftClickPositionNot3:
  cmp #$04
  bne CheckLeftClickPositionNot4
    lda knightPosition
    clc
    adc #$11
    sta knightPositionNew
    jmp CheckLeftClickDraw
CheckLeftClickPositionNot4:
  cmp #$05
  bne CheckLeftClickPositionNot5
    lda knightPosition
    clc
    adc #$0F
    sta knightPositionNew
    jmp CheckLeftClickDraw
CheckLeftClickPositionNot5:
  cmp #$06
  bne CheckLeftClickPositionNot6
    lda knightPosition
    clc
    adc #$06
    sta knightPositionNew
    jmp CheckLeftClickDraw
CheckLeftClickPositionNot6:
  cmp #$07
  beq CheckLeftClickPosition7
    rts
CheckLeftClickPosition7
  lda knightPosition
  sec
  sbc #$0A
  sta knightPositionNew
CheckLeftClickDraw:
  lda knightPositionNew
  jsr CheckAPositionBroken
  beq CheckLeftClickDrawNotBrokenPosition
    lda #$01
    sta end
    rts
CheckLeftClickDrawNotBrokenPosition:
  jsr UpdateDisallowedPositions
  lda #$00
  sta knightFrame
  lda positionFrame
  and #%00001000
  beq CheckLeftClickCornersNeutral
    lda positionFrame
    and #%00010000
    ora #%00001111
    sta positionFrame
    inc positionFrame
    jsr UpdatePositionCorners
CheckLeftClickCornersNeutral:
  lda #$01
  sta animateKnight
  lda knightPosition
  sta crackPosition
  jsr CrackTile
  jsr IncScore
  jsr IncCurrentBoardScore
  jsr UpdateTopScore
CheckLeftClickDone:
  rts

CursorOffsetToPosition:
  .byte $43, $56, $12, $07
