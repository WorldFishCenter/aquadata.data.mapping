import csv
from functools import reduce
import glob
import json
import os
import sys
import time
from urllib.request import urlopen, Request

def get_dataverse_metadata(organization):

    server = 'https://dataverse.harvard.edu'
    alias = organization

    # Get current date and time (may be in UTC)
    current_time = time.strftime('%Y.%m.%d_%H.%M.%S')

    # Get ID of given dataverse alias
    url = '%s/api/dataverses/%s' % (server, alias)
    req = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    data = json.loads(urlopen(req).read())
    parent_dataverse_id = data['data']['id']
    dataverse_ids = [parent_dataverse_id]

    # Get IDs of any dataverses within the given dataverse
    print('\nGetting dataverse IDs in %s:' % (alias))

    for dataverse_id in dataverse_ids:

        # As a progress indicator, print a dot each time a row is written
        sys.stdout.write('.')
        sys.stdout.flush()

        url = '%s/api/dataverses/%s/contents' % (server, dataverse_id)
        req = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        data = json.loads(urlopen(req).read())

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
        data = json.loads(urlopen(req).read())

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
        url = '%s/api/datasets/:persistentId?persistentId=%s' % (
            server, dataset_pid)
        req = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        data = json.loads(urlopen(req).read())

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

    # Parse JSON files to write dataset DOI and publication date metadata to a
    # CSV file

    # Add path of csv file to filename variable
    basic_metadata_csv = '%s/basic_metadata_%s.csv' % (
        csv_files_directory, current_time)

    with open(basic_metadata_csv, mode='w') as metadatafile:
        metadatafile = csv.writer(
            metadatafile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        # Create header row
        metadatafile.writerow(['dataset_id', 'persistentUrl', 'publicationdate'])

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

            # Convert all characters to utf-8
            def to_utf8(lst):
                return [unicode(elem).encode('utf-8') for elem in lst]

            metadatafile = csv.writer(
                metadatafile,
                delimiter=',',
                quotechar='"',
                quoting=csv.QUOTE_MINIMAL)

            # Write new row
            metadatafile.writerow([dataset_id, persistentUrl, publicationDate])

        # As a progress indicator, print a dot each time a row is written
        sys.stdout.write('.')
        sys.stdout.flush()

    print('\nFinished writing dataset DOI and publication date metadata to %s' %
          (csv_files_directory))

    # Parse JSON files to write dataset title and subject metadata to CSVs files

    # Save list of fieldnames
    primativefields = ['title', 'subject']

    for fieldname in primativefields:

        # Store path of csv file to filename variable
        filename = '%s/%s_%s.csv' % (csv_files_directory, fieldname, current_time)

        with open(filename, mode='w') as metadatafile:
            metadatafile = csv.writer(
                metadatafile,
                delimiter=',',
                quotechar='"',
                quoting=csv.QUOTE_MINIMAL)

            # Create header row
            metadatafile.writerow(['dataset_id', 'persistentUrl', fieldname])

        print('\nGetting %s metadata:' % (fieldname))

        parseerrordatasets = []

        # For each file in a folder of json files
        for file in glob.glob(os.path.join(json_metadata_directory, '*.json')):

            # Open each file in read mode
            with open(file, 'r') as f1:

                # Copy content to dataset_metadata variable
                dataset_metadata = f1.read()

                # Overwrite variable with content as a python dict
                dataset_metadata = json.loads(dataset_metadata)

                if (dataset_metadata['status'] == 'OK') and (
                        'latestVersion' in dataset_metadata['data']):

                    # Save the dataset id of each dataset
                    dataset_id = str(dataset_metadata['data']['id'])

                    # Couple each field value with the dataset_id and write as a
                    # row to subjects.csv
                    for fields in dataset_metadata['data']['latestVersion']['metadataBlocks']['citation']['fields']:
                        if fields['typeName'] == fieldname:
                            value = fields['value']

                            # If value is a string, it's a field that doesn't allow
                            # multiple values
                            if isinstance(value, str):
                                persistentUrl = dataset_metadata['data']['persistentUrl']
                                dataset_id = str(dataset_metadata['data']['id'])

                                with open(filename, mode='a') as metadatafile:

                                    # Convert all characters to utf-8 to avoid
                                    # encoding errors when writing to the csv file
                                    def to_utf8(lst):
                                        return [
                                            unicode(elem).encode('utf-8') for elem in lst]

                                    metadatafile = csv.writer(
                                        metadatafile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

                                    # Write new row
                                    metadatafile.writerow(
                                        [dataset_id, persistentUrl, value])

                                    # As a progress indicator, print a dot each
                                    # time a row is written
                                    sys.stdout.write('.')
                                    sys.stdout.flush()

                            # If value is a list, it's a field that allows multiple
                            # values
                            elif isinstance(value, list):
                                for value in fields['value']:
                                    persistentUrl = dataset_metadata['data']['persistentUrl']
                                    with open(filename, mode='a') as metadatafile:

                                        # Convert all characters to utf-8 to avoid
                                        # encoding errors when writing to the csv
                                        # file
                                        def to_utf8(lst):
                                            return [
                                                unicode(elem).encode('utf-8') for elem in lst]

                                        metadatafile = csv.writer(
                                            metadatafile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

                                        # Write new row
                                        metadatafile.writerow(
                                            [dataset_id, persistentUrl, value])

                                        # As a progress indicator, print a dot each
                                        # time a row is written
                                        sys.stdout.write('.')
                                        sys.stdout.flush()
                else:
                    parseerrordatasets.append(file)

    print('\nFinished writing title and subject metadata to %s' %
          (csv_files_directory))

    if parseerrordatasets:
        parseerrordatasets = set(parseerrordatasets)
        print(
            '\nThe following %s JSON file(s) could not be parsed. It/they may be draft or deaccessioned dataset(s):' %
            (len(parseerrordatasets)))
        print(*parseerrordatasets, sep='\n')

    # Parse JSON files to write dataset keywords to a CSV file

    # Enter database name of the parent compound field, e.g. dsDescription
    parent_compound_field = 'keyword'

    # Enter database names of the parent compound field's subfields, e.g.
    # 'dsDescriptionValue', 'dsDescriptionDate'
    subfields = ['keywordValue', 'keywordVocabulary', 'keywordVocabularyURI']


    def getsubfields(parent_compound_field, subfield):
        try:
            for fields in dataset_metadata['data']['latestVersion']['metadataBlocks']['citation']['fields']:
                # Find compound name
                if fields['typeName'] == parent_compound_field:
                    # Find value in subfield
                    subfield = fields['value'][index][subfield]['value']
        except KeyError:
            subfield = ''
        return subfield


    # Store path of csv file to filename variable
    filename = '%s/%s_%s.csv' % (csv_files_directory,
                                 parent_compound_field, current_time)

    # Create column names for the header row
    ids = ['dataset_id', 'persistentUrl']
    header_row = ids + subfields

    with open(filename, mode='w') as metadatafile:
        metadatafile = csv.writer(
            metadatafile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        # Create header row
        metadatafile.writerow(header_row)

    print('\nGetting keyword metadata:')

    parseerrordatasets = []

    # For each file in a folder of json files
    for file in glob.glob(os.path.join(json_metadata_directory, '*.json')):

        # Open each file in read mode
        with open(file, 'r') as f1:

            # Copy content to dataset_metadata variable
            dataset_metadata = f1.read()

            # Overwrite variable with content as a python dict
            dataset_metadata = json.loads(dataset_metadata)

        if (dataset_metadata['status'] == 'OK') and (
                'latestVersion' in dataset_metadata['data']):

            # Count number of the given compound fields
            for fields in dataset_metadata['data']['latestVersion']['metadataBlocks']['citation']['fields']:
                # Find compound name
                if fields['typeName'] == parent_compound_field:
                    total = len(fields['value'])

                    # If there are compound fields
                    if total:
                        index = 0
                        condition = True

                        while (condition):

                            # Save the dataset id of each dataset
                            dataset_id = str(dataset_metadata['data']['id'])

                            # Save the identifier of each dataset
                            persistentUrl = dataset_metadata['data']['persistentUrl']

                            # Save subfield values to variables
                            for subfield in subfields:
                                globals()[subfield] = getsubfields(
                                    parent_compound_field, subfield)

                            # Append fields to the csv file
                            with open(filename, mode='a') as metadatafile:

                                # Create list of variables
                                row_variables = [dataset_id, persistentUrl]
                                for subfield in subfields:
                                    row_variables.append(globals()[subfield])

                                # Convert all characters to utf-8
                                def to_utf8(lst):
                                    return [unicode(elem).encode('utf-8')
                                            for elem in lst]

                                metadatafile = csv.writer(
                                    metadatafile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

                                # Write new row using list of variables
                                metadatafile.writerow(row_variables)

                                # As a progress indicator, print a dot each time a
                                # row is written
                                sys.stdout.write('.')
                                sys.stdout.flush()

                            index += 1
                            condition = index < total

        else:
            parseerrordatasets.append(file)

    print('\nFinished writing keyword metadata to %s' % (csv_files_directory))

    if parseerrordatasets:
        parseerrordatasets = set(parseerrordatasets)
        print(
            '\nThe following %s JSON file(s) could not be parsed. It/they may be draft or deaccessioned dataset(s):' %
            (len(parseerrordatasets)))
        print(*parseerrordatasets, sep='\n')

    # Create CSV of all metadata by joining CSV files in the csv_files folder

    # Create csv file in the directory that the user selected
    filename = 'data-raw/%s_dataset_metadata_%s.csv' % (alias, current_time)

    # Save directory paths to each csv file as a list and save in 'all_tables'
    # variable
    all_tables = glob.glob(os.path.join(csv_files_directory, '*.csv'))

    # Create a dataframe of each csv file in the 'all-tables' list
    dataframes = [pd.read_csv(table, sep=',') for table in all_tables]

    # For each dataframe, set the indexes (or the common columns across the
    # dataframes to join on)
    for dataframe in dataframes:
        dataframe.set_index(['dataset_id', 'persistentUrl'], inplace=True)

    print('\nMerging metadata files in %s' % (csv_files_directory))

    # Merge all dataframes and save to the 'merged' variable
    merged = reduce(lambda left, right: left.join(right, how='outer'), dataframes)

    # Reorder columns (not including the index columns dataset_id and
    # persistentUrl)
    merged = merged[['publicationdate', 'title', 'subject',
                     'keywordValue', 'keywordVocabulary', 'keywordVocabularyURI']]

    # Export merged dataframe to a csv file
    merged.to_csv(filename)

    print('CSV file with all metadata created at %s' % (filename))
