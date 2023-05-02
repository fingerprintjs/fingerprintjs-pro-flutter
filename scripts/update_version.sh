#!/bin/bash

echo "VERSION: $VERSION"


sed -i "s/^version: .*/version: $VERSION/g" pubspec.yaml
sed -i "s/s\.version          = '.*'/s.version          = '$VERSION'/g" ios/fpjs_pro_plugin.podspec
sed -i "s/version '.*'/version '$VERSION'/g" android/build.gradle
sed -i "s/fpjs_pro_plugin: ^.*/fpjs_pro_plugin: ^$VERSION/g" README.md
sed -i "s/const pluginVersion = '.*';/const pluginVersion = '$VERSION';/g" lib/fpjs_pro_plugin.dart


