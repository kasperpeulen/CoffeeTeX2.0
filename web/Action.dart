library Action;

import 'dart:html';

class Action {

  List<String> keyCode;
  String description;

  Action(this.description, this.keyCode, [this.context]) {
  }

  HtmlElement context;

}