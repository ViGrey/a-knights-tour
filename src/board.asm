; Copyright (C) 2020, Vi Grey
; All rights reserved.

ResetTimeScore:
  ; Set score to 0
  lda #$00
  sta score
  sta (score + 1)
  sta (score + 2)
  sta (score + 3)
  ; Set time to 0
  lda #$01
  sta time
  lda #$02
  sta (time + 1)
  lda #$00
  sta (time + 2)
  sta timeFrame
  rts

StartBoardScreen:
  ; Turn screen completely black for 1 frame to avoid flicker/tear
  jsr BlankScreen
  ; Turn screen and NMI off
  jsr Blank
  ; Set screen to SCREEN_BOARD
  lda #SCREEN_BOARD
  sta screen
  ; Set sprite table to pattern table 01
  lda #$01
  sta spriteTable
  ; Set background table to pattern table 00
  lda #$00
  sta backgroundTable
  ; reset Current Board Score
  sta currentBoardScore
  sta (currentBoardScore + 1)
  ; TODO - Consider a situation where started is not needed
  sta started
  ; Clear broken 64 bit flags
  sta broken
  sta (broken + 1)
  sta (broken + 2)
  sta (broken + 3)
  sta (broken + 4)
  sta (broken + 5)
  sta (broken + 6)
  sta (broken + 7)
  ; Clear end variable, as is not end
  sta end
  ; Reset positionFrame to zero for animation
  sta positionFrame
  ; Set all 64 positions on chess board to 1 for availablility
  lda #$FF
  sta availablePositions
  ; Initialize controller1 last frame to say all buttons pressed
  sta controller1D0LastFrame
  sta (controller1D0LastFrame + 1)
  ; Run LFSR to get new random number
  jsr LFSR
  ; Set knight position based on random number MOD 64
  lda lfsr
  and #%00111111
  sta knightPosition
  sta knightPositionNew
  ; Run LFSR to get new random number
  jsr LFSR
  ; Set end position based on random number MOD 64
  lda lfsr

  and #%00111110
  sta endPosition
  ; Get knightPosition last bit to make sure endPosition is opposite color
  eor knightPosition
  and #%00001000
  eor #%00001000
  lsr
  lsr
  lsr
  eor knightPosition
  and #%00000001
  ora endPosition
  sta endPosition
  ; Run LFSR to get new random number
  jsr LFSR
  ; Set selector init position based on random number MOD 8
  lda lfsr
  and #%00000111
  sta position
  ; Check if controller is a SNES mouse
  lda controllerType
  cmp #CONTROLLER_SNES_MOUSE
  bne StartBoardScreenNotSNESMouse
    ; Check if controller is a SNES mouse
    lda snesMouseReady
    beq StartBoardScreenNotSNESMouse
      ; Draw cursor if SNES mouse is ready
      jsr DrawCursor
StartBoardScreenNotSNESMouse:
  jsr GetAvailablePositions
  jsr CheckDisallowedPositions
  ; 
  jsr ResetPPURAM
  jsr SetBoardPalette
  jsr DrawChessBoard
  jsr DrawKnight
  jsr DrawEndPosition
  jsr AdjustPosition
  jsr DrawCorners
  jsr DisableDottedLines
  jsr ManageInvisibleGuides

  jsr DrawBoardTopBar
  ;jsr UpdateDone
  lda #$01
  sta needDraw
  ; Re-enable NMI
  jsr ResetScroll
  rts



DrawBoardTopBar:
  jsr DrawScore
  jsr DrawTopScore
  jsr DrawTimer
  rts

BoardEveryFrame:
  jsr DrawScore
  jsr DrawTopScore
  jsr DrawTimer
  lda drawCrack
  beq BoardEveryFrameNotDrawCrack
    ; Draw crack if drawCrack flag is set to 1
    jsr DrawCrack
BoardEveryFrameNotDrawCrack:
  ; End of Board screen code
  rts

SetBoardPalette:
  lda PPU_STATUS
  lda #$3F
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
  ldx #$04
