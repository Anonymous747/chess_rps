class Endpoint {
  static const _backendEndpoint = '10.0.2.2:8000';

  static const opponentSocket = '$_backendEndpoint/api/v1/game/ws';
  static const apiBase = 'http://$_backendEndpoint';
  static const createRoom = '$apiBase/api/v1/game/rooms';
  static const getRoom = '$apiBase/api/v1/game/rooms';
  static const checkAvailableRoom = '$apiBase/api/v1/game/rooms/available';
  static const matchmakeRoom = '$apiBase/api/v1/game/rooms/matchmake';
}
