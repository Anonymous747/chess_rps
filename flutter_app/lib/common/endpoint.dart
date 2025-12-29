class Endpoint {
  // Get backend endpoint from environment variable or use default
  // This is set via --dart-define=ENV=dev or --dart-define=ENV=prod
  static String get _backendEndpoint {
    const env = String.fromEnvironment('ENV', defaultValue: 'prod');
    
    switch (env) {
      case 'dev':
        // For Android emulator, use 10.0.2.2 to access host machine's localhost
        // For iOS simulator, use localhost
        // For physical devices, use your computer's IP address (e.g., 192.168.1.100:8000)
        // You can override this by setting BACKEND_HOST via --dart-define=BACKEND_HOST=your-ip:8000
        const customHost = String.fromEnvironment('BACKEND_HOST', defaultValue: '');
        if (customHost.isNotEmpty) {
          return customHost;
        }
        return '10.0.2.2:8000'; // Android emulator default
      case 'prod':
      default:
        return 'gamerbot.pro'; // Production server
    }
  }

  // Determine if we should use HTTPS/WSS based on environment
  static bool get _useSecure {
    const env = String.fromEnvironment('ENV', defaultValue: 'prod');
    return env == 'prod';
  }

  static String get opponentSocket {
    if (_useSecure) {
      return 'wss://$_backendEndpoint/api/v1/game/ws';
    } else {
      return 'ws://$_backendEndpoint/api/v1/game/ws';
    }
  }

  static String get apiBase {
    if (_useSecure) {
      return 'https://$_backendEndpoint';
    } else {
      return 'http://$_backendEndpoint';
    }
  }

  static String get createRoom => '$apiBase/api/v1/game/rooms';
  static String get getRoom => '$apiBase/api/v1/game/rooms';
  static String get checkAvailableRoom => '$apiBase/api/v1/game/rooms/available';
  static String get matchmakeRoom => '$apiBase/api/v1/game/rooms/matchmake';
}
