import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:html_editor_enhanced/utils/utils.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// Toolbar widget class
class ToolbarWidget extends StatefulWidget {
  /// The [HtmlEditorController] is mainly used to call the [execCommand] method
  final HtmlEditorController controller;
  final HtmlToolbarOptions htmlToolbarOptions;
  final Callbacks? callbacks;

  const ToolbarWidget({
    Key? key,
    required this.controller,
    required this.htmlToolbarOptions,
    required this.callbacks,
  }) : super(key: key);

  @override
  ToolbarWidgetState createState() {
    return ToolbarWidgetState();
  }
}

/// Toolbar widget state
class ToolbarWidgetState extends State<ToolbarWidget> {
  /// List that controls which [ToggleButtons] are selected for
  /// bold/italic/underline/clear styles
  List<bool> _fontSelected = List<bool>.filled(4, false);

  /// List that controls which [ToggleButtons] are selected for
  /// strikthrough/superscript/subscript
  List<bool> _miscFontSelected = List<bool>.filled(3, false);

  /// List that controls which [ToggleButtons] are selected for
  /// forecolor/backcolor
  List<bool> _colorSelected = List<bool>.filled(2, false);

  /// List that controls which [ToggleButtons] are selected for
  /// ordered/unordered list
  List<bool> _listSelected = List<bool>.filled(2, false);

  /// List that controls which [ToggleButtons] are selected for
  /// fullscreen, codeview, undo, redo, and help. Fullscreen and codeview
  /// are the only buttons that will ever be selected.
  List<bool> _miscSelected = List<bool>.filled(5, false);

  /// List that controls which [ToggleButtons] are selected for
  /// justify left/right/center/full.
  List<bool> _alignSelected = List<bool>.filled(4, false);

  List<bool> _textDirectionSelected = List<bool>.filled(2, false);

  /// Sets the selected item for the font style dropdown
  String _fontSelectedItem = 'p';

  String _fontNameSelectedItem = 'sans-serif';

  /// Sets the selected item for the font size dropdown
  double _fontSizeSelectedItem = 3;

  /// Sets the selected item for the font units dropdown
  String _fontSizeUnitSelectedItem = 'pt';

  /// Sets the selected item for the foreground color dialog
  Color _foreColorSelected = Colors.black;

  /// Sets the selected item for the background color dialog
  Color _backColorSelected = Colors.yellow;

  /// Sets the selected item for the list style dropdown
  String? _listStyleSelectedItem;

  /// Sets the selected item for the line height dropdown
  double _lineHeightSelectedItem = 1;

  /// Masks the toolbar with a grey color if false
  bool _enabled = true;

  /// Tracks the expanded status of the toolbar
  bool _isExpanded = false;

  void disable() {
    this.setState(() {
      _enabled = false;
    });
  }

  void enable() {
    this.setState(() {
      _enabled = true;
    });
  }

  void updateToolbar(Map<String, dynamic>? json) {
    this.setState(() {});
  }

