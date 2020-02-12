import 'dart:html' as html;
import 'dart:svg' as svg;
import 'package:avf/logger.dart';
import 'package:avf/model.dart' as model;
import 'package:avf/firebase.dart' as fb;
import 'dart:js' as js;

Logger logger = Logger("interactive.dart");

const DEFAULT_CHART_WIDTH = 300;
const MIN_CHART_WIDTH = 600;
const CHART_HEIGHT = 480;
const CHART_PADDING = 18;
const CHART_XAXIS_HEIGHT = 25;
const TOOLTIP_OFFSET = 25;
var SQ_IN_ROW = 12;
const SQ_WIDTH = 8;
const SPACE_BTWN_SQ = 1;

const HTML_BODY_SELECTOR = "body";
const ROW_CSS_CLASS = "row";
const CONTAINER_CSS_CLASS = "container";
const ANIMATE_BLINK_CSS_CLASS = "blink";

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
const CHART_TOOLTIP_CSS_CLASS = "tool-tip";

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
const CHART_LOADING_PLACEHOLDER_TEXT = "Loading interactive chart data...";
const CHART_CLEAR_PLACEHOLDER_TEXT = "Interactive chart cleared";
const MESSAGES_LABEL = "Messages";
const MESSAGES_PLACEHOLDER_TEXT =
    "Click on square to view messages between the person and Africa's voices's team.";

// Legend CSS classes
const LEGEND_COLUMN_CSS_CLASSES = ["col-lg-3", "col-md-4", "col-sm-6", "col-6"];
const LEGEND_ITEM_CSS_CLASS = "legend-item";
const CAPITALISE_TEXT_CSS_CLASS = "capitalise-text";

class Interactive {
  List<model.Filter> _filters;
  List<model.Theme> _themes;
  List<model.Message> _messages;
  List<model.Person> _people;
  num _chartWidth;
  model.Selected _selected;
  int _chartScrollLeft = 0;

  html.DivElement _container;
  html.SpanElement _tooltip;
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
    _container.nodes.clear();
    var placeholder = html.ParagraphElement()
      ..classes = [ANIMATE_BLINK_CSS_CLASS]
      ..appendText(CHART_LOADING_PLACEHOLDER_TEXT);
    _container.append(placeholder);

    await _loadFilters();
    await _loadThemes();
    _selected = model.Selected();
    _selected.updateMetric(_filters.first.value);
    await _loadPeople();

    _filtersWrapper = html.DivElement()
      ..classes = [ROW_CSS_CLASS, FILTER_WRAPPER_CSS_CLASS];
    _dataWrapper = html.DivElement()..classes = [ROW_CSS_CLASS];
    _chartsColumn = html.DivElement()..classes = CHART_COLUMN_CSS_CLASSES;
    _messagesColumn = html.DivElement()..classes = MESSAGES_COLUMN_CSS_CLASSES;
    _tooltip = html.SpanElement()
      ..classes = [CHART_TOOLTIP_CSS_CLASS]
      ..setAttribute("hidden", "true");
    _legendWrapper = html.DivElement()..classes = [ROW_CSS_CLASS];

    _dataWrapper.append(_chartsColumn);
    _dataWrapper.append(_messagesColumn);
    _dataWrapper.append(_tooltip);

    _container.nodes.clear();
    _container.append(_filtersWrapper);
    _container.append(_dataWrapper);
    _container.append(_legendWrapper);

