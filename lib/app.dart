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
html.DivElement get loginModal => html.querySelector("#login-modal");
html.ButtonElement get loginButton => html.querySelector("#login-button");
html.DivElement get loginError => html.querySelector("#login-error");
html.AnchorElement get logoutButton => html.querySelector("#logout-button");

class App {
  interactive.Interactive _interactiveInstance;

  App() {
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
}
