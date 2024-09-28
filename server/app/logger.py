import logging

from .config import settings


# Logger Setup
log_level = settings.LOG_LEVEL.upper()
logging.basicConfig(
    level=log_level, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)