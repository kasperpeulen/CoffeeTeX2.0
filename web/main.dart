// Copyright (c) 2015, Kasper Peulen. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:convert';
import 'getCaretXYFromTextArea.dart';
import 'replaceLetter.dart';

TextAreaElement textarea = querySelector("#ct_editor");
InputElement newCharInput;
DivElement popup ;
UListElement char_list;
LIElement selected;

String oldChars;
List newChars;
num selectedCharIndex = 0;
num lastCharIndex;
var caretStart,caretEnd;
Map caret_XY;

Map replaceLetter;

Storage local = window.localStorage;
StreamSubscription listen;
StreamSubscription listenBody;

List modKey = [KeyCode.WIN_KEY_RIGHT,KeyCode.CONTEXT_MENU,KeyCode.CTRL];
List modKey2 = [KeyCode.ALT];

void main() {
  print(KeyCode.MAC_FF_META);
  //load default letters, the first time
  if (local["replaceLetter3"] != null)
    replaceLetter = JSON.decode(local["replaceLetter3"]);
  else
    replaceLetter = replaceLetterDefault;

  //register keyDown on Body
  listenBody = document.body.onKeyDown.listen(onKeyDown);

}

void onKeyDown(KeyEvent keyEvent) {
  if (textarea.selectionEnd == 0) return;

  //if modKeyDown, create popup, or select next char in popup
  if (modKey.contains(keyEvent.keyCode)) {
    keyEvent.preventDefault();
    if (popup == null)
      createPopUp();
    else
      selectNextChar();
  }
  //if modKey2 down, expand selection to the left
  else if (modKey2.contains(keyEvent.keyCode)){
    keyEvent.preventDefault();
    textarea.selectionStart += -1;
    if (popup != null) removePopUp();
    createPopUp();
  }
  //if popUp, and no modkey, remove the popup
  else if (popup != null) {
    if (keyEvent.keyCode == KeyCode.ENTER)
      keyEvent.preventDefault();
    if (keyEvent.keyCode != KeyCode.ESC && newChars.length != 0)
      replaceChar();
    removePopUp();
  }
}


void createPopUp() {

  //create popup at caret coordinates with UList
  caret_XY = getCaretXYFromTextArea(textarea,textarea.selectionStart);
  popup = new DivElement()
    ..id = "popup"
    ..style.display = "block"
    ..style.top = (25+caret_XY["top"]).toString() +"px"
    ..style.left = (-10+caret_XY["left"]).toString() +"px";
  document.body.append(popup);
  char_list = new UListElement()
    ..id = "char_list";
  popup.append(char_list);

  //oldChars are the selected text, or the char next to the caret
  if (textarea.selectionStart == textarea.selectionEnd) textarea.selectionStart += -1;
  oldChars = textarea.value.substring(textarea.selectionStart,textarea.selectionEnd);

  //check if oldChars match replaceLetter

  print ([replaceLetter.containsKey(oldChars),replaceLetter[oldChars]]);

  if (replaceLetter.containsKey(oldChars) && replaceLetter[oldChars].length != 0) {
    newChars = replaceLetter[oldChars];
    //add those newChars to the list
    for (var char in newChars) {
      if (!(char is String)) char = char[0];
      LIElement li = new LIElement()
        ..text = char;
      char_list.append(li);
    }
    selectCharIndex(0);
  }
  else {
    newChars = new List();
    LIElement li = new LIElement()
      ..text = "";
    char_list.append(li);
    selectCharIndex(0);
    //createNewCharInput(null);
  }


  //make an addNewChar button at the end of the list
  LIElement addChar = new LIElement()
    ..style.minWidth = "5px"
    ..id = "addChar";
  char_list.append(addChar);
  addChar.onMouseEnter.listen(addNewChar);

  /*
  if (newChars.length == 1){
    removePopUp();
    replaceChar();
  }
  */

}

removePopUp(){
  if (popup != null) popup.remove();
  popup = null;
  if (char_list != null) char_list.remove();
  char_list = null;
}

selectNextChar(){
  if (selectedCharIndex == char_list.children.length -2)
    selectCharIndex(0);
  else
    selectCharIndex(selectedCharIndex+1);
}

