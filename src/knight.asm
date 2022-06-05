; Copyright (C) 2020, Vi Grey
; All rights reserved.

AnimateKnightStep:
  inc knightFrame
  lda knightPositionNew
  and #%00000111
  sta tmp
  lda knightPosition
  and #%00000111
  cmp tmp
  bne AnimateKnightHorizontalContinue
    jmp AnimateKnightVerticalStart
AnimateKnightHorizontalContinue:
  bcs AnimateKnightHorizontalLeft
    ; knightPosition mod 8 is less than knightPositionNew mod 8
    jmp AnimateKnightHorizontalRight
AnimateKnightHorizontalLeft:
  ; knightPosition mod 8 is greater than knightPositionNew mod 8
  dec (KNIGHT_TL + 3)
  dec (KNIGHT_TL + 3)
  dec (KNIGHT_TL + 3)
  dec (KNIGHT_TL + 3)
  dec (KNIGHT_TR + 3)
  dec (KNIGHT_TR + 3)
  dec (KNIGHT_TR + 3)
  dec (KNIGHT_TR + 3)
  dec (KNIGHT_BL + 3)
  dec (KNIGHT_BL + 3)
  dec (KNIGHT_BL + 3)
  dec (KNIGHT_BL + 3)
  dec (KNIGHT_BR + 3)
  dec (KNIGHT_BR + 3)
  dec (KNIGHT_BR + 3)
  dec (KNIGHT_BR + 3)
  lda knightFrame
  and #%00000011
  bne AnimateKnightHorizontalLeftDone
    dec knightPosition
AnimateKnightHorizontalLeftDone:
  jmp AnimateKnightStepDone
AnimateKnightHorizontalRight:
  ; knightPosition mod 8 is less than knightPositionNew mod 8
  inc (KNIGHT_TL + 3)
  inc (KNIGHT_TL + 3)
  inc (KNIGHT_TL + 3)
  inc (KNIGHT_TL + 3)
  inc (KNIGHT_TR + 3)
  inc (KNIGHT_TR + 3)
  inc (KNIGHT_TR + 3)
  inc (KNIGHT_TR + 3)
  inc (KNIGHT_BL + 3)
  inc (KNIGHT_BL + 3)
  inc (KNIGHT_BL + 3)
  inc (KNIGHT_BL + 3)
  inc (KNIGHT_BR + 3)
  inc (KNIGHT_BR + 3)
  inc (KNIGHT_BR + 3)
  inc (KNIGHT_BR + 3)
  lda knightFrame
  and #%00000011
  bne AnimateKnightHorizontalRightDone
    inc knightPosition
AnimateKnightHorizontalRightDone:
  jmp AnimateKnightStepDone
AnimateKnightVerticalStart:
  lda knightPositionNew
  and #%00111000
  sta tmp
  lda knightPosition
  and #%00111000
  cmp tmp
  bne AnimateKnightVerticalContinue
    jmp AnimateKnightVerticalDone
AnimateKnightVerticalContinue:
  bcs AnimateKnightVerticalUp
    ; knightPosition div 8 is less than knightPositionNew div 8
    jmp AnimateKnightVerticalDown
AnimateKnightVerticalUp:
  ; knightPosition div 8 is greater than knightPositionNew div 8
  dec KNIGHT_TL
  dec KNIGHT_TL
  dec KNIGHT_TL
  dec KNIGHT_TL
  dec KNIGHT_TR
  dec KNIGHT_TR
  dec KNIGHT_TR
  dec KNIGHT_TR
  dec KNIGHT_BL
  dec KNIGHT_BL
  dec KNIGHT_BL
  dec KNIGHT_BL
  dec KNIGHT_BR
  dec KNIGHT_BR
  dec KNIGHT_BR
  dec KNIGHT_BR
  lda knightFrame
  and #%00000011
  bne AnimateKnightVerticalUpDone
    lda knightPosition
    sec
    sbc #$08
    sta knightPosition
AnimateKnightVerticalUpDone:
  jmp AnimateKnightStepDone
AnimateKnightVerticalDown:
  ; knightPosition div 8 is less than knightPositionNew div 8
  inc KNIGHT_TL
  inc KNIGHT_TL
  inc KNIGHT_TL
  inc KNIGHT_TL
  inc KNIGHT_TR
  inc KNIGHT_TR
  inc KNIGHT_TR
  inc KNIGHT_TR
  inc KNIGHT_BL
  inc KNIGHT_BL
  inc KNIGHT_BL
  inc KNIGHT_BL
  inc KNIGHT_BR
  inc KNIGHT_BR
  inc KNIGHT_BR
  inc KNIGHT_BR
  lda knightFrame
  and #%00000011
  bne AnimateKnightVerticalDownDone
    lda knightPosition
    clc
    adc #$08
    sta knightPosition
AnimateKnightVerticalDownDone:
  jmp AnimateKnightStepDone
AnimateKnightVerticalDone:
  lda #$00
  sta animateKnight

  jsr GetAvailablePositions
  jsr CheckEndPosition
  jsr CheckDisallowedPositions
  jsr AdjustPosition


  lda #$01
  sta redrawSprites
AnimateKnightStepDone:
  rts
