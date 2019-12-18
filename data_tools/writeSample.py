import sys
import argparse
import firebase as fb
import generateSample

chartCollection = None


def themes():
    themes = generateSample.themes()
    chartCollection.document(u'themes').set(themes)
    print("Themes updated successfully")


def filters():
    filters = generateSample.filters()
    chartCollection.document(u'filters').set(filters)
    print("Filters updated successfully")


# usage python3 writeSample.py </path/to/fb_secret.json> <themes|filters>
parser = argparse.ArgumentParser()
parser.add_argument("secret",
                    help="Firebase service account secret json's file path")
parser.add_argument("option",
                    help="Option to write (themes|filters)")
args = parser.parse_args()

if args.secret:
    fb.init(args.secret)
    chartCollection = fb.db.collection('unit-chart')
else:
    print("ERROR: Path to Firebase secret not found. Use python3 writeSample.py </path/to/fb_secret.json> <themes|filters>")
    sys.exit()

if args.option == "themes":
    themes()
elif args.option == "filters":
    filters()
else:
    print("ERROR: Unknown option. Use python3 writeSample.py </path/to/fb_secret.json> <themes|filters>")
    sys.exit()
