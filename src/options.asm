; Copyright (C) 2020, Vi Grey
; All rights reserved.

StartOptionsScreen:
  ; Turn screen completely black for 1 frame to avoid flicker/tear
  jsr BlankScreen
  ; Turn screen and NMI off
  jsr Blank
  ; Set screen to SCREEN_OPTIONS
  lda #SCREEN_OPTIONS
  sta screen
  ; Set sprite table to pattern table 01
  lda #$01
  sta spriteTable
  ; Set background table to pattern table 00
  lda #$00
  sta backgroundTable
  ; TODO - Consider a situation where started is not needed
  sta started
  ; TODO - Consider a situation where titleOption and pointer are the same
  sta pointer
  jsr DrawOptionsScreen
  jsr SetTitleScreenPalette
  ; Initialize controller1 last frame to say all buttons pressed
  lda #$FF
  sta controller1D0LastFrame
  sta (controller1D0LastFrame + 1)
  ; Check if controller is a SNES mouse
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  bne StartOptionsScreenNotSNESMouse
    ; Check if controller is a SNES mouse
    lda snesMouseReady
    beq StartOptionsScreenNotSNESMouse
      ; Draw cursor if SNES mouse is ready
      jsr DrawCursor
StartOptionsScreenNotSNESMouse:
  ; Place option pointer based on mouse cursor
  jsr CursorOptionPointer
  jsr ModifyOptionsPointer
  ; Draw option pointer based on what pointer is set to
  jsr DrawOptionsPointer
  jsr CursorOptionPointer
  ; Set newDraw for when new frame happens
  jsr ReadThenResetGraphics
  jsr DrawOptionsValues
  jsr UpdateDone
  lda #$01
  sta needDraw
  ; Re-enable NMI
  jsr ResetScroll
  rts

DrawOptionsScreen:
  lda #<(OptionsScreen)
  sta addr
  lda #>(OptionsScreen)
  sta (addr + 1)
  ldx #$04
  ldy #$00
  lda PPU_STATUS
  lda #$20
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
DrawOptionsScreenLoop:
  lda (addr), Y
  sta PPU_DATA
  iny
  bne DrawOptionsScreenLoop
    inc (addr + 1)
    dex
    bne DrawOptionsScreenLoop
      rts

DrawOptionsPointer:
  lda pointer
  cmp #OPTIONS_TITLE_SCREEN + 1
  bcc DrawOptionsPointerContinue
    jsr ErasePointer
    rts
DrawOptionsPointerContinue:
  ldy #$28
  inc pointerFrames
  lda pointer
  asl
  asl
  tax
  lda OptionsPointerHitBoxes, X
  sta $2FC
  lda #$13
  sta $2FD
  lda #%00000000
  sta $2FE
  lda pointerFrames
  and #%00001000
  beq DrawOptionsPointerFinish
    lda pointerFrames
    and #%00010000
    bne DrawOptionsPointerNot3
      dey
      jmp DrawOptionsPointerFinish
DrawOptionsPointerNot3:
  iny
DrawOptionsPointerFinish:
  sty $2FF
  rts

ModifyOptionsPointer:
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  beq ModifyOptionsPointerDone
    lda pointer
    and #%10000000
    beq ModifyOptionsPointerNotNegative
      lda #OPTIONS_TITLE_SCREEN
      sta pointer
      rts
ModifyOptionsPointerNotNegative:
  lda pointer
  cmp #OPTIONS_TITLE_SCREEN + 1
  bcc ModifyOptionsPointerDone
    lda #$00
    sta pointer
ModifyOptionsPointerDone:
  rts

CheckControllerOptionsScreen:
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  bne CheckControllerOptionsScreenNotSNESMouse
    jsr CheckLeftClickOptions
    rts
CheckControllerOptionsScreenNotSNESMouse:
  jsr CheckAOptions
  jsr CheckLeftRightOptions
  jsr CheckUpOptionsScreen
  jsr CheckDownOptionsScreen
  rts

