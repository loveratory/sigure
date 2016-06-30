# Resurrection Remix Marshmallowのソースディレクトリに配置するconfig.sh
zip_name=$(get_build_var CM_VERSION)
rr_version="$(echo $zip_name | cut -c21-26)"
source_name="Resurrection Remix $rr_version"