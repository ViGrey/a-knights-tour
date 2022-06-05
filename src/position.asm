; Copyright (C) 2020, Vi Grey
; All rights reserved.

UpdatePositionCorners:
  lda animateKnight
  bne UpdatePositionCornersInanimate
    lda controllerType
    cmp #CONTROLLER_SNES_MOUSE
    bne UpdatePositionCornersSNESMouseChecked
      lda cursorPosition
      cmp #$08
      bne UpdatePositionCornersSNESMouseChecked
        jsr DrawCorners
        lda #$00
        sta positionFrame
        rts
UpdatePositionCornersInanimate:
  ldy #$00
  jmp UpdatePositionCornersIncDecContinue
UpdatePositionCornersSNESMouseChecked:
  lda position
  asl
  asl
  asl
  asl
  tax
  lda positionFrame
  and #%00000111
  beq UpdatePositionCornersContinue
    rts
UpdatePositionCornersContinue:
  ldy #$01
  lda positionFrame
  and #%00010000
  bne UpdatePositionCornersIncDecContinue:
    ldy #$FF
UpdatePositionCornersIncDecContinue:
  sty tmp
  lda POSITION_0, X
  clc
  adc tmp
  sta POSITION_0, X
  inx
  inx
  inx
  lda POSITION_0, X
  clc
  adc tmp
  sta POSITION_0, X
  inx
  lda POSITION_0, X
  clc
  adc tmp
  sta POSITION_0, X
  inx
  inx
  inx
  lda POSITION_0, X
  sec
  sbc tmp
  sta POSITION_0, X
  inx
  lda POSITION_0, X
  sec
  sbc tmp
  sta POSITION_0, X
  inx
  inx
  inx
  tya
  clc
  adc POSITION_0, X
  sta POSITION_0, X
  inx
  lda POSITION_0, X
  sec
  sbc tmp
  sta POSITION_0, X
  inx
  inx
  inx
  lda POSITION_0, X
  sec
  sbc tmp
  sta POSITION_0, X
  rts

GetAvailablePositions:
  lda #$00
  ldx knightPosition
  cpx #$10
  bcs GetAvailablePositionsRow0Checked
    ora #%00000011
GetAvailablePositionsRow0Checked:
  cpx #$08
  bcs GetAvailablePositionsRow1Checked
    ora #%10000100
GetAvailablePositionsRow1Checked:
  cpx #$38
  bcc GetAvailablePositionsRow2Checked
    ora #%01001000
GetAvailablePositionsRow2Checked:
  cpx #$30
  bcc GetAvailablePositionsRow3Checked
    ora #%00110000
GetAvailablePositionsRow3Checked:
  sta tmp
  lda knightPosition
  and #%00000111 
  tax
  lda tmp
  cpx #$02
  bcs GetAvailablePositionCol0Checked
    ora #%11000000
GetAvailablePositionCol0Checked:
  cpx #$01
  bcs GetAvailablePositionCol1Checked
    ora #%00100001
GetAvailablePositionCol1Checked:
  cpx #$07
  bcc GetAvailablePositionCol2Checked
    ora #%00010010
GetAvailablePositionCol2Checked:
  cpx #$06
  bcc GetAvailablePositionCol3Checked
    ora #%00001100
GetAvailablePositionCol3Checked:
  eor #$FF
  sta availablePositions
  rts

CheckAPositionAvailable:
  tax
  lda #$00
  sec
CheckAPositionAvailableShiftLoop:
  rol
  dex
  bpl CheckAPositionAvailableShiftLoop
    and availablePositions
    rts

AdjustPosition:
  lda #$00
  sta closestPositionLeft
  sta closestPositionRight
AdjustPositionRightLoopStart:
  lda position
AdjustPositionRightLoop:
  tay
  ; Set closest clockwise position to position value
  sty newPositionRight
  jsr CheckAPositionAvailable
  bne AdjustPositionLeftLoopStart
    ; new position is not a valid position
    ; Increment distance from original position
    inc closestPositionRight 
    ; increment position value by 1 (Go clockwise)
    iny
    cpy #$08
    bne AdjustPositionRightContinue
      ; wrap position value back to 0
      ldy #$00
