import 'dart:math' as math;
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart' as fs;

class DB {
  fs.DocumentReference _filtersRef;
  fs.DocumentReference _themesRef;
  fs.CollectionReference _peopleRef;

  DB() {
    fb.initializeApp(
        apiKey: "AIzaSyB3nbxl4cH5opeqmXSyRZMANoUMIlTch80",
        authDomain: "avf-metrics.firebaseapp.com",
        databaseURL: "https://avf-metrics.firebaseio.com",
        projectId: "avf-metrics",
        storageBucket: "avf-metrics.appspot.com",
        messagingSenderId: "542922892166",
        appId: "1:542922892166:web:cd7ae2802395a9f652c207");

    fs.Firestore store = fb.firestore();
    _filtersRef = store.collection("unit-chart").doc("filters");
    _themesRef = store.collection("unit-chart").doc("themes");
    _peopleRef =
        store.collection("unit-chart").doc("data").collection("people");
  }

  Future<Map<String, dynamic>> readFilters() async {
    var snapshot = await _filtersRef.get();
    return snapshot.data();
  }

  Future<Map<String, dynamic>> readThemes() async {
    var snapshot = await _themesRef.get();
    return snapshot.data();
  }

  Future<List<Map<String, dynamic>>> readPeople() async {
    var snapshot = await _peopleRef.get();
    List<Map<String, dynamic>> result = [];
    snapshot.forEach((doc) => result.add(doc.data()));
    return result;
  }

  // test themes
  void writeThemes() async {
    var themes = {
      "anti_corruption": {
        "value": "anti_corruption",
        "label": "Anti-corruption",
        "order": 0,
        "color": "#633246"
      },
      "rule_of_law": {
        "value": "rule_of_law",
        "label": "Rule of law",
        "order": 1,
        "color": "#3a8789"
      },
      "good_governance": {
        "value": "good_governance",
        "label": "Good governance",
        "order": 2,
        "color": "#bc4015"
      },
      "sanitation": {
        "value": "sanitation",
        "label": "Sanitation",
        "order": 3,
        "color": "#ed9e2b"
      },
      "strengthen_police": {
        "value": "strengthen_police",
        "label": "Strengthen police",
        "order": 4,
        "color": "#f7c889"
      },
      "disease": {
        "value": "disease",
        "label": "Disease",
        "order": 5,
        "color": "#b3eaff"
      },
    };

    await _themesRef.set(themes);
    print("Themes updated");
  }

  // test filters
  void writeFilter() async {
    var filters = {
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
    };

    await _filtersRef.set(filters);
    print("Filters updated");
  }

  String getAgeRange(int age) {
    if (age >= 18 && age <= 35) {
      return "18_35";
    } else if (age > 35 && age <= 50) {
      return "35_50";
    } else if (age > 50 && age <= 65) {
      return "50_65";
    }
    return "";
  }

  String getGender(int i) {
    switch (i) {
      case 0:
        return "male";
      case 1:
        return "female";
      case 2:
        return "unknown";
      default:
        return "";
    }
  }

  String getIDPStatus(int i) {
    switch (i) {
      case 0:
        return "status_a";
      case 1:
        return "status_b";
      case 2:
        return "status_c";
      default:
        return "";
    }
  }

  String getLocation(int i) {
    switch (i) {
      case 0:
        return "Mogadishu";
      case 1:
        return "Hargeysa";
      case 2:
        return "Merca";
      case 3:
        return "Berbera";
      case 4:
        return "Kismaayo";
      case 5:
        return "Borama";
      default:
        return "";
    }
  }

  String getTheme(int i) {
    switch (i) {
      case 0:
        return "anti_corruption";
      case 1:
        return "rule_of_law";
      case 2:
        return "good_governance";
      case 3:
        return "sanitation";
      case 4:
        return "strengthen_police";
      case 5:
        return "disease";
      default:
        return "";
    }
  }

  List<String> getThemes(int i) {
    var rnd = math.Random();
    var list = List.generate(i, (i) => rnd.nextInt(6)).toSet().toList();
    return list.map((item) => getTheme(item)).toList();
  }

  // test people
  void writePeople() async {
    var rnd = math.Random();

    List.generate(10, (i) {
      int age = rnd.nextInt(47) + 15;
      var people = {
        "id": i.toString(),
        "age": age,
        "age_category": getAgeRange(age),
        "gender": getGender(rnd.nextInt(3)),
        "idp_status": getIDPStatus(rnd.nextInt(3)),
        "location": getLocation(rnd.nextInt(6)),
        "themes": getThemes(rnd.nextInt(4) + 1),
        "messageCount": rnd.nextInt(20) + 2
      };

      _peopleRef.add(people);
    });
  }
}
