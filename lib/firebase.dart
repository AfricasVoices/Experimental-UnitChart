import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' as firestore;
import 'firebase_constants.dart' as fb_constants;

firestore.DocumentReference _filtersRef;

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
}

Future<Map<String, dynamic>> readFilters() async {
  var snapshot = await _filtersRef.get();
  return snapshot.data();
}
