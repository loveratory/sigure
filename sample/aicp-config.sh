# Android Ice Cold Project Marshmallowのソースディレクトリに配置するconfig.sh
zip_name=$(get_build_var AICP_VERSION)
source_name="Android Ice Cold Project "$(echo $zip_name | cut -f3 -d "_" | cut -c 4-7)