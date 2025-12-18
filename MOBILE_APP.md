# Mobile App Documentation

## Overview

The mobile application is built using Flutter and follows Clean Architecture principles with clear separation between Domain, Data, and Presentation layers. The app supports both classical chess gameplay and a unique RPS (Rock Paper Scissors) mode where players must win RPS rounds before making chess moves.

## Architecture

### Clean Architecture Layers

#### 1. **Domain Layer** (`lib/domain/`)
The core business logic layer, independent of external frameworks.

- **Models** (`domain/model/`):
  - `board.dart`: Chess board representation with 8x8 grid
  - `cell.dart`: Individual board cell with position, figure, and state
  - `figure.dart`: Base figure class with common chess piece logic
  - `figures/`: Specific chess piece implementations (Pawn, Rook, Knight, Bishop, Queen, King)
  - `position.dart`: Board position representation with algebraic notation support

- **Services** (`domain/service/`):
  - `game_strategy.dart`: Abstract strategy pattern for different game modes
  - `action_handler.dart`: Abstract interface for handling chess moves (AI or WebSocket)
  - `logger.dart`: Action logging service

#### 2. **Data Layer** (`lib/data/`)
Handles data sources and external integrations.

- **Services** (`data/service/`):
  - `game/classical_game_strategy.dart`: Classical chess game strategy implementation
  - `game/rps_game_strategy.dart`: RPS mode game strategy (with overlay mechanics)
  - `game/ai_action_handler.dart`: Stockfish engine integration for AI opponent
  - `game/action_logger.dart`: Logs game actions
  - `socket/socket_action_handler.dart`: WebSocket client for multiplayer games

#### 3. **Presentation Layer** (`lib/presentation/`)
UI components and state management.

- **Screens** (`presentation/screen/`):
  - `mode_selector.dart`: Game mode selection screen (Classical vs RPS)
  - `chess_screen.dart`: Main game board interface

- **Controllers** (`presentation/controller/`):
  - `game_controller.dart`: Main game state controller using Riverpod

- **State** (`presentation/state/`):
  - `game_state.dart`: Immutable game state using Freezed

- **Widgets** (`presentation/widget/`):
  - `board_widget.dart`: Main chess board UI component
  - `cell_widget.dart`: Individual cell widget
  - `collection/`: Board coordinate labels (letters and numbers)
  - `custom/`: Custom UI components (animated borders, available moves, gradients)
  - `layout/`: Layout helper widgets

- **Mediators** (`presentation/mediator/`):
  - `game_mode_mediator.dart`: Manages current game mode (Classical/RPS)
  - `player_side_mediator.dart`: Manages player side (Light/Dark)

- **Utils** (`presentation/utils/`):
  - `action_checker.dart`: Validates chess moves
  - `app_routes.dart`: Route definitions
  - `custom_router.dart`: Custom navigation router

## Game Modes

### Classical Mode
Traditional chess gameplay:
- Players alternate turns
- Standard chess rules apply
- No RPS mechanics involved
- Can play against AI (Stockfish) or another player via WebSocket

### RPS Mode
Chess with Rock Paper Scissors mechanics:
- Before each chess move, an overlay appears
- Both players simultaneously select Rock, Paper, or Scissors
- Choices are hidden until both players have selected
- Winner of RPS round is determined
- **Only the winner can make the next chess move**
- Game continues with alternating RPS rounds before each move
- Players don't know who will win until after both make their RPS choice

## User Flow

### 1. Mode Selection Screen
- User sees two options:
  - **Normal Mode** (Classical chess)
  - **RPS Mode** (Chess with RPS mechanics)
- Selecting a mode navigates to the game screen

### 2. Opponent Selection
- After mode selection, user chooses opponent:
  - **AI Opponent**: Play against Stockfish engine
  - **Online Opponent**: Play against another player via WebSocket

