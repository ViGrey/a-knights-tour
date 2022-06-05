; Copyright (C) 2020, Vi Grey
; All rights reserved.

CheckPowerPad:
  lda #$00
  sta tmp
  jsr PowerPadCheckA
  ora tmp
  sta tmp
  jsr PowerPadCheckB
  ora tmp
  sta tmp
  jsr PowerPadCheckUp
  ora tmp
  sta tmp
  jsr PowerPadCheckDown
  ora tmp
  sta tmp
  jsr PowerPadCheckLeft
  ora tmp
  sta tmp
  jsr PowerPadCheckRight
  ora tmp
  ora controller1D0
  sta controller1D0
  rts

PowerPadCheckA:
  ldx #$00
  lda controller1D4
  and #POWER_PAD_4
  beq PowerPadCheckADone
    ldx #%10000000
PowerPadCheckADone:
  txa
  rts

PowerPadCheckB:
  ldx #$00
  lda controller1D3
  and #POWER_PAD_1
  beq PowerPadCheckBDone
    ldx #%01000000
PowerPadCheckBDone:
  txa
  rts
  
PowerPadCheckUp:
  ldx #$00
  lda controller1D3
  and #POWER_PAD_2
  beq PowerPadCheckUpNot2
    ldx #%00001000
    txa
    rts
PowerPadCheckUpNot2:
  lda controller1D4
  and #POWER_PAD_3
  beq PowerPadCheckUpDone
    ldx #%00001000
PowerPadCheckUpDone:
  txa
  rts
  
PowerPadCheckDown:
  ldx #$00
  lda controller1D3
  and #POWER_PAD_10
  beq PowerPadCheckDownNot10
    ldx #%00000100
    txa
    rts
PowerPadCheckDownNot10:
  lda controller1D3
  and #POWER_PAD_11
  beq PowerPadCheckDownDone
    ldx #%00000100
PowerPadCheckDownDone:
  txa
  rts
  
PowerPadCheckLeft:
  ldx #$00
  lda controller1D3
  and #POWER_PAD_5
  beq PowerPadCheckLeftDone
    ldx #%00000010
PowerPadCheckLeftDone:
  txa
  rts
  
PowerPadCheckRight:
  ldx #$00
  lda controller1D4
  and #POWER_PAD_8
  beq PowerPadCheckRightDone
    ldx #%00000001
PowerPadCheckRightDone:
  txa
  rts
