import 'dart:html' as html;
import 'dart:svg' as svg;
import 'package:avf/logger.dart';
import 'package:avf/model.dart' as model;
import 'package:avf/firebase.dart' as fb;

Logger logger = Logger("interactive.dart");

const DEFAULT_CHART_WIDTH = 300;
const CHART_HEIGHT = 480;
const CHART_PADDING = 18;
const CHART_XAXIS_HEIGHT = 25;
const SQ_IN_ROW = 6;
const SQ_WIDTH = 12;

const HTML_BODY_SELECTOR = "body";
const ROW_CSS_CLASS = "row";
const CONTAINER_CSS_CLASS = "container";

// Filter CSS classes
const FILTER_COLUMN_CSS_CLASSES = ["col-lg-2", "col-md-4", "col-sm-4", "col-4"];
const FILTER_WRAPPER_CSS_CLASS = "filter-wrapper";
const FILTER_OPTION_CSS_CLASS = "filter-option";

// Chart CSS classes
const CHART_COLUMN_CSS_CLASSES = [
  "col-lg-9",
  "col-md-9",
  "col-sm-12",
  "col-12"
];
const CHART_WRAPPER_CSS_CLASS = "chart-wrapper";
const XAXIS_CSS_CLASS = "x-axis";
const XAXIS_LABEL_CSS_CLASS = "x-axis--label";

// Messages CSS classses
const MESSAGES_COLUMN_CSS_CLASSES = [
  "col-lg-3",
  "col-md-3",
  "col-sm-12",
  "col-12"
];
const MESSAGES_WRAPPER_CSS_CLASS = "messages-wrapper";
const MESSAGE_CSS_CLASS = "message";
const MESSAGES_RESPONSE_CSS_CLASS = "message-response";
const MESSAGES_QUESTION_CSS_CLASS = "message-question";
const PLACEHOLDER_CSS_CLASS = "placeholder";
const MESSAGES_PLACEHOLDER_TEXT =
    "Click on square to view messages between the person and Africa's voices's volunteers.";

// Legend CSS classes
const LEGEND_COLUMN_CSS_CLASSES = ["col-lg-3", "col-md-4", "col-sm-6", "col-6"];
const LEGEND_ITEM_CSS_CLASS = "legend-item";

class Interactive {
  List<model.Filter> _filters;
  List<model.Theme> _themes;
  List<model.Message> _messages;
  List<model.Person> _people;
  num _chartWidth;
  model.Selected _selected;

  html.DivElement _container;
  html.DivElement _filtersWrapper;
  html.DivElement _dataWrapper;
  html.DivElement _chartsColumn;
  html.DivElement _messagesColumn;
  html.DivElement _legendWrapper;

  Interactive(this._container) {
    _chartWidth = _computeChartWidth();
    init();
  }

  init() async {
    await fb.init();
    await _loadFilters();
    await _loadThemes();
    _selected = model.Selected();
    _selected.updateMetric(_filters.first.value);
    await _loadPeople();

    _filtersWrapper = html.DivElement()..classes = [ROW_CSS_CLASS];
    _dataWrapper = html.DivElement()..classes = [ROW_CSS_CLASS];
    _chartsColumn = html.DivElement()..classes = CHART_COLUMN_CSS_CLASSES;
    _messagesColumn = html.DivElement()..classes = MESSAGES_COLUMN_CSS_CLASSES;
    _legendWrapper = html.DivElement()..classes = [ROW_CSS_CLASS];

    _dataWrapper.append(_chartsColumn);
    _dataWrapper.append(_messagesColumn);

    _container.nodes.clear();
    _container.append(_filtersWrapper);
    _container.append(_dataWrapper);
    _container.append(_legendWrapper);

    _renderFilters();
    _renderChart();
    _renderMessages();
    _renderLegend();
  }

  // Utils
  num _computeChartWidth() {
    var width = DEFAULT_CHART_WIDTH;
    var container = html.DivElement()..classes = [CONTAINER_CSS_CLASS];
    var row = html.DivElement()..classes = [ROW_CSS_CLASS];
    var col = html.DivElement()..classes = CHART_COLUMN_CSS_CLASSES;
    var body = html.querySelector(HTML_BODY_SELECTOR);

    container.append(row);
    row.append(col);
    body.append(container);
    width = col.clientWidth;
    container.remove();

    return width;
  }

  String _getThemeColor(String theme) {
    String color = "black";
    _themes.forEach((t) {
      if (t.value == theme) color = t.color;
    });
    return color;
  }

  // Data fetch
  void _loadFilters() async {
    _filters = await fb.readFilters();
    logger.log("${_filters.length} filters loaded");
  }

