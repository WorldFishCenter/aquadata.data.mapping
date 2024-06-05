import csv
from functools import reduce
import glob
import json
import os
import pandas as pd
import sys
import time
from urllib.request import urlopen, Request
import ssl
import certifi

def get_dataverse_metadata(organization):
    server = 'https://dataverse.harvard.edu'
    alias = organization

    # Get current date and time (may be in UTC)
    current_time = time.strftime('%Y.%m.%d_%H.%M.%S')

    # Get ID of given dataverse alias
    url = '%s/api/dataverses/%s' % (server, alias)
    req = Request(url, headers={'User-Agent': 'Mozilla/5.0'})

    # Create an SSL context that uses certifi's CA bundle
    context = ssl.create_default_context(cafile=certifi.where())

    # Open the URL with the custom SSL context
    response = urlopen(req, context=context)
    data = json.loads(response.read())
    parent_dataverse_id = data['data']['id']

    # Get IDs of any dataverses within the given dataverse
    dataverse_ids = [parent_dataverse_id]
    print('\nGetting dataverse IDs in %s:' % (alias))

    for dataverse_id in dataverse_ids:
        # As a progress indicator, print a dot each time a row is written
        sys.stdout.write('.')
        sys.stdout.flush()

        url = '%s/api/dataverses/%s/contents' % (server, dataverse_id)
        req = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        data = json.loads(urlopen(req, context=context).read())

        for i in data['data']:
            if i['type'] == 'dataverse':
                dataverse_id = i['id']
                dataverse_ids.extend([dataverse_id])

    print('\n\nFound 1 dataverse and %s subdataverses' % (len(dataverse_ids) - 1))

    # Get PIDs of all datasets within each of the dataverses
    print('\nSaving dataset PIDs:')

    dataset_pids = []
    for dataverse_id in dataverse_ids:
        url = '%s/api/dataverses/%s/contents' % (server, dataverse_id)
        req = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        data = json.loads(urlopen(req, context=context).read())

        for i in data['data']:
            if i['type'] == 'dataset':
                protocol = i['protocol']
                authority = i['authority']
                identifier = i['identifier']
                dataset_pid = '%s:%s/%s' % (protocol, authority, identifier)
                dataset_pids.append(dataset_pid)

                # As a progress indicator, print a dot each time a row is written
                sys.stdout.write('.')
                sys.stdout.flush()

    total = len(dataset_pids)
    print('\n\nDataset PIDs saved: %s' % (total))

    # Create directory to store JSON metadata files
    json_metadata_directory = 'dataset_JSON_files_%s' % (current_time)
    os.mkdir(json_metadata_directory)

    # Get the JSON metadata for each dataset_pid
    print('\nDownloading JSON metadata files for each dataset')

    # Reset count variable for tracking progress
    count = 0

    for dataset_pid in dataset_pids:
        # Remove any trailing spaces from pid
        dataset_pid = dataset_pid.rstrip()

        # Use the dataset_pid as the file name, replacing the colon and slashes
        # with underscores
        filename_pid = dataset_pid.replace(':', '_').replace('/', '_')
        filename = '%s/%s.json' % (json_metadata_directory, filename_pid)

        # Get JSON metadata of the dataset_pid
        url = '%s/api/datasets/:persistentId?persistentId=%s' % (server, dataset_pid)
        req = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        data = json.loads(urlopen(req, context=context).read())

        # Write the JSON metadata to the new file
        with open(filename, mode='w') as f:
            json.dump(data, f, indent=4, sort_keys=True)

        # Increase count variable to track progress
        count += 1

        # As a progress indicator, print a dot each time a row is written
        sys.stdout.write('.')
        sys.stdout.flush()

    print('\nFinished downloading %s of %s JSON files' % (count, total))

    # Create directory to store CSV files
    csv_files_directory = 'csv_files_%s' % (current_time)
    os.mkdir(csv_files_directory)

    # Parse JSON files to write dataset DOI and publication date metadata to a CSV file
    basic_metadata_csv = '%s/basic_metadata_%s.csv' % (csv_files_directory, current_time)

    with open(basic_metadata_csv, mode='w') as metadatafile:
        metadatawriter = csv.writer(metadatafile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        # Create header row
        metadatawriter.writerow(['dataset_id', 'persistentUrl', 'publicationdate'])

    print('Getting dataset DOI and publication date metadata:')

    # For each JSON file in the folder of JSON files
    for file in glob.glob(os.path.join(json_metadata_directory, '*.json')):
        # Open each file in read mode
        with open(file, 'r') as f1:
            # Copy content to dataset_metadata variable
            dataset_metadata = f1.read()

            # Overwrite variable with content as a python dict
            dataset_metadata = json.loads(dataset_metadata)

        # Save the metadata values in variables
        dataset_id = dataset_metadata['data']['id']
        persistentUrl = dataset_metadata['data']['persistentUrl']
        publicationDate = dataset_metadata['data']['publicationDate']

        # In the csv file, add rows for each field value
        with open(basic_metadata_csv, mode='a') as metadatafile:
            metadatawriter = csv.writer(metadatafile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            # Write new row
            metadatawriter.writerow([dataset_id, persistentUrl, publicationDate])

        # As a progress indicator, print a dot each time a row is written
        sys.stdout.write('.')
        sys.stdout.flush()

    print('\nFinished writing dataset DOI and publication date metadata to %s' % (csv_files_directory))

    # Parse JSON files to write dataset title and subject metadata to CSVs files
    primativefields = ['title', 'subject']

    for fieldname in primativefields:
        filename = '%s/%s_%s.csv' % (csv_files_directory, fieldname, current_time)

        with open(filename, mode='w') as metadatafile:
            metadatawriter = csv.writer(metadatafile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            metadatawriter.writerow(['dataset_id', 'persistentUrl', fieldname])

        print('\nGetting %s metadata:' % (fieldname))

        parseerrordatasets = []

        for file in glob.glob(os.path.join(json_metadata_directory, '*.json')):
            with open(file, 'r') as f1:
                dataset_metadata = f1.read()
                dataset_metadata = json.loads(dataset_metadata)

            if (dataset_metadata['status'] == 'OK') and ('latestVersion' in dataset_metadata['data']):
                dataset_id = str(dataset_metadata['data']['id'])

                for fields in dataset_metadata['data']['latestVersion']['metadataBlocks']['citation']['fields']:
                    if fields['typeName'] == fieldname:
                        value = fields['value']
                        if isinstance(value, str):
                            persistentUrl = dataset_metadata['data']['persistentUrl']
                            with open(filename, mode='a') as metadatafile:
                                metadatawriter = csv.writer(metadatafile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
                                metadatawriter.writerow([dataset_id, persistentUrl, value])
                                sys.stdout.write('.')
                                sys.stdout.flush()
                        elif isinstance(value, list):
                            for v in value:
                                persistentUrl = dataset_metadata['data']['persistentUrl']
                                with open(filename, mode='a') as metadatafile:
                                    metadatawriter = csv.writer(metadatafile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
                                    metadatawriter.writerow([dataset_id, persistentUrl, v])
                                    sys.stdout.write('.')
                                    sys.stdout.flush()
            else:
                parseerrordatasets.append(file)

        print('\nFinished writing %s metadata to %s' % (fieldname, csv_files_directory))

    if parseerrordatasets:
        parseerrordatasets = set(parseerrordatasets)
        print('\nThe following %s JSON file(s) could not be parsed. It/they may be draft or deaccessioned dataset(s):' % (len(parseerrordatasets)))
        print(*parseerrordatasets, sep='\n')

    # Parse JSON files to write dataset keywords to a CSV file
    parent_compound_field = 'keyword'
    subfields = ['keywordValue', 'keywordVocabulary', 'keywordVocabularyURI']

    def getsubfields(dataset_metadata, parent_compound_field, index, subfield):
        try:
            for fields in dataset_metadata['data']['latestVersion']['metadataBlocks']['citation']['fields']:
                if fields['typeName'] == parent_compound_field:
                    subfield = fields['value'][index][subfield]['value']
        except KeyError:
            subfield = ''
        return subfield

    filename = '%s/%s_%s.csv' % (csv_files_directory, parent_compound_field, current_time)

    ids = ['dataset_id', 'persistentUrl']
    header_row = ids + subfields

    with open(filename, mode='w') as metadatafile:
        metadatawriter = csv.writer(metadatafile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        metadatawriter.writerow(header_row)

    print('\nGetting keyword metadata:')

    parseerrordatasets = []

    for file in glob.glob(os.path.join(json_metadata_directory, '*.json')):
        with open(file, 'r') as f1:
            dataset_metadata = f1.read()
            dataset_metadata = json.loads(dataset_metadata)

        if (dataset_metadata['status'] == 'OK') and ('latestVersion' in dataset_metadata['data']):
            for fields in dataset_metadata['data']['latestVersion']['metadataBlocks']['citation']['fields']:
                if fields['typeName'] == parent_compound_field:
                    total = len(fields['value'])
                    if total:
                        index = 0
                        condition = True
                        while condition:
                            dataset_id = str(dataset_metadata['data']['id'])
                            persistentUrl = dataset_metadata['data']['persistentUrl']
                            row_variables = [dataset_id, persistentUrl]
                            for subfield in subfields:
                                row_variables.append(getsubfields(dataset_metadata, parent_compound_field, index, subfield))
                            with open(filename, mode='a') as metadatafile:
                                metadatawriter = csv.writer(metadatafile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
                                metadatawriter.writerow(row_variables)
                                sys.stdout.write('.')
                                sys.stdout.flush()
                            index += 1
                            condition = index < total
        else:
            parseerrordatasets.append(file)

    print('\nFinished writing keyword metadata to %s' % (csv_files_directory))

    if parseerrordatasets:
        parseerrordatasets = set(parseerrordatasets)
        print('\nThe following %s JSON file(s) could not be parsed. It/they may be draft or deaccessioned dataset(s):' % (len(parseerrordatasets)))
        print(*parseerrordatasets, sep='\n')

    # Create CSV of all metadata by joining CSV files in the csv_files folder
    filename = 'inst/dataverse_raw/%s_dataset_metadata_%s.csv' % (alias, current_time)

    all_tables = glob.glob(os.path.join(csv_files_directory, '*.csv'))

    dataframes = [pd.read_csv(table, sep=',') for table in all_tables]

    for dataframe in dataframes:
        dataframe.set_index(['dataset_id', 'persistentUrl'], inplace=True)

    print('\nMerging metadata files in %s' % (csv_files_directory))

    merged = reduce(lambda left, right: left.join(right, how='outer'), dataframes)

    merged = merged[['publicationdate', 'title', 'subject', 'keywordValue', 'keywordVocabulary', 'keywordVocabularyURI']]

    merged.to_csv(filename)

    print('CSV file with all metadata created at %s' % (filename))
