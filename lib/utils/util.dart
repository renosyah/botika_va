String removeHtmlTagFromString(String? text) {
  if (text == null) {
    return "";
  }
  var listTag = ["<B>", "</B>"];
  for (String i in listTag) {
    text = text.toString().replaceAll(i, "");
  }
  return text!.replaceAll("<BR>", "\n");
}

List splice(List list, int index, [num howMany = 0, dynamic elements]) {
  var endIndex = index + howMany.truncate();
  list.removeRange(index, endIndex >= list.length ? list.length : endIndex);
  if (elements != null) {
    list.insertAll(index, elements is List ? elements : <String>[elements]);
  }
  return list;
}

String printDuration(Duration duration) {
  String negativeSign = duration.isNegative ? '-' : '';
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  //return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  return "$twoDigitMinutes:$twoDigitSeconds";
}
