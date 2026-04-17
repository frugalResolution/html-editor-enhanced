import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/utils/i18n.dart';

/// Abstract class that all the toolbar classes extend
abstract class Toolbar {
  const Toolbar();
}

/// Style group
class StyleButtons extends Toolbar {
  final bool style;

  const StyleButtons({
    this.style = true,
  });
}

/// Font setting group
class FontSettingButtons extends Toolbar {
  final bool fontName;
  final bool fontSize;
  final bool fontSizeUnit;

  const FontSettingButtons({
    this.fontName = true,
    this.fontSize = true,
    this.fontSizeUnit = true,
  });
}

/// Font group
class FontButtons extends Toolbar {
  final bool bold;
  final bool italic;
  final bool underline;
  final bool clearAll;
  final bool strikethrough;
  final bool superscript;
  final bool subscript;

  const FontButtons({
    this.bold = true,
    this.italic = true,
    this.underline = true,
    this.clearAll = true,
    this.strikethrough = true,
    this.superscript = true,
    this.subscript = true,
  });

  List<Icon> getIcons1(HtmlToolbarI18n i18n) {
    var icons = <Icon>[];
    if (bold) icons.add(Icon(Icons.format_bold, semanticLabel: i18n.bold));
    if (italic)
      icons.add(Icon(Icons.format_italic, semanticLabel: i18n.italic));
    if (underline) {
      icons.add(Icon(Icons.format_underline, semanticLabel: i18n.underline));
    }
    if (clearAll) {
      icons.add(Icon(Icons.format_clear, semanticLabel: i18n.clearFormatting));
    }
    return icons;
  }

  List<Icon> getIcons2(HtmlToolbarI18n i18n) {
    var icons = <Icon>[];
    if (strikethrough) {
      icons.add(
          Icon(Icons.format_strikethrough, semanticLabel: i18n.strikethrough));
    }
    if (superscript) {
      icons.add(Icon(Icons.superscript, semanticLabel: i18n.superscript));
    }
    if (subscript) {
      icons.add(Icon(Icons.subscript, semanticLabel: i18n.subscript));
    }
    return icons;
  }
}

/// Color bar group
class ColorButtons extends Toolbar {
  final bool foregroundColor;
  final bool highlightColor;

  const ColorButtons({
    this.foregroundColor = true,
    this.highlightColor = true,
  });

  List<Icon> getIcons(HtmlToolbarI18n i18n) {
    var icons = <Icon>[];
    if (foregroundColor) {
      icons.add(Icon(Icons.format_color_text, semanticLabel: i18n.fontColor));
    }
    if (highlightColor) {
      icons.add(
          Icon(Icons.format_color_fill, semanticLabel: i18n.highlightColor));
    }
    return icons;
  }
}

/// List group
class ListButtons extends Toolbar {
  final bool ul;
  final bool ol;
  final bool listStyles;

  const ListButtons({
    this.ul = true,
    this.ol = true,
    this.listStyles = true,
  });

  List<Icon> getIcons(HtmlToolbarI18n i18n) {
    var icons = <Icon>[];
    if (ul) {
      icons.add(
          Icon(Icons.format_list_bulleted, semanticLabel: i18n.unorderedList));
    }
    if (ol) {
      icons.add(
          Icon(Icons.format_list_numbered, semanticLabel: i18n.orderedList));
    }
    return icons;
  }
}

/// Paragraph group
class ParagraphButtons extends Toolbar {
  final bool alignLeft;
  final bool alignCenter;
  final bool alignRight;
  final bool alignJustify;
  final bool increaseIndent;
  final bool decreaseIndent;
  final bool textDirection;
  final bool lineHeight;
  final bool caseConverter;

  const ParagraphButtons({
    this.alignLeft = true,
    this.alignCenter = true,
    this.alignRight = true,
    this.alignJustify = true,
    this.increaseIndent = true,
    this.decreaseIndent = true,
    this.textDirection = true,
    this.lineHeight = true,
    this.caseConverter = true,
  });

