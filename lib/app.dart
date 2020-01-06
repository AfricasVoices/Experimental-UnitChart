import 'dart:html' as html;
import 'package:avf/logger.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:avf/firebase.dart' as fb;
import 'firebase_constants.dart' as fb_constants;
import 'package:avf/interactive.dart' as interactive;

Logger logger = Logger("app.dart");

html.DivElement get content => html.querySelector("#content");
html.DivElement get container => html.querySelector("#container");
html.DivElement get interactiveContainer => html.querySelector("#interactive");
html.DivElement get progress => html.querySelector("#progress");
html.ButtonElement get prevButton => html.querySelector("#prev-button");
html.ButtonElement get nextButton => html.querySelector("#next-button");
html.DivElement get loginModal => html.querySelector("#login-modal");
html.ButtonElement get loginButton => html.querySelector("#login-button");
html.DivElement get loginError => html.querySelector("#login-error");
html.AnchorElement get logoutButton => html.querySelector("#logout-button");

class App {
  int _currentPage = 0;
  int _maxPageCount = container.children.length;
  interactive.Interactive _interactiveInstance;

  int get firstPageIndex => 0;
  int get lastPageIndex => _maxPageCount - 1;

  App() {
    _listenToPrevClick();
    _listenToNextClick();
    _listenToShortcuts();

    _showContent(_currentPage);
    _renderProgress();
    container.classes.toggle("hidden", false);

    initFirebase();
  }

  void initFirebase() async {
    await fb.init();
    fb.firebaseAuth.onAuthStateChanged.listen(_fbAuthChanged);
    loginButton.onClick.listen((_) => fb.signInWithGoogle());
    logoutButton.onClick.listen((_) => fb.signOut());
  }

  void _fbAuthChanged(firebase.User user) async {
    if (user == null) {
      logger.log("User not signedin");
      loginModal.removeAttribute("hidden");
      _interactiveInstance?.clear();
      return;
    }

    if (!fb_constants.allowedEmailDomains
        .any((domain) => user.email.endsWith(domain))) {
      logger.error("Email domain not allowed");
      await fb.deleteUser();
      loginError
        ..removeAttribute("hidden")
        ..innerText = "Email domain not allowed";
      return;
    }

    if (!user.emailVerified) {
      logger.error("Email not verified");
      await fb.deleteUser();
      loginError
        ..removeAttribute("hidden")
        ..innerText = "Email is not verified";
      return;
    }

    _interactiveInstance = interactive.Interactive(interactiveContainer);
    loginModal.setAttribute("hidden", "true");
    loginError.setAttribute("hidden", "true");
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
