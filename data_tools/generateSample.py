#!/bin/env python
import validators
import random
import uuid
import datetime
import lorem
from random import randint

themesSample = {
    "anti_corruption": {
        "color": "#3a8789",
        "label": "Anti Corruption",
        "order": 0,
        "value": "anti_corruption"
    },
    "disease": {
        "color": "#ed9e2b",
        "label": "Disease",
        "order": 1,
        "value": "disease"
    },
    "good_governance": {
        "color": "#f7c889",
        "label": "Governance",
        "order": 2,
        "value": "good_governance"
    },
    "rule_of_law": {
        "color": "#3a8789",
        "label": "Rule of law",
        "order": 3,
        "value": "rule_of_law"
    },
    "sanitation": {
        "color": "#ed9e2b",
        "label": "Sanitation",
        "order": 4,
        "value": "sanitation"
    },
    "strengthen_police": {
        "color": "#f7c889",
        "label": "Strengthen police",
        "order": 5,
        "value": "strengthen_police"
    },
}


def validateThemes(themes):
    for attr, value in themes.items():
        validators.validate_hexcolor(value["color"])
        validators.validate_string(value["label"])
        validators.validate_int(value["order"])
        validators.validate_string(value["value"])
        assert attr == value["value"]


def themes():
    validateThemes(themesSample)
    return themesSample


filtersSample = {
    "age_category": {
        "value": "age_category",
        "label": "Age",
        "order": 0,
        "options": [
            {"value": "18_35", "label": "18 to 35 years"},
            {"value": "35_50", "label": "35 to 50 years"},
            {"value": "50_65", "label": "50 to 65 years"}
        ]
    },
    "gender": {
        "value": "gender",
        "label": "Gender",
        "order": 1,
        "options": [
            {"value": "male", "label": "Male"},
            {"value": "female", "label": "Female"},
            {"value": "unknown", "label": "Unknown"}
        ]
    },
    "idp_status": {
        "value": "idp_status",
        "label": "IDP Status",
        "order": 2,
        "options": [
            {"value": "status_a", "label": "Status A"},
            {"value": "status_b", "label": "Status B"},
            {"value": "status_c", "label": "Status C"}
        ]
    }
}


def validateFilters(filters):
    for attr, value in filters.items():
        validators.validate_string(value["value"])
        assert (attr == value["value"])
        validators.validate_string(value["label"])
        validators.validate_int(value["order"])
        validators.validate_list(value["options"])
        for option in value["options"]:
            validators.validate_string(option["value"])
            validators.validate_string(option["label"])


def filters():
    validateFilters(filtersSample)
    return filtersSample


def getAgeRange(age):
    if (age >= 18 and age <= 35):
        return "18_35"
    elif (age > 35 and age <= 50):
        return "35_50"
    elif (age > 50 and age <= 65):
        return "50_65"
    else:
        print("Age not within range")
        return 0


def randGender():
    genders = ["male", "female", "unknown"]
    return random.choice(genders)


def randIDPStatus():
    status = ["status_a", "status_b", "status_c"]
    return random.choice(status)


def randLocation():
    location = ["Mogadishu", "Hargeysa",
                "Merca", "Berbera", "Kismaayo", "Borama"]
    return random.choice(location)


def randThemes():
    themes = list(themesSample.keys())
    return random.sample(themes, randint(1, 3))


def samplePeople(i):
    age = randint(18, 65)
    return {
        "id": str(i),
        "age": age,
        "age_category": getAgeRange(age),
        "gender": randGender(),
        "idp_status": randIDPStatus(),
        "location": randLocation(),
        "themes": randThemes(),
        "message_count": randint(3, 50)
    }


def validatePeople(people):
    for person in people:
        validators.validate_string(person["id"])
        validators.validate_int(person["age"])
        validators.validate_string(person["age_category"])
        validators.validate_string(person["gender"])
        validators.validate_string(person["idp_status"])
        validators.validate_string(person["location"])
        validators.validate_list(person["themes"])
        for theme in person["themes"]:
            validators.validate_string(theme)
        validators.validate_int(person["message_count"])


def people(count):
    peopleList = list(map(samplePeople, list(range(count))))
    validatePeople(peopleList)
    return peopleList


def sampleMessages(i):
    messages = list()
    for i in range(randint(5, 20)):
        isResponse = random.choice([True, False])
        themes = list(themesSample.keys())
        theme = None if not isResponse else random.choice(themes)
        message = {
            "id": str(i),
            "text": lorem.sentence(),
            "theme": theme,
            "time": datetime.datetime(2020, 1, 1, i+1, 0, 0),
            "is_response": isResponse
        }
        messages.append(message)
    return messages


def validateMessages(messages):
    for message in messages:
        validators.validate_string(message["id"])
        validators.validate_string(message["text"])
        if message["theme"] is not None:
            validators.validate_string(message["theme"])
        validators.validate_datetime(message["time"])
        validators.validate_bool(message["is_response"])


def messages(i):
    messagesList = list()
    for i in range(i):
        messages = sampleMessages(i)
        validateMessages(messages)
        messagesList.append(messages)
    return messagesList
