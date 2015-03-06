library TextAreaUtil;

import 'dart:math';
import 'dart:html';

class TextAreaUtil {
  TextAreaElement element;

  TextAreaUtil(this.element);

  ///Removes the selected text from the textarea.
  void removeSelectedText() {
    List newTextArea = element.value.split("");
    int selectionStart = element.selectionStart;
    for (var i = element.selectionStart; i < element.selectionEnd; i++) {
      newTextArea[i] = "";
    }
    element.value = newTextArea.join("");
    element.selectionEnd = selectionStart;
  }


  void insertStringAtCaret(String string, {int moveCaretRelatively: 0}) {
    int selectionStart = element.selectionStart;
    List newTextArea = new List.from(element.value.split(""), growable: true);
    newTextArea.insert(element.selectionStart, string);
    element.value = newTextArea.join("");
    element.selectionEnd = selectionStart + string.length + moveCaretRelatively;
    element.selectionStart = selectionStart + string.length + moveCaretRelatively;
  }


  ///The selected text in the textarea.
  String get selectedText {
    return element.value.substring(
        element.selectionStart, element.selectionEnd);
  }

  ///Gives the position of the caret in the element. Where y is the top coordinate and x is the left coordinate.
  Point get caretPosition {
    int position = element.selectionStart;
    String text = element.value;
    DivElement mirror = new DivElement()..text = text.substring(0, position);
    mirror.style
      ..whiteSpace = 'pre-wrap'
      ..wordWrap = 'break-word'
      ..position = ' absolute'
      ..overflow = 'hidden';
    CssStyleDeclaration computed = element.getComputedStyle();

    var properties = [
      'direction',
      'box-sizing',
      'width',
      'height',
      'overflowX',
      'overflowY',
      'border-top-width',
      'border-right-width',
      'border-bottom-width',
      'border-left-width',
      'padding-top',
      'padding-right',
      'padding-bottom',
      'padding-left',
      'font-style',
      'font-variant',
      'font-weight',
      'font-stretch',
      'font-size',
      'font-size-adjust',
      'line-height',
      'font-family',
      'text-align',
      'text-transform',
      'text-indent',
      'text-decoration',
      'letter-spacing',
      'word-spacing'
    ];
    properties.forEach((prop) =>
        mirror.style.setProperty(prop, computed.getPropertyValue(prop)));
    document.body.append(mirror);

    SpanElement span = new SpanElement();
    if (text.substring(position) == "") {
      span.text = '.';
    } else {
      span.text = text.substring(position);
    }
    mirror.append(span);

    Point point = new Point(element.offsetLeft +
            span.offsetLeft +
            int.parse(computed.getPropertyValue('border-left-width')[0]),
        element.offsetTop +
            span.offsetTop +
            int.parse(computed.getPropertyValue('border-top-width')[0]));
    mirror.remove();
    return point;
  }
}
