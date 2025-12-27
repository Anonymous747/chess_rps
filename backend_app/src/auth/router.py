from datetime import datetime, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials
from jose import jwt
from passlib.context import CryptContext
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, delete

from src.config import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES, REFRESH_TOKEN_EXPIRE_DAYS
from src.database import get_async_session
from src.auth.models import User, Token
from src.auth.schemas import UserRegister, UserLogin, TokenResponse, UserResponse, RefreshTokenRequest, UpdateProfileNameRequest
from src.auth.dependencies import get_current_active_user, security

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain password against a hashed password."""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Hash a password."""
    return pwd_context.hash(password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create a JWT access token."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire, "type": "access"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def create_refresh_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create a JWT refresh token."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    
    to_encode.update({"exp": expire, "type": "refresh"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(
    user_data: UserRegister,
    session: AsyncSession = Depends(get_async_session)
):
    """
    Register a new user with phone number and password.
    Returns an access token upon successful registration.
    """
    # Check if user already exists
    query = select(User).where(User.phone_number == user_data.phone_number)
    result = await session.execute(query)
    existing_user = result.scalar_one_or_none()

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number already registered"
        )

    # Create new user
    hashed_password = get_password_hash(user_data.password)
    new_user = User(
        phone_number=user_data.phone_number,
        hashed_password=hashed_password,
        is_active=True
    )
    session.add(new_user)
    await session.commit()
    await session.refresh(new_user)

    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    token_data = {"sub": str(new_user.id), "phone": new_user.phone_number}
    access_token = create_access_token(data=token_data, expires_delta=access_token_expires)

    # Create refresh token
    refresh_token_expires = timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    refresh_token = create_refresh_token(data=token_data, expires_delta=refresh_token_expires)

    # Save tokens to database
    access_expires_at = datetime.utcnow() + access_token_expires
    refresh_expires_at = datetime.utcnow() + refresh_token_expires
    
    access_token_record = Token(
        user_id=new_user.id,
        token=access_token,
        token_type="access",
        expires_at=access_expires_at
    )
    refresh_token_record = Token(
        user_id=new_user.id,
        token=refresh_token,
        token_type="refresh",
        expires_at=refresh_expires_at
    )
    session.add(access_token_record)
    session.add(refresh_token_record)
    await session.commit()

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user_id=new_user.id,
        phone_number=new_user.phone_number
    )


@router.post("/login", response_model=TokenResponse)
async def login(
    user_data: UserLogin,
    session: AsyncSession = Depends(get_async_session)
):
    """
    Login with phone number and password.
    Returns an access token upon successful authentication.
    """
    # Find user by phone number
    query = select(User).where(User.phone_number == user_data.phone_number)
    result = await session.execute(query)
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect phone number or password"
        )

    # Verify password
    if not verify_password(user_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect phone number or password"
        )

    # Check if user is active
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive"
        )

    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    token_data = {"sub": str(user.id), "phone": user.phone_number}
    access_token = create_access_token(data=token_data, expires_delta=access_token_expires)

    # Create refresh token
    refresh_token_expires = timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    refresh_token = create_refresh_token(data=token_data, expires_delta=refresh_token_expires)

    # Invalidate old tokens (optional - you can keep them or delete)
    # For now, we'll keep old tokens in the database
    # Multiple tokens per user are allowed for different devices/sessions

    # Save new tokens to database
    access_expires_at = datetime.utcnow() + access_token_expires
    refresh_expires_at = datetime.utcnow() + refresh_token_expires
    
    access_token_record = Token(
        user_id=user.id,
        token=access_token,
        token_type="access",
        expires_at=access_expires_at
    )
    refresh_token_record = Token(
        user_id=user.id,
        token=refresh_token,
        token_type="refresh",
        expires_at=refresh_expires_at
    )
    session.add(access_token_record)
    session.add(refresh_token_record)
    await session.commit()

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user_id=user.id,
        phone_number=user.phone_number
    )


@router.post("/logout", status_code=status.HTTP_200_OK)
async def logout(
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session),
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """
    Logout by invalidating the current token.
    """
    token = credentials.credentials

    # Delete token from database
    stmt = delete(Token).where(Token.token == token)
    await session.execute(stmt)
    await session.commit()

    return {"message": "Successfully logged out"}


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_active_user)
):
    """
    Get current authenticated user information.
    """
    return current_user


@router.get("/validate-token", status_code=status.HTTP_200_OK)
async def validate_token(
    current_user: User = Depends(get_current_active_user)
):
    """
    Validate if the current token is still valid.
    """
    return {
        "valid": True,
        "user_id": current_user.id,
        "phone_number": current_user.phone_number
    }


@router.patch("/profile-name", response_model=UserResponse)
async def update_profile_name(
    update_data: UpdateProfileNameRequest,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """
    Update user's profile name.
    """
    current_user.profile_name = update_data.profile_name
    await session.commit()
    await session.refresh(current_user)
    
    return current_user


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    refresh_data: RefreshTokenRequest,
    session: AsyncSession = Depends(get_async_session)
):
    """
    Refresh access token using refresh token.
    Returns new access and refresh tokens.
    """
    try:
        # Decode and verify refresh token
        payload = jwt.decode(refresh_data.refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        
        # Check token type
        if payload.get("type") != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token type"
            )
        
        user_id = int(payload.get("sub"))
        phone_number = payload.get("phone")
        
        # Verify refresh token exists in database and is not expired
        query = select(Token).where(
            and_(
                Token.token == refresh_data.refresh_token,
                Token.token_type == "refresh",
                Token.user_id == user_id,
                Token.expires_at > datetime.utcnow()
            )
        )
        result = await session.execute(query)
        token_record = result.scalar_one_or_none()
        
        if not token_record:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token"
            )
        
        # Get user
        user_query = select(User).where(User.id == user_id)
        user_result = await session.execute(user_query)
        user = user_result.scalar_one_or_none()
        
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found or inactive"
            )
        
        # Invalidate old refresh token
        stmt = delete(Token).where(Token.id == token_record.id)
        await session.execute(stmt)
        
        # Create new access token
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        token_data = {"sub": str(user.id), "phone": user.phone_number}
        access_token = create_access_token(data=token_data, expires_delta=access_token_expires)
        
        # Create new refresh token
        refresh_token_expires = timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        new_refresh_token = create_refresh_token(data=token_data, expires_delta=refresh_token_expires)
        
        # Save new tokens to database
        access_expires_at = datetime.utcnow() + access_token_expires
        refresh_expires_at = datetime.utcnow() + refresh_token_expires
        
        access_token_record = Token(
            user_id=user.id,
            token=access_token,
            token_type="access",
            expires_at=access_expires_at
        )
        refresh_token_record = Token(
            user_id=user.id,
            token=new_refresh_token,
            token_type="refresh",
            expires_at=refresh_expires_at
        )
        session.add(access_token_record)
        session.add(refresh_token_record)
        await session.commit()
        
        return TokenResponse(
            access_token=access_token,
            refresh_token=new_refresh_token,
            token_type="bearer",
            user_id=user.id,
            phone_number=user.phone_number
        )
        
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token has expired"
        )
    except jwt.JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )

