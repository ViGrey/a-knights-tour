; Copyright (C) 2020, Vi Grey
; All rights reserved.

CONTROLLER1             = $4016
CONTROLLER2             = $4017

BUTTON_A                = 1 << 7
BUTTON_B                = 1 << 6
BUTTON_SELECT           = 1 << 5
BUTTON_START            = 1 << 4
BUTTON_UP               = 1 << 3
BUTTON_DOWN             = 1 << 2
BUTTON_LEFT             = 1 << 1
BUTTON_RIGHT            = 1 << 0

RIGHT_CLICK             = 1 << 7
LEFT_CLICK              = 1 << 6

POWER_PAD_1             = 1 << 6
POWER_PAD_2             = 1 << 7
POWER_PAD_3             = 1 << 6
POWER_PAD_4             = 1 << 7
POWER_PAD_5             = 1 << 5
POWER_PAD_6             = 1 << 3
POWER_PAD_7             = 1 << 0
POWER_PAD_8             = 1 << 4
POWER_PAD_9             = 1 << 4
POWER_PAD_10            = 1 << 2
POWER_PAD_11            = 1 << 1
POWER_PAD_12            = 1 << 5

PPU_CTRL                = $2000
PPU_MASK                = $2001
PPU_STATUS              = $2002
PPU_OAM_ADDR            = $2003
PPU_OAM_DATA            = $2004
PPU_SCROLL              = $2005
PPU_ADDR                = $2006
PPU_DATA                = $2007

OAM_DMA                 = $4014
APU_FRAME_COUNTER       = $4017

CALLBACK                = $FFFA

KNIGHT_TL               = $204
KNIGHT_TR               = $208
KNIGHT_BL               = $20C
KNIGHT_BR               = $210

POSITION_0              = $214
POSITION_1              = $224
POSITION_2              = $234
POSITION_3              = $244
POSITION_4              = $254
POSITION_5              = $264
POSITION_6              = $274
POSITION_7              = $284

L_3                     = $294
L_1                     = $298
L_2                     = $29C
L_0                     = $2A0
L_4                     = $2A4

CURSOR                  = $200

CONTROLLER_STANDARD     = 0
CONTROLLER_SNES_MOUSE   = 1
CONTROLLER_POWER_PAD    = 2

SCREEN_TITLE            = 0
SCREEN_BOARD            = 1
SCREEN_OPTIONS          = 2

TITLE_OPTION_LEVEL_MODE = 0
TITLE_OPTION_SCORE_MODE = 1
TITLE_OPTION_OPTIONS    = 2

OPTIONS_LEFT_HANDED      = 0
OPTIONS_CAN_FALL         = 1
OPTIONS_INVISIBLE_CRACKS = 2
OPTIONS_INVISIBLE_GUIDES = 3
OPTIONS_END_POSITION     = 4
;; SET OPTIONS_LAST TO LAST OPTION VALUE BEFORE DEFAULT
OPTIONS_LAST = OPTIONS_END_POSITION
;;
OPTIONS_DEFAULT          = OPTIONS_LAST + 1
OPTIONS_TITLE_SCREEN     = OPTIONS_DEFAULT + 1

