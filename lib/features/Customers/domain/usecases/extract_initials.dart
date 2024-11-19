String extractInitials(String text) {
  String initials = '';
  var split = text.split(" ");
  for (var word in split) {
    if (word.isNotEmpty) {
      initials += word.substring(0, 1);  // Add the first letter of the word
    }
  }
  return initials.toUpperCase();
}