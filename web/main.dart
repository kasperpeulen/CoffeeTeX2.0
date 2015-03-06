library main;

import "dart:html";
import "dart:convert";
import "dart:math";

import 'Popup.dart';
import 'TextareaUtil.dart';
import 'KeyCodeUtil.dart';
import 'ActionManager.dart';
import 'Action.dart';
part 'ReplaceUtil.dart';
part 'Settings.dart';


TextAreaElement editor = querySelector("#editor");
TextAreaUtil textAreaUtil = new TextAreaUtil(editor);
ReplaceUtil replaceUtil = new ReplaceUtil();
ActionManager actionManager = new ActionManager();

Popup popup;

ButtonElement settingsButton = querySelector("#settingsButton");
Settings settings;
void main() {
  Map<String,Action> action = actionManager.actionMap;
  document.body.onKeyDown.listen((e) {
    if (action["openSettings"].keyCode.contains(convertKeyboardEventToUnicode(e))) {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
      if (settings == null || settings.removed) {
        settings = new Settings(actionManager.actionMap, settingsButton.offsetLeft + 40, settingsButton.offsetTop + 20);
      } else {
        settings.saveActions();
        settings = null;
        editor.focus();
      }
    }
  });
  settingsButton.onClick.listen((e) {
    if (settings == null || settings.removed) settings = new Settings(actionManager.actionMap, settingsButton.offsetLeft + 40, settingsButton.offsetTop + 20);
  });
  editor.onKeyDown.listen(onKeyDown);



}

void onKeyDown(KeyboardEvent e) {
  if (editor.selectionEnd == 0) return;

  String typedChar = new String.fromCharCode(e.keyCode);
  int typedNumber;
  try {
    typedNumber = int.parse(typedChar);
  } on FormatException {
    typedNumber = null;
  }

  Map<String,Action> action = actionManager.actionMap;

  Action selectNextChar = ActionManager.selectNextChar;



  if (popup == null && action["showPopup"].keyCode.contains(convertKeyboardEventToUnicode(e))) {
    e.preventDefault();
    createPopup();
  } else if (popup != null) {

    if (typedNumber != null) {
      e.preventDefault();
      popup.selectedIndex = typedNumber - 1;
    }
    else if (action["selectNextChar"].keyCode.contains(convertKeyboardEventToUnicode(e))) {
      e.preventDefault();
      popup.selectedIndex += 1;
    }
    else if (action["selectPreviousChar"].keyCode.contains(convertKeyboardEventToUnicode(e))) {
        e.preventDefault();
        popup.selectedIndex -= 1;
      }
      else if (action["editPopUpChar"].keyCode.contains(convertKeyboardEventToUnicode(e))) {
          e.preventDefault();
          popup.focusSelectedChar();
        }
      else if (action["removePopUp"].keyCode.contains(convertKeyboardEventToUnicode(e))) {
          e.preventDefault();
          replaceUtil.saveReplaceList(popup.replaceList);
          removePopup();
        }
        else if (action["insertPopUpChar"].keyCode.contains(convertKeyboardEventToUnicode(e))) {
            e.preventDefault();
            replaceUtil.saveReplaceList(popup.replaceList);
            popup.insertSelectedChar();
            removePopup();
          } else {
              replaceUtil.saveReplaceList(popup.replaceList);
              popup.insertSelectedChar();
              removePopup();
          }


  }

}

void createPopup() {
  //if nothing selected, select the char next to the caret
  if (textAreaUtil.selectedText == "") editor.selectionStart += -1;
  if (replaceUtil.replaceMap.containsKey(textAreaUtil.selectedText)) {
    popup = new Popup(
        editor, replaceUtil.getReplaceList(textAreaUtil.selectedText));
  }
}

void removePopup() {
  popup.remove();
  popup = null;
}