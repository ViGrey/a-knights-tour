; Copyright (C) 2020, Vi Grey
; All rights reserved.

IncTmpBytesByABigEndian:
  clc
  adc (tmp + 1)
  sta (tmp + 1)
  lda tmp
  adc #$00
  sta tmp
  rts

IncTmpBytesByALittleEndian:
  clc
  adc tmp
  sta tmp
  lda (tmp + 1)
  adc #$00
  sta (tmp + 1)
  rts
