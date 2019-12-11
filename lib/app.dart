import 'dart:html' as html;

html.DivElement get content => html.querySelector("#content");
html.DivElement get progress => html.querySelector("#progress");
html.ButtonElement get prevButton => html.querySelector("#prev-button");
html.ButtonElement get nextButton => html.querySelector("#next-button");

class App {
  int currentPage = 0;
  int maxPageCount = 10;

  App() {
    _listenToPrevClick();
    _listenToNextClick();
    _listenToShortcuts();

    _renderProgress();
  }

  void _listenToPrevClick() {
    prevButton.onClick.listen((evt) => _goToPrevSlide());
  }

  void _listenToNextClick() {
    nextButton.onClick.listen((evt) => _goToNextSlide());
  }

  void _listenToShortcuts() {
    html.window.onKeyUp.listen((evt) {
      switch (evt.keyCode) {
        case html.KeyCode.RIGHT:
          _goToNextSlide();
          break;
        case html.KeyCode.LEFT:
          _goToPrevSlide();
          break;
        default:
      }
    });
  }

  void _goToPrevSlide() {
    if (currentPage > 0) {
      --currentPage;
    }
    _renderProgress();
    _updateButtonsState();
  }

  void _goToNextSlide() {
    if (currentPage < maxPageCount - 1) {
      ++currentPage;
    }
    _renderProgress();
    _updateButtonsState();
  }

  void _updateButtonsState() {
    if (currentPage <= 0) {
      prevButton.disabled = true;
    } else {
      prevButton.disabled = false;
    }

    if (currentPage >= maxPageCount - 1) {
      nextButton.disabled = true;
    } else {
      nextButton.disabled = false;
    }
  }

  void _renderProgress() {
    progress.children.clear();

    List<num>.generate(maxPageCount, (i) => i).forEach((i) {
      html.SpanElement progressIndicator = html.SpanElement()
        ..classes = ["flex-grow-1", "footer-progress"];

      if (i <= currentPage) {
        progressIndicator.classes.add("footer-progress--filled");
      }

      progress.append(progressIndicator);
    });
  }
}
