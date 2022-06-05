; Copyright (C) 2020, Vi Grey
; All rights reserved.

CONTROL_MODE_FLAG = 1 << 7

; graphicsControlFlags
; 7  bit  0
; ---- ----
; |
; +--------- Control Mode (0: on, 1: off)

.enum $300
  graphicsControlFlags  dsb 1
  graphicsPointer       dsb 1
  ppuAddr               dsb 2 
  ppuAddrLast           dsb 2 

  graphics              dsb 244
.ende


; $00 = Control
; |
; +--$00 = New PPU Line
; |
; +--$01 = Repeat Start
; |  |
; |  +--$XX = Tag Byte
; |     |
; |     +--$LL = Repeat Length
; |
; +--$02 = Repeat End
; |  |
; |  +--$XX = Tag Byte
; |
; +--$80 = Literal Byte Next
; |  |
; |  +--$XX = Literal Byte
; |
; +--$FE = PPU_ADDR Start
; |
; +--$FF = Total End
;
; $00, $FE, PPU_ADDR_HI, PPU_ADDR_LO, [Content...], $00, $FF
; $00, $FE, PPU_ADDR2_HI, PPU_ADDR2_LO, [Content2...], $00, $FF, $FF

ResetGraphics:
  ldx #$00
  stx graphics
  stx graphicsPointer
  stx graphicsControlFlags
  lda #$FF
  inx
  sta graphics, X
  inx
  sta graphics, X
  rts

PPUAddrIncLine:
  lda (ppuAddr + 1)
  clc
  adc #$20
  sta (ppuAddr + 1)
  lda ppuAddr
  adc #$00
  sta ppuAddr
  rts

ReadGraphics:
  lda PPU_STATUS
  lda #$20
  ldx #$00
  sta PPU_ADDR
  stx PPU_ADDR
ReadGraphicsLoop:
  lda graphics, X
  beq ReadGraphicsControlByte
    sta PPU_DATA
    inx
    stx graphicsPointer
    jmp ReadGraphicsLoop
ReadGraphicsControlByte:
  inx
  lda graphics, X
  bne ReadGraphicsControlByteNot00
    jsr ReadGraphicsControl00Handle
    jmp ReadGraphicsLoop
ReadGraphicsControlByteNot00:
  cmp #$80
  bne ReadGraphicsControlByteNot80
    jsr ReadGraphicsControl80Handle
    jmp ReadGraphicsLoop
ReadGraphicsControlByteNot80:
  cmp #$FE
  bne ReadGraphicsControlByteNotFE
    jsr ReadGraphicsControlFEHandle
    jmp ReadGraphicsLoop
ReadGraphicsControlByteNotFE:
  cmp #$FF
  bne ReadGraphicsControlByteNotFF
    lda ppuAddr
    sta ppuAddrLast
    lda (ppuAddr + 1)
    sta (ppuAddrLast + 1)
    rts
ReadGraphicsControlByteNotFF:
ReadGraphicsControlByteInvalid:
  jmp ReadGraphicsLoop


; New Line Handle
ReadGraphicsControl00Handle:
  jsr PPUAddrIncLine
  lda PPU_STATUS
  lda ppuAddr
  sta PPU_ADDR
  lda (ppuAddr + 1)
  sta PPU_ADDR
  inx
  stx graphicsPointer
  rts

; Literal Byte Handle
ReadGraphicsControl80Handle:
  inx
  lda graphics, X
  sta PPU_DATA
  inx
  stx graphicsPointer
  rts

; End GraphicsSectionHandle
ReadGraphicsControlFEHandle:
  lda PPU_STATUS
  inx
  lda graphics, X
  sta ppuAddr
  sta PPU_ADDR
  inx
  lda graphics, X
  sta ppuAddr + 1
  sta PPU_ADDR
  inx
  stx graphicsPointer
  rts
  




ReadGraphicsControl01Handle:
  rts
ReadGraphicsControl02Handle:
  rts

SetPPUAddrInGraphicsBuffer:
  ldx graphicsPointer
  lda #$00
  sta graphics, X
  inx
  lda #$FE
  sta graphics, X
  inx
  lda ppuAddrLast
  sta graphics, X
  inx
  lda (ppuAddrLast + 1)
  sta graphics, X
  inx
  stx graphicsPointer
  rts

DecPPUAddr1Line:
  lda (ppuAddr + 1)
  sec
  sbc #$20
  sta (ppuAddr + 1)
  lda ppuAddr
  sbc #$00
  sta ppuAddr
  rts

ReadThenResetGraphics:
  jsr ReadGraphics
  jsr ResetGraphics
  rts

BlankScreen:
  jsr WaitForNewFrame
  jsr BlankPalette
  lda #$01
  sta needDraw
  jsr WaitForNewFrameDisableDraw
  jsr DisableSprites
  rts

BlankPalette:
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
  ldy #$20
  lda #$0F
BlankPaletteLoop:
  sta graphics, X
  inx
  dey
  bne BlankPaletteLoop
    stx graphicsPointer
    rts
