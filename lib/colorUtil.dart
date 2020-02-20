import 'package:avf/model.dart' as model;

// todo: this is temporary, this will be moved to server
List<List<num>> _generateColorsCollection(num themeCount) {
  const colors = [
    [356, 55, 35],
    [13, 51, 54],
    [38, 100, 57],
    [34, 72, 70],
    [49, 56, 50],
    [184, 58, 38],
    [194, 100, 75],
    [209, 54, 59],
    [207, 82, 53],
    [308, 46, 58]
  ];

  var themeColors = List<List<num>>.from(colors);
  var numIter = (themeCount / colors.length).ceil();
  for (var i = 1; i <= numIter; ++i) {
    for (var j = 0; j < colors.length; ++j) {
      themeColors.add([
        colors[j][0] + i * 10,
        colors[j][1] + i * 10,
        colors[j][2] + i * 10
      ]);
    }
  }

  return themeColors;
}

List<model.Theme> addColorsToThemes(themes) {
  var themeColors = _generateColorsCollection(themes.length);
  for (var i = 0; i < themes.length; ++i) {
    var h = themeColors[i][0];
    var s = themeColors[i][1];
    var l = themeColors[i][2];
    themes[i].color = "hsl($h, $s%, $l%)";
  }
  return themes;
}
