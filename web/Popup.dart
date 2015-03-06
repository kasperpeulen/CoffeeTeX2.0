library popup;

import 'dart:math';
import 'dart:html';
import 'TextareaUtil.dart';
import 'KeyCodeUtil.dart';
import 'ActionManager.dart';
import 'Action.dart';

class Popup {
  DivElement _div = new DivElement()..id = "popup";
  UListElement _ul;

  TextAreaElement _editor;
  TextAreaUtil _textAreaUtil;
  List _replaceList;
  int _selectedIndex;

  Popup(this._editor, this._replaceList) {
    _textAreaUtil = new TextAreaUtil(_editor);
    Point point = _textAreaUtil.caretPosition;
    _div
      ..style.left = "${point.x}px"
      ..style.top = "${point.y + 25}px";
    replaceList = _replaceList;
    selectedIndex = 0;
    document.body.append(_div);
  }

  set replaceList(List replaceList) {
    _div.children.clear();
    _ul = new UListElement()..id = "replaceList";
    for (List char in replaceList) {
      LIElement li = newLIElement(char);
      _ul.append(li);
    }
    LIElement addChar = new LIElement()
      ..style.minWidth = "5px"
      ..id = "addChar"
      ..onClick.listen(addNewChar);
    _ul.append(addChar);
    _div.append(_ul);

    _replaceList = replaceList;
  }

  List get replaceList {
    List newReplaceList = new List();
    for (LIElement li in _ul.children) {
      if (li != _ul.lastChild) {
        String char = li.children[0].text;
        int caretPosition;
        try {
          caretPosition = int.parse(li.children[1].text);
        } on FormatException {
          caretPosition = 0;
        }
        newReplaceList.add([char, caretPosition]);
      }
    }
    return newReplaceList;
  }

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int newIndex) {
    newIndex = newIndex % replaceList.length;
    if (selectedIndex != null)
      _ul.children[_selectedIndex].classes.remove("selected");
    _selectedIndex = newIndex;
    _ul.children[_selectedIndex].classes.add("selected");
  }

  String get selectedChar => replaceList[selectedIndex][0];

  int get caretPosForSelectedChar => replaceList[selectedIndex][1];

  void focusSelectedChar() {
    _ul.children[selectedIndex].children[0].focus();
  }

  void insertSelectedChar() {
    _textAreaUtil.removeSelectedText();
    _textAreaUtil.insertStringAtCaret(
        selectedChar, moveCaretRelatively: caretPosForSelectedChar);
  }

  void addNewChar(e) {
    LIElement li = newLIElement(["", 0]);
    (e.target as LIElement).insertAdjacentElement('beforebegin', li);
    li.children[0].focus();

    selectedIndex = _replaceList.length;
  }

  LIElement newLIElement(List char) {
    return new LIElement()
      ..append(new SpanElement()
        ..text = char[0]
        ..classes.add("char")
        ..contentEditable = "true")
      ..append(new SpanElement()
        ..text = char[1].toString()
        ..classes.add("caret")
        ..contentEditable = "true"
        ..style.display = "none")
      ..onKeyDown.listen(
          (e) => changeChar(e, _editor.selectionStart, _editor.selectionEnd));
  }

  void changeChar(KeyboardEvent e, int oldSelectionStart, int oldSelectionEnd) {
    ActionManager actionManager = new ActionManager();
    Map<String,Action> action = actionManager.actionMap;

    if ("⏎" == convertKeyboardEventToUnicode(e)) {
      e.preventDefault();
      if ((e.target as SpanElement).parent.children[0].text.isEmpty) {
        (e.target as SpanElement).parent.remove();
        selectedIndex = _selectedIndex;
      }
      _editor
        ..select()
        ..setSelectionRange(oldSelectionStart, oldSelectionEnd);
    } else if (action["editPopUpCaret"].keyCode.contains(convertKeyboardEventToUnicode(e))) {
      e.preventDefault();
      for (SpanElement span in querySelectorAll('.caret')) {
        if (span.style.display == "none") {
          span.style.display = "block";
        } else {
          span.style.display = "none";
        }
      }
    }
  }
  void remove() {
    _div.remove();
  }
}
