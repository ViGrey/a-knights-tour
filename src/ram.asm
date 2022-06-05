; Copyright (C) 2020, Vi Grey
; All rights reserved.

.enum $0000
Variables:
  pointer               dsb 1

  needDraw              dsb 1
  regionCheck           dsb 1
  updateDisabled        dsb 1

  frames                dsb 1
  timer                 dsb 1

; Options (MUST BE IN ORDER)
OptionsVariables:
  leftHanded            dsb 1
  canFall               dsb 1
  invisibleCracks       dsb 1
  invisibleGuides       dsb 1
  endPositionOption     dsb 1

  addr                  dsb 2
  spriteTable           dsb 1
  backgroundTable       dsb 1

  screen                dsb 1
  drawNewScreen         dsb 1

  titleOption           dsb 1
  titleFrames           dsb 1
  titleOptionHover      dsb 1

  lfsr                  dsb 3
  broken                dsb 8

  wasReset              dsb 1

  fps                   dsb 1
  region                dsb 1
  regionTmp             dsb 1

  closestPositionLeft   dsb 1
  closestPositionRight  dsb 1
  newPositionLeft       dsb 1
  newPositionRight      dsb 1
  tmp                   dsb 2
  endPosition           dsb 1
  knightPosition        dsb 1
  knightPositionNew     dsb 1
  knightFrame           dsb 1
  positionFrame         dsb 1
  position              dsb 1

  redrawSprites         dsb 1
  animateKnight         dsb 1
  availablePositions    dsb 1

  availablePositionsTmp dsb 1

  positionRealTmp       dsb 1
  positionTmp           dsb 1
  positionMoveOffset    dsb 1

  crackPosition         dsb 1
  crackAddr             dsb 2
  crackAddrTmp          dsb 2
  crackColor            dsb 1
  drawCrack             dsb 1

  time                  dsb 3
  timeInc               dsb 3
  timeFrame             dsb 1
  currentBoardScore     dsb 2
  score                 dsb 4
  topscore              dsb 4
  topscoreTmp           dsb 4
  end                   dsb 1

  started               dsb 1
  pointerFrames         dsb 1

.ende

.enum $00FA
  resetCheck0           dsb 6
.ende

.enum $03FA
  resetCheck3           dsb 6
.ende

.enum $04FA
  resetCheck4           dsb 6
.ende

.enum $0500
  cursorPosition          dsb 1
  controller1D0           dsb 4
  controller1D0LastFrame  dsb 4
  controller1D0Final      dsb 2
  controller1D3           dsb 1
  controller1D4           dsb 1
  controllerType          dsb 1
  controllerTypeLastFrame dsb 1
  snesMouseReady          dsb 1
.ende
.enum $05FA
  resetCheck5           dsb 6
.ende

.enum $06FA
  resetCheck6           dsb 6
.ende

.enum $0700
  scoreCodeLFSR         dsb 3
  knightPositionLFSR    dsb 3
  endPositionTrue       dsb 1
  runScore              dsb 1
  runTime               dsb 3
.ende

.enum $07FA
  resetCheck7           dsb 6
.ende