### 3. Game Screen
- Main chess board interface
- Board displays:
  - 8x8 grid with alternating light/dark cells
  - Chess pieces in their starting positions
  - Available moves highlighted when piece is selected
  - Captured pieces displayed in side areas
- In RPS mode:
  - Overlay appears before each move
  - Players select Rock, Paper, or Scissors
  - Winner is determined and can make the move
  - Overlay disappears after RPS round

## State Management

### Riverpod
The app uses Riverpod for state management:
- `GameController`: Manages game state and logic
- `GameState`: Immutable state using Freezed
- Providers for dependency injection

### State Structure
```dart
GameState {
  Board board              // Current board state
  Side currentOrder        // Whose turn it is (light/dark)
  String? selectedFigure  // Currently selected piece position
  Side playerSide         // Player's side (light/dark)
}
```

## Key Components

### GameController
Main controller managing game logic:
- `onPressed(Cell)`: Handles cell selection and moves
- `makeMove(Cell)`: Executes a chess move
- `makeOpponentsMove()`: Gets and executes opponent's move (AI or WebSocket)
- `showAvailableActions(Cell)`: Highlights available moves for selected piece
- `dispose()`: Cleans up resources

### Board
Chess board representation:
- 8x8 grid of cells
- Manages piece positions
- Handles move execution
- Tracks captured pieces
- Supports castling

### Game Strategy Pattern
Different strategies for different game modes:
- `ClassicalGameStrategy`: Standard chess flow
- `RpsGameStrategy`: RPS overlay and winner determination logic

### Action Handlers
Different implementations for different opponent types:
- `AIActionHandler`: Communicates with Stockfish engine
- `SocketActionHandler`: WebSocket communication for multiplayer

## Dependencies

### Core Dependencies
- `flutter`: SDK
- `hooks_riverpod`: State management
- `riverpod_annotation`: Code generation for providers
- `freezed_annotation`: Immutable data classes
- `json_annotation`: JSON serialization

### Game Engine
- `stockfish`: Stockfish chess engine integration
- `stockfish_interpreter`: Custom wrapper for Stockfish (local package)

### Networking
- `dio`: HTTP client for REST API
- `web_socket_channel`: WebSocket client for real-time multiplayer

### Development
- `build_runner`: Code generation
- `freezed`: Freezed code generation
- `json_serializable`: JSON serialization code generation
- `riverpod_generator`: Riverpod code generation
- `mockito`: Mocking for tests
- `riverpod_test`: Testing utilities
- `golden_toolkit`: Widget testing with golden files

## Code Generation

The app uses code generation for:
- Riverpod providers (`.g.dart` files)
- Freezed models (`.freezed.dart` files)
- JSON serialization

Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing

### Test Structure
- `test/base/`: Base test utilities
- `test/mocks/`: Mock implementations
- `test/utils/`: Test helper functions
- `test/golden/`: Golden file tests for UI

### Running Tests
```bash
flutter test
```

## Assets

### Images
- `assets/images/figures/`: Chess piece images
  - `black/`: Black piece images
  - `white/`: White piece images

## Configuration

### Endpoints
Defined in `lib/common/endpoint.dart`:
- Backend API endpoint
- WebSocket endpoint for multiplayer

### Enums
Defined in `lib/common/enum.dart`:
- `Side`: Light/Dark sides
- `Role`: Chess piece types
- `GameMode`: Classical/RPS modes
- `OpponentMode`: AI/Socket opponent types

## Platform Support

The app supports:
- Android
- iOS
- Web
- Linux
- macOS
- Windows

## Build Configuration

### Android
- Gradle-based build system
- Native Kotlin code support

### iOS
- Xcode project configuration
- Swift bridging headers

## Future Enhancements

Potential improvements:
- RPS overlay UI implementation
- Game history and replay
- Move validation and chess rules enforcement
- Online matchmaking
- User profiles and statistics
- Push notifications for online games
- Offline game support
