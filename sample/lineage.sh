# put this to lineage source directory, rename lineage.sh to config.sh
version="$(get_build_var PRODUCT_VERSION_MAJOR).$(get_build_var PRODUCT_VERSION_MINOR)"
source="LineageOS $version"
zip="lineage-$(get_build_var LINEAGE_VERSION 2> /dev/null)"