selectCharIndex(i) {
  if (char_list.children.length < (i+1))
    return;

  if ((selectedCharIndex) > (char_list.children.length -2))
    i = 0;

  //remove the selected class, and add it to child i
  if (selected != null) selected.classes.remove('selected');
  selected = char_list.children[i];
  selected.classes.add("selected");
  selectedCharIndex = i;

  //remove old listener, and add listener to selectedLI
  if (listen != null) listen.cancel();
  listen = selected.onMouseEnter.listen(createNewCharInput);
}

replaceChar() {
  //replace oldChar with newChar and fix caretPos
  var newChar, dCaretPos;
  if (newChars[selectedCharIndex] is String) {
    newChar = newChars[selectedCharIndex];
    dCaretPos = 0;
  }
  else {
    newChar = newChars[selectedCharIndex][0];
    dCaretPos = newChars[selectedCharIndex][1];
  }

  if (replaceLetterAfter.containsKey(newChar)){
    newChar = replaceLetterAfter[newChar];
  }

  List newText = textarea.value.split("");

  //remove oldChars
  for (var i=1 ; i<=oldChars.length ; i++){
    newText[textarea.selectionEnd-i] = "";
  }

  //place newChar
  newText[textarea.selectionEnd-1] = newChar;
  textarea.value = newText.join("");

  //fix caretPos
  var newCaretPos = textarea.selectionEnd + dCaretPos + newChar.length - 1;
  textarea.setSelectionRange(newCaretPos,newCaretPos);
}

createNewCharInput(MouseEvent e){

  //remember caret position
  caretStart = textarea.selectionStart;
  caretEnd = textarea.selectionEnd;
  listenBody.pause();

  //create input to type new chars
  newCharInput = new InputElement();
  newCharInput ..id = "changeChar"
        ..type = "text"
        ..value = selected.text
        ..style.width = selected.getComputedStyle().width
        ..onKeyUp.listen(inputKeyUp);
  selected ..children.clear()
          ..append(newCharInput)
          ..onMouseLeave.listen(inputMouseLeave);
}

inputMouseLeave(MouseEvent e){
  updateChar();
}

updateChar() {

  //select textarea at saved position
  textarea  ..select()
            ..setSelectionRange(caretStart,caretEnd);

  //update char in selected List element
  var updatedChar = newCharInput.value;
  selected.text = updatedChar;

  //if updateChar is empty, remove selected from list
  if (updatedChar  == "") {
    removeSelectedChar();
  }
  //else update char in replaceLetter map
  else {
    //if it is the first Char
    if (newChars.length == 0){
      replaceLetter[oldChars] = [updatedChar];
      newChars = replaceLetter[oldChars];
    }
    //if char is just added
    else if (selected.classes.contains("new")) {
      replaceLetter[oldChars].add(updatedChar);
      selected.classes.remove("new");
    }
    else {
      replaceLetter[oldChars][selectedCharIndex] = updatedChar;
    }
  }
  //update to localstorage;
  local["replaceLetter3"] = JSON.encode(replaceLetter);

  //remove input
  newCharInput.remove();
  listenBody.resume();
}

inputKeyUp(KeyEvent keyEvent){

  //hack to properly resize input width

  SpanElement span = new SpanElement()
    ..text = newCharInput.value;
  newCharInput.parentNode.append(span);
  newCharInput.style.width = (span.contentEdge.width+10).toString() + "px";
  span.remove();

  //updatechar when press enter
  if (keyEvent.keyCode == KeyCode.ENTER) {
    keyEvent.preventDefault();
    updateChar();
  }
}

addNewChar(MouseEvent e){
  (e.target as LIElement).insertAdjacentElement('beforebegin', new LIElement()..text = "" ..classes.add("new"));
  //save oldindex;
  lastCharIndex = selectedCharIndex;
  selectCharIndex(newChars.length);
}

removeSelectedChar(){
  //removes SelectedChar from replaceLetter and char_list

  //if last Char, removepopup
  if (char_list.children.length == 2){
    replaceLetter[oldChars].removeAt(selectedCharIndex);
    removePopUp();
  }
  else {
    //if char just added, go to lastCharIndex
    if (selected.classes.contains("new"))
      selectedCharIndex = lastCharIndex;
    //else remove from replaceLetter
    else
      replaceLetter[oldChars].removeAt(selectedCharIndex);
    selected.remove();
    selectCharIndex(selectedCharIndex);
  }
}