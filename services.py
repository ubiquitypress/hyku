from collections import Mapping, Iterable
from csv import writer, QUOTE_MINIMAL
import json
import logging
from os import system, path

from nameko.events import event_handler, EventDispatcher
from nameko.rpc import rpc


logger = logging.getLogger(__name__)


def convert_unicode(data):
    if isinstance(data, basestring):
        return str(data.encode('utf-8'))
    elif isinstance(data, Mapping):
        return dict(map(convert_unicode, data.iteritems()))
    elif isinstance(data, Iterable):
        return type(data)(map(convert_unicode, data))
    else:
        return data


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
    )
    def save_entry(self, entry_data):
        """Save new text entry from repo-importer."""

        logger.info(entry_data)
        entry_data = convert_unicode(json.loads(entry_data))

        domain = entry_data.pop('domain')
        tenant = entry_data.pop('tenant')
        import_id = entry_data['id']
        file_name = entry_data['file']

        import_folder = path.join('importer', domain, tenant)
        csv_folder = path.join(import_folder, 'csv')

        csv_path = '{folder}/{uuid}.csv'.format(
            folder=csv_folder,
            uuid=import_id,
        )

        with open(csv_path, 'w') as csv_file:
            csv_writer = writer(csv_file, quoting=QUOTE_MINIMAL)
            csv_writer.writerows([entry_data['headers']])
            csv_writer.writerows([entry_data['values']])

        logger.info(
            '[importer] Importing UUID :{uuid} - file: {file_name}'.format(
                uuid=import_id,
                file_name=file_name,
            )
        )

        try:
            cmd = (
                './bin/import_from_csv '
                '{tenant}.{domain} '
                '{csv_file} '
                '{import_folder}'
            ).format(
                tenant=tenant,
                domain=domain,
                csv_file=csv_path,
                import_folder=import_folder,
            )
            system(cmd)
            logger.info(cmd)
        except Exception as e:
            logger.info(e)
