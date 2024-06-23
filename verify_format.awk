BEGIN {
    FS = ":"
    valid_format = 1
}
/^[a-zA-Z]+:[a-zA-Z]+:[a-zA-Z0-9,]+:(oui|non):[a-zA-Z0-9]+$/ {
    next
}
{
    print "Ligne invalide: " $0
    valid_format = 0
}
END {
    if (valid_format) {
        print "Format de <" FILENAME "> valide..."
    } else {
        exit 1
    }
}

