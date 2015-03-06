library ActionManager;

import 'Action.dart';
import 'dart:html';
import 'dart:convert';
class ActionManager {

  Storage storage = window.localStorage;
  static Action showPopup = new Action(
      "Create a new popup:",
      ["⌘"],
      document.body
  );

  static Action selectNextChar = new Action(
      "Select next char in the popup:",
      ["⌘", "→", "↓"],
      querySelector('#popup')
  );

  static Action selectPreviousChar = new Action(
      "Select previous char in the popup:",
      ["←", "↑"]);

  static Action removePopUp = new Action(
      "Remove the popup:",
      ["⎋", "⌫"]
  );

 static Action insertPopUpChar = new Action(
      "Insert selected popup char in the textarea:",
      ["⏎", "⇥"]);

  static Action editPopUpChar = new Action(
      "Edit the selected popup char:",
      ["Space"]);

  static Action editPopUpCaret = new Action(
      "Edit the selected popup caret position:",
      ["⇥"]);
  static Action openSettings = new Action(
      "Open/Close settings:",
      ["⌘,"]);


  static Map<String,Action> defaultActionMap = {
      "showPopup" : showPopup,
      "selectNextChar" : selectNextChar,
      "selectPreviousChar" : selectPreviousChar,
      "removePopUp" : removePopUp,
      "insertPopUpChar" : insertPopUpChar,
      "editPopUpChar" : editPopUpChar,
      "editPopUpCaret" : editPopUpCaret,
      "openSettings" : openSettings
  };

  Map<String,Action> _actionMap;

  Map<String,Action> actionMapSavedByUser;
  ActionManager() {
    if (storage["actionMap"] == null) {

      actionMap  = defaultActionMap;
    } else {
      actionMapSavedByUser = JSON.decode(storage["actionMap"]);
      actionMap = actionMapSavedByUser;
    }
  }

  Map<String, Action> get actionMap {
    Map<String, Action> actionMap;
    if (storage["actionMap"] == null) {
      actionMap = defaultActionMap;
    } else {
      actionMapSavedByUser = JSON.decode(storage["actionMap"]);
      actionMap = actionMapSavedByUser;
    }
    return actionMap;
  }

  set actionMap(Map<String, Action> value) {
//    storage["actionMap"] = JSON.encode(value);
    actionMapSavedByUser  = value;
    _actionMap = value;
  }

}