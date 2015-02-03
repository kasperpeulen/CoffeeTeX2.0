// Copyright (c) 2015, Kasper Peulen. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:convert';
import 'getCaretXYFromTextArea.dart';
import 'replaceLetter.dart';

TextAreaElement textarea = querySelector("#ct_editor");
HtmlElement settings = querySelector("#settings");
InputElement newCharInput;
DivElement popup ;
UListElement char_list;
LIElement selected;

String oldChars;
List newChars;
num selectedCharIndex = 0;
num lastCharIndex;
int caretStart,caretEnd;
Map caret_XY;

Map replaceLetter;

Storage local = window.localStorage;
StreamSubscription listen;
StreamSubscription listenBody;

List modKey = [KeyCode.WIN_KEY_RIGHT,KeyCode.CONTEXT_MENU];
List modKey2 = [KeyCode.ALT];
List modKey3 = [KeyCode.TAB];

ParagraphElement registerKeyCode = new ParagraphElement();

void main() {
  print([window.navigator.userAgent,window.navigator.userAgent.contains("NET")]);
  if (window.navigator.userAgent.contains("NET")){
    modKey2 = [KeyCode.CTRL];
  }

  //load default letters, the first time
  if (local["replaceLetter3"] != null)
    replaceLetter = JSON.decode(local["replaceLetter3"]);
  else
    replaceLetter = replaceLetterDefault;

  //register keyDown on Body
  listenBody = document.body.onKeyDown.listen(onKeyDown);
  settings.onClick.listen(settingsClicked);

}

