"""add_user_settings_table

Revision ID: dbe3a1c00f39
Revises: d0a2d70fc984
Create Date: 2025-12-18 19:12:25.137894

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'dbe3a1c00f39'
down_revision: Union[str, None] = 'd0a2d70fc984'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create user_settings table if it doesn't exist
    # Check if table exists first to avoid errors if already created by Base.metadata.create_all()
    connection = op.get_bind()
    inspector = sa.inspect(connection)
    
    if 'user_settings' not in inspector.get_table_names():
        op.create_table('user_settings',
            sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
            sa.Column('user_id', sa.Integer(), nullable=False),
            sa.Column('board_theme', sa.String(), nullable=False, server_default='glass_dark'),
            sa.Column('piece_set', sa.String(), nullable=False, server_default='neon_3d'),
            sa.Column('auto_queen', sa.Boolean(), nullable=False, server_default='true'),
            sa.Column('confirm_moves', sa.Boolean(), nullable=False, server_default='false'),
            sa.Column('master_volume', sa.Float(), nullable=False, server_default='0.8'),
            sa.Column('push_notifications', sa.Boolean(), nullable=False, server_default='true'),
            sa.Column('online_status_visible', sa.Boolean(), nullable=False, server_default='true'),
            sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
            sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
            sa.PrimaryKeyConstraint('id'),
            sa.UniqueConstraint('user_id')
        )
        op.create_index('ix_user_settings_id', 'user_settings', ['id'], unique=False)
        op.create_index('ix_user_settings_user_id', 'user_settings', ['user_id'], unique=True)


def downgrade() -> None:
    op.drop_index('ix_user_settings_user_id', table_name='user_settings')
    op.drop_index('ix_user_settings_id', table_name='user_settings')
    op.drop_table('user_settings')
