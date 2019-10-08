#!/usr/bin/env bash
change_endianness() {
    temp=""
    for str in ${1//-/ }; do
        part="$(echo $str|sed -e 'G;:1' -e 's/\(..\)\(.*\n\)/\2\1/;t1' -e 's/.//')"
        if [[ "$temp" == "" ]]; then
            temp="$part"
        else
            temp="$temp-$part"
        fi
    done
    echo $temp
}
get_uuids_from_bdmesg() {
    bdmesg="$(ioreg -l -p IODeviceTree -w0 | grep boot-log | cut -d'<' -f2 | cut -d'>' -f1 | xxd -r -p)"
    volumeprime=""
    
    while read -r line; do
        if [[ "$line" == *"[ ScanVolumes ]"* ]]; then
            echo "... $line ..."
        fi
    done <<< "$bdmesg"
}
clear
echo "###################"
echo "Get UUID"
echo "###################"
echo
read -p "Please type a disk or mount point:  " disk
if [[ "$disk" == "" ]]; then
    disk="/"
fi
littleuid="$(diskutil info $disk 2>/dev/null | grep -i "partition uuid" | cut -d":" -f2 | xargs)"
if [[ "$littleuid" == "" ]]; then
    echo "Disk not found!"
    exit 1
fi
biguuid="$(change_endianness $littleuid)"
volname="$(diskutil info $disk | grep -i "volume name" | cut -d":" -f2 | xargs)"
clear
echo "###################"
echo "Get UUID For $volname"
echo "###################"
echo
echo "Little Endian:            $littleuid"
echo "Little Endian No Dashes:  ${littleuid//-}"
echo "Big Endian:               $biguuid"
echo "Big Endian No Dashes:     ${biguuid//-}"
echo
echo "Use ${biguuid//-} for Clover's DefaultVolume."
echo
echo $(get_uuids_from_bdmesg)