import 'dart:html' as html;
import 'dart:svg' as svg;
import 'package:avf/logger.dart';
import 'package:avf/model.dart' as model;
import 'package:avf/firebase.dart' as fb;

Logger logger = Logger("interactive.dart");

const BS_ROW_CSS = "row";
const BS_CONTAINER_CSS = "container";
const filterColumnCSS = ["col-lg-3", "col-md-4", "col-sm-4", "col-4"];
const chartColumnCSS = ["col-lg-9", "col-md-9", "col-sm-12", "col-12"];
const messagesColumnCSS = ["col-lg-3", "col-md-3", "col-sm-12", "col-12"];
const themeColumnCSS = ["col-lg-3", "col-md-4", "col-sm-6", "col-6"];

const DEFAULT_CHART_WIDTH = 300;
const CHART_PADDING = 18;
const CHART_HEIGHT = 480;
const CHART_XAXIS_HEIGHT = 25;

const HTML_BODY_SELECTOR = "body";
const FILTER_WRAPPER_CSS = "filter-wrapper";
const FILTER_OPTION_CSS = "filter-option";
const CHART_WRAPPER_CSS = "chart-wrapper";
const MESSAGES_WRAPPER_CSS = "messages-wrapper";
const PLACEHOLDER_CSS = "placeholder";
const XAXIS_CSS = "x-axis";
const XAXIS_LABEL_CSS = "x-axis--label";
const LEGEND_ITEM_CSS = "legend-item";

const MESSAGES_PLACEHOLDER_CSS =
    "Click on square to view messages between the person and Africa's voices's volunteers.";

// to do: make this configurable based on number of people
const SQ_IN_ROW = 6;
const SQ_SIZE = 12;

class Interactive {
  List<model.Filter> _filters;
  List<model.Theme> _themes;
  List<model.Message> _messages;
  List<model.Person> _people;
  num _chartWidth;
  model.Selected _selected = model.Selected();

  html.DivElement _container;

  Interactive(this._container) {
    _chartWidth = _gatherChartWidth();
    init();
  }

  init() async {
    await fb.init();
    _loadFilters();
  }

  num _gatherChartWidth() {
    var width = DEFAULT_CHART_WIDTH;
    var container = html.DivElement()..classes = [BS_CONTAINER_CSS];
    var row = html.DivElement()..classes = [BS_ROW_CSS];
    var col = html.DivElement()..classes = chartColumnCSS;
    var body = html.querySelector(HTML_BODY_SELECTOR);

    container.append(row);
    row.append(col);
    body.append(container);
    width = col.clientWidth;
    container.remove();

    return width;
  }

  void _loadFilters() async {
    _filters = await fb.readFilters();
    _themes = await fb.readThemes();
    _selected.updateMetric(_filters.first.value);
    await _loadPeople();
    _render();
  }

  void _updateMetric(String value) async {
    _selected.updateMetric(value);
    await _loadPeople();
    _render();
  }

  void _updateFilter(String value) {
    value = value == "null" ? null : value;
    _selected.updateFilter(value);
    _render();
  }

  void _updateFilterOption(String value) async {
    value = value == "null" ? null : value;
    _selected.updateOption(value);
    await _loadPeople();
    _render();
  }

