"""add progressstatus table

Revision ID: 83a22913317e
Revises: ad20917fd015
Create Date: 2024-09-14 18:17:08.286390

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '83a22913317e'
down_revision: Union[str, None] = 'ad20917fd015'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create progress_status table if it doesn't exist
    op.create_table('progress_status',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('task_id', sa.Integer(), nullable=False),
        sa.Column('status', sa.String(length=16), nullable=False),
        sa.Column('updated_at', sa.DateTime(), server_default=sa.text('CURRENT_TIMESTAMP')),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('user_id', 'task_id', name='uq_user_task_progress')
    )
    op.create_index(op.f('ix_progress_status_id'), 'progress_status', ['id'], unique=False)

    # Add id column to user_tasks table
    with op.batch_alter_table('user_tasks') as batch_op:
        batch_op.add_column(sa.Column('id', sa.Integer(), nullable=True))
        batch_op.create_primary_key('pk_user_tasks', ['id'])
        batch_op.create_unique_constraint('uq_user_task', ['user_id', 'task_id'])

    # Update the id column with unique values
    op.execute('UPDATE user_tasks SET id = (SELECT COALESCE(MAX(id), 0) + 1 FROM user_tasks)')

    # Make id column not nullable
    with op.batch_alter_table('user_tasks') as batch_op:
        batch_op.alter_column('id', nullable=False)


def downgrade() -> None:
    # Remove id column from user_tasks table
    with op.batch_alter_table('user_tasks') as batch_op:
        batch_op.drop_constraint('uq_user_task', type_='unique')
        batch_op.drop_constraint('pk_user_tasks', type_='primary')
        batch_op.drop_column('id')

    # Drop progress_status table
    op.drop_index(op.f('ix_progress_status_id'), table_name='progress_status')
    op.drop_table('progress_status')
