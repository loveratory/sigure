# Android Ice Cold Project Marshmallowのソースディレクトリに配置するconfig.sh
zipname=$(get_build_var AICP_VERSION)
source="Android Ice Cold Project "$(echo $zipname | cut -f3 -d "_" | cut -c 4-7)
model=$(cat vendor/aicp/products/$device.mk 2>&1 | grep 'PRODUCT_MODEL' | cut -c 18-)
if [ "$model" = "" ]; then
        model=$(cat device/*/$device/full_$device.mk 2>&1 | grep 'PRODUCT_MODEL' | cut -c 18-)
fi
if [ "$model" = "" ]; then
        model=$device
fi
