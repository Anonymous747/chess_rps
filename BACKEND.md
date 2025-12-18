# Backend Documentation

## Overview

The backend is built using FastAPI, providing a RESTful API for authentication and game management, along with WebSocket support for real-time multiplayer chess games. The backend uses PostgreSQL for data persistence and SQLAlchemy for ORM operations.

## Architecture

### Project Structure

```
backend_app/
├── src/
│   ├── auth/              # Authentication module
│   │   ├── models.py      # User and Token database models
│   │   ├── router.py      # Authentication endpoints
│   │   ├── schemas.py     # Pydantic models for request/response
│   │   └── dependencies.py # Auth dependencies and utilities
│   ├── game/              # Game module
│   │   ├── models.py      # Game-related database models
│   │   ├── router.py      # Game endpoints and WebSocket
│   │   ├── schemas.py     # Game Pydantic models
│   │   └── ws_connect.py  # WebSocket connection handling
│   ├── config.py          # Configuration and environment variables
│   └── database.py        # Database connection and session management
├── alembic/               # Database migrations
└── docker/                # Docker configuration
```

## API Endpoints

### Authentication (`/api/v1/auth`)

#### POST `/api/v1/auth/register`
Register a new user.

**Request Body:**
```json
{
  "phone_number": "1234567890",
  "password": "password123"
}
```

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "user_id": 1,
  "phone_number": "1234567890"
}
```

**Validation:**
- Phone number: Minimum 10 digits (non-digits are stripped)
- Password: Minimum 8 characters

#### POST `/api/v1/auth/login`
Login with phone number and password.

**Request Body:**
```json
{
  "phone_number": "1234567890",
  "password": "password123"
}
```

**Response:** Same as register endpoint

#### POST `/api/v1/auth/logout`
Logout by invalidating the current token.

**Headers:**
- `Authorization: Bearer <token>`

**Response:**
```json
{
  "message": "Successfully logged out"
}
```

#### GET `/api/v1/auth/me`
Get current authenticated user information.

**Headers:**
- `Authorization: Bearer <token>`

**Response:**
```json
{
  "id": 1,
  "phone_number": "1234567890",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00"
}
```

#### GET `/api/v1/auth/validate-token`
Validate if the current token is still valid.

**Headers:**
- `Authorization: Bearer <token>`

**Response:**
```json
{
  "valid": true,
  "user_id": 1,
  "phone_number": "1234567890"
}
```

### Game (`/api/v1/game`)

#### GET `/api/v1/game/last_messages`
Get last 5 game messages from database.

**Response:**
```json
[
  {
    "id": 1,
    "message": "Client #1 says: e2e4"
  }
]
```

#### WebSocket `/api/v1/game/ws/{client_id}`
WebSocket endpoint for real-time game communication.

**Connection:**
```
ws://<host>/api/v1/game/ws/{client_id}
```

**Message Format:**
- Client sends: Chess move in algebraic notation (e.g., "e2e4")
- Server broadcasts: "Client #{client_id} says: {message}"

**Connection Management:**
- `ConnectionManager` handles active connections
- Messages are broadcast to all connected clients
- Messages are optionally saved to database

### Health Check

#### GET `/health`
Health check endpoint with database connectivity verification.

**Response:**
```json
{
  "status": "healthy",
  "database": "connected",
  "message": "All systems operational"
}
```

#### GET `/ok`
Simple health check without database dependency.

**Response:**
```json
{
  "status": "ok"
}
```

## Database Models

### User Model
```python
class User(Base):
    id: int (Primary Key)
    phone_number: str (Unique, Indexed)
    hashed_password: str
    is_active: bool (Default: True)
    created_at: datetime
    updated_at: datetime
    tokens: Relationship (One-to-Many with Token)
```

### Token Model
```python
class Token(Base):
    id: int (Primary Key)
    user_id: int (Foreign Key -> User.id, CASCADE delete)
    token: str (Unique, Indexed)
    created_at: datetime
    expires_at: datetime
    user: Relationship (Many-to-One with User)
```

### Messages Model
```python
class Messages(Base):
    id: int (Primary Key)
    message: str
