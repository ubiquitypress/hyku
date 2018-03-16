from csv import writer, QUOTE_MINIMAL
from os import system
from uuid import uuid4

from nameko.events import event_handler


class JournalImportServiceReceiver(object):
    """ Nameko receiver to listen for newly published content from UPCDN. """

    name = 'upcdn_import_service'

    @event_handler('repository_notify_service', 'notify_data')
    def trigger_article_import(self, content_dict):
        """ Trigger a content import when receiving a notification. """

        print(content_dict)
        csv_folder = 'csv_imports'
        file_name = '{folder}/{uuid}-{content_id}-{journal_id}.csv'.format(
            folder=csv_folder,
            uuid=uuid4(),
            content_id=content_dict.get('id'),
            journal_id=content_dict.get('journal_id')
        )

        with open(file_name, 'w') as csv_file:
            csv_writer = writer(
                csv_file,
                delimiter=',',
                quotechar='"',
                quoting=QUOTE_MINIMAL,
            )

            num_subjects = len(content_dict.get('subjects'))
            num_contributors = len(content_dict.get('contributors'))

            headers = ['id', 'type', 'title', 'description']
            [headers.extend(['subject']) for _ in range(num_subjects)]
            headers.extend(['resource_type'])
            [headers.extend(['contributor']) for _ in range(num_contributors)]
            headers.extend(['date_created'])

            csv_writer.writerow(headers)

            csv_writer.writerow(
                [
                    uuid4(),  # Id.
                    'ETD',  # Type.
                    content_dict.get('title'),
                    content_dict.get('description')
                ] + [
                    _ for _ in content_dict.get('subjects')
                ] + [
                    'text'
                ] + [
                    _ for _ in content_dict.get('contributors')
                ] + [
                    content_dict.get('date_created')
                ]
            )

        try:
            cmd = './bin/import_from_csv {tenant} {file}'.format(
                tenant=content_dict.get('tenant'),
                file=file_name,
            )
            system(cmd)
        except Exception as e:
            print(e)
