import sys
import json
import argparse
import firebase as fb
import generateSample


def themes(fbConfig):
    themes = generateSample.themes()
    fb.db.collection(fbConfig["chartCollection"]).document(
        fbConfig['themesDoc']).set(themes)
    print("Themes updated successfully")


def filters(fbConfig):
    filters = generateSample.filters()
    fb.db.collection(fbConfig["chartCollection"]).document(
        fbConfig['filtersDoc']).set(filters)
    print("Filters updated successfully")


def people(fbConfig):
    people = generateSample.people(10)
    peopleCollection = fb.db.collection(fbConfig["chartCollection"]).document(
        fbConfig["dataDoc"]).collection(fbConfig["peopleCollection"])
    for person in people:
        peopleCollection.document(person["id"]).set(person)
    print(len(people), "people updated successfully")


# usage python3 writeSample.py </path/to/fb_secret.json> </path/to/fb_const.json> <themes|filters>
parser = argparse.ArgumentParser()
parser.add_argument("secret",
                    help="Firebase service account secret json's file path")
parser.add_argument("fbconst",
                    help="Firebase constants file path")
parser.add_argument("option",
                    help="Option to write (themes|filters)")
args = parser.parse_args()

if args.secret is None:
    print("ERROR: Path to Firebase secret not found.")
    sys.exit()

if args.fbconst is None:
    print("ERROR: Path to Firebase constants not found.")
    sys.exit()

if args.option not in ["themes", "filters", "people"]:
    print("ERROR: Unknown option. <themes|filters|people>")
    sys.exit()

fb.init(args.secret)
f = open(args.fbconst, "r")
contents = f.read()
f.close()
fbConfig = json.loads(contents)

if args.option == "themes":
    themes(fbConfig)
elif args.option == "filters":
    filters(fbConfig)
elif args.option == "people":
    people(fbConfig)
