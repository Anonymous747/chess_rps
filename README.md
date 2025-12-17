# Chess RPS - Chess Game with Rock Paper Scissors Mechanics

## Overview

Chess RPS is a unique chess application that combines classical chess gameplay with Rock Paper Scissors (RPS) mechanics. The application supports multiple game modes, allowing users to play classical chess or a variant where players must win a Rock Paper Scissors round before making each move.

## Architecture

The application is built using a modern, scalable architecture with clear separation of concerns:

- **Mobile App**: Flutter-based cross-platform mobile application
- **Backend**: FastAPI-based RESTful API with WebSocket support
- **Database**: PostgreSQL for persistent data storage
- **DevOps**: Docker for containerization and deployment

## Key Features

### Game Modes

1. **Classical Mode**: Traditional chess gameplay without RPS mechanics
2. **RPS Mode**: Chess game where players must win a Rock Paper Scissors round before each move

### Opponent Selection

- **AI Opponent**: Play against Stockfish chess engine
- **Online Opponent**: Play against another player via WebSocket connection

### Game Flow

1. **Mode Selection Screen**: User selects game mode (Classical or RPS)
2. **Opponent Selection Screen**: User chooses to play with AI or another player
3. **Game Screen**: Main chess board interface

### RPS Mode Mechanics

In RPS mode:
- Before each chess move, an overlay appears prompting both players to select Rock, Paper, or Scissors
- Players make their RPS choice simultaneously (choices are hidden until both players have selected)
- The winner of the RPS round is determined
- Only the winner can make the next chess move
- The game continues with alternating RPS rounds before each move

## Project Structure

```
chess_rps/
├── flutter_app/          # Mobile application (Flutter)
├── backend_app/          # Backend API (FastAPI)
│   ├── src/
│   │   ├── auth/        # Authentication module
│   │   ├── game/        # Game logic and WebSocket
│   │   └── database.py  # Database configuration
│   └── docker/          # Docker configuration
├── stockfish_interpreter/ # Stockfish engine wrapper
└── scripts/             # Utility scripts
```

## Technology Stack

### Mobile App
- **Framework**: Flutter 3.0.6+
- **State Management**: Riverpod with Hooks
- **Architecture**: Clean Architecture (Domain, Data, Presentation layers)
- **Chess Engine**: Stockfish via custom interpreter
- **WebSocket**: web_socket_channel for real-time multiplayer

### Backend
- **Framework**: FastAPI
- **Database**: PostgreSQL with SQLAlchemy (async)
- **Authentication**: JWT tokens with bcrypt password hashing
- **WebSocket**: Starlette WebSocket for real-time game communication
- **Migrations**: Alembic

### DevOps
- **Containerization**: Docker and Docker Compose
- **Database**: PostgreSQL (containerized)

## Getting Started

### Prerequisites

- Flutter SDK (3.0.6 or higher)
- Python 3.8+
- Docker and Docker Compose
- PostgreSQL (or use Docker Compose)

### Quick Start

1. **Backend Setup** (All-in-One):
   ```bash
   cd backend_app
   # Windows
   start-all.bat
   
   # Linux/Mac
   chmod +x start-all.sh
   ./start-all.sh
   ```
   This will automatically:
   - Start Docker containers (PostgreSQL)
   - Wait for database to be ready
   - Run database migrations
   - Start FastAPI backend server

2. **Mobile App Setup**:
   ```bash
   cd flutter_app
   flutter pub get
   flutter run
   ```

For detailed setup instructions, see:
- [Mobile App Documentation](MOBILE_APP.md)
- [Backend Documentation](BACKEND.md)
- [DevOps Documentation](DEVOPS.md)

## Documentation

- [Mobile App Architecture](MOBILE_APP.md) - Detailed mobile app functionality and architecture
- [Backend API Documentation](BACKEND.md) - Backend services, APIs, and database schema
- [DevOps Guide](DEVOPS.md) - Deployment and Docker configuration

## Development

### Running Tests

```bash
# Mobile app tests
cd flutter_app
flutter test

# Backend tests (when implemented)
cd backend_app
pytest
```

### Code Generation

The Flutter app uses code generation for:
- Riverpod providers
- Freezed models
- JSON serialization

Run code generation:
```bash
cd flutter_app
flutter pub run build_runner build --delete-conflicting-outputs
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Ensure tests pass
4. Submit a pull request

## License

[Add your license information here]

## Version

Current Version: 2.0.0