AdjustPositionRightContinue:
  tya
  jmp AdjustPositionRightLoop
AdjustPositionLeftLoopStart:
  lda position
AdjustPositionLeftLoop:
  tay
  ; Set closest anticlockwise position to position value
  sty newPositionLeft
  jsr CheckAPositionAvailable
  bne AdjustPositionLeftDone
    ; new position is not a valid position
    ; Increment distance from original position
    inc closestPositionLeft
    ; decrement position value by 1 (Go anticlockwise)
    dey
    cpy #$FF
    bne AdjustPositionLeftContinue
      ; wrap position value back to 0
      ldy #$07
AdjustPositionLeftContinue:
  tya
  jmp AdjustPositionLeftLoop
AdjustPositionLeftDone:
  lda closestPositionLeft
  cmp closestPositionRight
  ; On a tie, go clockwise
  bcs AdjustPositionIsRight
    ; closestPositionLeft is less than closestPositionRight
    ; Go anticlockwise
    lda newPositionLeft
    sta position
    lda #$00
    sta positionFrame
    rts
AdjustPositionIsRight:
  ; closestPositionLeft is greater or equal to closestPositionRight
  ; Go anticlockwise
  lda newPositionRight
  sta position
  lda #$00
  sta positionFrame
  rts

DisableDottedLines:
  lda #$FE
  sta L_0
  sta L_1
  sta L_2
  sta L_3
  sta L_4
  rts

DrawDottedLines:
  lda cursorPosition
  cmp #$08
  bne DrawDottedLinesCheckForSNESMouse
    jsr DisableDottedLines
    rts
DrawDottedLinesCheckForSNESMouse:
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  bne DrawDottedLinesSNESMouseChecked
    lda started
    bne DrawDottedLinesSNESMouseChecked
      lda #$01
      sta started
      jsr DisableDottedLines
      rts
DrawDottedLinesSNESMouseChecked:
  lda KNIGHT_TL
  clc
  adc #$04
  sta L_0
  sta L_1
  sta L_2
  sta L_3
  sta L_4
  lda #$04
  sta (L_0 + 1)
  sta (L_1 + 1)
  sta (L_2 + 1)
  lda #$06
  sta (L_3 + 1)
  lda #$07
  sta (L_4 + 1)
  lda #%00000001
  sta (L_0 + 2)
  sta (L_1 + 2)
  sta (L_2 + 2)
  sta (L_3 + 2)
  sta (L_4 + 2)
  lda (KNIGHT_TL + 3)
  clc
  adc #$04
  sta (L_0 + 3)
  sta (L_1 + 3)
  sta (L_2 + 3)
  sta (L_3 + 3)
  sta (L_4 + 3)
  lda position
  bne DrawDottedLinesPositionNot0
    lda (L_0 + 3)
    sec
    sbc #$0C
    sta (L_0 + 3)
    lda L_3
    sec
    sbc #$04
    sta L_3
    inc (L_1 + 1)
    inc (L_2 + 1)
    lda L_1
    sec
    sbc #$0C
    sta L_1
    lda L_2
    sec
    sbc #$14
    sta L_2
    lda (L_1 + 3)
    sec
    sbc #$10
    sta (L_1 + 3)
    sta (L_2 + 3)
    lda (L_3 + 3)
    sec
    sbc #$10
    sta (L_3 + 3)
    sta (L_4 + 3)
    jmp DrawDottedLinesDone
