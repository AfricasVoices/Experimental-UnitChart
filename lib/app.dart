import 'dart:html' as html;

html.DivElement get content => html.querySelector("#content");
html.DivElement get container => html.querySelector("#container");
html.DivElement get interactive => html.querySelector("#interactive");
html.DivElement get progress => html.querySelector("#progress");
html.ButtonElement get prevButton => html.querySelector("#prev-button");
html.ButtonElement get nextButton => html.querySelector("#next-button");

class App {
  int _currentPage = 0;
  int _maxPageCount = 10;

  int get firstPageIndex => 0;
  int get lastPageIndex => _maxPageCount - 1;

  App() {
    _listenToPrevClick();
    _listenToNextClick();
    _listenToShortcuts();

    _showContent(0);
    _renderProgress();
    container.classes.toggle("hidden", false);
  }

  void _listenToPrevClick() {
    prevButton.onClick.listen((_) => _goToSlide(--_currentPage));
  }

  void _listenToNextClick() {
    nextButton.onClick.listen((_) => _goToSlide(++_currentPage));
  }

  void _listenToShortcuts() {
    html.window.onKeyUp.listen((evt) {
      switch (evt.keyCode) {
        case html.KeyCode.RIGHT:
          _goToSlide(++_currentPage);
          break;
        case html.KeyCode.LEFT:
          _goToSlide(--_currentPage);
          break;
        default:
      }
    });
  }

  void _goToSlide(slideNum) {
    if (slideNum < firstPageIndex || slideNum > lastPageIndex) {
      return;
    }

    _currentPage = slideNum;
    _showContent(_currentPage);
    _renderProgress();
    _updateButtonsState();
  }

  void _updateButtonsState() {
    if (_currentPage <= firstPageIndex) {
      prevButton.disabled = true;
    } else {
      prevButton.disabled = false;
    }

    if (_currentPage >= lastPageIndex) {
      nextButton.disabled = true;
    } else {
      nextButton.disabled = false;
    }
  }

  void _renderProgress() {
    progress.children.clear();

    List<num>.generate(_maxPageCount, (i) => i).forEach((i) {
      html.SpanElement progressIndicator = html.SpanElement()
        ..classes = ["flex-grow-1", "footer-progress"]
        ..onClick.listen((_) => _goToSlide(i));

      if (i <= _currentPage) {
        progressIndicator.classes.add("footer-progress--filled");
      }

      progress.append(progressIndicator);
    });
  }

  void _showContent(int slideNum) {
    for (var i = 0; i < _maxPageCount; ++i) {
      var slide = html.querySelector('div[data-slide="$i"]');
      if (i == slideNum) {
        slide.classes.toggle("hidden", false);
      } else {
        slide.classes.toggle("hidden", true);
      }
    }
  }
}
