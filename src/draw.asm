; Copyright (C) 2020, Vi Grey
; All rights reserved.

ResetScroll:
  lda #$00
  sta PPU_SCROLL
  sta PPU_SCROLL
  jsr EnableNMI
  rts

Draw:
  lda #%00011110
  sta PPU_MASK
  rts

DisableNMI:
  lda spriteTable
  ror
  ror tmp
  lda backgroundTable
  lsr
  lda tmp
  ror
  ror
  ror
  ror
  and #%00011000
  sta PPU_CTRL
  rts

EnableNMI:
  lda spriteTable
  lsr
  ror tmp
  lda backgroundTable
  lsr
  lda tmp
  ror
  ror
  ror
  ror
  ora #%10000000
  and #%10011000
  sta PPU_CTRL
  rts

Blank:
  lda #%00000110
  sta PPU_MASK
  jsr DisableNMI
  rts


ResetPPURAM:
  lda #$20
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
  ldy #$10
  ldx #$00
  txa
ResetPPURAMLoop:
  sta PPU_DATA
  dex
  bne ResetPPURAMLoop
    ldx #$00
    dey
    bne ResetPPURAMLoop
      rts

DisableSprites:
  ldx #$00
  lda #$FE
DisableSpritesLoop:
  sta $200, X
  inx
  bne DisableSpritesLoop
    rts

BlankPalettes:
  lda PPU_STATUS
  lda #$3F
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
  ldx #$20
  lda #$0F
BlankPalettesLoop:
  sta PPU_DATA
  dex
  bne BlankPalettesLoop
    rts

ErasePointer:
  lda #$FE
  sta #$2FC
  rts
