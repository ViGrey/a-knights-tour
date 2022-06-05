; Copyright (C) 2020, Vi Grey
; All rights reserved.

StartTitleScreen:
  ; Turn screen completely black for 1 frame to avoid flicker/tear
  jsr BlankScreen
  ; Turn screen and NMI off
  jsr Blank
  ; Set screen to SCREEN_TITLE
  lda #SCREEN_TITLE
  sta screen
  ; Set background table to pattern table 01
  lda #$01
  sta backgroundTable
  ; Initialize titleFrames and started.
  ; Set sprite table to pattern table 00
  lda #$00
  sta titleFrames
  ; Consider a situation where started is not needed
  sta started
  sta spriteTable
  jsr DrawTitleScreen
  jsr SetTitleScreenPalette
  jsr UpdateDone
  jsr ReadThenResetGraphics
  ; Initialize controller1 last frame to say all buttons pressed
  lda #$FF
  sta controller1D0LastFrame
  sta (controller1D0LastFrame + 1)
  ; Check if controller is a SNES mouse
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  bne StartTitleScreenNotSNESMouse
    ; Check if SNES mouse is ready
    lda snesMouseReady
    beq StartTitleScreenNotSNESMouse
      ; Draw cursor if SNES mouse is ready
      jsr DrawCursor
StartTitleScreenNotSNESMouse:
  ; Place option pointer based on mouse cursor
  jsr CursorTitleOption
  jsr ManageTitleOption
  ; Draw option pointer based on what titleOption is set to
  jsr DrawTitleOptionCursor
  jsr CursorTitleOption
  ; Set newDraw for when new frame happens
  jsr ReadThenResetGraphics
  jsr DisableLevelModeAttr
  lda #$01
  sta needDraw
  ; Re-enable NMI
  jsr ResetScroll
  rts

DrawTitleScreen:
  lda #<(TitleScreen)
  sta addr
  lda #>(TitleScreen)
  sta (addr + 1)
  ldx #$04
  ldy #$00
  lda PPU_STATUS
  lda #$20
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
DrawTitleScreenLoop:
  lda (addr), Y
  sta PPU_DATA
  iny
  bne DrawTitleScreenLoop
    inc (addr + 1)
    dex
    bne DrawTitleScreenLoop
      rts

SetTitleScreenPalette:
  ldx graphicsPointer
  lda #$00
  sta graphics, X
  inx
  lda #$FE
  sta graphics, X
  inx
  lda #$3F
  sta graphics, X
  inx
  lda #$00
  sta graphics, X
  inx
  ldy #$04
SetTitleScreenPaletteBackgroundLoop:
  lda #$0F
  sta graphics, X
  inx
  lda #$80
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
  lda #$2D
  cpy #$04
  bne SetTitleScreenPaletteBackgroundLoopContinue
    lda #$30
SetTitleScreenPaletteBackgroundLoopContinue:
  sta graphics, X
  inx
  dey
  bne SetTitleScreenPaletteBackgroundLoop
    ldy #$04
SetTitleScreenPaletteSpritesLoop:
  lda #$0F
  sta graphics, X
  inx
  sta graphics, X
  inx
  sta graphics, X
  inx
  lda #$30
  sta graphics, X
  inx
  dey
  bne SetTitleScreenPaletteSpritesLoop
    stx graphicsPointer
    rts

DisableLevelModeAttr:
  ldx graphicsPointer
  lda #$00
  sta graphics, X
  inx
  lda #$FE
  sta graphics, X
  inx
  lda #$23
  sta graphics, X
  inx
  lda #$D9
  sta graphics, X
  inx
  lda #$0C
  sta graphics, X
  inx
  lda #$0F
  sta graphics, X
  inx
  sta graphics, X
  inx
  stx graphicsPointer
  rts




; TODO FIGURE OUT WHAT THIS CODE DOES!!!
; This is a hack-y way of preventing options during preview runs
ManageTitleOption:
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  bne ManageTitleOptionsNotSNESMouse
    lda titleOption
    bne ManageTitleOptionsSNESMouseTitleOptionNot0
      lda #$03
      sta titleOption
ManageTitleOptionsSNESMouseTitleOptionNot0:
  rts
ManageTitleOptionsNotSNESMouse:
  ; hack
  lda titleOption
  bne HackManageTitleOptionNot0
    lda #$02
    sta titleOption
HackManageTitleOptionNot0:
  ; hack
  lda titleOption
  and #%10000000
  beq ManageTitleOptionsNotNegative
    lda #$02
    sta titleOption
ManageTitleOptionsNotNegative:
  lda titleOption
  cmp #$03
  bcc ManageTitleOptionsNotOverflow
    ; hack
    lda #$01
    ; hack
ManageTitleOptionsNotOverflow:
  sta titleOption
  rts




CheckControllerTitleScreen:
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  bne CheckControllerTitleScreenNotSNESMouse
    jsr CheckLeftClickTitleScreen
    rts
CheckControllerTitleScreenNotSNESMouse:
  jsr CheckATitleScreen
  jsr CheckUpTitleScreen
  jsr CheckDownTitleScreen
  rts

