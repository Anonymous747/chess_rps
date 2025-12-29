#!/bin/bash
# Build Flutter app APK in prod mode
flutter build apk --dart-define=ENV=prod --flavor prod --release

