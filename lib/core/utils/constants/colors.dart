import 'package:flutter/material.dart';

const Color tBlack = Colors.black87;
const Color tWhite = Colors.white;
const Color tPurple = Colors.purpleAccent;
const Color tYellow = Colors.yellow;
const Color tGreen = Colors.green;
const Color tRed = Colors.red;
const Color tBlue = Colors.blue;
const Color tIndigo = Colors.indigo;
const Color tOrange = Colors.orange;

const Color tGreyLight = Color.fromRGBO(224, 224, 224, 1);
const Color darkGrey = Color.fromARGB(255, 31, 31, 31);
const Color lighterGrey = Color.fromARGB(255, 131, 129, 129);
const Color blackGrey = Color.fromARGB(255, 19, 19, 19);

const Color tCheckInColor = Color.fromARGB(255, 127, 224, 134);
const Color tCheckOutColor = Color.fromARGB(255, 244, 106, 106);

const greyGradient = [lighterGrey, darkGrey];

const Color tPrimary = Color.fromARGB(255, 1, 37, 55);
const Color tBackground = Color.fromARGB(255, 242, 247, 249);

const Color textColor1 = Colors.black;
const Color disabledText = Color.fromRGBO(190, 190, 190, 1);
const Color metaColor = Color.fromRGBO(0, 129, 251, 1);

// ----- New colors for the modern home screen mockup -----

// Card background for "Search asset" / "Add asset" tiles
const Color tCardBackground = Colors.white;

// Light grey surface used behind the search/add asset tiles
const Color tSurfaceGrey = Color.fromARGB(255, 244, 246, 248);

// Light blue accent text used inside stat cards (icon + sublabel) on the
// dark navy stat card background
const Color tStatAccentLight = Color.fromARGB(255, 181, 212, 244);

// Subtle border color for outlined cards (category tiles, customer tiles)
const Color tBorderLight = Color.fromARGB(255, 227, 227, 224);

// Muted text color for secondary labels / dates / subtitles
const Color tTextMuted = Color.fromARGB(255, 107, 107, 107);

// Inactive bottom nav icon/label color
const Color tNavInactive = Color.fromARGB(255, 168, 168, 164);

// Notification badge color (kept distinct from tRed in case tRed's shade
// changes later)
const Color tBadgeColor = Color.fromARGB(255, 216, 90, 48);

// Active Assets stat card — soft blue tint background with a darker blue
// for the count/label so it reads clearly against the light fill.
const Color tActiveAssetsCardBg = Color.fromARGB(255, 224, 238, 252);
const Color tActiveAssetsCardText = Color.fromARGB(255, 12, 68, 124);

// Checked Out Assets stat card — soft amber/yellow tint background with
// a darker amber for the count/label.
const Color tCheckedOutCardBg = Color.fromARGB(255, 253, 240, 215);
const Color tCheckedOutCardText = Color.fromARGB(255, 133, 79, 11);

// Cycling border palette for list items (Assets by Category, Assets by
// Customer). Loop through with index % tBorderPalette.length so the
// colors repeat once the list is exhausted.
const List<Color> tBorderPalette = [
  Color.fromARGB(255, 97, 158, 244), // purple
  Color.fromARGB(255, 153, 60, 29), // coral
  Color.fromARGB(255, 153, 53, 86), // pink
  Color.fromARGB(255, 24, 95, 165), // blue
  Color.fromARGB(255, 59, 109, 17), // green
  Color.fromARGB(255, 133, 79, 11), // amber
];