CheckATitleScreen:
  lda controller1D0Final
  and #BUTTON_A
  beq CheckATitleScreenDone
    lda titleOption
    cmp #TITLE_OPTION_LEVEL_MODE
    bne CheckATitleScreenOptionNotLevelMode
      rts
CheckATitleScreenOptionNotLevelMode:
  cmp #TITLE_OPTION_SCORE_MODE
  bne CheckATitleScreenOptionNotScoreMode
    jsr ResetTimeScore
    jsr StartBoardScreen
    rts
CheckATitleScreenOptionNotScoreMode:
  cmp #TITLE_OPTION_OPTIONS
  bne CheckATitleScreenOptionNotOptions
    jsr StartOptionsScreen
    rts
CheckATitleScreenOptionNotOptions:
CheckATitleScreenDone:
  rts

CheckUpTitleScreen:
  lda controller1D0Final
  and #BUTTON_UP
  beq CheckUpTitleScreenDone
    dec titleOption
CheckUpTitleScreenDone:
  rts

CheckDownTitleScreen:
  lda controller1D0Final
  and #BUTTON_DOWN
  beq CheckDownTitleScreenDone
    inc titleOption
CheckDownTitleScreenDone:
  rts

DrawTitleOptionCursor:
  lda titleOption
  cmp #TITLE_OPTION_OPTIONS + 1
  bcc DrawTitleOptionCursorContinue
    jsr ErasePointer
    rts
DrawTitleOptionCursorContinue:
  ldy #$20
  lda titleOption
  asl
  asl
  asl
  asl
  clc
  adc #$5F
  sta $2FC
  lda #$13
  sta $2FD
  lda #%00000000
  sta $2FE
  lda titleFrames
  and #%00001000
  beq DrawTitleOptionCursorFinish
    lda titleFrames
    and #%00010000
    bne DrawTitleOptionCursorNot3
      dey
      jmp DrawTitleOptionCursorFinish
DrawTitleOptionCursorNot3:
  iny
DrawTitleOptionCursorFinish:
  sty $2FF
  rts

CheckLeftClickTitleScreen:
  lda (controller1D0Final + 1)
  and #LEFT_CLICK
  beq CheckLeftClickTitleScreenDone
    lda titleOption
    cmp #TITLE_OPTION_LEVEL_MODE
    bne CheckLeftClickTitleScreenOptionNotLevelMode
      rts
CheckLeftClickTitleScreenOptionNotLevelMode:
  cmp #TITLE_OPTION_SCORE_MODE
  bne CheckLeftClickTitleScreenOptionNotScoreMode
    jsr ResetTimeScore
    jsr StartBoardScreen
    rts
CheckLeftClickTitleScreenOptionNotScoreMode:
  cmp #TITLE_OPTION_OPTIONS
  bne CheckLeftClickTitleScreenOptionNotOptions
    jsr StartOptionsScreen
    rts
CheckLeftClickTitleScreenOptionNotOptions:
CheckLeftClickTitleScreenDone:
  rts

CursorTitleOption:
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  beq CursorTitleOptionContinue
    rts
CursorTitleOptionContinue:
  ldy #$00
  ldx #$00
CursorTitleOptionYPositionLoop:
  lda CURSOR
  cmp TitleOptionsHitBoxes, X
  bcs CursorTitleOptionCheckRange8
    ldy #OPTIONS_TITLE_SCREEN + 1
    sty titleOption
    rts
CursorTitleOptionCheckRange8:
  lda TitleOptionsHitBoxes, X
  inx
  inx
  inx
  inx
  clc
  adc #$08
  sta tmp
  lda CURSOR
  cmp tmp
  bcs CursorTitleOptionYPositionNotCorrect
    sty titleOption
    jsr CursorTitleOptionHorizontal
    rts
CursorTitleOptionYPositionNotCorrect:
  iny
  cpy #OPTIONS_TITLE_SCREEN + 1
  bne CursorTitleOptionYPositionLoop
    sty titleOption
    rts

CursorTitleOptionHorizontal:
  lda titleOption
  asl
  asl
  tax
  inx
  lda TitleOptionsHitBoxes, X
  sta tmp
  lda (CURSOR + 3)
  cmp tmp
  bcs CursorTitleOptionHorizontalNotTooLeft
    ldy #OPTIONS_TITLE_SCREEN + 1
    sty titleOption
    rts
CursorTitleOptionHorizontalNotTooLeft:
  inx
  lda TitleOptionsHitBoxes, X
  asl
  asl
  asl
  clc
  adc tmp
  sta tmp
  lda (CURSOR + 3)
  cmp tmp
  bcc CursorTitleOptionHoriziontalNotTooFarRight
    ldy #OPTIONS_TITLE_SCREEN + 1
    sty titleOption
CursorTitleOptionHoriziontalNotTooFarRight:
  rts

TitleOptionsHitBoxes:
  .byte $5F, $30, $0A, $00
  .byte $6F, $30, $0A, $00
  .byte $7F, $30, $07, $00

TitleScreen:
  .incbin "graphics/title.nam"
  .incbin "graphics/title.atr"