void onKeyDown(KeyEvent keyEvent) {
  var keyCode = keyEvent.keyCode;
  registerKeyCode.text = "Keycode ${keyCode}";
  document.body.append(registerKeyCode);

  if (textarea.selectionEnd == 0) return;




  //if no popup exists
  if (popup == null){
    if (modKey.contains(keyCode) || modKey2.contains(keyCode) ){
      keyEvent.preventDefault();
      createPopUp();
    }
  }
  //if popup already exists
  else {
    if (modKey.contains(keyCode) || modKey3.contains(keyCode) || keyCode == KeyCode.RIGHT || keyCode == KeyCode.DOWN) {
      keyEvent.preventDefault();
      selectCharIndex(selectedCharIndex + 1);
    }
    else if (keyCode == KeyCode.LEFT || keyCode == KeyCode.UP) {
      keyEvent.preventDefault();
      selectCharIndex(selectedCharIndex - 1);
    }
    else if (modKey2.contains(keyCode)) {
        keyEvent.preventDefault();
        textarea.selectionStart += -1;
        removePopUp();
        createPopUp();
      }
      else if (keyCode == KeyCode.SPACE){
          keyEvent.preventDefault();
          createNewCharInput("changeChar");
        }
      else if (newChars.length == 0){
          removePopUp();
        }
        else if (keyCode != KeyCode.ESC){
            removePopUp();
            replaceChar();
          }
          else{
            removePopUp();
          }

    if (keyCode == KeyCode.ENTER ){
      keyEvent.preventDefault();
    }
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

  //remember caret position
  caretStart = textarea.selectionStart;
  caretEnd = textarea.selectionEnd;
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

selectCharIndex(i) {

  if (i == (char_list.children.length -1))
    i = 0;
  else if (i == -1)
    i = char_list.children.length -2;

  //remove the selected class, and add it to child i
  if (selected != null) selected.classes.remove('selected');
  selected = char_list.children[i];
  selected.classes.add("selected");
  selectedCharIndex = i;

  //remove old listener, and add listener to selectedLI
  if (listen != null) listen.cancel();
  listen = selected.onMouseEnter.listen(inputMouseEnter);
}

replaceChar() {
  //replace oldChar with newChar and fix caretPos
  var newChar;
  String dCaretPos;
  if (newChars[selectedCharIndex] is String) {
    newChar = newChars[selectedCharIndex];
    dCaretPos = "0";
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
  int newCaretPos = caretEnd + int.parse(dCaretPos) + newChar.length - 1;
  textarea.setSelectionRange(newCaretPos,newCaretPos);
}


inputMouseEnter(MouseEvent e){
  createNewCharInput("changeChar");
}

createNewCharInput(String id){

  listenBody.pause();

  var value;

  if (newChars.length == 0 || selectedCharIndex == newChars.length){
    value = "";
  }

  else if (id == "changeCaret"){
    if (newChars[selectedCharIndex] is String){
      newChars[selectedCharIndex] = [newChars[selectedCharIndex],"0"];
    }
    value = newChars[selectedCharIndex][1];
  }
  else{
    if (newChars[selectedCharIndex] is String){
      value = selected.text;
    }
    else{
      value = newChars[selectedCharIndex][0];
    }
  }

  //create input to type new chars
  newCharInput = new InputElement();
  newCharInput
    ..id = id
    ..type = "text"
    ..value = value
    ..style.width = selected.getComputedStyle().width
    ..onKeyUp.listen(inputKeyUp)
    ..onKeyDown.listen((keyDown) {if (keyDown.keyCode == KeyCode.TAB) keyDown.preventDefault();});
  selected
    ..children.clear()
    ..append(newCharInput)
    ..onMouseLeave.listen(inputMouseLeave);
  newCharInput
    ..select()
    ..setSelectionRange(0,0);
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

  var i;
  if (newCharInput.id == "changeChar"){
    i = 0;
  }
  else{
    i = 1;
  }

  //if updateChar is empty, remove selected from list
  if (updatedChar  == "") {
    removeSelectedChar();
  }
  //else update char in replaceLetter map
  else {
    //if it is the first Char
    if (newChars.length == 0){
      replaceLetter[oldChars] = [[updatedChar,"0"]];
      newChars = replaceLetter[oldChars];
      selected.text = updatedChar;
    }
    //if char is just added
    else if (selected.classes.contains("new")) {
      if (i == 0) {
        replaceLetter[oldChars].add([updatedChar, "0"]);
        selected.text = updatedChar;
      }
      else
        replaceLetter[oldChars].add(["",updatedChar]);
      selected.classes.remove("new");
    }
    else {
      if (replaceLetter[oldChars][selectedCharIndex] is String){
        replaceLetter[oldChars][selectedCharIndex] = updatedChar;
        selected.text = updatedChar;
      }
      else {
        replaceLetter[oldChars][selectedCharIndex][i] = updatedChar;
        selected.text = replaceLetter[oldChars][selectedCharIndex][0];
      }
    }


  }
  //update to localstorage;
  local["replaceLetter3"] = JSON.encode(replaceLetter);
  //remove input
  newCharInput.remove();
  listenBody.resume();

}

inputKeyUp(KeyboardEvent e){
  //hack to properly resize input width

  SpanElement span = new SpanElement()
    ..text = newCharInput.value;
  newCharInput.parentNode.append(span);
  newCharInput.style.width = (span.contentEdge.width+10).toString() + "px";
  span.remove();

  //updatechar when press enter
  if (e.keyCode == KeyCode.ENTER) {
    e.preventDefault();
    updateChar();
  }

  else if (e.keyCode == KeyCode.TAB){
    e.preventDefault();
    updateChar();
    if (newCharInput.id == "changeCaret"){
      createNewCharInput("changeChar");
    }
    else if (newCharInput.id == "changeChar"){
      createNewCharInput("changeCaret");
    }
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

settingsClicked(KeyEvent e) {
  popup = new DivElement()
    ..id = "popup"
    ..style.display = "block"
    ..style.top = (settings.offsetTop -3).toString() + "px"
    ..style.left = settings.offsetLeft.toString() + "px";
  document.body.append(popup);
  char_list = new UListElement()
    ..id = "char_list";


  InputElement input = new InputElement()
    ..type = "text"
    ..id = "changeChar"
    ..style.width = "180px"
    ..placeholder = "Press new modifier key";
  popup.append(input);
  input
    ..select()
    ..setSelectionRange(0, 0)
    ..onKeyDown.listen((e) {
    e.preventDefault();
    modKey2 = [e.keyCode];
    popup.remove();
    popup = null;
  });
}