  @override
  void initState() {
    widget.controller.toolbar = this;
    _isExpanded = widget.htmlToolbarOptions.initiallyExpanded;
    for (var t in widget.htmlToolbarOptions.defaultToolbarButtons) {
      if (t is FontButtons) {
        _fontSelected = List<bool>.filled(
            t.getIcons1(widget.htmlToolbarOptions.i18n).length, false);
        _miscFontSelected = List<bool>.filled(
            t.getIcons2(widget.htmlToolbarOptions.i18n).length, false);
      }
      if (t is ColorButtons) {
        _colorSelected = List<bool>.filled(
            t.getIcons(widget.htmlToolbarOptions.i18n).length, false);
      }
      if (t is ListButtons) {
        _listSelected = List<bool>.filled(
            t.getIcons(widget.htmlToolbarOptions.i18n).length, false);
      }
      if (t is ParagraphButtons) {
        _alignSelected = List<bool>.filled(
            t.getIcons1(widget.htmlToolbarOptions.i18n).length, false);
      }
      if (t is OtherButtons) {
        _miscSelected = List<bool>.filled(
            t.getIcons1(widget.htmlToolbarOptions.i18n).length, false);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.htmlToolbarOptions.toolbarType == ToolbarType.nativeGrid) {
      return AbsorbPointer(
        absorbing: !_enabled,
        child: Opacity(
          opacity: _enabled ? 1 : 0.5,
          child: Column(
            children: [
              GridView.count(
                padding: const EdgeInsets.all(5),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width ~/
                    widget.htmlToolbarOptions.toolbarItemHeight,
                childAspectRatio: 1,
                mainAxisSpacing:
                    widget.htmlToolbarOptions.gridViewVerticalSpacing,
                crossAxisSpacing:
                    widget.htmlToolbarOptions.gridViewHorizontalSpacing,
                children: _buildChildren(),
              ),
            ],
          ),
        ),
      );
    } else if (widget.htmlToolbarOptions.toolbarType ==
        ToolbarType.nativeScrollable) {
      return AbsorbPointer(
        absorbing: !_enabled,
        child: Opacity(
          opacity: _enabled ? 1 : 0.5,
          child: Container(
            height: widget.htmlToolbarOptions.toolbarItemHeight + 10,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              children: intersperse(
                widget.htmlToolbarOptions.renderSeparatorWidget
                    ? widget.htmlToolbarOptions.separatorWidget
                    : Container(width: 0, height: 0),
                _buildChildren(),
              ).toList(),
            ),
          ),
        ),
      );
    } else if (widget.htmlToolbarOptions.toolbarType ==
        ToolbarType.nativeExpandable) {
      return AbsorbPointer(
        absorbing: !_enabled,
        child: Opacity(
          opacity: _enabled ? 1 : 0.5,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: _isExpanded
                  ? double.infinity
                  : widget.htmlToolbarOptions.toolbarItemHeight + 15,
            ),
            child: CustomScrollView(
              shrinkWrap: true,
              physics: _isExpanded
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ExpandIconDelegate(
                      widget.htmlToolbarOptions.toolbarItemHeight + 15,
                      _isExpanded, () {
                    setState(mounted, this.setState, () {
                      _isExpanded = !_isExpanded;
                    });
                  }),
                ),
                _isExpanded
                    ? SliverPadding(
                        padding: const EdgeInsets.all(5),
                        sliver: SliverGrid.count(
                          crossAxisCount: MediaQuery.of(context).size.width ~/
                              widget.htmlToolbarOptions.toolbarItemHeight,
                          childAspectRatio: 1,
                          mainAxisSpacing:
                              widget.htmlToolbarOptions.gridViewVerticalSpacing,
                          crossAxisSpacing: widget
                              .htmlToolbarOptions.gridViewHorizontalSpacing,
                          children: _buildChildren(),
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: Container(
                          height:
                              widget.htmlToolbarOptions.toolbarItemHeight + 15,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            children: intersperse(
                              widget.htmlToolbarOptions.renderSeparatorWidget
                                  ? widget.htmlToolbarOptions.separatorWidget
                                  : Container(width: 0, height: 0),
                              _buildChildren(),
                            ).toList(),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(height: 0, width: 0);
  }

  List<Widget> _buildChildren() {
    var toolbarChildren = <Widget>[];
    for (var t in widget.htmlToolbarOptions.defaultToolbarButtons) {
      if (t is StyleButtons && t.style) {
        toolbarChildren.add(Container(
          padding: const EdgeInsets.only(left: 8.0),
          height: widget.htmlToolbarOptions.toolbarItemHeight,
          decoration: !widget.htmlToolbarOptions.renderBorder
              ? null
              : widget.htmlToolbarOptions.dropdownBoxDecoration ??
                  BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.12))),
          child: CustomDropdownButtonHideUnderline(
            child: CustomDropdownButton<String>(
              elevation: widget.htmlToolbarOptions.dropdownElevation,
              icon: widget.htmlToolbarOptions.dropdownIcon,
              iconEnabledColor: widget.htmlToolbarOptions.dropdownIconColor,
              iconSize: widget.htmlToolbarOptions.dropdownIconSize,
              itemHeight: widget.htmlToolbarOptions.dropdownItemHeight,
              focusColor: widget.htmlToolbarOptions.dropdownFocusColor,
              dropdownColor: widget.htmlToolbarOptions.dropdownBackgroundColor,
              menuDirection: widget.htmlToolbarOptions.dropdownMenuDirection ??
                  (widget.htmlToolbarOptions.toolbarPosition ==
                          ToolbarPosition.belowEditor
                      ? DropdownMenuDirection.up
                      : DropdownMenuDirection.down),
              menuMaxHeight: widget.htmlToolbarOptions.dropdownMenuMaxHeight ??
                  MediaQuery.of(context).size.height / 3,
              style: widget.htmlToolbarOptions.textStyle,
              items: [
                CustomDropdownMenuItem(
                    value: 'p',
                    child: PointerInterceptor(
                        child: Text(widget.htmlToolbarOptions.i18n.normal))),
                CustomDropdownMenuItem(
                    value: 'blockquote',
                    child: PointerInterceptor(
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: Colors.grey, width: 3.0))),
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(widget.htmlToolbarOptions.i18n.quote,
                              style: TextStyle(
                                  fontFamily: 'times', color: Colors.grey))),
                    )),
                CustomDropdownMenuItem(
                    value: 'pre',
                    child: PointerInterceptor(
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey),
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(widget.htmlToolbarOptions.i18n.code,
                              style: TextStyle(
                                  fontFamily: 'courier', color: Colors.white))),
                    )),
                CustomDropdownMenuItem(
                  value: 'h1',
                  child: PointerInterceptor(
                      child: Text(widget.htmlToolbarOptions.i18n.header1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 32))),
                ),
                CustomDropdownMenuItem(
                  value: 'h2',
                  child: PointerInterceptor(
                      child: Text(widget.htmlToolbarOptions.i18n.header2,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24))),
                ),
                CustomDropdownMenuItem(
                  value: 'h3',
                  child: PointerInterceptor(
                      child: Text(widget.htmlToolbarOptions.i18n.header3,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18))),
                ),
                CustomDropdownMenuItem(
                  value: 'h4',
                  child: PointerInterceptor(
                      child: Text(widget.htmlToolbarOptions.i18n.header4,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16))),
                ),
                CustomDropdownMenuItem(
                  value: 'h5',
                  child: PointerInterceptor(
                      child: Text(widget.htmlToolbarOptions.i18n.header5,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13))),
                ),
                CustomDropdownMenuItem(
                  value: 'h6',
                  child: PointerInterceptor(
                      child: Text(widget.htmlToolbarOptions.i18n.header6,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                ),
              ],
              value: _fontSelectedItem,
              onChanged: (String? changed) async {
                void updateSelectedItem(dynamic changed) {
                  if (changed is String) {
                    setState(mounted, this.setState, () {
                      _fontSelectedItem = changed;
                    });
                  }
                }

                if (changed != null) {
                  var proceed =
                      await widget.htmlToolbarOptions.onDropdownChanged?.call(
                              DropdownType.style,
                              changed,
                              updateSelectedItem) ??
                          true;
                  if (proceed) {
                    widget.controller
                        .execCommand('formatBlock', argument: changed);
                    updateSelectedItem(changed);
                  }
                }
              },
            ),
          ),
        ));
      }
      if (t is FontSettingButtons) {
        if (t.fontName) {
          toolbarChildren.add(Container(
            padding: const EdgeInsets.only(left: 8.0),
            height: widget.htmlToolbarOptions.toolbarItemHeight,
            decoration: !widget.htmlToolbarOptions.renderBorder
                ? null
                : widget.htmlToolbarOptions.dropdownBoxDecoration ??
                    BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.12))),
            child: CustomDropdownButtonHideUnderline(
              child: CustomDropdownButton<String>(
                elevation: widget.htmlToolbarOptions.dropdownElevation,
                icon: widget.htmlToolbarOptions.dropdownIcon,
                iconEnabledColor: widget.htmlToolbarOptions.dropdownIconColor,
                iconSize: widget.htmlToolbarOptions.dropdownIconSize,
                itemHeight: widget.htmlToolbarOptions.dropdownItemHeight,
                focusColor: widget.htmlToolbarOptions.dropdownFocusColor,
                dropdownColor:
                    widget.htmlToolbarOptions.dropdownBackgroundColor,
                menuDirection:
                    widget.htmlToolbarOptions.dropdownMenuDirection ??
                        (widget.htmlToolbarOptions.toolbarPosition ==
                                ToolbarPosition.belowEditor
                            ? DropdownMenuDirection.up
                            : DropdownMenuDirection.down),
                menuMaxHeight:
                    widget.htmlToolbarOptions.dropdownMenuMaxHeight ??
                        MediaQuery.of(context).size.height / 3,
                style: widget.htmlToolbarOptions.textStyle,
                items: [
                  CustomDropdownMenuItem(
                    value: 'Courier New',
                    child: PointerInterceptor(
                        child: Text('Courier New',
                            style: TextStyle(fontFamily: 'courier'))),
                  ),
                  CustomDropdownMenuItem(
                    value: 'sans-serif',
                    child: PointerInterceptor(
                        child: Text('Sans Serif',
                            style: TextStyle(fontFamily: 'sans-serif'))),
                  ),
                  CustomDropdownMenuItem(
                    value: 'Times New Roman',
                    child: PointerInterceptor(
                        child: Text('Times New Roman',
                            style: TextStyle(fontFamily: 'times'))),
                  ),
                ],
                value: _fontNameSelectedItem,
                onChanged: (String? changed) async {
                  void updateSelectedItem(dynamic changed) {
                    if (changed is String) {
                      setState(mounted, this.setState, () {
                        _fontNameSelectedItem = changed;
                      });
                    }
                  }

                  if (changed != null) {
                    var proceed =
                        await widget.htmlToolbarOptions.onDropdownChanged?.call(
                                DropdownType.fontName,
                                changed,
                                updateSelectedItem) ??
                            true;
                    if (proceed) {
                      widget.controller
                          .execCommand('fontName', argument: changed);
                      updateSelectedItem(changed);
                    }
                  }
                },
              ),
            ),
          ));
        }
        if (t.fontSize) {
          toolbarChildren.add(Container(
            padding: const EdgeInsets.only(left: 8.0),
            height: widget.htmlToolbarOptions.toolbarItemHeight,
            decoration: !widget.htmlToolbarOptions.renderBorder
                ? null
                : widget.htmlToolbarOptions.dropdownBoxDecoration ??
                    BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.12))),
            child: CustomDropdownButtonHideUnderline(
              child: CustomDropdownButton<double>(
                elevation: widget.htmlToolbarOptions.dropdownElevation,
                icon: widget.htmlToolbarOptions.dropdownIcon,
                iconEnabledColor: widget.htmlToolbarOptions.dropdownIconColor,
                iconSize: widget.htmlToolbarOptions.dropdownIconSize,
                itemHeight: widget.htmlToolbarOptions.dropdownItemHeight,
                focusColor: widget.htmlToolbarOptions.dropdownFocusColor,
                dropdownColor:
                    widget.htmlToolbarOptions.dropdownBackgroundColor,
                menuDirection:
                    widget.htmlToolbarOptions.dropdownMenuDirection ??
                        (widget.htmlToolbarOptions.toolbarPosition ==
                                ToolbarPosition.belowEditor
                            ? DropdownMenuDirection.up
                            : DropdownMenuDirection.down),
                menuMaxHeight:
                    widget.htmlToolbarOptions.dropdownMenuMaxHeight ??
                        MediaQuery.of(context).size.height / 3,
                style: widget.htmlToolbarOptions.textStyle,
                items: [
                  CustomDropdownMenuItem(
                    value: 1,
                    child: PointerInterceptor(child: Text('1')),
                  ),
                  CustomDropdownMenuItem(
                    value: 2,
                    child: PointerInterceptor(child: Text('2')),
                  ),
                  CustomDropdownMenuItem(
                    value: 3,
                    child: PointerInterceptor(child: Text('3')),
                  ),
                  CustomDropdownMenuItem(
                    value: 4,
                    child: PointerInterceptor(child: Text('4')),
                  ),
                  CustomDropdownMenuItem(
                    value: 5,
                    child: PointerInterceptor(child: Text('5')),
                  ),
                  CustomDropdownMenuItem(
                    value: 6,
                    child: PointerInterceptor(child: Text('6')),
                  ),
                  CustomDropdownMenuItem(
                    value: 7,
                    child: PointerInterceptor(child: Text('7')),
                  ),
                ],
                value: _fontSizeSelectedItem,
                onChanged: (double? changed) async {
                  void updateSelectedItem(dynamic changed) {
                    if (changed is double) {
                      setState(mounted, this.setState, () {
                        _fontSizeSelectedItem = changed;
                      });
                    }
                  }

                  if (changed != null) {
                    var proceed =
                        await widget.htmlToolbarOptions.onDropdownChanged?.call(
                                DropdownType.fontSize,
                                changed,
                                updateSelectedItem) ??
                            true;
                    if (proceed) {
                      widget.controller.execCommand('fontSize',
                          argument: changed.toString());
                      updateSelectedItem(changed);
                    }
                  }
                },
              ),
            ),
          ));
        }
        if (t.fontSizeUnit) {
          toolbarChildren.add(Container(
            padding: const EdgeInsets.only(left: 8.0),
            height: widget.htmlToolbarOptions.toolbarItemHeight,
            decoration: !widget.htmlToolbarOptions.renderBorder
                ? null
                : widget.htmlToolbarOptions.dropdownBoxDecoration ??
                    BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.12))),
            child: CustomDropdownButtonHideUnderline(
              child: CustomDropdownButton<String>(
                elevation: widget.htmlToolbarOptions.dropdownElevation,
                icon: widget.htmlToolbarOptions.dropdownIcon,
                iconEnabledColor: widget.htmlToolbarOptions.dropdownIconColor,
                iconSize: widget.htmlToolbarOptions.dropdownIconSize,
                itemHeight: widget.htmlToolbarOptions.dropdownItemHeight,
                focusColor: widget.htmlToolbarOptions.dropdownFocusColor,
                dropdownColor:
                    widget.htmlToolbarOptions.dropdownBackgroundColor,
                menuDirection:
                    widget.htmlToolbarOptions.dropdownMenuDirection ??
                        (widget.htmlToolbarOptions.toolbarPosition ==
                                ToolbarPosition.belowEditor
                            ? DropdownMenuDirection.up
                            : DropdownMenuDirection.down),
                menuMaxHeight:
                    widget.htmlToolbarOptions.dropdownMenuMaxHeight ??
                        MediaQuery.of(context).size.height / 3,
                style: widget.htmlToolbarOptions.textStyle,
                items: [
                  CustomDropdownMenuItem(
                    value: 'pt',
                    child: PointerInterceptor(child: Text('pt')),
                  ),
                  CustomDropdownMenuItem(
                    value: 'px',
                    child: PointerInterceptor(child: Text('px')),
                  ),
                ],
                value: _fontSizeUnitSelectedItem,
                onChanged: (String? changed) async {
                  void updateSelectedItem(dynamic changed) {
                    if (changed is String) {
                      setState(mounted, this.setState, () {
                        _fontSizeUnitSelectedItem = changed;
                      });
                    }
                  }

                  if (changed != null) {
                    var proceed =
                        await widget.htmlToolbarOptions.onDropdownChanged?.call(
                                DropdownType.fontSizeUnit,
                                changed,
                                updateSelectedItem) ??
                            true;
                    if (proceed) {
                      updateSelectedItem(changed);
                    }
                  }
                },
              ),
            ),
          ));
        }
      }
      if (t is FontButtons &&
          (t.bold || t.italic || t.underline || t.clearAll)) {
        toolbarChildren.add(ToggleButtons(
          constraints: BoxConstraints.tightFor(
            width: widget.htmlToolbarOptions.toolbarItemHeight - 2,
            height: widget.htmlToolbarOptions.toolbarItemHeight - 2,
          ),
          color: widget.htmlToolbarOptions.buttonColor,
          selectedColor: widget.htmlToolbarOptions.buttonSelectedColor,
          fillColor: widget.htmlToolbarOptions.buttonFillColor,
          focusColor: widget.htmlToolbarOptions.buttonFocusColor,
          highlightColor: widget.htmlToolbarOptions.buttonHighlightColor,
          hoverColor: widget.htmlToolbarOptions.buttonHoverColor,
          splashColor: widget.htmlToolbarOptions.buttonSplashColor,
          selectedBorderColor:
              widget.htmlToolbarOptions.buttonSelectedBorderColor,
          borderColor: widget.htmlToolbarOptions.buttonBorderColor,
          borderRadius: widget.htmlToolbarOptions.buttonBorderRadius,
          borderWidth: widget.htmlToolbarOptions.buttonBorderWidth,
          renderBorder: widget.htmlToolbarOptions.renderBorder,
          textStyle: widget.htmlToolbarOptions.textStyle,
          onPressed: (int index) async {
            void updateStatus() {
              setState(mounted, this.setState, () {
                _fontSelected[index] = !_fontSelected[index];
              });
            }

            if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                Icons.format_bold) {
              var proceed = await widget.htmlToolbarOptions.onButtonPressed
                      ?.call(ButtonType.bold, _fontSelected[index],
                          updateStatus) ??
                  true;
              if (proceed) {
                widget.controller.execCommand('bold');
                updateStatus();
              }
            }
            if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                Icons.format_italic) {
              var proceed = await widget.htmlToolbarOptions.onButtonPressed
                      ?.call(ButtonType.italic, _fontSelected[index],
                          updateStatus) ??
                  true;
              if (proceed) {
                widget.controller.execCommand('italic');
                updateStatus();
              }
            }
            if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                Icons.format_underline) {
              var proceed = await widget.htmlToolbarOptions.onButtonPressed
                      ?.call(ButtonType.underline, _fontSelected[index],
                          updateStatus) ??
                  true;
              if (proceed) {
                widget.controller.execCommand('underline');
                updateStatus();
              }
            }
            if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                Icons.format_clear) {
              var proceed = await widget.htmlToolbarOptions.onButtonPressed
                      ?.call(ButtonType.clearFormatting, null, null) ??
                  true;
              if (proceed) {
                widget.controller.execCommand('removeFormat');
              }
            }
          },
          isSelected: _fontSelected,
          children: t.getIcons1(widget.htmlToolbarOptions.i18n),
        ));
      }
      if (t is FontButtons &&
          (t.strikethrough || t.superscript || t.subscript)) {
        if (t.getIcons2(widget.htmlToolbarOptions.i18n).isNotEmpty) {
          toolbarChildren.add(ToggleButtons(
            constraints: BoxConstraints.tightFor(
              width: widget.htmlToolbarOptions.toolbarItemHeight - 2,
              height: widget.htmlToolbarOptions.toolbarItemHeight - 2,
            ),
            color: widget.htmlToolbarOptions.buttonColor,
            selectedColor: widget.htmlToolbarOptions.buttonSelectedColor,
            fillColor: widget.htmlToolbarOptions.buttonFillColor,
            focusColor: widget.htmlToolbarOptions.buttonFocusColor,
            highlightColor: widget.htmlToolbarOptions.buttonHighlightColor,
            hoverColor: widget.htmlToolbarOptions.buttonHoverColor,
            splashColor: widget.htmlToolbarOptions.buttonSplashColor,
            selectedBorderColor:
                widget.htmlToolbarOptions.buttonSelectedBorderColor,
            borderColor: widget.htmlToolbarOptions.buttonBorderColor,
            borderRadius: widget.htmlToolbarOptions.buttonBorderRadius,
            borderWidth: widget.htmlToolbarOptions.buttonBorderWidth,
            renderBorder: widget.htmlToolbarOptions.renderBorder,
            textStyle: widget.htmlToolbarOptions.textStyle,
            onPressed: (int index) async {
              void updateStatus() {
                setState(mounted, this.setState, () {
                  _miscFontSelected[index] = !_miscFontSelected[index];
                });
              }

              if (t.getIcons2(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.format_strikethrough) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.strikethrough,
                            _miscFontSelected[index], updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('strikethrough');
                  updateStatus();
                }
              }
              if (t.getIcons2(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.superscript) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.superscript, _miscFontSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('superscript');
                  updateStatus();
                }
              }
              if (t.getIcons2(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.subscript) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.subscript, _miscFontSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('subscript');
                  updateStatus();
                }
              }
            },
            isSelected: _miscFontSelected,
            children: t.getIcons2(widget.htmlToolbarOptions.i18n),
          ));
        }
      }
      if (t is ColorButtons && (t.foregroundColor || t.highlightColor)) {
        toolbarChildren.add(ToggleButtons(
          constraints: BoxConstraints.tightFor(
            width: widget.htmlToolbarOptions.toolbarItemHeight - 2,
            height: widget.htmlToolbarOptions.toolbarItemHeight - 2,
          ),
          color: widget.htmlToolbarOptions.buttonColor,
          selectedColor: widget.htmlToolbarOptions.buttonSelectedColor,
          fillColor: widget.htmlToolbarOptions.buttonFillColor,
          focusColor: widget.htmlToolbarOptions.buttonFocusColor,
          highlightColor: widget.htmlToolbarOptions.buttonHighlightColor,
          hoverColor: widget.htmlToolbarOptions.buttonHoverColor,
          splashColor: widget.htmlToolbarOptions.buttonSplashColor,
          selectedBorderColor:
              widget.htmlToolbarOptions.buttonSelectedBorderColor,
          borderColor: widget.htmlToolbarOptions.buttonBorderColor,
          borderRadius: widget.htmlToolbarOptions.buttonBorderRadius,
          borderWidth: widget.htmlToolbarOptions.buttonBorderWidth,
          renderBorder: widget.htmlToolbarOptions.renderBorder,
          textStyle: widget.htmlToolbarOptions.textStyle,
          onPressed: (int index) async {
            void updateStatus(Color? color) {
              setState(mounted, this.setState, () {
                _colorSelected[index] = !_colorSelected[index];
                if (color != null &&
                    t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                        Icons.format_color_text) {
                  _foreColorSelected = color;
                }
                if (color != null &&
                    t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                        Icons.format_color_fill) {
                  _backColorSelected = color;
                }
              });
            }

            if (_colorSelected[index]) {
              if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.format_color_text) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.foregroundColor,
                            _colorSelected[index], updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('foreColor',
                      argument: (Colors.black.toARGB32() & 0xFFFFFF)
                          .toRadixString(16)
                          .padLeft(6, '0')
                          .toUpperCase());
                  updateStatus(null);
                }
              }
              if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.format_color_fill) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.highlightColor, _colorSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('hiliteColor',
                      argument: (Colors.yellow.toARGB32() & 0xFFFFFF)
                          .toRadixString(16)
                          .padLeft(6, '0')
                          .toUpperCase());
                  updateStatus(null);
                }
              }
            } else {
              var proceed = true;
              if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.format_color_text) {
                proceed = await widget.htmlToolbarOptions.onButtonPressed?.call(
                        ButtonType.foregroundColor,
                        _colorSelected[index],
                        updateStatus) ??
                    true;
              } else if (t
                      .getIcons(widget.htmlToolbarOptions.i18n)[index]
                      .icon ==
                  Icons.format_color_fill) {
                proceed = await widget.htmlToolbarOptions.onButtonPressed?.call(
                        ButtonType.highlightColor,
                        _colorSelected[index],
                        updateStatus) ??
                    true;
              }
              if (proceed) {
                late Color newColor;
                if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                    Icons.format_color_text) {
                  newColor = _foreColorSelected;
                } else {
                  newColor = _backColorSelected;
                }
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PointerInterceptor(
                        child: AlertDialog(
                          scrollable: true,
                          content: ColorPicker(
                            color: newColor,
                            onColorChanged: (color) {
                              newColor = color;
                            },
                            title: Text(
                                t
                                            .getIcons(widget
                                                .htmlToolbarOptions.i18n)[index]
                                            .icon ==
                                        Icons.format_color_text
                                    ? widget.htmlToolbarOptions.i18n.fontColor
                                    : widget
                                        .htmlToolbarOptions.i18n.highlightColor,
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            width: 40,
                            height: 40,
                            spacing: 0,
                            runSpacing: 0,
                            borderRadius: 0,
                            wheelDiameter: 165,
                            enableOpacity: false,
                            showColorCode: true,
                            colorCodeHasColor: true,
                            pickersEnabled: <ColorPickerType, bool>{
                              ColorPickerType.wheel: true,
                            },
                            copyPasteBehavior:
                                const ColorPickerCopyPasteBehavior(
                              parseShortHexCode: true,
                            ),
                            actionButtons: const ColorPickerActionButtons(
                              dialogActionButtons: true,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child:
                                  Text(widget.htmlToolbarOptions.i18n.cancel),
                            ),
                            TextButton(
                                onPressed: () {
                                  if (t
                                          .getIcons(widget
                                              .htmlToolbarOptions.i18n)[index]
                                          .icon ==
                                      Icons.format_color_text) {
                                    setState(mounted, this.setState, () {
                                      _foreColorSelected = Colors.black;
                                    });
                                    widget.controller.execCommand(
                                        'removeFormat',
                                        argument: 'foreColor');
                                    widget.controller.execCommand('foreColor',
                                        argument: 'initial');
                                  }
                                  if (t
                                          .getIcons(widget
                                              .htmlToolbarOptions.i18n)[index]
                                          .icon ==
                                      Icons.format_color_fill) {
                                    setState(mounted, this.setState, () {
                                      _backColorSelected = Colors.yellow;
                                    });
                                    widget.controller.execCommand(
                                        'removeFormat',
                                        argument: 'hiliteColor');
                                    widget.controller.execCommand('hiliteColor',
                                        argument: 'initial');
                                  }
                                  Navigator.of(context).pop();
                                },
                                child:
                                    Text(widget.htmlToolbarOptions.i18n.reset)),
                            TextButton(
                              onPressed: () {
                                if (t
                                        .getIcons(widget
                                            .htmlToolbarOptions.i18n)[index]
                                        .icon ==
                                    Icons.format_color_text) {
                                  widget.controller.execCommand('foreColor',
                                      argument: (newColor.toARGB32() & 0xFFFFFF)
                                          .toRadixString(16)
                                          .padLeft(6, '0')
                                          .toUpperCase());
                                  setState(mounted, this.setState, () {
                                    _foreColorSelected = newColor;
                                  });
                                }
                                if (t
                                        .getIcons(widget
                                            .htmlToolbarOptions.i18n)[index]
                                        .icon ==
                                    Icons.format_color_fill) {
                                  widget.controller.execCommand('hiliteColor',
                                      argument: (newColor.toARGB32() & 0xFFFFFF)
                                          .toRadixString(16)
                                          .padLeft(6, '0')
                                          .toUpperCase());
                                  setState(mounted, this.setState, () {
                                    _backColorSelected = newColor;
                                  });
                                }
                                Navigator.of(context).pop();
                                updateStatus(newColor);
                              },
                              child: Text(widget.htmlToolbarOptions.i18n.ok),
                            ),
                          ],
                        ),
                      );
                    });
              }
            }
          },
          isSelected: _colorSelected,
          children: t.getIcons(widget.htmlToolbarOptions.i18n),
        ));
      }
      if (t is ListButtons && (t.ul || t.ol || t.listStyles)) {
        if (t.ul || t.ol) {
          toolbarChildren.add(ToggleButtons(
            constraints: BoxConstraints.tightFor(
              width: widget.htmlToolbarOptions.toolbarItemHeight - 2,
              height: widget.htmlToolbarOptions.toolbarItemHeight - 2,
            ),
            color: widget.htmlToolbarOptions.buttonColor,
            selectedColor: widget.htmlToolbarOptions.buttonSelectedColor,
            fillColor: widget.htmlToolbarOptions.buttonFillColor,
            focusColor: widget.htmlToolbarOptions.buttonFocusColor,
            highlightColor: widget.htmlToolbarOptions.buttonHighlightColor,
            hoverColor: widget.htmlToolbarOptions.buttonHoverColor,
            splashColor: widget.htmlToolbarOptions.buttonSplashColor,
            selectedBorderColor:
                widget.htmlToolbarOptions.buttonSelectedBorderColor,
            borderColor: widget.htmlToolbarOptions.buttonBorderColor,
            borderRadius: widget.htmlToolbarOptions.buttonBorderRadius,
            borderWidth: widget.htmlToolbarOptions.buttonBorderWidth,
            renderBorder: widget.htmlToolbarOptions.renderBorder,
            textStyle: widget.htmlToolbarOptions.textStyle,
            onPressed: (int index) async {
              void updateStatus() {
                setState(mounted, this.setState, () {
                  _listSelected[index] = !_listSelected[index];
                });
              }

              if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.format_list_bulleted) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.ul, _listSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('insertUnorderedList');
                  updateStatus();
                }
              }
              if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.format_list_numbered) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.ol, _listSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('insertOrderedList');
                  updateStatus();
                }
              }
            },
            isSelected: _listSelected,
            children: t.getIcons(widget.htmlToolbarOptions.i18n),
          ));
        }
        if (t.listStyles) {
          toolbarChildren.add(Container(
            padding: const EdgeInsets.only(left: 8.0),
            height: widget.htmlToolbarOptions.toolbarItemHeight,
            decoration: !widget.htmlToolbarOptions.renderBorder
                ? null
                : widget.htmlToolbarOptions.dropdownBoxDecoration ??
                    BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.12))),
            child: CustomDropdownButtonHideUnderline(
              child: CustomDropdownButton<String>(
                elevation: widget.htmlToolbarOptions.dropdownElevation,
                icon: widget.htmlToolbarOptions.dropdownIcon,
                iconEnabledColor: widget.htmlToolbarOptions.dropdownIconColor,
                iconSize: widget.htmlToolbarOptions.dropdownIconSize,
                itemHeight: widget.htmlToolbarOptions.dropdownItemHeight,
                focusColor: widget.htmlToolbarOptions.dropdownFocusColor,
                dropdownColor:
                    widget.htmlToolbarOptions.dropdownBackgroundColor,
                menuDirection:
                    widget.htmlToolbarOptions.dropdownMenuDirection ??
                        (widget.htmlToolbarOptions.toolbarPosition ==
                                ToolbarPosition.belowEditor
                            ? DropdownMenuDirection.up
                            : DropdownMenuDirection.down),
                menuMaxHeight:
                    widget.htmlToolbarOptions.dropdownMenuMaxHeight ??
                        MediaQuery.of(context).size.height / 3,
                style: widget.htmlToolbarOptions.textStyle,
                items: [
                  CustomDropdownMenuItem(
                    value: 'decimal',
                    child: PointerInterceptor(
                        child: Text(
                            '1. ${widget.htmlToolbarOptions.i18n.numbered}')),
                  ),
                  CustomDropdownMenuItem(
                    value: 'lower-alpha',
                    child: PointerInterceptor(
                        child: Text(
                            'a. ${widget.htmlToolbarOptions.i18n.lowerAlpha}')),
                  ),
                  CustomDropdownMenuItem(
                    value: 'lower-roman',
                    child: PointerInterceptor(
                        child: Text(
                            'i. ${widget.htmlToolbarOptions.i18n.lowerRoman}')),
                  ),
                  CustomDropdownMenuItem(
                    value: 'upper-alpha',
                    child: PointerInterceptor(
                        child: Text(
                            'A. ${widget.htmlToolbarOptions.i18n.upperAlpha}')),
                  ),
                  CustomDropdownMenuItem(
                    value: 'upper-roman',
                    child: PointerInterceptor(
                        child: Text(
                            'I. ${widget.htmlToolbarOptions.i18n.upperRoman}')),
                  ),
                  CustomDropdownMenuItem(
                    value: 'disc',
                    child: PointerInterceptor(
                        child:
                            Text('• ${widget.htmlToolbarOptions.i18n.disc}')),
                  ),
                  CustomDropdownMenuItem(
                    value: 'circle',
                    child: PointerInterceptor(
                        child:
                            Text('○ ${widget.htmlToolbarOptions.i18n.circle}')),
                  ),
                  CustomDropdownMenuItem(
                    value: 'square',
                    child: PointerInterceptor(
                        child:
                            Text('■ ${widget.htmlToolbarOptions.i18n.square}')),
                  ),
                ],
                hint: Text(widget.htmlToolbarOptions.i18n.listStyle),
                value: _listStyleSelectedItem,
                onChanged: (String? changed) async {
                  void updateSelectedItem(dynamic changed) {
                    if (changed is String) {
                      setState(mounted, this.setState, () {
                        _listStyleSelectedItem = changed;
                      });
                    }
                  }

                  if (changed != null) {
                    var proceed =
                        await widget.htmlToolbarOptions.onDropdownChanged?.call(
                                DropdownType.listStyles,
                                changed,
                                updateSelectedItem) ??
                            true;
                    if (proceed) {
                      widget.controller.changeListStyle(changed);
                      updateSelectedItem(changed);
                    }
                  }
                },
              ),
            ),
          ));
        }
      }
      if (t is ParagraphButtons) {
        if (t.alignLeft || t.alignCenter || t.alignRight || t.alignJustify) {
          toolbarChildren.add(ToggleButtons(
            constraints: BoxConstraints.tightFor(
              width: widget.htmlToolbarOptions.toolbarItemHeight - 2,
              height: widget.htmlToolbarOptions.toolbarItemHeight - 2,
            ),
            color: widget.htmlToolbarOptions.buttonColor,
            selectedColor: widget.htmlToolbarOptions.buttonSelectedColor,
            fillColor: widget.htmlToolbarOptions.buttonFillColor,
            focusColor: widget.htmlToolbarOptions.buttonFocusColor,
            highlightColor: widget.htmlToolbarOptions.buttonHighlightColor,
            hoverColor: widget.htmlToolbarOptions.buttonHoverColor,
            splashColor: widget.htmlToolbarOptions.buttonSplashColor,
            selectedBorderColor:
                widget.htmlToolbarOptions.buttonSelectedBorderColor,
            borderColor: widget.htmlToolbarOptions.buttonBorderColor,
            borderRadius: widget.htmlToolbarOptions.buttonBorderRadius,
            borderWidth: widget.htmlToolbarOptions.buttonBorderWidth,
            renderBorder: widget.htmlToolbarOptions.renderBorder,
            textStyle: widget.htmlToolbarOptions.textStyle,
            onPressed: (int index) async {
              void updateStatus() {
                setState(mounted, this.setState, () {
                  _alignSelected =
                      List<bool>.filled(_alignSelected.length, false);
                  _alignSelected[index] = true;
                });
              }

              if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.format_align_left) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.alignLeft, _alignSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('justifyLeft');
                  updateStatus();
                }
              }
              if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.format_align_center) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.alignCenter, _alignSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('justifyCenter');
                  updateStatus();
                }
              }
              if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.format_align_right) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.alignRight, _alignSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('justifyRight');
                  updateStatus();
                }
              }
              if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.format_align_justify) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.alignJustify, _alignSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('justifyFull');
                  updateStatus();
                }
              }
            },
            isSelected: _alignSelected,
            children: t.getIcons1(widget.htmlToolbarOptions.i18n),
          ));
        }
        if (t.increaseIndent || t.decreaseIndent) {
          toolbarChildren.add(ToggleButtons(
            constraints: BoxConstraints.tightFor(
              width: widget.htmlToolbarOptions.toolbarItemHeight - 2,
              height: widget.htmlToolbarOptions.toolbarItemHeight - 2,
            ),
            color: widget.htmlToolbarOptions.buttonColor,
            selectedColor: widget.htmlToolbarOptions.buttonSelectedColor,
            fillColor: widget.htmlToolbarOptions.buttonFillColor,
            focusColor: widget.htmlToolbarOptions.buttonFocusColor,
            highlightColor: widget.htmlToolbarOptions.buttonHighlightColor,
            hoverColor: widget.htmlToolbarOptions.buttonHoverColor,
            splashColor: widget.htmlToolbarOptions.buttonSplashColor,
            selectedBorderColor:
                widget.htmlToolbarOptions.buttonSelectedBorderColor,
            borderColor: widget.htmlToolbarOptions.buttonBorderColor,
            borderRadius: widget.htmlToolbarOptions.buttonBorderRadius,
            borderWidth: widget.htmlToolbarOptions.buttonBorderWidth,
            renderBorder: widget.htmlToolbarOptions.renderBorder,
            textStyle: widget.htmlToolbarOptions.textStyle,
            onPressed: (int index) async {
              if (t.getIcons2(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.format_indent_increase) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.increaseIndent, null, null) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('indent');
                }
              }
              if (t.getIcons2(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.format_indent_decrease) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.decreaseIndent, null, null) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('outdent');
                }
              }
            },
            isSelected: List<bool>.filled(
                t.getIcons2(widget.htmlToolbarOptions.i18n).length, false),
            children: t.getIcons2(widget.htmlToolbarOptions.i18n),
          ));
        }
        if (t.textDirection) {
          toolbarChildren.add(ToggleButtons(
            constraints: BoxConstraints.tightFor(
              width: widget.htmlToolbarOptions.toolbarItemHeight - 2,
              height: widget.htmlToolbarOptions.toolbarItemHeight - 2,
            ),
            color: widget.htmlToolbarOptions.buttonColor,
            selectedColor: widget.htmlToolbarOptions.buttonSelectedColor,
            fillColor: widget.htmlToolbarOptions.buttonFillColor,
            focusColor: widget.htmlToolbarOptions.buttonFocusColor,
            highlightColor: widget.htmlToolbarOptions.buttonHighlightColor,
            hoverColor: widget.htmlToolbarOptions.buttonHoverColor,
            splashColor: widget.htmlToolbarOptions.buttonSplashColor,
            selectedBorderColor:
                widget.htmlToolbarOptions.buttonSelectedBorderColor,
            borderColor: widget.htmlToolbarOptions.buttonBorderColor,
            borderRadius: widget.htmlToolbarOptions.buttonBorderRadius,
            borderWidth: widget.htmlToolbarOptions.buttonBorderWidth,
            renderBorder: widget.htmlToolbarOptions.renderBorder,
            textStyle: widget.htmlToolbarOptions.textStyle,
            onPressed: (int index) async {
              void updateStatus() {
                setState(mounted, this.setState, () {
                  _textDirectionSelected =
                      List<bool>.filled(_textDirectionSelected.length, false);
                  _textDirectionSelected[index] = true;
                });
              }

              if (index == 0) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.ltr, _textDirectionSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.changeTextDirection('ltr');
                  updateStatus();
                }
              }
              if (index == 1) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.rtl, _textDirectionSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.changeTextDirection('rtl');
                  updateStatus();
                }
              }
            },
            isSelected: _textDirectionSelected,
            children: [
              Icon(
                Icons.format_textdirection_l_to_r,
                semanticLabel: widget.htmlToolbarOptions.i18n.ltr,
              ),
              Icon(
                Icons.format_textdirection_r_to_l,
                semanticLabel: widget.htmlToolbarOptions.i18n.rtl,
              ),
            ],
          ));
        }
        if (t.lineHeight) {
          toolbarChildren.add(Container(
            padding: const EdgeInsets.only(left: 8.0),
            height: widget.htmlToolbarOptions.toolbarItemHeight,
            decoration: !widget.htmlToolbarOptions.renderBorder
                ? null
                : widget.htmlToolbarOptions.dropdownBoxDecoration ??
                    BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.12))),
            child: CustomDropdownButtonHideUnderline(
              child: CustomDropdownButton<double>(
                elevation: widget.htmlToolbarOptions.dropdownElevation,
                icon: widget.htmlToolbarOptions.dropdownIcon,
                iconEnabledColor: widget.htmlToolbarOptions.dropdownIconColor,
                iconSize: widget.htmlToolbarOptions.dropdownIconSize,
                itemHeight: widget.htmlToolbarOptions.dropdownItemHeight,
                focusColor: widget.htmlToolbarOptions.dropdownFocusColor,
                dropdownColor:
                    widget.htmlToolbarOptions.dropdownBackgroundColor,
                menuDirection:
                    widget.htmlToolbarOptions.dropdownMenuDirection ??
                        (widget.htmlToolbarOptions.toolbarPosition ==
                                ToolbarPosition.belowEditor
                            ? DropdownMenuDirection.up
                            : DropdownMenuDirection.down),
                menuMaxHeight:
                    widget.htmlToolbarOptions.dropdownMenuMaxHeight ??
                        MediaQuery.of(context).size.height / 3,
                style: widget.htmlToolbarOptions.textStyle,
                items: [
                  CustomDropdownMenuItem(
                    value: 1,
                    child: PointerInterceptor(child: Text('1.0')),
                  ),
                  CustomDropdownMenuItem(
                    value: 1.2,
                    child: PointerInterceptor(child: Text('1.2')),
                  ),
                  CustomDropdownMenuItem(
                    value: 1.4,
                    child: PointerInterceptor(child: Text('1.4')),
                  ),
                  CustomDropdownMenuItem(
                    value: 1.5,
                    child: PointerInterceptor(child: Text('1.5')),
                  ),
                  CustomDropdownMenuItem(
                    value: 1.6,
                    child: PointerInterceptor(child: Text('1.6')),
                  ),
                  CustomDropdownMenuItem(
                    value: 1.8,
                    child: PointerInterceptor(child: Text('1.8')),
                  ),
                  CustomDropdownMenuItem(
                    value: 2,
                    child: PointerInterceptor(child: Text('2.0')),
                  ),
                  CustomDropdownMenuItem(
                    value: 3,
                    child: PointerInterceptor(child: Text('3.0')),
                  ),
                ],
                hint: Text(widget.htmlToolbarOptions.i18n.lineHeight),
                value: _lineHeightSelectedItem,
                onChanged: (double? changed) async {
                  void updateSelectedItem(dynamic changed) {
                    if (changed is double) {
                      setState(mounted, this.setState, () {
                        _lineHeightSelectedItem = changed;
                      });
                    }
                  }

                  if (changed != null) {
                    var proceed =
                        await widget.htmlToolbarOptions.onDropdownChanged?.call(
                                DropdownType.lineHeight,
                                changed,
                                updateSelectedItem) ??
                            true;
                    if (proceed) {
                      widget.controller.changeLineHeight(changed.toString());
                      updateSelectedItem(changed);
                    }
                  }
                },
              ),
            ),
          ));
        }
        if (t.caseConverter) {
          toolbarChildren.add(Container(
            padding: const EdgeInsets.only(left: 8.0),
            height: widget.htmlToolbarOptions.toolbarItemHeight,
            decoration: !widget.htmlToolbarOptions.renderBorder
                ? null
                : widget.htmlToolbarOptions.dropdownBoxDecoration ??
                    BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.12))),
            child: CustomDropdownButtonHideUnderline(
              child: CustomDropdownButton<String>(
                elevation: widget.htmlToolbarOptions.dropdownElevation,
                icon: widget.htmlToolbarOptions.dropdownIcon,
                iconEnabledColor: widget.htmlToolbarOptions.dropdownIconColor,
                iconSize: widget.htmlToolbarOptions.dropdownIconSize,
                itemHeight: widget.htmlToolbarOptions.dropdownItemHeight,
                focusColor: widget.htmlToolbarOptions.dropdownFocusColor,
                dropdownColor:
                    widget.htmlToolbarOptions.dropdownBackgroundColor,
                menuDirection:
                    widget.htmlToolbarOptions.dropdownMenuDirection ??
                        (widget.htmlToolbarOptions.toolbarPosition ==
                                ToolbarPosition.belowEditor
                            ? DropdownMenuDirection.up
                            : DropdownMenuDirection.down),
                menuMaxHeight:
                    widget.htmlToolbarOptions.dropdownMenuMaxHeight ??
                        MediaQuery.of(context).size.height / 3,
                style: widget.htmlToolbarOptions.textStyle,
                items: [
                  CustomDropdownMenuItem(
                    value: 'lowerCase',
                    child: PointerInterceptor(
                        child: Text(widget.htmlToolbarOptions.i18n.lowercase)),
                  ),
                  CustomDropdownMenuItem(
                    value: 'sentenceCase',
                    child: PointerInterceptor(
                        child:
                            Text(widget.htmlToolbarOptions.i18n.sentenceCase)),
                  ),
                  CustomDropdownMenuItem(
                    value: 'titleCase',
                    child: PointerInterceptor(
                        child: Text(widget.htmlToolbarOptions.i18n.titleCase)),
                  ),
                  CustomDropdownMenuItem(
                    value: 'upperCase',
                    child: PointerInterceptor(
                        child: Text(widget.htmlToolbarOptions.i18n.uppercase)),
                  ),
                ],
                hint: Text(widget.htmlToolbarOptions.i18n.caseConverter),
                onChanged: (String? changed) async {
                  if (changed != null) {
                    var proceed = await widget
                            .htmlToolbarOptions.onDropdownChanged
                            ?.call(DropdownType.caseConverter, changed, null) ??
                        true;
                    if (proceed) {
                      if (changed == 'lowerCase') {
                        widget.controller.execCommand('toLowerCase');
                      } else if (changed == 'sentenceCase') {
                        widget.controller.execCommand('toSentenceCase');
                      } else if (changed == 'titleCase') {
                        widget.controller.execCommand('toTitleCase');
                      } else if (changed == 'upperCase') {
                        widget.controller.execCommand('toUpperCase');
                      }
                    }
                  }
                },
              ),
            ),
          ));
        }
      }
      if (t is InsertButtons) {
        toolbarChildren.add(ToggleButtons(
          constraints: BoxConstraints.tightFor(
            width: widget.htmlToolbarOptions.toolbarItemHeight - 2,
            height: widget.htmlToolbarOptions.toolbarItemHeight - 2,
          ),
          color: widget.htmlToolbarOptions.buttonColor,
          selectedColor: widget.htmlToolbarOptions.buttonSelectedColor,
          fillColor: widget.htmlToolbarOptions.buttonFillColor,
          focusColor: widget.htmlToolbarOptions.buttonFocusColor,
          highlightColor: widget.htmlToolbarOptions.buttonHighlightColor,
          hoverColor: widget.htmlToolbarOptions.buttonHoverColor,
          splashColor: widget.htmlToolbarOptions.buttonSplashColor,
          selectedBorderColor:
              widget.htmlToolbarOptions.buttonSelectedBorderColor,
          borderColor: widget.htmlToolbarOptions.buttonBorderColor,
          borderRadius: widget.htmlToolbarOptions.buttonBorderRadius,
          borderWidth: widget.htmlToolbarOptions.buttonBorderWidth,
          renderBorder: widget.htmlToolbarOptions.renderBorder,
          textStyle: widget.htmlToolbarOptions.textStyle,
          onPressed: (int index) async {
            if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                Icons.link) {
              var proceed = await widget.htmlToolbarOptions.onButtonPressed
                      ?.call(ButtonType.link, null, null) ??
                  true;
              if (proceed) {
                var text = TextEditingController();
                var url = TextEditingController();
                var isNewWindow = true;
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PointerInterceptor(
                        child: StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return AlertDialog(
                              scrollable: true,
                              title: Text(
                                  widget.htmlToolbarOptions.i18n.insertLink),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      widget.htmlToolbarOptions.i18n
                                          .textToDisplay,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: text,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(widget.htmlToolbarOptions.i18n.url,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: url,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Checkbox(
                                          value: isNewWindow,
                                          onChanged: (value) {
                                            setState(() {
                                              isNewWindow = value!;
                                            });
                                          }),
                                      const SizedBox(width: 5),
                                      Text(widget.htmlToolbarOptions.i18n
                                          .openInNewWindow),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                      widget.htmlToolbarOptions.i18n.cancel),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    var proceed = await widget
                                            .htmlToolbarOptions
                                            .linkInsertInterceptor
                                            ?.call(text.text, url.text,
                                                isNewWindow) ??
                                        true;
                                    if (proceed) {
                                      widget.controller.insertLink(
                                          text.text, url.text, isNewWindow);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child:
                                      Text(widget.htmlToolbarOptions.i18n.ok),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    });
              }
            }
            if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                Icons.image_outlined) {
              var proceed = await widget.htmlToolbarOptions.onButtonPressed
                      ?.call(ButtonType.picture, null, null) ??
                  true;
              if (proceed) {
                var url = TextEditingController();
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PointerInterceptor(
                        child: AlertDialog(
                          scrollable: true,
                          title:
                              Text(widget.htmlToolbarOptions.i18n.insertImage),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.htmlToolbarOptions.allowImagePicking)
                                Text(
                                    widget.htmlToolbarOptions.i18n
                                        .selectFromFiles,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.htmlToolbarOptions.allowImagePicking)
                                const SizedBox(height: 10),
                              if (widget.htmlToolbarOptions.allowImagePicking)
                                ElevatedButton(
                                  onPressed: () async {
                                    var result = await FilePicker.platform
                                        .pickFiles(
                                            type: FileType.image,
                                            allowMultiple: false);
                                    if (result != null &&
                                        result.files.isNotEmpty) {
                                      var proceed = await widget
                                              .htmlToolbarOptions
                                              .mediaUploadInterceptor
                                              ?.call(result.files.first,
                                                  InsertFileType.image) ??
                                          true;
                                      if (proceed) {
                                        widget.controller.insertHtml(
                                            "<img src='data:image/${result.files.first.extension};base64,${base64Encode(result.files.first.bytes!)}' />");
                                      }
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Text(widget
                                      .htmlToolbarOptions.i18n.chooseImage),
                                ),
                              if (widget.htmlToolbarOptions.allowImagePicking)
                                const SizedBox(height: 20),
                              Text(widget.htmlToolbarOptions.i18n.url,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              TextField(
                                controller: url,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child:
                                  Text(widget.htmlToolbarOptions.i18n.cancel),
                            ),
                            TextButton(
                              onPressed: () async {
                                var proceed = await widget.htmlToolbarOptions
                                        .mediaLinkInsertInterceptor
                                        ?.call(
                                            url.text, InsertFileType.image) ??
                                    true;
                                if (proceed) {
                                  widget.controller
                                      .insertNetworkImage(url.text);
                                }
                                Navigator.of(context).pop();
                              },
                              child: Text(widget.htmlToolbarOptions.i18n.ok),
                            ),
                          ],
                        ),
                      );
                    });
              }
            }
            if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                Icons.audiotrack_outlined) {
              var proceed = await widget.htmlToolbarOptions.onButtonPressed
                      ?.call(ButtonType.audio, null, null) ??
                  true;
              if (proceed) {
                var url = TextEditingController();
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PointerInterceptor(
                        child: AlertDialog(
                          scrollable: true,
                          title:
                              Text(widget.htmlToolbarOptions.i18n.insertAudio),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  widget
                                      .htmlToolbarOptions.i18n.selectFromFiles,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  var result = await FilePicker.platform
                                      .pickFiles(
                                          type: FileType.audio,
                                          allowMultiple: false);
                                  if (result != null &&
                                      result.files.isNotEmpty) {
                                    var proceed = await widget
                                            .htmlToolbarOptions
                                            .mediaUploadInterceptor
                                            ?.call(result.files.first,
                                                InsertFileType.audio) ??
                                        true;
                                    if (proceed) {
                                      widget.controller.insertHtml(
                                          "<audio controls src='data:audio/${result.files.first.extension};base64,${base64Encode(result.files.first.bytes!)}'></audio>");
                                    }
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text(
                                    widget.htmlToolbarOptions.i18n.chooseAudio),
                              ),
                              const SizedBox(height: 20),
                              Text(widget.htmlToolbarOptions.i18n.url,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              TextField(
                                controller: url,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child:
                                  Text(widget.htmlToolbarOptions.i18n.cancel),
                            ),
                            TextButton(
                              onPressed: () async {
                                var proceed = await widget.htmlToolbarOptions
                                        .mediaLinkInsertInterceptor
                                        ?.call(
                                            url.text, InsertFileType.audio) ??
                                    true;
                                if (proceed) {
                                  widget.controller.insertHtml(
                                      "<audio controls src='${url.text}'></audio>");
                                }
                                Navigator.of(context).pop();
                              },
                              child: Text(widget.htmlToolbarOptions.i18n.ok),
                            ),
                          ],
                        ),
                      );
                    });
              }
            }
            if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                Icons.videocam_outlined) {
              var proceed = await widget.htmlToolbarOptions.onButtonPressed
                      ?.call(ButtonType.video, null, null) ??
                  true;
              if (proceed) {
                var url = TextEditingController();
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PointerInterceptor(
                        child: AlertDialog(
                          scrollable: true,
                          title:
                              Text(widget.htmlToolbarOptions.i18n.insertVideo),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  widget
                                      .htmlToolbarOptions.i18n.selectFromFiles,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  var result = await FilePicker.platform
                                      .pickFiles(
                                          type: FileType.video,
                                          allowMultiple: false);
                                  if (result != null &&
                                      result.files.isNotEmpty) {
                                    var proceed = await widget
                                            .htmlToolbarOptions
                                            .mediaUploadInterceptor
                                            ?.call(result.files.first,
                                                InsertFileType.video) ??
                                        true;
                                    if (proceed) {
                                      widget.controller.insertHtml(
                                          "<video controls src='data:video/${result.files.first.extension};base64,${base64Encode(result.files.first.bytes!)}'></video>");
                                    }
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text(
                                    widget.htmlToolbarOptions.i18n.chooseVideo),
                              ),
                              const SizedBox(height: 20),
                              Text(widget.htmlToolbarOptions.i18n.url,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              TextField(
                                controller: url,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child:
                                  Text(widget.htmlToolbarOptions.i18n.cancel),
                            ),
                            TextButton(
                              onPressed: () async {
                                var proceed = await widget.htmlToolbarOptions
                                        .mediaLinkInsertInterceptor
                                        ?.call(
                                            url.text, InsertFileType.video) ??
                                    true;
                                if (proceed) {
                                  widget.controller.insertHtml(
                                      "<video controls src='${url.text}'></video>");
                                }
                                Navigator.of(context).pop();
                              },
                              child: Text(widget.htmlToolbarOptions.i18n.ok),
                            ),
                          ],
                        ),
                      );
                    });
              }
            }
            if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                Icons.attach_file) {
              var proceed = await widget.htmlToolbarOptions.onButtonPressed
                      ?.call(ButtonType.otherFile, null, null) ??
                  true;
              if (proceed) {
                var url = TextEditingController();
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PointerInterceptor(
                        child: AlertDialog(
                          scrollable: true,
                          title:
                              Text(widget.htmlToolbarOptions.i18n.insertFile),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  widget
                                      .htmlToolbarOptions.i18n.selectFromFiles,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  var result = await FilePicker.platform
                                      .pickFiles(allowMultiple: false);
                                  if (result != null &&
                                      result.files.isNotEmpty) {
                                    widget.htmlToolbarOptions.onOtherFileUpload
                                        ?.call(result.files.first);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text(
                                    widget.htmlToolbarOptions.i18n.chooseFile),
                              ),
                              const SizedBox(height: 20),
                              Text(widget.htmlToolbarOptions.i18n.url,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              TextField(
                                controller: url,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child:
                                  Text(widget.htmlToolbarOptions.i18n.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                widget.htmlToolbarOptions.onOtherFileLinkInsert
                                    ?.call(url.text);
                                Navigator.of(context).pop();
                              },
                              child: Text(widget.htmlToolbarOptions.i18n.ok),
                            ),
                          ],
                        ),
                      );
                    });
              }
            }
            if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                Icons.table_chart_outlined) {
              var proceed = await widget.htmlToolbarOptions.onButtonPressed
                      ?.call(ButtonType.table, null, null) ??
                  true;
              if (proceed) {
                var rows = 2;
                var cols = 2;
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PointerInterceptor(
                        child: StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return AlertDialog(
                              scrollable: true,
                              title: Text(
                                  widget.htmlToolbarOptions.i18n.insertTable),
                              content: Row(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(widget.htmlToolbarOptions.i18n.rows),
                                      NumberPicker(
                                        value: rows,
                                        minValue: 1,
                                        maxValue: 10,
                                        onChanged: (value) {
                                          setState(() {
                                            rows = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  Text('x'),
                                  const SizedBox(width: 20),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(widget
                                          .htmlToolbarOptions.i18n.columns),
                                      NumberPicker(
                                        value: cols,
                                        minValue: 1,
                                        maxValue: 10,
                                        onChanged: (value) {
                                          setState(() {
                                            cols = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                      widget.htmlToolbarOptions.i18n.cancel),
                                ),
                                TextButton(
                                  onPressed: () {
                                    widget.controller
                                        .insertTable('${cols}x$rows');
                                    Navigator.of(context).pop();
                                  },
                                  child:
                                      Text(widget.htmlToolbarOptions.i18n.ok),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    });
              }
            }
            if (t.getIcons(widget.htmlToolbarOptions.i18n)[index].icon ==
                Icons.horizontal_rule) {
              var proceed = await widget.htmlToolbarOptions.onButtonPressed
                      ?.call(ButtonType.hr, null, null) ??
                  true;
              if (proceed) {
                widget.controller.execCommand('insertHorizontalRule');
              }
            }
          },
          isSelected: List<bool>.filled(
              t.getIcons(widget.htmlToolbarOptions.i18n).length, false),
          children: t.getIcons(widget.htmlToolbarOptions.i18n),
        ));
      }
      if (t is OtherButtons) {
        if (t.getIcons1(widget.htmlToolbarOptions.i18n).isNotEmpty) {
          toolbarChildren.add(ToggleButtons(
            constraints: BoxConstraints.tightFor(
              width: widget.htmlToolbarOptions.toolbarItemHeight - 2,
              height: widget.htmlToolbarOptions.toolbarItemHeight - 2,
            ),
            color: widget.htmlToolbarOptions.buttonColor,
            selectedColor: widget.htmlToolbarOptions.buttonSelectedColor,
            fillColor: widget.htmlToolbarOptions.buttonFillColor,
            focusColor: widget.htmlToolbarOptions.buttonFocusColor,
            highlightColor: widget.htmlToolbarOptions.buttonHighlightColor,
            hoverColor: widget.htmlToolbarOptions.buttonHoverColor,
            splashColor: widget.htmlToolbarOptions.buttonSplashColor,
            selectedBorderColor:
                widget.htmlToolbarOptions.buttonSelectedBorderColor,
            borderColor: widget.htmlToolbarOptions.buttonBorderColor,
            borderRadius: widget.htmlToolbarOptions.buttonBorderRadius,
            borderWidth: widget.htmlToolbarOptions.buttonBorderWidth,
            renderBorder: widget.htmlToolbarOptions.renderBorder,
            textStyle: widget.htmlToolbarOptions.textStyle,
            onPressed: (int index) async {
              void updateStatus() {
                setState(mounted, this.setState, () {
                  _miscSelected[index] = !_miscSelected[index];
                });
              }

              if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.fullscreen) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.fullscreen, _miscSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.toggleFullScreen();
                  updateStatus();
                }
              }
              if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.code) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.codeview, _miscSelected[index],
                            updateStatus) ??
                    true;
                if (proceed) {
                  widget.controller.toggleCodeView();
                  updateStatus();
                }
              }
              if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.undo) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.undo, null, null) ??
                    true;
                if (proceed) {
                  widget.controller.undo();
                }
              }
              if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.redo) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.redo, null, null) ??
                    true;
                if (proceed) {
                  widget.controller.redo();
                }
              }
              if (t.getIcons1(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.help_outline) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.help, null, null) ??
                    true;
                if (proceed) {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PointerInterceptor(
                          child: AlertDialog(
                            title:
                                Text(widget.htmlToolbarOptions.i18n.helpTitle),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DataTable(
                                    columns: [
                                      DataColumn(
                                          label: Text(widget.htmlToolbarOptions
                                              .i18n.helpAction)),
                                      DataColumn(
                                          label: Text(widget.htmlToolbarOptions
                                              .i18n.helpShortcut)),
                                    ],
                                    rows: [
                                      DataRow(cells: [
                                        DataCell(Text(widget.htmlToolbarOptions
                                            .i18n.helpEscape)),
                                        DataCell(Text('ESC')),
                                      ]),
                                      DataRow(cells: [
                                        DataCell(Text(widget.htmlToolbarOptions
                                            .i18n.helpInsertParagraph)),
                                        DataCell(Text('ENTER')),
                                      ]),
                                      DataRow(cells: [
                                        DataCell(Text(widget
                                            .htmlToolbarOptions.i18n.helpUndo)),
                                        DataCell(Text('CTRL+Z')),
                                      ]),
                                      DataRow(cells: [
                                        DataCell(Text(widget
                                            .htmlToolbarOptions.i18n.helpRedo)),
                                        DataCell(Text('CTRL+Y')),
                                      ]),
                                      DataRow(cells: [
                                        DataCell(Text('TAB')),
                                        DataCell(Text('TAB')),
                                      ]),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(widget.htmlToolbarOptions.i18n.ok),
                              ),
                            ],
                          ),
                        );
                      });
                }
              }
            },
            isSelected: _miscSelected,
            children: t.getIcons1(widget.htmlToolbarOptions.i18n),
          ));
        }
        if (t.getIcons2(widget.htmlToolbarOptions.i18n).isNotEmpty) {
          toolbarChildren.add(ToggleButtons(
            constraints: BoxConstraints.tightFor(
              width: widget.htmlToolbarOptions.toolbarItemHeight - 2,
              height: widget.htmlToolbarOptions.toolbarItemHeight - 2,
            ),
            color: widget.htmlToolbarOptions.buttonColor,
            selectedColor: widget.htmlToolbarOptions.buttonSelectedColor,
            fillColor: widget.htmlToolbarOptions.buttonFillColor,
            focusColor: widget.htmlToolbarOptions.buttonFocusColor,
            highlightColor: widget.htmlToolbarOptions.buttonHighlightColor,
            hoverColor: widget.htmlToolbarOptions.buttonHoverColor,
            splashColor: widget.htmlToolbarOptions.buttonSplashColor,
            selectedBorderColor:
                widget.htmlToolbarOptions.buttonSelectedBorderColor,
            borderColor: widget.htmlToolbarOptions.buttonBorderColor,
            borderRadius: widget.htmlToolbarOptions.buttonBorderRadius,
            borderWidth: widget.htmlToolbarOptions.buttonBorderWidth,
            renderBorder: widget.htmlToolbarOptions.renderBorder,
            textStyle: widget.htmlToolbarOptions.textStyle,
            onPressed: (int index) async {
              if (t.getIcons2(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.copy) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.copy, null, null) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('copy');
                }
              }
              if (t.getIcons2(widget.htmlToolbarOptions.i18n)[index].icon ==
                  Icons.paste) {
                var proceed = await widget.htmlToolbarOptions.onButtonPressed
                        ?.call(ButtonType.paste, null, null) ??
                    true;
                if (proceed) {
                  widget.controller.execCommand('paste');
                }
              }
            },
            isSelected: List<bool>.filled(
                t.getIcons2(widget.htmlToolbarOptions.i18n).length, false),
            children: t.getIcons2(widget.htmlToolbarOptions.i18n),
          ));
        }
      }
    }
    return toolbarChildren;
  }
}
