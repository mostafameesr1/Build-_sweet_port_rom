#!/bin/bash

# =============================================
# Sweet ROM build script
# Vendor stock untouched
# Screen density untouched
# =============================================

# === Update Product Overlay ===
sudo rm -rf "$GITHUB_WORKSPACE"/images/product/overlay/*
sudo unzip -o -q "$GITHUB_WORKSPACE"/"${device}"_files/overlay.zip -d "$GITHUB_WORKSPACE"/images/product/overlay

# === Update device_features ===
sudo rm -rf "$GITHUB_WORKSPACE"/images/product/etc/device_features/*
sudo unzip -o -q "$GITHUB_WORKSPACE"/"${device}"_files/device_features.zip -d "$GITHUB_WORKSPACE"/images/product/etc/device_features/

# === Update displayconfig ===
sudo rm -rf "$GITHUB_WORKSPACE"/images/product/etc/displayconfig/*
sudo unzip -o -q "$GITHUB_WORKSPACE"/"${device}"_files/displayconfig.zip -d "$GITHUB_WORKSPACE"/images/product/etc/displayconfig/

# === Standardize build.prop in system/product ===
sudo sed -i 's/ro.build.user=[^*]*/ro.build.user=YuKongA/' "$GITHUB_WORKSPACE"/images/system/system/build.prop
for port_build_prop in $(sudo find "$GITHUB_WORKSPACE"/images/ -type f -name "build.prop"); do
  sudo sed -i 's/build.date=[^*]*/build.date='"${build_time}"'/' "${port_build_prop}"
  sudo sed -i 's/build.date.utc=[^*]*/build.date.utc='"${build_utc}"'/' "${port_build_prop}"
  sudo sed -i 's/'"${port_os_version}"'/'"${vendor_os_version}"'/g' "${port_build_prop}"
  sudo sed -i 's/'"${port_version}"'/'"${vendor_version}"'/g' "${port_build_prop}"
  sudo sed -i 's/'"${port_base_line}"'/'"${vendor_base_line}"'/g' "${port_build_prop}"
  sudo sed -i 's/ro.product.product.name=[^*]*/ro.product.product.name='"${device}"'/' "${port_build_prop}"
done

# === Remove unnecessary MIUI apps ===
apps=("MIGalleryLockscreen" "MIUIDriveMode" "MIUIDuokanReader" "MIUIGameCenter" "MIUINewHome" "MIUIYoupin" "MIUIHuanJi" "MIUIMiDrive" "MIUIVirtualSim" "ThirdAppAssistant" "XMRemoteController" "MIUIVipAccount" "MiuiScanner" "Xinre" "SmartHome" "MiShop" "MiRadio" "MIUICompass" "MediaEditor" "BaiduIME" "iflytek.inputmethod" "MIService" "MIUIEmail" "MIUIVideo" "MIUIMusicT")
for app in "${apps[@]}"; do
  appsui=$(sudo find "$GITHUB_WORKSPACE"/images/product/data-app/ -type d -iname "*${app}*")
  if [[ -n $appsui ]]; then
    sudo rm -rf "$appsui"
  fi
done

# === Replace MiuiCamera.apk ===
sudo rm -rf "$GITHUB_WORKSPACE"/images/product/priv-app/MiuiCamera/*
sudo cp -f "$GITHUB_WORKSPACE"/"${device}"_files/MiuiCamera.apk "$GITHUB_WORKSPACE"/images/product/priv-app/MiuiCamera/

# === Replace Boot Animation ===
sudo cp -f "$GITHUB_WORKSPACE"/"${device}"_files/bootanimation.zip "$GITHUB_WORKSPACE"/images/product/media/bootanimation.zip

# === Update Theme Icons ===
cd "$GITHUB_WORKSPACE"
git clone --depth=1 https://github.com/pzcn/Perfect-Icons-Completion-Project.git icons &>/dev/null
rm -rf "$GITHUB_WORKSPACE"/icons/icons/com.xiaomi.scanner
mv "$GITHUB_WORKSPACE"/images/product/media/theme/default/icons "$GITHUB_WORKSPACE"/images/product/media/theme/default/icons.zip
mkdir -p "$GITHUB_WORKSPACE"/icons/res
mv "$GITHUB_WORKSPACE"/icons/icons "$GITHUB_WORKSPACE"/icons/res/drawable-xxhdpi
cd "$GITHUB_WORKSPACE"/icons
zip -qr "$GITHUB_WORKSPACE"/images/product/media/theme/default/icons.zip res
cd "$GITHUB_WORKSPACE"/icons/themes/Hyper/
zip -qr "$GITHUB_WORKSPACE"/images/product/media/theme/default/dynamicicons.zip layer_animating_icons
cd "$GITHUB_WORKSPACE"/icons/themes/common/
zip -qr "$GITHUB_WORKSPACE"/images/product/media/theme/default/dynamicicons.zip layer_animating_icons
mv "$GITHUB_WORKSPACE"/images/product/media/theme/default/icons.zip "$GITHUB_WORKSPACE"/images/product/media/theme/default/icons
mv "$GITHUB_WORKSPACE"/images/product/media/theme/default/dynamicicons.zip "$GITHUB_WORKSPACE"/images/product/media/theme/default/dynamicicons
rm -rf "$GITHUB_WORKSPACE"/icons

# === Build super.img ===
# Keep all existing super.img creation steps
# Adjust partition names and paths for Sweet

# === Output final ROM ===
# Compress super.img to super.zst and create final ZIP

echo "Sweet ROM build script ready. Vendor stock untouched. Screen density untouched."
