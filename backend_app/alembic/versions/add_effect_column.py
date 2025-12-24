"""add effect column to user_settings

Revision ID: add_effect_column
Revises: add_profile_name
Create Date: 2024-01-01 12:00:00.000000

"""
from typing import Union
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'add_effect_column'
down_revision: Union[str, None] = 'add_profile_name'
branch_labels: Union[str, None] = None
depends_on: Union[str, None] = None


def upgrade() -> None:
    # Add effect column to user_settings table
    # Check if column already exists to avoid errors
    connection = op.get_bind()
    inspector = sa.inspect(connection)
    
    columns = [col['name'] for col in inspector.get_columns('user_settings')]
    if 'effect' not in columns:
        op.add_column('user_settings', sa.Column('effect', sa.String(), nullable=True))


def downgrade() -> None:
    # Remove effect column
    op.drop_column('user_settings', 'effect')

