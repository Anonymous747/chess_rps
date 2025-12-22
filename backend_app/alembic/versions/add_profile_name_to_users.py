"""add_profile_name_to_users

Revision ID: add_profile_name
Revises: 812eaabb1488
Create Date: 2025-12-22 20:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = 'add_profile_name'
down_revision: Union[str, None] = '812eaabb1488'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add profile_name column to users table
    op.add_column('users', sa.Column('profile_name', sa.String(), nullable=False, server_default='Player'))


def downgrade() -> None:
    # Remove profile_name column
    op.drop_column('users', 'profile_name')