SetBoardPaletteBackgroundLoop:
  lda #$0F
  sta PPU_DATA 
  sta PPU_DATA 
  sta PPU_DATA 
  lda #$30
  sta PPU_DATA
  dex
  bne SetBoardPaletteBackgroundLoop
    lda #$0F
    sta PPU_DATA
    sta PPU_DATA
    sta PPU_DATA
    lda #$30
    sta PPU_DATA
    ldx #$03
SetBoardPaletteSpriteLoop:
  lda #$0F
  sta PPU_DATA
  lda #$11
  sta PPU_DATA
  lda #$21
  sta PPU_DATA
  lda #$30
  sta PPU_DATA
  dex
  bne SetBoardPaletteSpriteLoop
    rts

DrawChessBoard:
  lda PPU_STATUS
  lda #$20 
  sta PPU_ADDR
  lda #$E7
  sta PPU_ADDR
  ldx #$80
  stx PPU_DATA
  ldy #$10
  inx
DrawChessBoardTopEdge:
  stx PPU_DATA
  dey
  bne DrawChessBoardTopEdge
    inx
    stx PPU_DATA
    ldy #"8"
;ROW 1a
  lda PPU_STATUS
  lda #$21
  sta PPU_ADDR
  lda #$07
  sta PPU_ADDR
  lda #$90
  sta PPU_DATA
  ldx #$01
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 1b
  lda PPU_STATUS
  lda #$21
  sta PPU_ADDR
  lda #$26
  sta PPU_ADDR
  sty PPU_DATA
  dey
  lda #$90
  sta PPU_DATA
  ldx #$01
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 2a
  lda PPU_STATUS
  lda #$21
  sta PPU_ADDR
  lda #$47
  sta PPU_ADDR
  lda #$90
  sta PPU_DATA
  ldx #$00
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 2b
  lda PPU_STATUS
  lda #$21
  sta PPU_ADDR
  lda #$66
  sta PPU_ADDR
  sty PPU_DATA
  dey
  lda #$90
  sta PPU_DATA
  ldx #$00
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 3a
  lda PPU_STATUS
  lda #$21
  sta PPU_ADDR
  lda #$87
  sta PPU_ADDR
  lda #$90
  sta PPU_DATA
  ldx #$01
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 3b
  lda PPU_STATUS
  lda #$21
  sta PPU_ADDR
  lda #$A6
  sta PPU_ADDR
  sty PPU_DATA
  dey
  lda #$90
  sta PPU_DATA
  ldx #$01
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 4a
  lda PPU_STATUS
  lda #$21
  sta PPU_ADDR
  lda #$C7
  sta PPU_ADDR
  lda #$90
  sta PPU_DATA
  ldx #$00
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 4b
  lda PPU_STATUS
  lda #$21
  sta PPU_ADDR
  lda #$E6
  sta PPU_ADDR
  sty PPU_DATA
  dey
  lda #$90
  sta PPU_DATA
  ldx #$00
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 5a
  lda PPU_STATUS
  lda #$22
  sta PPU_ADDR
  lda #$07
  sta PPU_ADDR
  lda #$90
  sta PPU_DATA
  ldx #$01
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 5b
  lda PPU_STATUS
  lda #$22
  sta PPU_ADDR
  lda #$26
  sta PPU_ADDR
  sty PPU_DATA
  dey
  lda #$90
  sta PPU_DATA
  ldx #$01
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 6a
  lda PPU_STATUS
  lda #$22
  sta PPU_ADDR
  lda #$47
  sta PPU_ADDR
  lda #$90
  sta PPU_DATA
  ldx #$00
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 6b
  lda PPU_STATUS
  lda #$22
  sta PPU_ADDR
  lda #$66
  sta PPU_ADDR
  sty PPU_DATA
  dey
  lda #$90
  sta PPU_DATA
  ldx #$00
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 7a
  lda PPU_STATUS
  lda #$22
  sta PPU_ADDR
  lda #$87
  sta PPU_ADDR
  lda #$90
  sta PPU_DATA
  ldx #$01
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 7b
  lda PPU_STATUS
  lda #$22
  sta PPU_ADDR
  lda #$A6
  sta PPU_ADDR
  sty PPU_DATA
  dey
  lda #$90
  sta PPU_DATA
  ldx #$01
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 8a
  lda PPU_STATUS
  lda #$22
  sta PPU_ADDR
  lda #$C7
  sta PPU_ADDR
  lda #$90
  sta PPU_DATA
  ldx #$00
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;ROW 8b
  lda PPU_STATUS
  lda #$22
  sta PPU_ADDR
  lda #$E6
  sta PPU_ADDR
  sty PPU_DATA
  dey
  lda #$90
  sta PPU_DATA
  ldx #$00
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  dex
  stx PPU_DATA
  stx PPU_DATA
  inx
  stx PPU_DATA
  stx PPU_DATA
  lda #$92
  sta PPU_DATA
;Bottom Row
  lda PPU_STATUS
  lda #$23
  sta PPU_ADDR
  lda #$07
  sta PPU_ADDR
  ldx #$A0
  stx PPU_DATA
  ldy #$10
  inx
DrawChessBoardBottomEdge:
  stx PPU_DATA
  dey
  bne DrawChessBoardBottomEdge
    inx
    stx PPU_DATA
    lda PPU_STATUS
    lda #$23
    sta PPU_ADDR
    lda #$28
    sta PPU_ADDR
    lda #$00
    ldx #"A"
    stx PPU_DATA
    sta PPU_DATA
    inx
    stx PPU_DATA
    sta PPU_DATA
    inx
    stx PPU_DATA
    sta PPU_DATA
    inx
    stx PPU_DATA
    sta PPU_DATA
    inx
    stx PPU_DATA
    sta PPU_DATA
    inx
    stx PPU_DATA
    sta PPU_DATA
    inx
    stx PPU_DATA
    sta PPU_DATA
    inx
    stx PPU_DATA
    sta PPU_DATA
    rts

DrawKnight:
  lda knightPosition
  and #%00111000
  asl
  clc
  adc #$3F
  sta KNIGHT_TL
  lda #$01
  sta (KNIGHT_TL + 1)
  lda #$00
  sta (KNIGHT_TL + 2)
  lda knightPosition
  and #%00000111
  asl
  asl
  asl
  asl
  clc
  adc #$40
  sta (KNIGHT_TL + 3)

  lda KNIGHT_TL
  sta KNIGHT_TR
  lda (KNIGHT_TL + 1)
  clc
  adc #$01
  sta (KNIGHT_TR + 1)
  lda (KNIGHT_TL + 2)
  sta (KNIGHT_TR + 2)
  lda (KNIGHT_TL + 3)
  clc
  adc #$08
  sta (KNIGHT_TR + 3)

  lda KNIGHT_TL
  clc
  adc #$08
  sta KNIGHT_BL
  lda (KNIGHT_TL + 1)
  clc
  adc #$10
  sta (KNIGHT_BL + 1)
  lda (KNIGHT_TL + 2)
  sta (KNIGHT_BL + 2)
  lda (KNIGHT_TL + 3)
  sta (KNIGHT_BL + 3)

  lda KNIGHT_TL
  clc
  adc #$08
  sta KNIGHT_BR
  lda (KNIGHT_TL + 1)
  clc
  adc #$11
  sta (KNIGHT_BR + 1)
  lda (KNIGHT_TL + 2)
  sta (KNIGHT_BR + 2)
  lda (KNIGHT_TL + 3)
  clc
  adc #$08
  sta (KNIGHT_BR + 3)

  rts


DrawCorners:
DrawCornersPosition0:
  lda #$00
  jsr CheckAPositionAvailable
  bne DrawCornersPosition0Continue
    lda #$FE
    sta (POSITION_0)
    sta (POSITION_0 + 4)
    sta (POSITION_0 + 8)
    sta (POSITION_0 + 12)
    jmp DrawCornersPosition1
