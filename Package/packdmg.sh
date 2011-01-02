#!/bin/sh

rm -rf *.dmg
hdiutil create -srcfolder ./build/SPlayerX.pkg -volname 'SPlayerX' -fs HFS+ -fsargs '-c c=64,a=16,e=16' -format UDRW ./SPlayerX-tmp.dmg
hdiutil convert ./SPlayerX-tmp.dmg -format UDZO -imagekey zlib-level=9 -o ./SPlayerX.dmg