    _renderFilters();
    _renderChart();
    _renderMessages();
    _renderLegend();
  }

  void clear() {
    _filters?.clear();
    _themes?.clear();
    _messages?.clear();
    _people?.clear();
    _selected = null;
    _container.nodes.clear();

    var placeholder = html.ParagraphElement()
      ..appendText(CHART_CLEAR_PLACEHOLDER_TEXT);
    _container.append(placeholder);
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

    if (width < MIN_CHART_WIDTH) {
      width = MIN_CHART_WIDTH;
    }

    return width;
  }

  String _getThemeColor(String theme) {
    String color = "black";
    _themes.forEach((t) {
      if (t.value == theme) color = t.color;
    });
    return color;
  }

  String _lookupFilterLabels(String filter, String option) {
    String label = "Unknown";
    for (var f in _filters) {
      if (f.value != filter) continue;
      for (var o in f.options) {
        if (o.value == option) {
          return o.label;
        }
      }
    }
    return label;
  }

  String _lookupThemeLabels(List<String> themes) {
    List<String> labels = List();
    for (var theme in themes) {
      for (var t in _themes) {
        if (t.value == theme) {
          labels.add(t.label);
        }
      }
    }
    return labels.join(", ");
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
    _selected.updatePerson(null);
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
    _selected.updatePerson(null);
    await _loadPeople();
    _renderFilters();
    _renderChart();
    _messages = null;
    _renderMessages();
  }

  String _getTooltipContent(model.Person person) {
    var displayAge = person.age < 0 ? 'Unknown' : '${person.age} years';
    var displayThemes = _lookupThemeLabels(person.themes).replaceAll("_", " ");
    return """
      <table>
        <tr>
          <td>Gender</td>
          <td>${_lookupFilterLabels('gender', person.gender)}</td>
        </tr>
        <tr>
          <td>Age</td>
          <td>${displayAge}</td>
        </tr>
        <tr>
          <td>IDP Status</td>
          <td>${_lookupFilterLabels('idp_status', person.idpStatus)}</td>
        </tr>
        <tr>
          <td>Location</td>
          <td class='${CAPITALISE_TEXT_CSS_CLASS}'>${person.location}</td>
        </tr>
        <tr>
          <td>Talked about</td>
          <td class='${CAPITALISE_TEXT_CSS_CLASS}'>${displayThemes}</td>
        </tr>
      </table>
    """;
  }

  bool isTouchDevice() {
    return js.context.callMethod('hasTouchSupport');
  }

  void _handleMouseEnter(
      svg.SvgElement rect, num x, num y, model.Person person) {
    if (!isTouchDevice()) {
      var dist = -2 * SQ_WIDTH;
      rect.parent.append(rect);
      rect..setAttribute("transform", "translate($dist, $dist) scale(2)");
    }

    int pageTopOffset = html.document.documentElement.scrollTop;

    _tooltip
      ..nodes.clear()
      ..setInnerHtml(_getTooltipContent(person))
      ..style.setProperty("left", "${x + TOOLTIP_OFFSET}px")
      ..style.setProperty("top", "${y - 4 * TOOLTIP_OFFSET + pageTopOffset}px")
      ..removeAttribute("hidden");
  }

  void _handleMouseOut(svg.SvgElement rect) {
    if (!isTouchDevice()) {
      rect..setAttribute("transform", "translate(0, 0) scale(1)");
    }

    _tooltip..setAttribute("hidden", "true");
  }

  void _handleClick(html.MouseEvent evt, String personID) async {
    logger.log("Messages for person with ID ${personID} loading");
    evt.stopPropagation();
    _selected.updatePerson(personID);
    _renderChart();
    await _loadMessages(personID);
    _renderMessages();
  }

  void _clearSelectedPerson() {
    if (_selected.personID == null) return;

    _selected.updatePerson(null);
    _renderChart();
    _messages = null;
    _renderMessages();
    _chartScrollLeft = 0;
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
    var wrapper = html.DivElement()
      ..classes = FILTER_COLUMN_CSS_CLASSES
      ..id = FILTER_OPTION_CSS_CLASS;
    var label = html.LabelElement()..innerText = ".";
    var select = html.SelectElement()
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

  void _setChartScroll(html.Event event) {
    _chartScrollLeft = (event.target as html.DivElement).scrollLeft;
  }

  void _renderChart() {
    _chartsColumn.nodes.clear();

    var wrapper = html.DivElement()..classes = [CHART_WRAPPER_CSS_CLASS];
    var chartWidth = _chartWidth - (4 * CHART_PADDING);

    var svgContainer = svg.SvgSvgElement()
      ..style.width = "${chartWidth}px"
      ..style.height = "${CHART_HEIGHT}px"
      ..onClick.listen((e) => _clearSelectedPerson());

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
          SQ_IN_ROW = 12;
          break;
        case "gender":
          key = people.gender;
          SQ_IN_ROW = 24;
          break;
        case "idp_status":
          key = people.idpStatus;
          SQ_IN_ROW = 24;
          break;
        default:
          logger.error("Selected metric ${_selected.metric} not found");
      }
      if (peopleByLabel[key] != null) {
        peopleByLabel[key].add(people);
      }
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
          ..onClick.listen((e) => this._handleClick(e, colData[j].id))
          ..onMouseEnter.listen((e) => this._handleMouseEnter(
              e.currentTarget, e.client.x, e.client.y, colData[j]))
          ..onMouseOut.listen((e) => this._handleMouseOut(e.currentTarget));

        var themes = colData[j].themes;
        String primaryTheme = themes.first;
        var square = svg.RectElement()
          ..setAttribute("x", x.toString())
          ..setAttribute("y", y.toString())
          ..setAttribute("width", SQ_WIDTH.toString())
          ..setAttribute("height", SQ_WIDTH.toString())
          ..setAttribute("fill", _getThemeColor(primaryTheme))
          ..setAttribute(
              "stroke", colData[j].id == _selected.personID ? "black" : "white")
          ..setAttribute("stroke-width", SPACE_BTWN_SQ.toString());
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

    wrapper
      ..append(svgContainer)
      ..onScroll.listen((e) => _setChartScroll(e));
    _chartsColumn.append(wrapper);
    wrapper.scroll(this._chartScrollLeft, 0);
  }

  void _renderMessages() {
    _messagesColumn.nodes.clear();
    var title = html.HeadingElement.h5()..innerText = MESSAGES_LABEL;
    _messagesColumn.append(title);
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

      var messages = text.split(";");
      for (var msg in messages) {
        var messageDiv = html.DivElement()
          ..appendText(msg)
          ..classes = [MESSAGE_CSS_CLASS, msgClass]
          ..style.borderLeftColor = message.theme != null
              ? "${_getThemeColor(message.theme)}"
              : "white";
        wrapper.append(messageDiv);
      }
    }

    _messagesColumn.append(wrapper);
  }

  void _renderLegend() {
    _legendWrapper.nodes.clear();
    _themes.forEach((theme) {
      var legendColumn = html.DivElement()..classes = LEGEND_COLUMN_CSS_CLASSES;
      var legendColor = html.LabelElement()
        ..classes = [LEGEND_ITEM_CSS_CLASS]
        ..innerText = theme.label.replaceAll("_", " ")
        ..style.borderLeftColor = theme.color;
      legendColumn.append(legendColor);

      _legendWrapper.append(legendColumn);
    });
  }
}
