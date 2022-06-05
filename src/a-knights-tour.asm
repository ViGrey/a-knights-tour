; Copyright (C) 2020, Vi Grey
; All rights reserved.

  .db "NES", $1A
  .db $02
  .db $01
  .db $00
  .db $00
  .db 0, 0, 0, 0, 0, 0, 0, 0

.include "ram.asm"
.include "defs.asm"

.base $8000

.include "prg.asm"

  .pad CALLBACK, #$FF
  .dw  NMI
  .dw  RESET
  .dw  0

.base $0000
  .incbin "graphics/tileset.chr"
