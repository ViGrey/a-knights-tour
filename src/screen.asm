NMISplit:
  jmp NMIDone

  ; Draw Previous Frame Code Here
  lda drawNewScreen
  beq NMINotNewScreenDraw
    ;;;;; New screen is ready to be drawn
    jsr NMIDrawNewScreen
    lda #$00
    sta drawNewScreen
    jmp NMIDone
    ; rti
    ; End NMI (subroutine)

NMINotNewScreenDraw:
  lda screen
  cmp #SCREEN_BOARD
  bne NMINotScreenBoard
    ; Do every frame Board screen
NMINotScreenBoard:
  lda screen
  cmp #SCREEN_OPTIONS
  bne NMINotScreenOptions
    ; Do every frame Options screen
    jsr DrawOptionsValues
NMINotScreenOptions:
  ; Draw Previous Frame Code Here
  jmp NMIContinue
  ;rts



NMIDrawNewScreen:
  jsr BlankPalettes
  lda screen
  cmp #SCREEN_TITLE
  bne NMIDrawNewScreenNotTitle
    jsr StartTitleScreen
    rts
NMIDrawNewScreenNotTitle:
  cmp #SCREEN_BOARD
  bne NMIDrawNewScreenNotBoard
    jsr StartBoardScreen
    rts
NMIDrawNewScreenNotBoard:
  cmp #SCREEN_OPTIONS
  bne NMIDrawNewScreenNotOptions
    jsr StartOptionsScreen
    rts
NMIDrawNewScreenNotOptions:
  rts
