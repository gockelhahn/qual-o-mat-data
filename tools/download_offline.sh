#!/bin/bash
#
# download all offline versions of wahl-o-mat
#

WGET_OPTS="--no-verbose --no-clobber"

SCRIPT_DIR="$(cd "`dirname "$0"`" && pwd)"
[ -z "$SCRIPT_DIR" ] && echo "ERROR: Script directory could not be detected. Abort!" >&2 && exit 1

( ! which wget &>/dev/null) && echo "ERROR: Command \"wget\" not available. Abort!" >&2 && exit 1

# download
cd "$SCRIPT_DIR/offline"
wget $WGET_OPTS "https://www.wahl-o-mat.de/bw2006/wahlomat.zip" -O "WahlomatOfflineBadenWuerttemberg2006.zip"
wget $WGET_OPTS "https://www.bpb.de/system/files/datei/wahlomat-bw11.zip" -O "WahlomatOfflineBadenWuerttemberg2011.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/bayern2003/wahlomat.zip" -O "WahlomatOfflineBayern2003.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/bayern2013/wahlomat.zip" -O "WahlomatOfflineBayern2013.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/berlin2006/wahlomat.zip" -O "WahlomatOfflineBerlin2006.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/berlin2011/wahlomat.zip" -O "WahlomatOfflineBerlin2011.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/brandenburg2014/wahlomat.zip" -O "WahlomatOfflineBrandenburg2014.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/bremen2007/wahlomat.zip" -O "WahlomatOfflineBremen2007.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/bremen2011/wahlomat.zip" -O "WahlomatOfflineBremen2011.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/bundestagswahl2005/wahlomat.zip" -O "WahlomatOfflineBundestagswahl2005.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/bundestagswahl2009/wahlomat.zip" -O "WahlomatOfflineBundestagswahl2009.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/bundestagswahl2013/wahlomat.zip" -O "WahlomatOfflineBundestagswahl2013.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/europa2004/wahlomat.zip" -O "WahlomatOfflineEuropawahl2004.zip"
wget $WGET_OPTS "https://www.bpb.de/system/files/datei/wahlomat-eu2009.zip" -O "WahlomatOfflineEuropawahl2009.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/europawahl2014/wahlomat.zip" -O "WahlomatOfflineEuropawahl2014.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/hamburg2008/wahlomat.zip" -O "WahlomatOfflineHamburg2008.zip"
wget $WGET_OPTS "https://www.bpb.de/system/files/datei/wahlomat_0.zip" -O "WahlomatOfflineHamburg2011.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/hamburg2015/wahlomat.zip" -O "WahlomatOfflineHamburg2015.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/niedersachsen2008/wahlomat.zip" -O "WahlomatOfflineNiedersachsen2008.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/niedersachsen2013/wahlomat.zip" -O "WahlomatOfflineNiedersachsen2013.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/nrw2005/wahlomat.zip" -O "WahlomatOfflineNordrheinWestfalen2005.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/nrw2010/wahlomat.zip" -O "WahlomatOfflineNordrheinWestfalen2010.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/nrw2012/wahlomat.zip" -O "WahlomatOfflineNordrheinWestfalen2012.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/rlp2006/wahlomat.zip" -O "WahlomatOfflineRheinlandPfalz2006.zip"
wget $WGET_OPTS "https://www.bpb.de/system/files/datei/wahlomat-rlp11.zip" -O "WahlomatOfflineRheinlandPfalz2011.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/saarland2004/wahlomat.zip" -O "WahlomatOfflineSaarland2004.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/saarland2012/wahlomat.zip" -O "WahlomatOfflineSaarland2012.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/sachsen2004/wahlomat.zip" -O "WahlomatOfflineSachsen2004.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/sachsen2014/wahlomat.zip" -O "WahlomatOfflineSachsen2014.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/sachsenanhalt2006/wahlomat.zip" -O "WahlomatOfflineSachsenAnhalt2006.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/schleswigholstein2005/wahlomat.zip" -O "WahlomatOfflineSchleswigHolstein2005.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/schleswigholstein2012/wahlomat.zip" -O "WahlomatOfflineSchleswigHolstein2012.zip"
wget $WGET_OPTS "https://www.wahl-o-mat.de/thueringen2014/wahlomat.zip" -O "WahlomatOfflineThueringen2014.zip"

# check if downloaded files have correct hash (have not been changed)
sha256sum --quiet --strict --check offline.sha256sum
if [ "$?" -ne 0 ]
then
    echo "ERROR: Checksum failed. Something seems odd. Please check the above messages!" >&2
    exit 1
fi