```

## Authentication

### JWT Tokens
- Algorithm: HS256
- Expiration: 7 days (configurable via `ACCESS_TOKEN_EXPIRE_MINUTES`)
- Secret Key: Configurable via `SECRET_AUTH` environment variable

### Password Hashing
- Uses bcrypt via Passlib
- Passwords are hashed before storage
- Verification on login

### Token Storage
- Tokens are stored in database
- Multiple tokens per user allowed (for different devices/sessions)
- Tokens can be invalidated on logout

## WebSocket Implementation

### ConnectionManager
Manages WebSocket connections:
- `active_connections`: List of active WebSocket connections
- `connect(websocket)`: Accepts and stores new connection
- `disconnect(websocket)`: Removes connection
- `send_personal_message(message, websocket)`: Sends message to specific client
- `broadcast(message, add_to_db)`: Broadcasts to all clients, optionally saves to DB

### WebSocket Flow
1. Client connects to `/api/v1/game/ws/{client_id}`
2. Server accepts connection and adds to active connections
3. Client sends chess moves as text messages
4. Server broadcasts messages to all connected clients
5. On disconnect, server removes connection and notifies others

## Configuration

### Environment Variables
Defined in `src/config.py`:

**Database:**
- `DB_HOST`: Database host
- `DB_PORT`: Database port
- `DB_NAME`: Database name
- `DB_USER`: Database user
- `DB_PASS`: Database password

**Test Database:**
- `DB_HOST_TEST`: Test database host
- `DB_PORT_TEST`: Test database port
- `DB_NAME_TEST`: Test database name
- `DB_USER_TEST`: Test database user
- `DB_PASS_TEST`: Test database password

**Authentication:**
- `SECRET_AUTH`: JWT secret key (default: "your-secret-key-change-in-production")
- `ACCESS_TOKEN_EXPIRE_MINUTES`: Token expiration in minutes (default: 10080 = 7 days)

### Database Connection
- Uses asyncpg for async PostgreSQL operations
- Connection pooling with SQLAlchemy
- Connection recycling every hour
- Pool pre-ping for connection verification

## Database Migrations

### Alembic
Database migrations are managed using Alembic:
- Migration files in `alembic/versions/`
- Initial migration: `d0a2d70fc984_initial_migration.py`

### Running Migrations
```bash
# Using Python script
python migrate.py

# Using Alembic directly
alembic upgrade head
```

## Dependencies

### Core
- `fastapi`: Web framework
- `uvicorn[standard]`: ASGI server
- `sqlalchemy`: ORM
- `asyncpg`: Async PostgreSQL driver
- `pydantic`: Data validation

### Authentication
- `python-jose[cryptography]`: JWT handling
- `passlib[bcrypt]`: Password hashing
- `bcrypt`: Bcrypt implementation

### Database
- `alembic`: Database migrations

### Utilities
- `python-dotenv`: Environment variable management

## API Documentation

FastAPI automatically generates interactive API documentation:
- Swagger UI: `http://<host>/docs`
- ReDoc: `http://<host>/redoc`

## Error Handling

### HTTP Exceptions
- `400 Bad Request`: Invalid input (e.g., phone already registered)
- `401 Unauthorized`: Invalid credentials
- `403 Forbidden`: Inactive user account
- `503 Service Unavailable`: Database connection failure

### Validation
- Pydantic models validate request bodies
- Phone numbers are cleaned (non-digits removed)
- Password length validation (minimum 8 characters)

## Security Considerations

1. **Password Security:**
   - Passwords are hashed with bcrypt
   - Never stored in plain text

2. **JWT Security:**
   - Secret key should be strong and kept secure
   - Tokens expire after configured time
   - Tokens can be invalidated

3. **Database Security:**
   - Connection credentials from environment variables
   - SQL injection protection via SQLAlchemy ORM

4. **WebSocket Security:**
   - Consider adding authentication to WebSocket connections
   - Rate limiting for message broadcasting

## Future Enhancements

Potential improvements:
- Game room management for WebSocket connections
- RPS round handling in backend
- Game state persistence
- Move validation and chess rules
- Game history and replay
- User statistics and leaderboards
- Rate limiting and DDoS protection
- WebSocket authentication
- Game matchmaking service
- Real-time game state synchronization

