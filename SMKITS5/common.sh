
##################################################
# Script: common.sh
# Syntax: -
# Ausführungsumgebung: -
# Beschreibung: beinhaltet von mehreren Scripten benutzte Code-Anteile
##################################################

#print n characters
function printN {
    s=$(printf "%${2}s")
    echo -n "${s// /${1}}"
}

#arithmetic floating point operations
function add {
    OUT_ADD=$(echo $1 $2 | awk "{print $1 + $2}")
}
function sub {
    OUT_SUB=$(echo $1 $2 | awk "{print $1 - $2}")
}
function mul {
    OUT_MUL=$(echo $1 $2 | awk "{print $1 * $2}")
}
function div {
    OUT_DIV=$(echo $1 $2 | awk "{print $1 / $2}")
}

#required for correct printf
export LC_NUMERIC="en_US.UTF-8"

#progress bar
function printProgress {
    BAR_WIDTH=50

    CSV_TOTAL=${1}
    CSV_CURRENT=${2}
    ix=${3}

    div $CSV_CURRENT $CSV_TOTAL
    mul $OUT_DIV $BAR_WIDTH
    
    VAL_DONE=$(echo $OUT_MUL | cut -d "." -f1)

    mul $OUT_DIV 100
    PERCENTAGE=$(printf "%.3f\n" "$OUT_MUL")

    sub $BAR_WIDTH $VAL_DONE
    VAL_DIFF=$OUT_SUB

    CSV_CURRENT=$(printf "%04d" $CSV_CURRENT)
    CSV_TOTAL=$(printf "%04d" $CSV_TOTAL)
    ix=$(printf "%02d" $ix)

    echo -ne "\r$CSV_CURRENT/$CSV_TOTAL: $ix ["
    printN "#" $VAL_DONE
    printN "." $VAL_DIFF
    echo -ne "] $PERCENTAGE%"
}