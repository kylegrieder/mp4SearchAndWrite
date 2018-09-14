#!/bin/bash

# // 1:filePath, 2:artworkPath, 3:title, 4:genre, 5:releaseDate, 6:longDesc, 7:storeDesc, 8:mpaaCert, 9:stik

/usr/local/bin/atomicparsley "${1}" -W --title "${3}" --artwork "${2}" --genre "${4}" --year "${5}" --longdesc "${6}" --storedesc "${7}" --description "${7}" --contentRating "${8}" --stik "${9}"
rm -rf "${2}"

