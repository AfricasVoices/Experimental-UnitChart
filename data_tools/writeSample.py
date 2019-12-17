import argparse
import firebase as fb
import generateSample

chartCollection = fb.db.collection('unit-chart')


def themes():
    themes = generateSample.themes()
    chartCollection.document(u'themes').set(themes)
    print("Themes updated successfully")


def filters():
    filters = generateSample.filters()
    chartCollection.document(u'filters').set(filters)
    print("Filters updated successfully")


# usage python writeSample.py -w <themes|filters>
# initiate the parser
parser = argparse.ArgumentParser()
parser.add_argument("-w", "--write", help="Option to write (themes|filters)")

# read arguments from the command line
args = parser.parse_args()

if args.write == "themes":
    themes()
elif args.write == "filters":
    filters()
else:
    print("Unknown option. use -w themes|filters")