DrawDottedLinesPositionNot0:
  cmp #$01
  bne DrawDottedLinesPositionNot1
    lda (L_0 + 3)
    clc
    adc #$0C
    sta (L_0 + 3)
    lda L_3
    sec
    sbc #$04
    sta L_3
    inc (L_1 + 1)
    inc (L_2 + 1)
    lda L_1
    sec
    sbc #$0C
    sta L_1
    lda L_2
    sec
    sbc #$14
    sta L_2
    lda (L_1 + 3)
    clc
    adc #$10
    sta (L_1 + 3)
    sta (L_2 + 3)
    sta (L_4 + 3)
    lda (L_3 + 3)
    clc
    adc #$10
    sta (L_3 + 3)
    lda (L_3 + 2)
    ora #%01000000
    sta (L_3 + 2)
    lda (L_4 + 2)
    ora #%01000000
    sta (L_4 + 2)
    jmp DrawDottedLinesDone
DrawDottedLinesPositionNot1:
  cmp #$02
  bne DrawDottedLinesPositionNot2
    lda (L_0 + 3)
    clc
    adc #$0C
    sta (L_0 + 3)
    lda L_3
    sec
    sbc #$04
    sta L_3
    lda (L_1 + 3)
    clc
    adc #$14
    sta (L_1 + 3)
    adc #$08
    sta (L_2 + 3)
    adc #$04
    sta (L_3 + 3)
    sta (L_4 + 3)
    lda (L_3 + 2)
    ora #%01000000
    sta (L_3 + 2)
    lda (L_4 + 2)
    ora #%01000000
    sta (L_4 + 2)
    jmp DrawDottedLinesDone
DrawDottedLinesPositionNot2:
  cmp #$03
  bne DrawDottedLinesPositionNot3
    lda (L_0 + 3)
    clc
    adc #$0C
    sta (L_0 + 3)
    lda L_3
    clc
    adc #$04
    sta L_3
    lda (L_1 + 3)
    clc
    adc #$14
    sta (L_1 + 3)
    adc #$08
    sta (L_2 + 3)
    adc #$04
    sta (L_3 + 3)
    sta (L_4 + 3)
    lda (L_3 + 2)
    ora #%11000000
    sta (L_3 + 2)
    lda (L_4 + 2)
    ora #%11000000
    sta (L_4 + 2)
    jmp DrawDottedLinesDone
DrawDottedLinesPositionNot3:
  cmp #$04
  bne DrawDottedLinesPositionNot4
    lda (L_0 + 3)
    clc
    adc #$0C
    sta (L_0 + 3)
    lda L_3
    clc
    adc #$04
    sta L_3
    inc (L_1 + 1)
    inc (L_2 + 1)
    lda L_1
    clc
    adc #$0C
    sta L_1
    lda L_2
    clc
    adc #$14
    sta L_2
    lda (L_1 + 3)
    clc
    adc #$10
    sta (L_1 + 3)
    sta (L_2 + 3)
    lda (L_3 + 3)
    clc
    adc #$10
    sta (L_3 + 3)
    sta (L_4 + 3)
    lda (L_3 + 2)
    ora #%11000000
    sta (L_3 + 2)
    lda (L_4 + 2)
    ora #%11000000
    sta (L_4 + 2)
    jmp DrawDottedLinesDone
DrawDottedLinesPositionNot4:
  cmp #$05
  bne DrawDottedLinesPositionNot5
    lda (L_0 + 3)
    sec
    sbc #$0C
    sta (L_0 + 3)
    lda L_3
    clc
    adc #$04
    sta L_3
    inc (L_1 + 1)
    inc (L_2 + 1)
    lda L_1
    clc
    adc #$0C
    sta L_1
    lda L_2
    clc
    adc #$14
    sta L_2
    lda (L_1 + 3)
    sec
    sbc #$10
    sta (L_1 + 3)
    sta (L_2 + 3)
    lda (L_3 + 3)
    sec
    sbc #$10
    sta (L_3 + 3)
    sta (L_4 + 3)
    lda (L_3 + 2)
    ora #%10000000
    sta (L_3 + 2)
    lda (L_4 + 2)
    ora #%10000000
    sta (L_4 + 2)
    jmp DrawDottedLinesDone