  List<Icon> getIcons1(HtmlToolbarI18n i18n) {
    var icons = <Icon>[];
    if (alignLeft) {
      icons.add(Icon(Icons.format_align_left, semanticLabel: i18n.alignLeft));
    }
    if (alignCenter) {
      icons.add(
          Icon(Icons.format_align_center, semanticLabel: i18n.alignCenter));
    }
    if (alignRight) {
      icons.add(Icon(Icons.format_align_right, semanticLabel: i18n.alignRight));
    }
    if (alignJustify) {
      icons.add(
          Icon(Icons.format_align_justify, semanticLabel: i18n.alignJustify));
    }
    return icons;
  }

  List<Icon> getIcons2(HtmlToolbarI18n i18n) {
    var icons = <Icon>[];
    if (increaseIndent) {
      icons.add(Icon(Icons.format_indent_increase,
          semanticLabel: i18n.increaseIndent));
    }
    if (decreaseIndent) {
      icons.add(Icon(Icons.format_indent_decrease,
          semanticLabel: i18n.decreaseIndent));
    }
    return icons;
  }
}

/// Insert group
class InsertButtons extends Toolbar {
  final bool link;
  final bool picture;
  final bool audio;
  final bool video;
  final bool otherFile;
  final bool table;
  final bool hr;

  const InsertButtons({
    this.link = true,
    this.picture = true,
    this.audio = true,
    this.video = true,
    this.otherFile = false,
    this.table = true,
    this.hr = true,
  });

  List<Icon> getIcons(HtmlToolbarI18n i18n) {
    var icons = <Icon>[];
    if (link) icons.add(Icon(Icons.link, semanticLabel: i18n.insertLink));
    if (picture) {
      icons.add(Icon(Icons.image_outlined, semanticLabel: i18n.insertImage));
    }
    if (audio) {
      icons.add(
          Icon(Icons.audiotrack_outlined, semanticLabel: i18n.insertAudio));
    }
    if (video) {
      icons.add(Icon(Icons.videocam_outlined, semanticLabel: i18n.insertVideo));
    }
    if (otherFile) {
      icons.add(Icon(Icons.attach_file, semanticLabel: i18n.insertFile));
    }
    if (table) {
      icons.add(
          Icon(Icons.table_chart_outlined, semanticLabel: i18n.insertTable));
    }
    if (hr) {
      icons.add(Icon(Icons.horizontal_rule,
          semanticLabel: i18n.insertHorizontalRule));
    }
    return icons;
  }
}

/// Miscellaneous group
class OtherButtons extends Toolbar {
  final bool fullscreen;
  final bool codeview;
  final bool undo;
  final bool redo;
  final bool help;
  final bool copy;
  final bool paste;

  const OtherButtons({
    this.fullscreen = true,
    this.codeview = true,
    this.undo = true,
    this.redo = true,
    this.help = true,
    this.copy = true,
    this.paste = true,
  });

  List<Icon> getIcons1(HtmlToolbarI18n i18n) {
    var icons = <Icon>[];
    if (fullscreen) {
      icons.add(Icon(Icons.fullscreen, semanticLabel: i18n.fullscreen));
    }
    if (codeview) icons.add(Icon(Icons.code, semanticLabel: i18n.codeview));
    if (undo) icons.add(Icon(Icons.undo, semanticLabel: i18n.undo));
    if (redo) icons.add(Icon(Icons.redo, semanticLabel: i18n.redo));
    if (help) icons.add(Icon(Icons.help_outline, semanticLabel: i18n.help));
    return icons;
  }

  List<Icon> getIcons2(HtmlToolbarI18n i18n) {
    var icons = <Icon>[];
    if (copy) icons.add(Icon(Icons.copy, semanticLabel: i18n.copy));
    if (paste) icons.add(Icon(Icons.paste, semanticLabel: i18n.paste));
    return icons;
  }
}
