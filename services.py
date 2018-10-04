import logging
import os

from nameko.events import SINGLETON, event_handler


logger = logging.getLogger(__name__)


class RepoImporterDataServiceReceiver(object):
    """Nameko receiver to listen for new entries from the repo-importer."""

    name = 'repo_importer_data_service_receiver'

    @event_handler('repo_importer_data_service_sender', 'new_entry', handler_type=SINGLETON)
    def save_entry(self, entry_data):
        """Save new text entry from repo-importer."""

        logger.info(str(entry_data))