  void _loadThemes() async {
    _themes = await fb.readThemes();
    logger.log("${_themes.length} themes loaded");
  }

  void _loadPeople() async {
    _people = await fb.readPeople(_selected.filter, _selected.option);
    logger.log("${_people.length} people loaded");
  }

  void _loadMessages(String personID) async {
    _messages = await fb.readMessages(personID);
    logger.log("${_messages.length} messages loaded");
  }

  // User events
  void _updateMetric(String value) async {
    _selected.updateMetric(value);
    await _loadPeople();
    _renderFilters();
    _renderChart();
    _messages = null;
    _renderMessages();
  }

  void _updateFilter(String value) {
    value = value == "null" ? null : value;
    _selected.updateFilter(value);
    _renderFilters();
  }

  void _updateFilterOption(String value) async {
    value = value == "null" ? null : value;
    _selected.updateOption(value);
    await _loadPeople();
    _renderFilters();
    _renderChart();
    _messages = null;
    _renderMessages();
  }

  void handleMouseEnter(svg.SvgElement rect, int sqWidth) {
    rect.parent.append(rect);
    rect
      ..setAttribute(
          "transform", "translate(${-2 * sqWidth}, ${-2 * sqWidth}) scale(2)");
  }

  void handleMouseOut(svg.SvgElement rect) {
    rect..setAttribute("transform", "translate(0, 0) scale(1)");
  }

  // Render
  html.DivElement _getMetricDropdown() {
    var wrapper = html.DivElement()..classes = FILTER_COLUMN_CSS_CLASSES;
    var label = html.LabelElement()..innerText = "View by";
    var select = html.SelectElement()
      ..onChange
          .listen((e) => _updateMetric((e.target as html.SelectElement).value));
    _filters.forEach((filter) {
      var option = html.OptionElement()
        ..value = filter.value
        ..innerText = filter.label
        ..selected = filter.value == _selected.metric;
      select.append(option);
    });

    wrapper.append(label);
    wrapper.append(select);
    return wrapper;
  }

  html.DivElement _getFilterDropdown() {
    var wrapper = html.DivElement()..classes = FILTER_COLUMN_CSS_CLASSES;
    var label = html.LabelElement()..innerText = "Filter by";
    var select = html.SelectElement()
      ..onChange
          .listen((e) => _updateFilter((e.target as html.SelectElement).value));
    var emptyOption = html.OptionElement()
      ..innerText = "--"
      ..value = null
      ..selected = _selected.filter == null;
    select.append(emptyOption);
    _filters.forEach((filter) {
      var option = html.OptionElement()
        ..value = filter.value
        ..innerText = filter.label
        ..selected = filter.value == _selected.filter;
      if (filter.value != _selected.metric) {
        select.append(option);
      }
    });

    wrapper.append(label);
    wrapper.append(select);
    return wrapper;
  }

  html.DivElement _getFilterOptionDropdown() {
    var wrapper = html.DivElement()..classes = FILTER_COLUMN_CSS_CLASSES;
    var label = html.LabelElement()..innerText = ".";
    var select = html.SelectElement()
      ..classes = [FILTER_OPTION_CSS_CLASS]
      ..onChange.listen(
          (e) => _updateFilterOption((e.target as html.SelectElement).value));
    var emptyOption = html.OptionElement()
      ..innerText = "--"
      ..value = null
      ..selected = _selected.option == null;
    select.append(emptyOption);

    var currentFilter =
        _filters.firstWhere((filter) => filter.value == _selected.filter);
    currentFilter.options.forEach((filter) {
      var option = html.OptionElement()
        ..value = filter.value
        ..innerText = filter.label
        ..selected = filter.value == _selected.option;
      select.append(option);
    });

    wrapper.append(label);
    wrapper.append(select);
    return wrapper;
  }

  void _renderFilters() {
    _filtersWrapper.nodes.clear();

    _filtersWrapper.append(_getMetricDropdown());
    _filtersWrapper.append(_getFilterDropdown());
    if (_selected.filter != null) {
      _filtersWrapper.append(_getFilterOptionDropdown());
    }
  }

  void _loadRenderMessages(String personID) async {
    await _loadMessages(personID);
    _renderMessages();
  }

