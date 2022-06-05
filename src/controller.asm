; Copyright (C) 2020, Vi Grey
; All rights reserved.

PollController:
  lda controllerType
  sta controllerTypeLastFrame
  lda controller1D0
  sta controller1D0LastFrame
  lda (controller1D0 + 1)
  sta (controller1D0LastFrame + 1)
  lda (controller1D0 + 2)
  sta (controller1D0LastFrame + 2)
  lda (controller1D0 + 3)
  sta (controller1D0LastFrame + 3)
  lda controller1D3
  lda controller1D4
PollControllerLatch:
  lda #$01
  sta CONTROLLER1
  jsr SetMouseSensitivity
  lda #$00
  sta CONTROLLER1
  ldy #$08
  ldx #$00
PollController1Loop:
  lda CONTROLLER1                       ; 4
  sta tmp
  lsr                                   ; 2
  rol controller1D0, X                  ; 7
  cpx #$00                              ; 2
  bne PollController1LoopNotFirstByte   ; 3
    lsr
    lsr
    lsr
    rol controller1D3
    lsr
    rol controller1D4
    lda tmp
PollController1LoopNotFirstByte:
  dey                                   ; 2
  bne PollController1Loop               ; 3
    ldy #$08                            ; 2
    inx                                 ; 2
    cpx #$04                            ; 2
    bne PollController1Loop             ; 3
      jsr IdentifyController
      jsr CheckPowerPad
      rts

CheckController:
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  beq CheckControllerMouse
    jsr CheckUp
    jsr CheckDown
    jsr CheckLeft
    jsr CheckRight
    jsr CheckA
    rts
CheckControllerMouse:
  jsr CheckLeftClick
  rts

ModifyController:
  lda controller1D0
  and controller1D0LastFrame
  eor controller1D0
  sta controller1D0Final

  lda (controller1D0 + 1)
  and (controller1D0LastFrame + 1)
  eor (controller1D0 + 1)
  and #%11000000
  sta (controller1D0Final + 1)

  lda leftHanded
  bne AdjustLeftHanded
    rts
AdjustLeftHanded:
  lda controllerType
  cmp #CONTROLLER_POWER_PAD
  bne AdjustLeftHandedNotPowerPad
    lda controller1D0Final
    and #%00101010
    lsr
    sta tmp
    lda controller1D0Final
    and #%00010101
    asl
    ora tmp
    sta tmp
    lda controller1D0Final
    and #%11000000
    ora tmp
    sta controller1D0Final
AdjustLeftHandedNotPowerPad:
  lda controller1D0Final
  and #%10101010
  lsr
  sta tmp
  lda controller1D0Final
  and #%01010101
  asl
  ora tmp
  sta controller1D0Final
  lda (controller1D0Final + 1)
  and #%10000000
  lsr
  sta tmp
  lda (controller1D0Final + 1)
  and #%01000000
  asl
  ora tmp
  sta tmp
  lda (controller1D0Final + 1)
  and #%00000001
  ora tmp
  sta (controller1D0Final + 1)

  rts

CheckUp:
  lda controller1D0Final
  and #BUTTON_UP
  beq CheckUpDone
    lda position
    sta positionTmp
    sta positionMoveOffset
    dec positionMoveOffset
    jsr MovePosition
    cmp position
    beq CheckUpDone
      sta position
      lda #$00
      sta positionFrame
      lda #$01
      sta redrawSprites
CheckUpDone:
  rts

CheckDown:
  lda controller1D0Final
  and #BUTTON_DOWN
  beq CheckDownDone
    lda position
    sta positionTmp
    sta positionMoveOffset
    inc positionMoveOffset
    inc positionMoveOffset
    inc positionMoveOffset
    jsr MovePosition
    cmp position
    beq CheckDownDone
      sta position
      lda #$00
      sta positionFrame
      lda #$01
      sta redrawSprites
CheckDownDone:
  rts

