import validators

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