  void _renderChart() {
    _chartsColumn.nodes.clear();

    var wrapper = html.DivElement()..classes = [CHART_WRAPPER_CSS_CLASS];
    var chartWidth = _chartWidth - (4 * CHART_PADDING);

    var svgContainer = svg.SvgSvgElement()
      ..style.width = "${chartWidth}px"
      ..style.height = "${CHART_HEIGHT}px";

    var xAxisLine = svg.LineElement()
      ..classes = [XAXIS_CSS_CLASS]
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
        ..classes = [XAXIS_LABEL_CSS_CLASS]
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
      List<model.Person> colData = peopleByLabel[xAxisCategories[i].value]
          .map((t) => model.Person(t.id, t.age, t.ageCategory, t.gender,
              t.idpStatus, t.location, t.themes, t.messageCount))
          .toList();
      colData.sort(
          (p1, p2) => p1.themes.toString().compareTo(p2.themes.toString()));

      num colOffsetPx = (i + 0.5) * (chartWidth / xAxisCategories.length);

      for (var j = 0; j < colData.length; ++j) {
        num x = (j % SQ_IN_ROW - (SQ_IN_ROW / 2)) * SQ_WIDTH + colOffsetPx;
        num y = (CHART_HEIGHT - CHART_XAXIS_HEIGHT - (1.5 * SQ_WIDTH)) -
            (j / SQ_IN_ROW).floor() * SQ_WIDTH;
        num xOrigin = x - (1.5 * SQ_WIDTH);
        num yOrigin = y - (1.5 * SQ_WIDTH);

        var sqGroup = svg.SvgElement.tag("g")
          ..setAttribute("transform-origin", "$xOrigin $yOrigin")
          ..onClick.listen((e) => _loadRenderMessages(colData[j].id))
          ..onMouseEnter
              .listen((e) => this.handleMouseEnter(e.currentTarget, SQ_WIDTH))
          ..onMouseOut.listen((e) => this.handleMouseOut(e.currentTarget));

        var themes = colData[j].themes;
        String primaryTheme = themes.first;
        var square = svg.RectElement()
          ..setAttribute("x", x.toString())
          ..setAttribute("y", y.toString())
          ..setAttribute("width", SQ_WIDTH.toString())
          ..setAttribute("height", SQ_WIDTH.toString())
          ..setAttribute("fill", _getThemeColor(primaryTheme))
          ..setAttribute("stroke", "white")
          ..setAttribute("stroke-width", "2");
        sqGroup.append(square);

        if (themes.length > 1) {
          String secondaryTheme = themes[1];
          var circle = svg.CircleElement()
            ..setAttribute("cx", (x + (SQ_WIDTH / 2)).toString())
            ..setAttribute("cy", (y + (SQ_WIDTH / 2)).toString())
            ..setAttribute("r", (SQ_WIDTH / 6).toString())
            ..setAttribute("fill", _getThemeColor(secondaryTheme))
            ..setAttribute("pointer-events", "none");
          sqGroup.append(circle);
        }

        colSVG.append(sqGroup);
      }

      svgContainer.append(colSVG);
    }

    wrapper..append(svgContainer);
    _chartsColumn.append(wrapper);
  }

  void _renderMessages() {
    _messagesColumn.nodes.clear();
    var wrapper = html.DivElement()..classes = [MESSAGES_WRAPPER_CSS_CLASS];

    if (_messages == null) {
      var placeholderText = html.ParagraphElement()
        ..classes = [PLACEHOLDER_CSS_CLASS]
        ..appendText(MESSAGES_PLACEHOLDER_TEXT);
      wrapper.append(placeholderText);
      _messagesColumn.append(wrapper);
      return;
    }

    wrapper.style.height = (CHART_HEIGHT + 2 * CHART_PADDING).toString() + "px";
    wrapper.children.clear();

    for (var message in _messages) {
      var text = message.text;
      var msgClass = MESSAGES_RESPONSE_CSS_CLASS;
      if (message.isResponse == false) {
        text = "AVF: $text";
        msgClass = MESSAGES_QUESTION_CSS_CLASS;
      }
      var messageDiv = html.DivElement()
        ..appendText(text)
        ..classes = [MESSAGE_CSS_CLASS, msgClass]
        ..style.borderLeftColor = message.theme != null
            ? "${_getThemeColor(message.theme)}"
            : "white";
      wrapper.append(messageDiv);
    }

    _messagesColumn.append(wrapper);
  }

  void _renderLegend() {
    _legendWrapper.nodes.clear();
    _themes.forEach((theme) {
      var legendColumn = html.DivElement()..classes = LEGEND_COLUMN_CSS_CLASSES;
      var legendColor = html.LabelElement()
        ..classes = [LEGEND_ITEM_CSS_CLASS]
        ..innerText = theme.label
        ..style.borderLeftColor = theme.color;
      legendColumn.append(legendColor);

      _legendWrapper.append(legendColumn);
    });
  }
}
