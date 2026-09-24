#!/bin/bash

VERSION=$(node -p "require('./package.json').version")

echo "VERSION: $VERSION"

sed -i "s/^version: .*/version: $VERSION/g" pubspec.yaml
sed -i "s/s.version          = '.*'/s.version          = '$VERSION'/g" ios/fingerprint_flutter.podspec
sed -i "s/version '.*'/version '$VERSION'/g" android/build.gradle
sed -i "s/fingerprint_flutter: ^.*/fingerprint_flutter: ^$VERSION/g" README.md
sed -i "s/const pluginVersion = '.*';/const pluginVersion = '$VERSION';/g" lib/fingerprint_flutter.dart

cd ./example && flutter pub get