DrawCornersPosition0Continue:
; Position 0
  lda KNIGHT_TL
  sec
  sbc #$20
  sta POSITION_0
  lda #$03
  sta (POSITION_0 + 1)
  lda #$00000001
  sta (POSITION_0 + 2)
  lda (KNIGHT_TL + 3)
  sec
  sbc #$10
  sta (POSITION_0 + 3)

  lda POSITION_0
  sta (POSITION_0 + 4)
  lda (POSITION_0 + 1)
  sta (POSITION_0 + 5)
  lda (POSITION_0 + 2)
  eor #%01000000
  sta (POSITION_0 + 6)
  lda (POSITION_0 + 3)
  clc
  adc #$08
  sta (POSITION_0 + 7)

  lda POSITION_0
  clc
  adc #$08
  sta (POSITION_0 + 8)
  lda (POSITION_0 + 1)
  sta (POSITION_0 + 9)
  lda (POSITION_0 + 2)
  eor #%10000000
  sta (POSITION_0 + 10)
  lda (POSITION_0 + 3)
  sta (POSITION_0 + 11)

  lda POSITION_0
  clc
  adc #$08
  sta (POSITION_0 + 12)
  lda (POSITION_0 + 1)
  sta (POSITION_0 + 13)
  lda (POSITION_0 + 2)
  eor #%11000000
  sta (POSITION_0 + 14)
  lda (POSITION_0 + 3)
  clc
  adc #$08
  sta (POSITION_0 + 15)

DrawCornersPosition1:
  lda #$01
  jsr CheckAPositionAvailable
  bne DrawCornersPosition1Continue
    lda #$FE
    sta (POSITION_1)
    sta (POSITION_1 + 4)
    sta (POSITION_1 + 8)
    sta (POSITION_1 + 12)
    jmp DrawCornersPosition2
DrawCornersPosition1Continue:
; Position 1
  lda KNIGHT_TL
  sec
  sbc #$20
  sta POSITION_1
  lda #$03
  sta (POSITION_1 + 1)
  lda #$00000001
  sta (POSITION_1 + 2)
  lda (KNIGHT_TL + 3)
  clc
  adc #$10
  sta (POSITION_1 + 3)

  lda POSITION_1
  sta (POSITION_1 + 4)
  lda (POSITION_1 + 1)
  sta (POSITION_1 + 5)
  lda (POSITION_1 + 2)
  eor #%01000000
  sta (POSITION_1 + 6)
  lda (POSITION_1 + 3)
  clc
  adc #$08
  sta (POSITION_1 + 7)

  lda POSITION_1
  clc
  adc #$08
  sta (POSITION_1 + 8)
  lda (POSITION_1 + 1)
  sta (POSITION_1 + 9)
  lda (POSITION_1 + 2)
  eor #%10000000
  sta (POSITION_1 + 10)
  lda (POSITION_1 + 3)
  sta (POSITION_1 + 11)

  lda POSITION_1
  clc
  adc #$08
  sta (POSITION_1 + 12)
  lda (POSITION_1 + 1)
  sta (POSITION_1 + 13)
  lda (POSITION_1 + 2)
  eor #%11000000
  sta (POSITION_1 + 14)
  lda (POSITION_1 + 3)
  clc
  adc #$08
  sta (POSITION_1 + 15)

DrawCornersPosition2:
  lda #$02
  jsr CheckAPositionAvailable
  bne DrawCornersPosition2Continue
    lda #$FE
    sta (POSITION_2)
    sta (POSITION_2 + 4)
    sta (POSITION_2 + 8)
    sta (POSITION_2 + 12)
    jmp DrawCornersPosition3
DrawCornersPosition2Continue:
; Position 2
  lda KNIGHT_TL
  sec
  sbc #$10
  sta POSITION_2
  lda #$03
  sta (POSITION_2 + 1)
  lda #$00000001
  sta (POSITION_2 + 2)
  lda (KNIGHT_TL + 3)
  clc
  adc #$20
  sta (POSITION_2 + 3)

  lda POSITION_2
  sta (POSITION_2 + 4)
  lda (POSITION_2 + 1)
  sta (POSITION_2 + 5)
  lda (POSITION_2 + 2)
  eor #%01000000
  sta (POSITION_2 + 6)
  lda (POSITION_2 + 3)
  clc
  adc #$08
  sta (POSITION_2 + 7)

  lda POSITION_2
  clc
  adc #$08
  sta (POSITION_2 + 8)
  lda (POSITION_2 + 1)
  sta (POSITION_2 + 9)
  lda (POSITION_2 + 2)
  eor #%10000000
  sta (POSITION_2 + 10)
  lda (POSITION_2 + 3)
  sta (POSITION_2 + 11)

  lda POSITION_2
  clc
  adc #$08
  sta (POSITION_2 + 12)
  lda (POSITION_2 + 1)
  sta (POSITION_2 + 13)
  lda (POSITION_2 + 2)
  eor #%11000000
  sta (POSITION_2 + 14)
  lda (POSITION_2 + 3)
  clc
  adc #$08
  sta (POSITION_2 + 15)