CheckUpOptionsScreen:
  lda controller1D0Final
  and #BUTTON_UP
  beq CheckUpOptionsScreenDone
    dec pointer
CheckUpOptionsScreenDone:
  rts

CheckDownOptionsScreen:
  lda controller1D0Final
  and #BUTTON_DOWN
  beq CheckDownOptionsScreenDone
    inc pointer
CheckDownOptionsScreenDone:
  rts

CheckLeftRightOptions:
  lda controller1D0Final
  and #(BUTTON_LEFT + BUTTON_RIGHT)
  beq CheckLeftRightOptionsScreenDone
    eor #(BUTTON_LEFT + BUTTON_RIGHT)
    beq CheckLeftRightOptionsScreenDone
      lda pointer
      cmp #OPTIONS_DEFAULT
      bcs CheckLeftRightOptionsScreenNotPositionBeforeOptions
        jsr ToggleOption
        jsr DrawSingleOnOff
        rts
CheckLeftRightOptionsScreenNotPositionBeforeOptions:
CheckLeftRightOptionsScreenDone:
  rts

CheckAOptions:
  lda controller1D0Final
  and #BUTTON_A
  beq CheckAOptionsScreenDone
    lda pointer
    cmp #OPTIONS_DEFAULT
    bcs CheckAOptionsScreenNotPositionBeforeOptions
      jsr ToggleOption
      jsr DrawSingleOnOff
      rts
CheckAOptionsScreenNotPositionBeforeOptions:
  bne CheckAOptionsScreenNotPositionDefaultOptions
    jsr DefaultOptions
    jsr DrawOptionsValues
    rts
CheckAOptionsScreenNotPositionDefaultOptions:
  cmp #OPTIONS_TITLE_SCREEN
  bne CheckAOptionsScreenNotPositionTitleScreen
    jsr StartTitleScreen
    rts
CheckAOptionsScreenNotPositionTitleScreen:
CheckAOptionsScreenDone:
  rts

CheckLeftClickOptions:
  lda (controller1D0Final + 1)
  and #LEFT_CLICK
  beq CheckLeftClickOptionsScreenDone
    lda pointer
    cmp #OPTIONS_DEFAULT
    bcs CheckLeftClickOptionsScreenNotPositionBeforeOptions
      jsr ToggleOption
      jsr DrawSingleOnOff
      rts
CheckLeftClickOptionsScreenNotPositionBeforeOptions:
  bne CheckLeftClickOptionsScreenNotPositionDefaultOptions
    jsr DefaultOptions
    jsr DrawOptionsValues
    rts
CheckLeftClickOptionsScreenNotPositionDefaultOptions:
  cmp #OPTIONS_TITLE_SCREEN
  bne CheckLeftClickOptionsScreenNotPositionTitleScreen
    jsr StartTitleScreen
    rts
CheckLeftClickOptionsScreenNotPositionTitleScreen:
CheckLeftClickOptionsScreenDone:
  rts

ToggleOption:
  ldy pointer
  lda OptionsVariables, Y
  eor #%00000001
  and #%00000001
  sta OptionsVariables, Y
  rts

DrawOptionsValues:
  lda pointer
  pha
  lda #$00
  sta pointer
DrawOptionsValuesLoop:
  jsr DrawSingleOnOff
  inc pointer
  lda pointer
  cmp #OPTIONS_DEFAULT
  bcc DrawOptionsValuesLoop
    pla
    sta pointer
    rts

DrawOn:
  lda #"O"
  sta graphics, X
  inx
  lda #"N"
  sta graphics, X
  inx
  lda #$00
  sta graphics, X
  inx
  lda #$80
  sta graphics, X
  inx
  lda #$00
  sta graphics, X
  inx
  rts

DrawOff:
  lda #"O"
  sta graphics, X
  inx
  lda #"F"
  sta graphics, X
  inx
  sta graphics, X
  inx
  rts

