package main

import (
	"bytes"
	//"fmt"
	"io/ioutil"
	"strconv"
	"time"
)

var (
	px0   = [8]uint8{14, 10, 10, 10, 14, 0, 0, 0}
	px1   = [8]uint8{4, 12, 4, 4, 14, 0, 0, 0}
	px2   = [8]uint8{14, 2, 14, 8, 14, 0, 0, 0}
	px3   = [8]uint8{14, 2, 14, 2, 14, 0, 0, 0}
	px4   = [8]uint8{10, 10, 14, 2, 2, 0, 0, 0}
	px5   = [8]uint8{14, 8, 14, 2, 14, 0, 0, 0}
	px6   = [8]uint8{14, 8, 14, 10, 14, 0, 0, 0}
	px7   = [8]uint8{14, 2, 2, 2, 2, 0, 0, 0}
	px8   = [8]uint8{14, 10, 14, 10, 14, 0, 0, 0}
	px9   = [8]uint8{14, 10, 14, 2, 2, 0, 0, 0}
	pxu   = [8]uint8{0, 0, 0, 0, 14, 0, 0, 0}
	pxMap = map[byte][8]uint8{'0': px0, '1': px1, '2': px2,
		'3': px3, '4': px4, '5': px5, '6': px6, '7': px7,
		'8': px8, '9': px9, '_': pxu}

	versionData    string
	lastDateString string
	curDateString  string
	protoValue     string
	chrValues      []byte
)

func openCurrentTxt() {
	versionDataBytes, _ := ioutil.ReadFile("current.txt")
	versionDataBytes = bytes.Replace(versionDataBytes, []byte("\r\n"), []byte{}, -1)
	versionDataBytes = bytes.Replace(versionDataBytes, []byte("\n"), []byte{}, -1)
	if len(versionDataBytes) > 9 {
		lastDateString = string(versionDataBytes[:8])
		versionData = string(versionDataBytes[9:])
	} else {
		lastDateString = "00000000"
		versionData = "0"
	}
}

func getCurDateString() {
	curTime := time.Now().UTC()
	curDateString = curTime.Format("20060102")
}

func compareLastCurDate() {
	if lastDateString == curDateString {
		versionDataInt, err := strconv.Atoi(versionData)
		if err != nil {
			versionData = "0"
		} else {
			versionData = strconv.Itoa(versionDataInt + 1)
		}
	} else {
		versionData = "0"
	}
	protoValue = curDateString + "_" + versionData
}

func writeToCurrentTxt() {
	ioutil.WriteFile("current.txt", []byte(protoValue+"\n"), 0644)
}

func makePixelArray() {
	bytesVals := [][]uint8{}
	tileVals := []uint8{0, 0, 0, 0, 0, 0, 0, 0}
	for x, y := range []byte(protoValue) {
		if x%2 == 0 {
			for i := 0; i < 8; i++ {
				tileVals[i] += pxMap[y][i] << 4
			}
			if x == len([]byte(protoValue))-1 {
				bytesVals = append(bytesVals, tileVals)
				tileVals = []uint8{0, 0, 0, 0, 0, 0, 0, 0}
			}
		} else {
			for i := 0; i < 8; i++ {
				tileVals[i] += pxMap[y][i]
			}
			bytesVals = append(bytesVals, tileVals)
			tileVals = []uint8{0, 0, 0, 0, 0, 0, 0, 0}
		}
	}
	for _, m := range bytesVals {
		chrValues = append(chrValues, append(m, m...)...)
	}
}

func rewriteTilesetCHR() {
	tilesetData, _ := ioutil.ReadFile("src/graphics/tileset.chr")
	if len(tilesetData) == 8192 && 0x1f60+len(chrValues) < 8192-6 {
		tilesetDataTmp := append(tilesetData[:0x1f60], chrValues...)
		tilesetDataTmp = append(tilesetDataTmp, tilesetData[0x1f60+len(chrValues):]...)
		ioutil.WriteFile("src/graphics/tileset.chr", tilesetDataTmp, 0644)
	}
}

func main() {
	openCurrentTxt()
	getCurDateString()
	compareLastCurDate()
	writeToCurrentTxt()
	makePixelArray()
	rewriteTilesetCHR()
}