DrawDottedLinesPositionNot5:
  cmp #$06
  bne DrawDottedLinesPositionNot6
    lda (L_0 + 3)
    sec
    sbc #$0C
    sta (L_0 + 3)
    lda L_3
    clc
    adc #$04
    sta L_3
    lda (L_1 + 3)
    sec
    sbc #$14
    sta (L_1 + 3)
    sbc #$08
    sta (L_2 + 3)
    sbc #$04
    sta (L_3 + 3)
    sta (L_4 + 3)
    lda (L_3 + 2)
    ora #%10000000
    sta (L_3 + 2)
    lda (L_4 + 2)
    ora #%10000000
    sta (L_4 + 2)
    jmp DrawDottedLinesDone
DrawDottedLinesPositionNot6:
  lda (L_0 + 3)
  sec
  sbc #$0C
  sta (L_0 + 3)
  lda L_3
  sec
  sbc #$04
  sta L_3
  lda (L_1 + 3)
  sec
  sbc #$14
  sta (L_1 + 3)
  sbc #$08
  sta (L_2 + 3)
  sbc #$04
  sta (L_3 + 3)
  sta (L_4 + 3)
  jmp DrawDottedLinesDone
DrawDottedLinesDone:
  rts

UpdateDisallowedPositions:
  lda knightPosition
  and #%00111000
  lsr
  lsr
  lsr
  tax
  lda knightPosition
  and #%00000111
  tay
  iny
  lda #%00000000
  sec
UpdateDisallowedPositionsLoop:
  ror
  dey
  bne UpdateDisallowedPositionsLoop
    sta tmp
    lda broken, X
    ora tmp
    sta broken, X
    rts

CheckDisallowedPositions:
  sta availablePositionsTmp
  lda knightPosition
  sec
  sbc #$11
  sta positionRealTmp
  lda availablePositions
  and #%00000001
  beq CheckDisallowedPosition1
    lda positionRealTmp
    jsr CheckAPositionBroken
    beq CheckDisallowedPosition1
      lda availablePositions 
      and #%11111110
      sta availablePositions
CheckDisallowedPosition1:
  lda positionRealTmp
  clc
  adc #$02
  sta positionRealTmp
  lda availablePositions
  and #%00000010
  beq CheckDisallowedPosition2
    lda positionRealTmp
    jsr CheckAPositionBroken
    beq CheckDisallowedPosition2
      lda availablePositions 
      and #%11111101
      sta availablePositions
CheckDisallowedPosition2:
  lda positionRealTmp
  clc
  adc #$09
  sta positionRealTmp
  lda availablePositions
  and #%00000100
  beq CheckDisallowedPosition3
    lda positionRealTmp
    jsr CheckAPositionBroken
    beq CheckDisallowedPosition3
      lda availablePositions 
      and #%11111011
      sta availablePositions
CheckDisallowedPosition3:
  lda positionRealTmp
  clc
  adc #$10
  sta positionRealTmp
  lda availablePositions
  and #%00001000
  beq CheckDisallowedPosition4
    lda positionRealTmp
    jsr CheckAPositionBroken
    beq CheckDisallowedPosition4
      lda availablePositions 
      and #%11110111
      sta availablePositions
CheckDisallowedPosition4:
  lda positionRealTmp
  clc
  adc #$07
  sta positionRealTmp
  lda availablePositions
  and #%00010000
  beq CheckDisallowedPosition5
    lda positionRealTmp
    jsr CheckAPositionBroken
    beq CheckDisallowedPosition5
      lda availablePositions 
      and #%11101111
      sta availablePositions
CheckDisallowedPosition5:
  lda positionRealTmp
  sec
  sbc #$02
  sta positionRealTmp
  lda availablePositions
  and #%00100000
  beq CheckDisallowedPosition6
    lda positionRealTmp
    jsr CheckAPositionBroken
    beq CheckDisallowedPosition6
      lda availablePositions 
      and #%11011111
      sta availablePositions
