"""add_level_and_experience_to_user_stats

Revision ID: 812eaabb1488
Revises: dbe3a1c00f39
Create Date: 2025-12-22 19:57:41.542378

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '812eaabb1488'
down_revision: Union[str, None] = 'dbe3a1c00f39'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add level and experience columns to user_stats table
    op.add_column('user_stats', sa.Column('level', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('user_stats', sa.Column('experience', sa.Integer(), nullable=False, server_default='0'))


def downgrade() -> None:
    # Remove level and experience columns
    op.drop_column('user_stats', 'experience')
    op.drop_column('user_stats', 'level')