DrawCornersPosition3:
  lda #$03
  jsr CheckAPositionAvailable
  bne DrawCornersPosition3Continue
    lda #$FE
    sta (POSITION_3)
    sta (POSITION_3 + 4)
    sta (POSITION_3 + 8)
    sta (POSITION_3 + 12)
    jmp DrawCornersPosition4
DrawCornersPosition3Continue:
; Position 3
  lda KNIGHT_TL
  clc
  adc #$10
  sta POSITION_3
  lda #$03
  sta (POSITION_3 + 1)
  lda #$00000001
  sta (POSITION_3 + 2)
  lda (KNIGHT_TL + 3)
  clc
  adc #$20
  sta (POSITION_3 + 3)

  lda POSITION_3
  sta (POSITION_3 + 4)
  lda (POSITION_3 + 1)
  sta (POSITION_3 + 5)
  lda (POSITION_3 + 2)
  eor #%01000000
  sta (POSITION_3 + 6)
  lda (POSITION_3 + 3)
  clc
  adc #$08
  sta (POSITION_3 + 7)

  lda POSITION_3
  clc
  adc #$08
  sta (POSITION_3 + 8)
  lda (POSITION_3 + 1)
  sta (POSITION_3 + 9)
  lda (POSITION_3 + 2)
  eor #%10000000
  sta (POSITION_3 + 10)
  lda (POSITION_3 + 3)
  sta (POSITION_3 + 11)

  lda POSITION_3
  clc
  adc #$08
  sta (POSITION_3 + 12)
  lda (POSITION_3 + 1)
  sta (POSITION_3 + 13)
  lda (POSITION_3 + 2)
  eor #%11000000
  sta (POSITION_3 + 14)
  lda (POSITION_3 + 3)
  clc
  adc #$08
  sta (POSITION_3 + 15)

DrawCornersPosition4:
  lda #$04
  jsr CheckAPositionAvailable
  bne DrawCornersPosition4Continue
    lda #$FE
    sta (POSITION_4)
    sta (POSITION_4 + 4)
    sta (POSITION_4 + 8)
    sta (POSITION_4 + 12)
    jmp DrawCornersPosition5
DrawCornersPosition4Continue:
; Position 4
  lda KNIGHT_TL
  clc
  adc #$20
  sta POSITION_4
  lda #$03
  sta (POSITION_4 + 1)
  lda #$00000001
  sta (POSITION_4 + 2)
  lda (KNIGHT_TL + 3)
  clc
  adc #$10
  sta (POSITION_4 + 3)

  lda POSITION_4
  sta (POSITION_4 + 4)
  lda (POSITION_4 + 1)
  sta (POSITION_4 + 5)
  lda (POSITION_4 + 2)
  eor #%01000000
  sta (POSITION_4 + 6)
  lda (POSITION_4 + 3)
  clc
  adc #$08
  sta (POSITION_4 + 7)

  lda POSITION_4
  clc
  adc #$08
  sta (POSITION_4 + 8)
  lda (POSITION_4 + 1)
  sta (POSITION_4 + 9)
  lda (POSITION_4 + 2)
  eor #%10000000
  sta (POSITION_4 + 10)
  lda (POSITION_4 + 3)
  sta (POSITION_4 + 11)

  lda POSITION_4
  clc
  adc #$08
  sta (POSITION_4 + 12)
  lda (POSITION_4 + 1)
  sta (POSITION_4 + 13)
  lda (POSITION_4 + 2)
  eor #%11000000
  sta (POSITION_4 + 14)
  lda (POSITION_4 + 3)
  clc
  adc #$08
  sta (POSITION_4 + 15)

DrawCornersPosition5:
  lda #$05
  jsr CheckAPositionAvailable
  bne DrawCornersPosition5Continue
    lda #$FE
    sta (POSITION_5)
    sta (POSITION_5 + 4)
    sta (POSITION_5 + 8)
    sta (POSITION_5 + 12)
    jmp DrawCornersPosition6
DrawCornersPosition5Continue:
; Position 5
  lda KNIGHT_TL
  clc
  adc #$20
  sta POSITION_5
  lda #$03
  sta (POSITION_5 + 1)
  lda #$00000001
  sta (POSITION_5 + 2)
  lda (KNIGHT_TL + 3)
  sec
  sbc #$10
  sta (POSITION_5 + 3)

  lda POSITION_5
  sta (POSITION_5 + 4)
  lda (POSITION_5 + 1)
  sta (POSITION_5 + 5)
  lda (POSITION_5 + 2)
  eor #%01000000
  sta (POSITION_5 + 6)
  lda (POSITION_5 + 3)
  clc
  adc #$08
  sta (POSITION_5 + 7)

  lda POSITION_5
  clc
  adc #$08
  sta (POSITION_5 + 8)
  lda (POSITION_5 + 1)
  sta (POSITION_5 + 9)
  lda (POSITION_5 + 2)
  eor #%10000000
  sta (POSITION_5 + 10)
  lda (POSITION_5 + 3)
  sta (POSITION_5 + 11)

  lda POSITION_5
  clc
  adc #$08
  sta (POSITION_5 + 12)
  lda (POSITION_5 + 1)
  sta (POSITION_5 + 13)
  lda (POSITION_5 + 2)
  eor #%11000000
  sta (POSITION_5 + 14)
  lda (POSITION_5 + 3)
  clc
  adc #$08
  sta (POSITION_5 + 15)

DrawCornersPosition6:
  lda #$06
  jsr CheckAPositionAvailable
  bne DrawCornersPosition6Continue
    lda #$FE
    sta (POSITION_6)
    sta (POSITION_6 + 4)
    sta (POSITION_6 + 8)
    sta (POSITION_6 + 12)
    jmp DrawCornersPosition7
DrawCornersPosition6Continue:
; Position 6
  lda KNIGHT_TL
  clc
  adc #$10
  sta POSITION_6
  lda #$03
  sta (POSITION_6 + 1)
  lda #$00000001
  sta (POSITION_6 + 2)
  lda (KNIGHT_TL + 3)
  sec
  sbc #$20
  sta (POSITION_6 + 3)

  lda POSITION_6
  sta (POSITION_6 + 4)
  lda (POSITION_6 + 1)
  sta (POSITION_6 + 5)
  lda (POSITION_6 + 2)
  eor #%01000000
  sta (POSITION_6 + 6)
  lda (POSITION_6 + 3)
  clc
  adc #$08
  sta (POSITION_6 + 7)

  lda POSITION_6
  clc
  adc #$08
  sta (POSITION_6 + 8)
  lda (POSITION_6 + 1)
  sta (POSITION_6 + 9)
  lda (POSITION_6 + 2)
  eor #%10000000
  sta (POSITION_6 + 10)
  lda (POSITION_6 + 3)
  sta (POSITION_6 + 11)

  lda POSITION_6
  clc
  adc #$08
  sta (POSITION_6 + 12)
  lda (POSITION_6 + 1)
  sta (POSITION_6 + 13)
  lda (POSITION_6 + 2)
  eor #%11000000
  sta (POSITION_6 + 14)
  lda (POSITION_6 + 3)
  clc
  adc #$08
  sta (POSITION_6 + 15)

DrawCornersPosition7:
  lda #$07
  jsr CheckAPositionAvailable
  bne DrawCornersPosition7Continue
    lda #$FE
    sta (POSITION_7)
    sta (POSITION_7 + 4)
    sta (POSITION_7 + 8)
    sta (POSITION_7 + 12)
    rts
