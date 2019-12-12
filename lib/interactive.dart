import 'dart:html' as html;
import 'package:avf/model.dart' as model;
import 'package:avf/firebase.dart';

const filterColumnCSS = ["col-lg-3", "col-md-4", "col-sm-4", "col-4"];
const themeColumnCSS = ["col-lg-3", "col-md-4", "col-sm-6", "col-6"];

class Interactive {
  DB _db;
  List<model.Filter> _filters;
  List<model.Theme> _themes;
  List<model.Person> _people;
  model.Selected _selected = model.Selected();

  html.DivElement _container;

  Interactive(this._container) {
    _db = DB();
    _loadInitialData();
  }

  void _loadInitialData() async {
    var filtersObj = await _db.readFilters();
    _filters = filtersObj.values.map((v) => model.Filter.fromObj(v)).toList()
      ..sort((f1, f2) => f1.order.compareTo(f2.order));
    _selected.updateMetric(_filters.first.value);

    var themesObj = await _db.readThemes();
    _themes = themesObj.values.map((v) => model.Theme.fromObj(v)).toList()
      ..sort((t1, t2) => t1.order.compareTo(t2.order));

    var peopleList = await _db.readPeople();
    _people = peopleList.map((p) => model.Person.fromObj(p)).toList();

    _render();
  }

  void _updateMetric(String value) {
    _selected.updateMetric(value);
    _render();
  }

  void _updateFilter(String value) {
    value = value == "null" ? null : value;
    _selected.updateFilter(value);
    _render();
  }

  void _updateFilterOption(String value) {
    value = value == "null" ? null : value;
    _selected.updateOption(value);
    _render();
  }

  html.DivElement _renderMetricDropdown() {
    var metricWrapper = html.DivElement()..classes = filterColumnCSS;
    var metricLabel = html.LabelElement()..innerText = "View by";
    var metricSelect = html.SelectElement()
      ..onChange
          .listen((e) => _updateMetric((e.target as html.SelectElement).value));
    _filters.forEach((filter) {
      var metricOption = html.OptionElement()
        ..value = filter.value
        ..innerText = filter.label
        ..selected = filter.value == _selected.metric;
      metricSelect.append(metricOption);
    });

    metricWrapper.append(metricLabel);
    metricWrapper.append(metricSelect);
    return metricWrapper;
  }

  html.DivElement _renderFilterDropdown() {
    var filterWrapper = html.DivElement()..classes = filterColumnCSS;
    var filterLabel = html.LabelElement()..innerText = "Filter by";
    var filterSelect = html.SelectElement()
      ..onChange
          .listen((e) => _updateFilter((e.target as html.SelectElement).value));
    var emptyOption = html.OptionElement()
      ..innerText = "--"
      ..selected = _selected.filter == null;
    filterSelect.append(emptyOption);
    _filters.forEach((filter) {
      var filterOption = html.OptionElement()
        ..value = filter.value
        ..innerText = filter.label
        ..selected = filter.value == _selected.filter;
      if (filter.value != _selected.metric) {
        filterSelect.append(filterOption);
      }
    });

    filterWrapper.append(filterLabel);
    filterWrapper.append(filterSelect);
    return filterWrapper;
  }

  html.DivElement _renderFilterOptionDropdown() {
    var filterOptionWrapper = html.DivElement()..classes = filterColumnCSS;
    var filterOptionLabel = html.LabelElement()..innerText = ".";
    var filterOptionSelect = html.SelectElement()
      ..classes = ["filter-option"]
      ..onChange.listen(
          (e) => _updateFilterOption((e.target as html.SelectElement).value));
    var emptyOption = html.OptionElement()
      ..innerText = "--"
      ..selected = _selected.option == null;
    filterOptionSelect.append(emptyOption);

    var currentFilter =
        _filters.firstWhere((filter) => filter.value == _selected.filter);
    currentFilter.options.forEach((filter) {
      var filterOption = html.OptionElement()
        ..value = filter.value
        ..innerText = filter.label
        ..selected = filter.value == _selected.option;
      filterOptionSelect.append(filterOption);
    });

    filterOptionWrapper.append(filterOptionLabel);
    filterOptionWrapper.append(filterOptionSelect);
    return filterOptionWrapper;
  }

  html.DivElement _renderLegend() {
    var legendWrapper = html.DivElement()..classes = ["row"];
    _themes.forEach((theme) {
      var legendColumn = html.DivElement()..classes = themeColumnCSS;
      var legendColor = html.LabelElement()
        ..className = "legend-item"
        ..innerText = theme.label
        ..style.borderLeftColor = theme.color;
      legendColumn.append(legendColor);

      legendWrapper.append(legendColumn);
    });

    return legendWrapper;
  }

  void _render() {
    print("render ${_selected.metric} ${_selected.filter} ${_selected.option}");

    var filtersWrapper = html.DivElement()..classes = ["row", "filter-wrapper"];
    filtersWrapper.append(_renderMetricDropdown());
    filtersWrapper.append(_renderFilterDropdown());
    if (_selected.filter != null) {
      filtersWrapper.append(_renderFilterOptionDropdown());
    }

    _container.children.clear();
    _container.append(filtersWrapper);
    _container.append(_renderLegend());
  }
}
