class Message {
  String id;
  String text;
  String theme;
  DateTime time;
  bool isResponse;
}

class Person {
  num age;
  String age_category;
  String gender;
  String IDPStatus;
  String location;
  List<String> themes;
  int messageCount;

  Person(this.age, this.age_category, this.gender, this.IDPStatus,
      this.location, this.themes, this.messageCount);

  factory Person.fromObj(Map<String, dynamic> obj) {
    List<String> themes =
        (obj["themes"] as List).map((t) => t.toString()).toList();
    return Person(obj["age"], obj["age_category"], obj["gender"],
        obj["IDPStatus"], obj["location"], themes, obj["messageCount"]);
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

  factory Option.fromObj(Map<String, dynamic> obj) {
    return Option(obj["value"], obj["label"]);
  }
}

class Filter {
  String value;
  String label;
  int order;
  List<Option> options;

  Filter(this.value, this.label, this.order, this.options);

  factory Filter.fromObj(Map<String, dynamic> obj) {
    var options = (obj["options"] as List)
        .map((option) => Option.fromObj(option))
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

  factory Theme.fromObj(Map<String, dynamic> obj) {
    return Theme(obj["value"], obj["label"], obj["order"], obj["color"]);
  }
}

class Selected {
  String _metric;
  String _filter;
  String _option;

  String get metric => _metric;
  String get filter => _filter;
  String get option => _option;

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
}
