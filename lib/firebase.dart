import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart' as fs;

class DB {
  fs.DocumentReference _filtersRef;

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
  }

  Future<Map<String, dynamic>> readFilters() async {
    var snapshot = await _filtersRef.get();
    return snapshot.data();
  }

  // test filters
  void writeFilter() async {
    var filters = {
      "age": {
        "value": "age",
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
}
