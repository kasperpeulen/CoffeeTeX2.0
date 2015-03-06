library KeyCodeUtil;

import 'dart:html';
import "dart:convert";



String convertKeyboardEventToUnicode(KeyboardEvent e) {
  String string = "";
  if (e.ctrlKey) {
    string += "^";
  }
  if (e.altKey) {
    string +="⌥";
  }
  if (e.shiftKey) {
    string +="⇧";
  }
  if (e.metaKey && e.keyCode != 93) {
    string += "⌘";
  }
  if (convertKeyCodeToUnicode(e.keyCode) != null) {
    string +=  convertKeyCodeToUnicode(e.keyCode);
  } else {
    string += new String.fromCharCode(e.keyCode);
  }
  return string;
}

String convertKeyCodeToUnicode(int keyCode) {
  switch(keyCode) {
//    case KeyCode.ALT: return "⌥";
    case KeyCode.BACKSPACE: return "⌫";
    case KeyCode.CAPS_LOCK: return "⇪";
    case KeyCode.CTRL: return "";
    case KeyCode.DELETE: return "⌦";
    case KeyCode.DOWN: return "↓";
    case KeyCode.END: return "END";
    case KeyCode.ENTER: return "⏎";
    case KeyCode.ESC: return "⎋";
    case KeyCode.F1: return "F1";
    case KeyCode.F2: return "F2";
    case KeyCode.F3: return "F3";
    case KeyCode.F4: return "F4";
    case KeyCode.F5: return "F5";
    case KeyCode.F6: return "F6";
    case KeyCode.F7: return "F7";
    case KeyCode.F8: return "F8";
    case KeyCode.F9: return "F9";
    case KeyCode.F10: return "F10";
    case KeyCode.F11: return "F11";
    case KeyCode.F12: return "F12";
    case KeyCode.HOME: return "HOME";
    case KeyCode.INSERT: return "INSERT";
    case KeyCode.LEFT: return "←";
    case KeyCode.META: return "";
    case KeyCode.NUMLOCK: return "NUM_LOCK";
    case KeyCode.PAGE_DOWN: return "PAGE_DOWN";
    case KeyCode.PAGE_UP: return "PAGE_UP";
    case KeyCode.PAUSE: return "PAUSE";
    case KeyCode.PRINT_SCREEN: return "PRINT_SCREEN";
    case KeyCode.RIGHT: return "→";
    case KeyCode.SCROLL_LOCK: return "SCROLL";
    case KeyCode.SHIFT: return "";
    case KeyCode.SPACE: return "Space";
    case KeyCode.TAB: return "⇥";
    case KeyCode.UP: return "↑";
    case KeyCode.SEMICOLON: return ";";
    case KeyCode.DASH: return "-";
    case KeyCode.EQUALS: return "=";
    case KeyCode.PERIOD: return ".";
    case KeyCode.SLASH: return "/";
    case KeyCode.APOSTROPHE: return "`";
    case KeyCode.TILDE: return "~";
    case KeyCode.SINGLE_QUOTE: return "'";
    case KeyCode.OPEN_SQUARE_BRACKET: return "[";
    case KeyCode.BACKSLASH: return "\\";
    case 188 : return ",";
    case 221 : return "]";
    case 93 : return "R⌘";

    case KeyCode.WIN_IME:
    case KeyCode.WIN_KEY:
    case KeyCode.WIN_KEY_LEFT:
    case KeyCode.WIN_KEY_RIGHT:
      return "";
    default: return null;
  }
  return null;
}