  void _loadPeople() async {
    _people = await fb.readPeople(_selected.filter, _selected.option);
    logger.log("${_people.length} people loaded");
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
      ..value = null
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
      ..classes = [FILTER_OPTION_CSS]
      ..onChange.listen(
          (e) => _updateFilterOption((e.target as html.SelectElement).value));
    var emptyOption = html.OptionElement()
      ..innerText = "--"
      ..value = null
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

  html.DivElement _renderChart() {
    var chartWrapper = html.DivElement()..classes = [CHART_WRAPPER_CSS];
    var chartWidth = _chartWidth - 4 * CHART_PADDING;

    var svgContainer = svg.SvgSvgElement()
      ..style.width = "${chartWidth}px"
      ..style.height = "${CHART_HEIGHT}px";

    var xAxisLine = svg.LineElement()
      ..classes = [XAXIS_CSS]
      ..setAttribute("x1", "0")
      ..setAttribute("y1", "${CHART_HEIGHT - CHART_XAXIS_HEIGHT}")
      ..setAttribute("x2", "${chartWidth}")
      ..setAttribute("y2", "${CHART_HEIGHT - CHART_XAXIS_HEIGHT}");
    svgContainer.append(xAxisLine);

    var peopleByLabel = Map<String, List<model.Person>>();

    var xAxisCategories = _filters
        .firstWhere((filter) => filter.value == _selected.metric)
        .options;
    for (var i = 0; i < xAxisCategories.length; ++i) {
      var text = svg.TextElement()
        ..appendText(xAxisCategories[i].label)
        ..classes = [XAXIS_LABEL_CSS]
        ..setAttribute(
            "x", "${(i + 0.5) * (chartWidth / xAxisCategories.length)}")
        ..setAttribute("y", "${CHART_HEIGHT - CHART_XAXIS_HEIGHT / 4}");
      svgContainer.append(text);

      peopleByLabel[xAxisCategories[i].value] = List();
    }

    _people.forEach((people) {
      var key;
      switch (_selected.metric) {
        case "age_category":
          key = people.ageCategory;
          break;
        case "gender":
          key = people.gender;
          break;
        case "idp_status":
          key = people.idpStatus;
          break;
        default:
          logger.error("Selected metric ${_selected.metric} not found");
      }
      peopleByLabel[key].add(people);
    });

    for (var i = 0; i < xAxisCategories.length; ++i) {
      var colSVG = svg.SvgElement.tag("g");

      // cloning list of people to sort
      var colData = peopleByLabel[xAxisCategories[i].value]
          .map((t) => model.Person(t.age, t.ageCategory, t.gender, t.idpStatus,
              t.location, t.themes, t.messageCount))
          .toList();
      colData.sort(
          (p1, p2) => p1.themes.toString().compareTo(p2.themes.toString()));

      num colOffset = (i + 0.5) * (chartWidth / xAxisCategories.length);

      for (var j = 0; j < colData.length; ++j) {
        num x = (j % SQ_IN_ROW - SQ_IN_ROW / 2) * SQ_SIZE + colOffset;
        num y = (CHART_HEIGHT - CHART_XAXIS_HEIGHT - 1.5 * SQ_SIZE) -
            (j / SQ_IN_ROW).truncate() * SQ_SIZE;
        num xOrigin = x - 1.5 * SQ_SIZE;
        num yOrigin = y - 1.5 * SQ_SIZE;

        var sqGroup = svg.SvgElement.tag("g")
          ..setAttribute("transform-origin", "$xOrigin $yOrigin")
          ..onMouseEnter
              .listen((e) => this.handleMouseEnter(e.currentTarget, SQ_SIZE))
          ..onMouseOut.listen((e) => this.handleMouseOut(e.currentTarget));

        var themes = colData[j].themes;
        var square = svg.RectElement()
          ..setAttribute("x", x.toString())
          ..setAttribute("y", y.toString())
          ..setAttribute("width", SQ_SIZE.toString())
          ..setAttribute("height", SQ_SIZE.toString())
          ..setAttribute("fill", _getThemeColor(themes.first))
          ..setAttribute("stroke", "white")
          ..setAttribute("stroke-width", "2");
        sqGroup.append(square);

        if (themes.length > 1) {
          var circle = svg.CircleElement()
            ..setAttribute("cx", (x + SQ_SIZE / 2).toString())
            ..setAttribute("cy", (y + SQ_SIZE / 2).toString())
            ..setAttribute("r", (SQ_SIZE / 6).toString())
            ..setAttribute("fill", _getThemeColor(themes[1]))
            ..setAttribute("pointer-events", "none");
          sqGroup.append(circle);
        }

        colSVG.append(sqGroup);
      }

      svgContainer.append(colSVG);
    }

    return chartWrapper..append(svgContainer);
  }

  void handleMouseEnter(svg.SvgElement rect, int w) {
    rect.parent.append(rect);
    rect..setAttribute("transform", "translate(${-2 * w}, ${-2 * w}) scale(2)");
  }

  void handleMouseOut(svg.SvgElement rect) {
    rect..setAttribute("transform", "translate(0, 0) scale(1)");
  }

  String _getThemeColor(String theme) {
    String color = "black";
    _themes.forEach((t) {
      if (t.value == theme) color = t.color;
    });
    return color;
  }

  html.DivElement _renderLegend() {
    var legendWrapper = html.DivElement()..classes = [BS_ROW_CSS];
    _themes.forEach((theme) {
      var legendColumn = html.DivElement()..classes = themeColumnCSS;
      var legendColor = html.LabelElement()
        ..classes = [LEGEND_ITEM_CSS]
        ..innerText = theme.label
        ..style.borderLeftColor = theme.color;
      legendColumn.append(legendColor);

      legendWrapper.append(legendColumn);
    });

    return legendWrapper;
  }

  html.DivElement _renderMessages() {
    var messagesWrapper = html.DivElement()..classes = [MESSAGES_WRAPPER_CSS];
    if (_messages == null) {
      var placeholderText = html.ParagraphElement()
        ..classes = [PLACEHOLDER_CSS]
        ..appendText(MESSAGES_PLACEHOLDER_CSS);
      messagesWrapper.append(placeholderText);
    }
    return messagesWrapper;
  }

  void _render() {
    var filtersWrapper = html.DivElement()
      ..classes = [BS_ROW_CSS, FILTER_WRAPPER_CSS];
    filtersWrapper.append(_renderMetricDropdown());
    filtersWrapper.append(_renderFilterDropdown());
    if (_selected.filter != null) {
      filtersWrapper.append(_renderFilterOptionDropdown());
    }

    var chartMessageRow = html.DivElement()..classes = [BS_ROW_CSS];
    var chartColumn = html.DivElement()..classes = chartColumnCSS;
    var messageColumn = html.DivElement()..classes = messagesColumnCSS;
    chartMessageRow.append(chartColumn);
    chartColumn.append(_renderChart());
    chartMessageRow.append(messageColumn);
    messageColumn.append(_renderMessages());

    _container.children.clear();
    _container.append(filtersWrapper);
    _container.append(chartMessageRow);
    _container.append(_renderLegend());
  }
}
