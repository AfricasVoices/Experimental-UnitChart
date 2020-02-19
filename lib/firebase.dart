import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' as firestore;
import 'firebase_constants.dart' as fb_constants;
import 'package:avf/model.dart' as model;
import 'package:avf/logger.dart';
import 'package:avf/colorUtil.dart' as util;

Logger logger = Logger("firebase.dart");

firestore.DocumentReference _filtersRef;
firestore.DocumentReference _themesRef;
firestore.DocumentReference _metacodesRef;
firestore.CollectionReference _peopleRef;
firestore.CollectionReference _messagesRef;

firebase.Auth get firebaseAuth => firebase.auth();

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
  _metacodesRef = _store
      .collection(fb_constants.chartCollection)
      .doc(fb_constants.metacodesDoc);
  _peopleRef = _store
      .collection(fb_constants.chartCollection)
      .doc(fb_constants.dataDoc)
      .collection(fb_constants.peopleCollection);
  _messagesRef = _store
      .collection(fb_constants.chartCollection)
      .doc(fb_constants.dataDoc)
      .collection(fb_constants.messagesCollection);
}

// Auth login and logout
Future<firebase.UserCredential> signInWithGoogle() async {
  var provider = firebase.GoogleAuthProvider();
  return firebaseAuth.signInWithPopup(provider);
}

void signOut() {
  firebaseAuth.signOut();
}

void deleteUser() async {
  await firebaseAuth.currentUser.delete();
  logger.log("User deleted and signed out");
}

// Read data
Future<List<model.Filter>> readFilters() async {
  var snapshot = await _filtersRef.get();
  return snapshot
      .data()
      .values
      .map((v) => model.Filter.fromFirebaseMap(v))
      .toList()
        ..sort((f1, f2) => f1.order.compareTo(f2.order));
}

Future<List<model.Theme>> readThemes() async {
  var snapshot = await _themesRef.get();
  var themes = snapshot
      .data()
      .values
      .map((v) => model.Theme.fromFirebaseMap(v))
      .toList()
        ..sort((t1, t2) => t1.order.compareTo(t2.order));
  return util.addColorsToTheme(themes);
}

Future<List<model.Theme>> readMetacodes() async {
  var snapshot = await _metacodesRef.get();
  var themes = snapshot
      .data()
      .values
      .map((v) => model.Theme.fromFirebaseMap(v))
      .toList()
        ..sort((t1, t2) => t1.order.compareTo(t2.order));
  return util.addColorsToTheme(themes);
}

Future<List<model.Person>> readPeople(String filter, String option) async {
  var queryRef;
  if (filter != null && option != null) {
    queryRef = _peopleRef.where(filter, "==", option);
  }

  var querySnapshot =
      await (queryRef != null ? queryRef.get() : _peopleRef.get());
  List peopleList = List();
  querySnapshot.forEach((doc) {
    peopleList.add(doc.data());
  });

  return peopleList.map((v) => model.Person.fromFirebaseMap(v)).toList();
}

Future<List<model.Message>> readMessages(String personID) async {
  // personID is same ID for identifying messages
  var snapshot = await _messagesRef.doc(personID).get();
  return (snapshot.data()[fb_constants.messagesCollection] as List)
      .map((message) => model.Message.fromFirebaseMap(message))
      .toList();
}
