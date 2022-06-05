; Copyright (C) 2020, Vi Grey
; All rights reserved.


Update:
  jsr LFSR
  jsr PollController
  jsr ModifyController
  jsr UpdateScreen
  rts

UpdateDone:
  ldx graphicsPointer
  lda #$00
  sta graphics, X
  inx
  lda #$FF
  sta graphics, X
  inx
  stx graphicsPointer
  rts

UpdateScreen:
  lda screen
  cmp #SCREEN_TITLE
  bne UpdateScreenNotTitle
    jsr UpdateTitleScreen
    rts
UpdateScreenNotTitle:
  cmp #SCREEN_OPTIONS
  bne UpdateScreenNotOptions
    jsr UpdateOptionsScreen
    rts
UpdateScreenNotOptions:
  cmp #SCREEN_BOARD
  bne UpdateScreenNotBoard
    jsr UpdateBoardScreen
    rts
UpdateScreenNotBoard:
  rts

UpdateTitleScreen:
  jsr MoveCursor
  jsr CursorTitleOption
  jsr ManageTitleOption
  jsr DrawTitleOptionCursor
  inc titleFrames
  jsr CheckControllerTitleScreen
  rts

UpdateOptionsScreen:
  jsr MoveCursor
  jsr CursorOptionPointer
  jsr ModifyOptionsPointer
  jsr DrawOptionsPointer
  jsr CheckControllerOptionsScreen
  rts

UpdateBoardScreen:
  jsr DrawBoardTopBar
  lda drawCrack
  beq UpdateBoardNotDrawCrack
    jsr DrawCrack
UpdateBoardNotDrawCrack:
  ;jsr IncTimer
  jsr DecTime
  jsr CheckTimer000
  lda end
  beq UpdateBoardNotEnd
    lda #$01
    sta updateDisabled
    jsr CheckBoardFinished
    jsr StartBoardScreen
    lda #$00
    sta updateDisabled
    rts
UpdateBoardNotEnd:
  lda timeFrame
  cmp #$02
  bcc UpdateBoardContinue
    ; TODO figure out what this part does
    lda #$01
    sta started
UpdateBoardContinue:
  jsr MoveCursor
  jsr DetermineCursorOverPosition
  lda animateKnight
  beq UpdateBoardNotAnimateKnight
    ; While the knight is animated
    jsr DisableDottedLines
    jsr AnimateKnightStep
    sta positionFrame
    jsr UpdatePositionCorners
    jsr ManageInvisibleGuides
    rts
UpdateBoardNotAnimateKnight:
  ; While the knight was not animated
  lda redrawSprites
  beq UpdateBoardNotRedrawSprites
    jsr DrawKnight
    jsr DrawCorners
UpdateBoardNotRedrawSprites:
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  beq UpdateBoardSNESMouse
    lda position
    sta cursorPosition
UpdateBoardSNESMouse:
  lda #$00
  sta redrawSprites
  inc positionFrame
  jsr DrawDottedLines
  jsr UpdatePositionCorners
  jsr CheckController
UpdateBoardDone:
  jsr ManageInvisibleGuides
  rts