CheckDisallowedPosition6:
  lda positionRealTmp
  sec
  sbc #$09
  sta positionRealTmp
  lda availablePositions
  and #%01000000
  beq CheckDisallowedPosition7
    lda positionRealTmp
    jsr CheckAPositionBroken
    beq CheckDisallowedPosition7
      lda availablePositions 
      and #%10111111
      sta availablePositions
CheckDisallowedPosition7:
  lda positionRealTmp
  sec
  sbc #$10
  sta positionRealTmp
  lda availablePositions
  and #%10000000
  beq CheckDisallowedPositionsDone
    lda positionRealTmp
    jsr CheckAPositionBroken
    beq CheckDisallowedPositionsDone
      lda availablePositions 
      and #%01111111
      sta availablePositions
CheckDisallowedPositionsDone:
  lda availablePositions
  bne CheckDisallowedPositionsNotGameOver
    lda #$01
    sta end
CheckDisallowedPositionsNotGameOver:
  lda canFall
  beq CheckDisallowedPositionsNotCanFall
    lda availablePositionsTmp
    sta availablePositions
CheckDisallowedPositionsNotCanFall:
  rts

CheckAPositionBroken:
  sta tmp
  and #%00111000
  lsr
  lsr
  lsr
  tax
  lda tmp
  and #%00000111
  tay
  iny
  lda #%00000000
  sec
CheckAPositionBrokenLoop:
  ror
  dey
  bne CheckAPositionBrokenLoop
    sta tmp
    lda broken, X
    and tmp
    rts

CrackTile:
  lda invisibleCracks
  beq CrackTileContinue
    lda #$00
    sta drawCrack
    rts
CrackTileContinue:
  lda crackPosition
  and #%00001000
  lsr
  lsr
  lsr
  eor crackPosition
  eor #%00000001
  and #%00000001
  asl
  clc
  adc #$83
  sta crackColor
  lda #$21
  sta crackAddr
  lda #$08
  sta (crackAddr + 1)
  lda crackPosition
  and #%00111000
  lsr
  lsr
  lsr
  tay
  iny
CrackTitleIncAddrRowLoop:
  dey
  beq CrackTitleIncAddrRowLoopDone
    lda (crackAddr + 1)
    clc
    adc #$40
    sta (crackAddr + 1)
    lda crackAddr
    adc #$00
    sta crackAddr
    jmp CrackTitleIncAddrRowLoop
CrackTitleIncAddrRowLoopDone:
  lda crackPosition
  and #%00000111
  asl
  clc
  adc (crackAddr + 1)
  sta (crackAddr + 1)
  lda #$01
  sta drawCrack
  rts

PositionMovementBiases:
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte $01, $01, $06, $00, $00, $00, $00, $00
  .byte $01, $01, $01, $01, $04, $00, $00, $00
  .byte $03, $01, $06, $03, $04, $05, $02, $00

MovePosition:
  ldy #$00
  lda positionMoveOffset
  and #%00000111
  cmp #$04
  bcc MovePositionNotInvertBits
    eor #%00000111
    iny
MovePositionNotInvertBits:
  asl
  asl
  asl
  tax
  stx (tmp + 1)
MovePositionLoop:
  ldx (tmp + 1)
  lda PositionMovementBiases, X
  cpy #$01
  bne MovePositionLoopContinue
    lda #$00
    sec
    sbc PositionMovementBiases, X
MovePositionLoopContinue:
  sta tmp
  lda positionTmp
  sec
  sbc tmp
  sta positionTmp
  inc (tmp + 1)
  and #%00000111
  jsr CheckAPositionAvailable
  beq MovePositionLoop
    lda positionTmp
    and #%00000111
    sta positionTmp
    rts

CheckEndPosition:
  ldy endPositionOption
  beq CheckEndPositionDone
    ldy knightPosition
    cpy endPosition
    bne CheckEndPositionDone
      lda #$00
      sta availablePositions
CheckEndPositionDone:
  rts
