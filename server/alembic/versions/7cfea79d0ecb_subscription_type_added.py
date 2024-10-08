"""subscription type added

Revision ID: 7cfea79d0ecb
Revises: c4e539ad21f0
Create Date: 2024-09-03 07:48:36.757419

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '7cfea79d0ecb'
down_revision: Union[str, None] = 'c4e539ad21f0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('users', sa.Column('subscription_type', sa.String(), nullable=True))
    # ### end Alembic commands ###


def downgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('users', 'subscription_type')
    # ### end Alembic commands ###