DefaultOptions:
  lda #$00
  sta leftHanded
  sta canFall
  sta invisibleCracks
  sta invisibleGuides
  sta endPositionOption
  rts

CursorOptionPointer:
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  beq CursorOptionPointerContinue
    rts
CursorOptionPointerContinue:
  ldy #$00
  ldx #$00
CursorOptionPointerYPositionLoop:
  lda CURSOR
  cmp OptionsPointerHitBoxes, X
  bcs CursorOptionPointerCheckRange8
    ldy #OPTIONS_TITLE_SCREEN + 1
    sty pointer
    rts
CursorOptionPointerCheckRange8:
  lda OptionsPointerHitBoxes, X
  inx
  inx
  inx
  inx
  clc
  adc #$08
  sta tmp
  lda CURSOR
  cmp tmp
  bcs CursorOptionPointerYPositionNotCorrect
    sty pointer
    jsr CursorOptionPointerHorizontal
    rts
CursorOptionPointerYPositionNotCorrect:
  iny
  cpy #OPTIONS_TITLE_SCREEN + 1
  bne CursorOptionPointerYPositionLoop
    sty pointer
    rts

CursorOptionPointerHorizontal:
  lda pointer
  asl
  asl
  tax
  inx
  lda OptionsPointerHitBoxes, X
  sta tmp
  lda (CURSOR + 3)
  cmp tmp
  bcs CursorOptionPointerHorizontalNotTooLeft
    ldy #OPTIONS_TITLE_SCREEN + 1
    sty pointer
    rts
CursorOptionPointerHorizontalNotTooLeft:
  inx
  lda OptionsPointerHitBoxes, X
  asl
  asl
  asl
  clc
  adc tmp
  sta tmp
  lda (CURSOR + 3)
  cmp tmp
  bcc CursorOptionPointerHoriziontalNotTooFarRight
    ldy #OPTIONS_TITLE_SCREEN + 1
    sty pointer
CursorOptionPointerHoriziontalNotTooFarRight:
  rts

ManageInvisibleGuides:
  lda invisibleGuides
  bne ManageInvisibleGuidesContinue
    rts
ManageInvisibleGuidesContinue:
  lda #$00 
  ldx #$01
  ldy #$20
ManageInvisibleGuidesLoop:
  sta POSITION_0, X
  inx
  inx
  inx
  inx
  dey
  bne ManageInvisibleGuidesLoop
    ldx #$01
    ldy #$05
ManageInvisibleLLoop:
  sta L_3, X
  inx
  inx
  inx
  inx
  dey
  bne ManageInvisibleLLoop
    rts

DrawSingleOnOff:
  ldy pointer
  lda #$20
  sta tmp
  lda #$B8
  sta (tmp + 1)
DrawSingleOnOffPointerAddLoop:
  cpy #$00
  beq DrawSingleOnOffPointerAddLoopDone
    dey
    lda #$40
    jsr IncTmpBytesByABigEndian
    jmp DrawSingleOnOffPointerAddLoop
DrawSingleOnOffPointerAddLoopDone:
  ldx graphicsPointer
  lda #$00
  sta graphics, X
  inx
  lda #$FE
  sta graphics, X
  inx
  lda tmp
  sta graphics, X
  inx
  lda (tmp + 1)
  sta graphics, X
  inx
  ldy pointer
  lda OptionsVariables, Y
  bne DrawSingleOn
    jsr DrawOff
    jmp DrawSingleOnOffDone
DrawSingleOn:
  jsr DrawOn
DrawSingleOnOffDone:
  stx graphicsPointer
  rts
    
OptionsPointerHitBoxes:
  .byte $27, $38, $14, $00
  .byte $37, $38, $14, $00
  .byte $47, $38, $14, $00
  .byte $57, $38, $14, $00
  .byte $67, $38, $14, $00
  .byte $AF, $38, $0F, $00
  .byte $BF, $38, $0C, $00

OptionsScreen:
  .incbin "graphics/options.nam"
  .incbin "graphics/options.atr"
