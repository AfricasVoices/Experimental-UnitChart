library firebase.constants;

import 'dart:convert';
import 'dart:html';

void init() async {
  if (_constants != null) return;

  var constantsJson = await HttpRequest.getString(_constantsFilePath);
  _constants = (json.decode(constantsJson) as Map).map<String, String>(
      (key, value) => MapEntry(key.toString(), value.toString()));
}

String _constantsFilePath = 'assets/firebase_constants.json';
Map<String, String> _constants;

String get apiKey => _constants['apiKey'];
String get authDomain => _constants['authDomain'];
String get databaseURL => _constants['databaseURL'];
String get projectId => _constants['projectId'];
String get storageBucket => _constants['storageBucket'];
String get messagingSenderId => _constants['messagingSenderId'];
String get appId => _constants['appId'];
String get chartCollection => _constants['chartCollection'];
String get filtersDoc => _constants['filtersDoc'];
String get themesDoc => _constants['themesDoc'];
String get dataDoc => _constants['dataDoc'];
String get peopleCollection => _constants['peopleCollection'];
String get messagesCollection => _constants['messagesCollection'];
