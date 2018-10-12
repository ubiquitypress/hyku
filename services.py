from ast import literal_eval
from csv import writer, QUOTE_MINIMAL
import logging
from os import system, path

from nameko.events import SINGLETON, event_handler, EventDispatcher
from nameko.rpc import rpc


logger = logging.getLogger(__name__)


class RepoImporterServiceDispatcher(object):
    """Nameko dispatcher: send import status to the repository importer."""

    name = 'hyku_data_service_sender'
    dispatch = EventDispatcher()

    @staticmethod
    def pre_send(data):
        return data

    @rpc
    def send(self, data):
        """ Send entry data as a notification to Indexer. """
        self.dispatch('entry_status', data)

    @staticmethod
    def post_send(data):
        pass


class RepoImporterDataServiceReceiver(object):
    """Nameko receiver to listen for new entries from the repo-importer."""

    name = 'repo_importer_data_service_receiver'

    @event_handler(
        'repo_importer_data_service_sender',
        'new_entry',
        handler_type=SINGLETON
    )
    def save_entry(self, entry_data):
        """Save new text entry from repo-importer."""

        logger.info(str(entry_data))

        import_id = entry_data.pop('uuid')
        domain = entry_data.pop('domain')  # Cleanup entry data.
        tenant = entry_data.pop('tenant')
        _file_name = entry_data.pop('downloaded-file')

        import_folder = path.join('importer', domain, tenant)

        csv_name = '{folder}/{uuid}.csv'.format(
            folder=import_folder,
            uuid=import_id,
        )

        with open(csv_name, 'w') as csv_file:
            csv_writer = writer(
                csv_file,
                delimiter=',',
                quotechar='"',
                quoting=QUOTE_MINIMAL,
            )

            headers = list(entry_data)  # `entry_data` keys are CSV headers.
            csv_writer.writerow(headers)
            csv_writer.writerow([value for value in entry_data.values()])

        try:
            cmd = (
                './bin/import_from_csv '
                '{tenant}.{domain} '
                '{csv_file} '
                '{import_folder}'
            ).format(
                tenant=tenant,
                domain=domain,
                csv_file=csv_name,
                import_folder=import_folder,
            )
            # system(cmd)
            logger.info(cmd)
        except Exception as e:
            logger.info(e)