CheckLeft:
  lda controller1D0Final
  and #BUTTON_LEFT
  beq CheckLeftDone
    lda position
    sta positionTmp
    sta positionMoveOffset
    inc positionMoveOffset
    jsr MovePosition
    cmp position
    beq CheckLeftDone
      sta position
      lda #$00
      sta positionFrame
      lda #$01
      sta redrawSprites
CheckLeftDone:
  rts

CheckRight:
  lda controller1D0Final
  and #BUTTON_RIGHT
  beq CheckRightDone
    lda position
    sta positionTmp
    sta positionMoveOffset
    dec positionMoveOffset
    dec positionMoveOffset
    dec positionMoveOffset
    jsr MovePosition
    cmp position
    beq CheckRightDone
      sta position
      lda #$00
      sta positionFrame
      lda #$01
      sta redrawSprites
CheckRightDone:
  rts

CheckA:
  lda controller1D0Final
  and #BUTTON_A
  bne CheckAContinue
    rts
CheckAContinue:
  lda position 
  bne CheckAPositionNot0
    lda knightPosition
    sec
    sbc #$11
    sta knightPositionNew
    jmp CheckADraw
CheckAPositionNot0:
  cmp #$01
  bne CheckAPositionNot1
    lda knightPosition
    sec
    sbc #$0F
    sta knightPositionNew
    jmp CheckADraw
CheckAPositionNot1:
  cmp #$02
  bne CheckAPositionNot2
    lda knightPosition
    sec
    sbc #$06
    sta knightPositionNew
    jmp CheckADraw
CheckAPositionNot2:
  cmp #$03
  bne CheckAPositionNot3
    lda knightPosition
    clc
    adc #$0A
    sta knightPositionNew
    jmp CheckADraw
CheckAPositionNot3:
  cmp #$04
  bne CheckAPositionNot4
    lda knightPosition
    clc
    adc #$11
    sta knightPositionNew
    jmp CheckADraw
CheckAPositionNot4:
  cmp #$05
  bne CheckAPositionNot5
    lda knightPosition
    clc
    adc #$0F
    sta knightPositionNew
    jmp CheckADraw
CheckAPositionNot5:
  cmp #$06
  bne CheckAPositionNot6
    lda knightPosition
    clc
    adc #$06
    sta knightPositionNew
    jmp CheckADraw
CheckAPositionNot6:
  lda knightPosition
  sec
  sbc #$0A
  sta knightPositionNew
CheckADraw:
  lda knightPositionNew
  jsr CheckAPositionBroken
  beq CheckADrawNotBrokenPosition
    lda #$01
    sta end
    rts
CheckADrawNotBrokenPosition:
  jsr UpdateDisallowedPositions
  lda #$00
  sta knightFrame
  lda positionFrame
  and #%00001000
  beq CheckADrawContinue
    lda positionFrame
    and #%00010000
    ora #%00001111
    sta positionFrame
    inc positionFrame
    jsr UpdatePositionCorners
CheckADrawContinue:
  lda #$01
  sta animateKnight
  lda knightPosition
  sta crackPosition
  jsr CrackTile
  jsr IncScore
  jsr IncCurrentBoardScore
  jsr UpdateTopScore
CheckADone:
  rts

IdentifyController:
  lda (controller1D0 + 1)
  and #%00001111
  cmp #%00000001
  bne IdentifyControllerNotSNESMouse
    lda #CONTROLLER_SNES_MOUSE
    sta controllerType
    rts
IdentifyControllerNotSNESMouse:
  lda #$00
  sta snesMouseReady
  jsr EraseCursor
  lda controller1D4
  and #%00001111
  cmp #%00001111
  bne IdentifyControllerNotPowerPad
    lda #CONTROLLER_POWER_PAD
    sta controllerType
    rts
IdentifyControllerNotPowerPad:
  lda #CONTROLLER_STANDARD
  sta controllerType
  rts
