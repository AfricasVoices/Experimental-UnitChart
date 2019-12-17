import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' as firestore;
import 'firebase_constants.dart' as fb_constants;
import 'package:avf/model.dart' as model;

firestore.DocumentReference _filtersRef;
firestore.DocumentReference _themesRef;
firestore.CollectionReference _peopleRef;

init() async {
  await fb_constants.init();

  firebase.initializeApp(
      apiKey: fb_constants.apiKey,
      authDomain: fb_constants.authDomain,
      databaseURL: fb_constants.databaseURL,
      projectId: fb_constants.projectId,
      storageBucket: fb_constants.storageBucket,
      messagingSenderId: fb_constants.messagingSenderId,
      appId: fb_constants.appId);

  firestore.Firestore _store = firebase.firestore();
  _filtersRef = _store
      .collection(fb_constants.chartCollection)
      .doc(fb_constants.filtersDoc);
  _themesRef = _store
      .collection(fb_constants.chartCollection)
      .doc(fb_constants.themesDoc);
  _peopleRef = _store
      .collection(fb_constants.chartCollection)
      .doc(fb_constants.dataDoc)
      .collection(fb_constants.peopleCollection);
}

Future<List<model.Filter>> readFilters() async {
  var snapshot = await _filtersRef.get();
  return snapshot.data().values.map((v) => model.Filter.fromObj(v)).toList()
    ..sort((f1, f2) => f1.order.compareTo(f2.order));
}

Future<List<model.Theme>> readThemes() async {
  var snapshot = await _themesRef.get();
  return snapshot.data().values.map((v) => model.Theme.fromObj(v)).toList()
    ..sort((t1, t2) => t1.order.compareTo(t2.order));
}

Future<List<model.Person>> readPeople() async {
  var snapshot = await _peopleRef.get();
  List<Map<String, dynamic>> peopleList = [];
  snapshot.forEach((doc) => peopleList.add(doc.data()));
  return peopleList.map((p) => model.Person.fromObj(p)).toList();
}
