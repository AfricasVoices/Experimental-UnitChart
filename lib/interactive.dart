import 'dart:html' as html;
import 'dart:svg' as svg;
import 'package:avf/logger.dart';
import 'package:avf/model.dart' as model;
import 'package:avf/firebase.dart' as fb;

Logger logger = Logger("interactive.dart");

const ROW_CSS_CLASS = "row";
const CONTAINER_CSS_CLASS = "container";
const FILTER_COLUMN_CSS_CLASSES = ["col-lg-3", "col-md-4", "col-sm-4", "col-4"];
const CHART_COLUMN_CSS_CLASSES = [
  "col-lg-9",
  "col-md-9",
  "col-sm-12",
  "col-12"
];
const MESSAGES_COLUMN_CSS_CLASSES = [
  "col-lg-3",
  "col-md-3",
  "col-sm-12",
  "col-12"
];
const THEME_COLUMN_CSS_CLASSES = ["col-lg-3", "col-md-4", "col-sm-6", "col-6"];

const DEFAULT_CHART_WIDTH = 300;
const CHART_PADDING = 18;
const CHART_HEIGHT = 480;
const CHART_XAXIS_HEIGHT = 25;

const HTML_BODY_SELECTOR = "body";
const FILTER_WRAPPER_CSS_CLASS = "filter-wrapper";
const FILTER_OPTION_CSS_CLASS = "filter-option";
const CHART_WRAPPER_CSS_CLASS = "chart-wrapper";
const MESSAGES_WRAPPER_CSS_CLASS = "messages-wrapper";
const MESSAGE_CSS_CLASS = "message";
const MESSAGES_RESPONSE_CSS_CLASS = "message-response";
const MESSAGES_QUESTION_CSS_CLASS = "message-question";
const PLACEHOLDER_CSS_CLASS = "placeholder";
const XAXIS_CSS_CLASS = "x-axis";
const XAXIS_LABEL_CSS_CLASS = "x-axis--label";
const LEGEND_ITEM_CSS_CLASS = "legend-item";

const MESSAGES_PLACEHOLDER_TEXT =
    "Click on square to view messages between the person and Africa's voices's volunteers.";

// to do: make this configurable based on number of people
const SQ_IN_ROW = 6;
const SQ_WIDTH = 12;

class Interactive {
  List<model.Filter> _filters;
  List<model.Theme> _themes;
  List<model.Message> _messages;
  List<model.Person> _people;
  num _chartWidth;
  model.Selected _selected = model.Selected();

  html.DivElement _container;

  Interactive(this._container) {
    _chartWidth = _computeChartWidth();
    init();
  }

  init() async {
    await fb.init();
    _loadFilters();
  }

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

  void _loadMessages(String id) async {
    _messages = await fb.readMessages(id);
    logger.log("${_messages.length} messages loaded");
    _renderMessages();
  }

  html.DivElement _renderMetricDropdown() {
    var metricWrapper = html.DivElement()..classes = FILTER_COLUMN_CSS_CLASSES;
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
    var filterWrapper = html.DivElement()..classes = FILTER_COLUMN_CSS_CLASSES;
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
    var filterOptionWrapper = html.DivElement()
      ..classes = FILTER_COLUMN_CSS_CLASSES;
    var filterOptionLabel = html.LabelElement()..innerText = ".";
    var filterOptionSelect = html.SelectElement()
      ..classes = [FILTER_OPTION_CSS_CLASS]
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
    var chartWrapper = html.DivElement()..classes = [CHART_WRAPPER_CSS_CLASS];
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
          ..onClick.listen((e) => this._loadMessages(colData[j].id))
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

    return chartWrapper..append(svgContainer);
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

  String _getThemeColor(String theme) {
    String color = "black";
    _themes.forEach((t) {
      if (t.value == theme) color = t.color;
    });
    return color;
  }

  html.DivElement _renderLegend() {
    var legendWrapper = html.DivElement()..classes = [ROW_CSS_CLASS];
    _themes.forEach((theme) {
      var legendColumn = html.DivElement()..classes = THEME_COLUMN_CSS_CLASSES;
      var legendColor = html.LabelElement()
        ..classes = [LEGEND_ITEM_CSS_CLASS]
        ..innerText = theme.label
        ..style.borderLeftColor = theme.color;
      legendColumn.append(legendColor);

      legendWrapper.append(legendColumn);
    });

    return legendWrapper;
  }

  html.DivElement _renderMessages() {
    if (_messages == null) {
      var messagesWrapper = html.DivElement()
        ..classes = [MESSAGES_WRAPPER_CSS_CLASS];
      var placeholderText = html.ParagraphElement()
        ..classes = [PLACEHOLDER_CSS_CLASS]
        ..appendText(MESSAGES_PLACEHOLDER_TEXT);
      messagesWrapper.append(placeholderText);
      return messagesWrapper;
    }

    var wrapper = html.querySelector("#$MESSAGES_WRAPPER_CSS_CLASS");
    wrapper.classes.toggle(MESSAGES_WRAPPER_CSS_CLASS, true);
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
    return wrapper;
  }

  void _render() {
    var filtersWrapper = html.DivElement()
      ..classes = [ROW_CSS_CLASS, FILTER_WRAPPER_CSS_CLASS];
    filtersWrapper.append(_renderMetricDropdown());
    filtersWrapper.append(_renderFilterDropdown());
    if (_selected.filter != null) {
      filtersWrapper.append(_renderFilterOptionDropdown());
    }

    var chartMessageRow = html.DivElement()..classes = [ROW_CSS_CLASS];
    var chartColumn = html.DivElement()..classes = CHART_COLUMN_CSS_CLASSES;
    var messageColumn = html.DivElement()
      ..classes = MESSAGES_COLUMN_CSS_CLASSES;
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
