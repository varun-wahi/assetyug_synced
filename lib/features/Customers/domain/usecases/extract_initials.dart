String extractInitials(String text){

  String initials = '';
  var split = text.split(" ");
  for (var word in split) {
    initials = initials + word.substring(0, 1);
  }
  return initials.toUpperCase();

}