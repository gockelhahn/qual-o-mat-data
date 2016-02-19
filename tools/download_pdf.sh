#!/bin/bash
#
# download all pdf files from wahl-o-mat
#

SCRIPT_DIR="$(cd "`dirname "$0"`" && pwd)"
[ -z "$SCRIPT_DIR" ] && echo "Script directory could not be detected!" >&2 && exit 1

# create pdf folder
mkdir -p "$SCRIPT_DIR/pdf"

# download
cd "$SCRIPT_DIR/pdf"
wget -nv "https://www.wahl-o-mat.de/bayern2013/PositionsvergleichBayern2013.pdf"
wget -nv "https://www.wahl-o-mat.de/berlin2011/PositionsvergleichBerlin2011.pdf"
wget -nv "https://www.wahl-o-mat.de/brandenburg2014/PositionsvergleichBrandenburg2014.pdf"
wget -nv "https://www.wahl-o-mat.de/bremen2011/PositionsvergleichBremen2011.pdf"
wget -nv "https://www.wahl-o-mat.de/bremen2015/PositionsvergleichBremen2015.pdf"
wget -nv "https://www.wahl-o-mat.de/bundestagswahl2013/PositionsvergleichBundestagswahl2013.pdf"
wget -nv "https://www.wahl-o-mat.de/bw2011/PositionsvergleichBadenWuerttemberg2011.pdf"
wget -nv "https://www.wahl-o-mat.de/bw2016/PositionsvergleichBadenWuerttemberg2016.pdf"
wget -nv "https://www.wahl-o-mat.de/europawahl2014/PositionsvergleichEuropawahl2014.pdf"
wget -nv "https://www.wahl-o-mat.de/hamburg2011/PositionsvergleichHamburg2011.pdf"
wget -nv "https://www.wahl-o-mat.de/hamburg2015/PositionsvergleichHamburg2015.pdf"
wget -nv "https://www.wahl-o-mat.de/niedersachsen2013/PositionsvergleichNiedersachsen2013.pdf"
wget -nv "https://www.wahl-o-mat.de/nrw2012/PositionsvergleichNordrheinWestfalen2012.pdf"
wget -nv "https://www.wahl-o-mat.de/rlp2011/PositionsvergleichRheinlandPfalz2011.pdf"
wget -nv "https://www.wahl-o-mat.de/rlp2016/PositionsvergleichRheinlandPfalz2016.pdf"
wget -nv "https://www.wahl-o-mat.de/saarland2012/PositionsvergleichSaarland2012.pdf"
wget -nv "https://www.wahl-o-mat.de/sachsen2014/PositionsvergleichSachsen2014.pdf"
wget -nv "https://www.wahl-o-mat.de/sachsenanhalt2016/PositionsvergleichSachsenAnhalt2016.pdf"
wget -nv "https://www.wahl-o-mat.de/schleswigholstein2012/PositionsvergleichSchleswigHolstein2012.pdf"
wget -nv "https://www.wahl-o-mat.de/thueringen2014/PositionsvergleichThueringen2014.pdf"