DrawCornersPosition7Continue:
; Position 7
  lda KNIGHT_TL
  sec
  sbc #$10
  sta POSITION_7
  lda #$03
  sta (POSITION_7 + 1)
  lda #$00000001
  sta (POSITION_7 + 2)
  lda (KNIGHT_TL + 3)
  sec
  sbc #$20
  sta (POSITION_7 + 3)

  lda POSITION_7
  sta (POSITION_7 + 4)
  lda (POSITION_7 + 1)
  sta (POSITION_7 + 5)
  lda (POSITION_7 + 2)
  eor #%01000000
  sta (POSITION_7 + 6)
  lda (POSITION_7 + 3)
  clc
  adc #$08
  sta (POSITION_7 + 7)

  lda POSITION_7
  clc
  adc #$08
  sta (POSITION_7 + 8)
  lda (POSITION_7 + 1)
  sta (POSITION_7 + 9)
  lda (POSITION_7 + 2)
  eor #%10000000
  sta (POSITION_7 + 10)
  lda (POSITION_7 + 3)
  sta (POSITION_7 + 11)

  lda POSITION_7
  clc
  adc #$08
  sta (POSITION_7 + 12)
  lda (POSITION_7 + 1)
  sta (POSITION_7 + 13)
  lda (POSITION_7 + 2)
  eor #%11000000
  sta (POSITION_7 + 14)
  lda (POSITION_7 + 3)
  clc
  adc #$08
  sta (POSITION_7 + 15)
  rts

DrawCrack:
  ldx graphicsPointer
  lda #$00
  sta graphics, X
  inx
  lda #$FE
  sta graphics, X
  inx

  lda crackAddr
  sta graphics, X
  inx
  lda (crackAddr + 1)
  sta graphics, X
  inx

  ldy crackColor
  tya
  sta graphics, X
  inx
  iny
  tya
  sta graphics, X
  inx

  lda crackColor
  clc
  adc #$10
  sta crackColor

  lda #$00
  sta graphics, X
  inx
  lda #$00
  sta graphics, X
  inx

  ldy crackColor
  tya
  sta graphics, X
  inx
  iny
  tya
  sta graphics, X
  inx
  stx graphicsPointer
  lda #$00
  sta drawCrack
  rts

DrawEndPosition:
  lda endPositionOption
  bne DrawEndPositionContinue
    rts
DrawEndPositionContinue:
  ; tmp starts at 21 08
  ; #%00[111] - row (ppu row * 40) [111] - Position on row
  ;
  lda #$21
  sta tmp
  lda #$08
  sta (tmp + 1)
  lda endPosition
  and #%00111000
  lsr
  lsr
  lsr
  tay
DrawEndPositionIncTmpRowLoop:
  cpy #$00
  beq DrawEndPositionIncTmpRowLoopDone
    lda #$40
    jsr IncTmpBytesByABigEndian
    dey
    jmp DrawEndPositionIncTmpRowLoop
DrawEndPositionIncTmpRowLoopDone:
  lda endPosition
  and #%00000111
  asl
  clc
  adc (tmp + 1)
  sta (tmp + 1)
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

  ; endPosition & 00001000 = row
  ; endPosition & 00000001 = color offset row

  lda endPosition
  and #%00001000
  lsr
  lsr
  lsr
  eor endPosition
  and #%00000001
  eor #%00000001
  asl
  clc
  adc #$87
  tay
  sta graphics, X
  inx
  iny
  tya
  sta graphics, X
  inx
  clc
  adc #$0F
  tay
  lda #$00
  sta graphics, X
  inx
  sta graphics, X
  inx
  tya
  sta graphics, X
  inx
  iny
  tya
  sta graphics, X
  inx
  stx graphicsPointer
  rts

CheckBoardFinished:
  lda currentBoardScore
  cmp #$06
  bne CurrentBoardFinishedNotWin
    lda (currentBoardScore + 1)
    cmp #$03
    bne CurrentBoardFinishedNotWin
      lda #$00
      sta timeInc
      sta (timeInc + 2)
      lda #$03
      sta (timeInc + 1)
      jsr IncTimerByTimeInc
      rts
CurrentBoardFinishedNotWin:
  jsr SetTopScoreTmpToTopScore
  jsr ResetTimeScore
  rts
