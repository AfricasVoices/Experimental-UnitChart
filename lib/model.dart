import 'dart:core';

class Message {
  String id;
  String text;
  String theme;
  DateTime time;
  bool isResponse;

  Message(this.id, this.text, this.theme, this.time, this.isResponse);

  factory Message.fromFirebaseMap(Map<String, dynamic> obj) {
    return Message(obj["id"].toString(), obj["text"], obj["theme"], obj["time"],
        obj["is_response"]);
  }
}

class Person {
  String id;
  num age;
  String ageCategory;
  String gender;
  String idpStatus;
  String location;
  List<String> themes;
  int messageCount;

  Person(this.id, this.age, this.ageCategory, this.gender, this.idpStatus,
      this.location, this.themes, this.messageCount);

  factory Person.fromFirebaseMap(Map<String, dynamic> obj) {
    var age = int.tryParse(obj["age"]);
    if (age == null) age = -1;

    List<String> themes =
        (obj["themes"] as List).map((t) => t.toString()).toList();
    return Person(obj["id"], age, obj["age_category"], obj["gender"],
        obj["idp_status"], obj["location"], themes, obj["messageCount"]);
  }
}

class UnitChart {
  String title;
  String subtitle;
  String note;
  List<String> axisLabels;
  List<List<Person>> data;
}

class Option {
  String value;
  String label;

  Option(this.value, this.label);

  factory Option.fromFirebaseMap(Map<String, dynamic> obj) {
    return Option(obj["value"], obj["label"]);
  }
}

class Filter {
  String value;
  String label;
  int order;
  List<Option> options;

  Filter(this.value, this.label, this.order, this.options);

  factory Filter.fromFirebaseMap(Map<String, dynamic> obj) {
    var options = (obj["options"] as List)
        .map((option) => Option.fromFirebaseMap(option))
        .toList();
    return Filter(obj["value"], obj["label"], obj["order"], options);
  }
}

class Theme {
  String value;
  String label;
  int order;
  String color;

  Theme(this.value, this.label, this.order, this.color);

  factory Theme.fromFirebaseMap(Map<String, dynamic> obj) {
    return Theme(obj["value"], obj["label"], obj["order"], obj["color"]);
  }
}

class Selected {
  String _metric;
  String _filter;
  String _option;
  String _personID;

  String get metric => _metric;
  String get filter => _filter;
  String get option => _option;
  String get personID => _personID;

  void updateMetric(metric) {
    if (_metric == metric) return;
    _metric = metric;
    _filter = null;
    _option = null;
  }

  void updateFilter(filter) {
    if (_filter == filter) return;
    _filter = filter;
    _option = null;
  }

  void updateOption(option) {
    if (_option == option) return;
    _option = option;
  }

  void updatePerson(personID) {
    _personID = personID;
  }
}
