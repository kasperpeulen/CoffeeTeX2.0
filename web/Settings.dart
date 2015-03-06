part of main;

class Settings {
  Map<String, Action> _actionList;
  DivElement _div = new DivElement()..id = "settings";
  bool removed = false;

  Settings(this._actionList, int x, int y) {
    _div
      ..style.left = "${x}px"
      ..style.top = "${y}px";
    actionList = _actionList;
    document.body.append(_div);
  }

  Map<String, Action> get actionList {
    _actionList.forEach((String string, Action action) {
      UListElement ul = querySelector("#${string} #keyList");
      List keyCodes = new List();
      for (LIElement li in ul.children) {
        keyCodes.add(li.text);
      }
      _actionList[string].keyCode = keyCodes;
    });
    return _actionList;
  }

  set actionList(Map<String,Action> actionList) {
    _div.children.clear();
    actionList.forEach((String string, Action action) {
      _div..append(new DivElement()
        ..id = string
        ..append(
          new DivElement()
            ..text = action.description
            ..classes.add("actionDescription"))
        ..append(ULFromList(action.keyCode)
        ..id = "keyList"));
    });
    _div.append(new ButtonElement()..text="Save"..id="saveButton"..onClick.listen((e) => saveActions()));
  }

  UListElement ULFromList(List list ) {
    UListElement ul = new UListElement();
    for (String key in list ) {
      ul.append(new LIElement()
        ..text = key
        ..contentEditable = "true"
        ..onKeyDown.listen((e) => changeChar(e)));
    }
    return ul;
  }

  void changeChar(KeyboardEvent e) {
    e.preventDefault();
    (e.target as LIElement).text = convertKeyboardEventToUnicode(e);
  }
  void saveActions() {
    actionManager.actionMap = actionList;
    _div.remove();
    removed = true;

  }


}