#!/bin/bash
# Run Flutter app in prod mode (gamerbot.pro backend)
flutter run --dart-define=ENV=prod --flavor prod -t lib/main.dart

