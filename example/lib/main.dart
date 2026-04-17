import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:html_editor_enhanced/utils/i18n.dart';

class ExampleI18n {
  static const Map<String, String> de = {
    'title': 'Flutter HTML Editor Beispiel',
    'refresh': 'Aktualisieren',
    'toggleCodeView': 'Code-Ansicht umschalten',
    'hint': 'Dein Text hier...',
    'undo': 'Rückgängig',
    'reset': 'Zurücksetzen',
    'submit': 'Absenden',
    'redo': 'Wiederholen',
    'disable': 'Deaktivieren',
    'enable': 'Aktivieren',
    'insertText': 'Text einfügen',
    'insertHtml': 'HTML einfügen',
    'insertLink': 'Link einfügen',
    'insertNetworkImage': 'Netzwerkbild einfügen',
    'info': 'Info',
    'warning': 'Warnung',
    'success': 'Erfolg',
    'danger': 'Gefahr',
    'plaintext': 'Klartext',
    'remove': 'Entfernen',
  };

  static const Map<String, String> en = {
    'title': 'Flutter HTML Editor Example',
    'refresh': 'Refresh',
    'toggleCodeView': 'Toggle Code View',
    'hint': 'Your text here...',
    'undo': 'Undo',
    'reset': 'Reset',
    'submit': 'Submit',
    'redo': 'Redo',
    'disable': 'Disable',
    'enable': 'Enable',
    'insertText': 'Insert Text',
    'insertHtml': 'Insert HTML',
    'insertLink': 'Insert Link',
    'insertNetworkImage': 'Insert Network Image',
    'info': 'Info',
    'warning': 'Warning',
    'success': 'Success',
    'danger': 'Danger',
    'plaintext': 'Plaintext',
    'remove': 'Remove',
  };

  static const Map<String, String> es = {
    'title': 'Ejemplo de Flutter HTML Editor',
    'refresh': 'Actualizar',
    'toggleCodeView': 'Alternar Vista de Código',
    'hint': 'Tu texto aquí...',
    'undo': 'Deshacer',
    'reset': 'Restablecer',
    'submit': 'Enviar',
    'redo': 'Rehacer',
    'disable': 'Desactivar',
    'enable': 'Activar',
    'insertText': 'Insertar Texto',
    'insertHtml': 'Insertar HTML',
    'insertLink': 'Insertar Enlace',
    'insertNetworkImage': 'Insertar Imagen de Red',
    'info': 'Info',
    'warning': 'Advertencia',
    'success': 'Éxito',
    'danger': 'Peligro',
    'plaintext': 'Texto plano',
    'remove': 'Eliminar',
  };

  static const Map<String, String> jp = {
    'title': 'Flutter HTMLエディタ 例',
    'refresh': '更新',
    'toggleCodeView': 'コード表示切替',
    'hint': 'ここにテキストを入力...',
    'undo': '元に戻す',
    'reset': 'リセット',
    'submit': '送信',
    'redo': 'やり直し',
    'disable': '無効化',
    'enable': '有効化',
    'insertText': 'テキスト挿入',
    'insertHtml': 'HTML挿入',
    'insertLink': 'リンク挿入',
    'insertNetworkImage': 'ネットワーク画像挿入',
    'info': '情報',
    'warning': '警告',
    'success': '成功',
    'danger': '危険',
    'plaintext': 'プレーンテキスト',
    'remove': '削除',
  };

  static Map<String, String> getTranslations(String langCode) {
    switch (langCode) {
      case 'de':
        return de;
      case 'es':
        return es;
      case 'ja':
        return jp;
      default:
        return en;
    }
  }
}

void main() => runApp(HtmlEditorExampleApp());

class HtmlEditorExampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      locale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('de', 'DE'),
        Locale('es', 'ES'),
        Locale('ja', 'JP'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HtmlEditorExample(),
    );
  }
}

class HtmlEditorExample extends StatefulWidget {
  const HtmlEditorExample({Key? key}) : super(key: key);

  @override
  _HtmlEditorExampleState createState() => _HtmlEditorExampleState();
}

class _HtmlEditorExampleState extends State<HtmlEditorExample> {
  String result = '';
  final HtmlEditorController controller = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    String currentLang = Localizations.localeOf(context).languageCode;
    Map<String, String> i18n = ExampleI18n.getTranslations(currentLang);
    HtmlToolbarI18n toolbarI18n;
    switch (currentLang) {
      case 'de':
        toolbarI18n = HtmlToolbarI18n.de;
        break;
      case 'es':
        toolbarI18n = HtmlToolbarI18n.es;
        break;
      case 'ja':
        toolbarI18n = HtmlToolbarI18n.jp;
        break;
      default:
        toolbarI18n = HtmlToolbarI18n.en;
        break;
    }

    return GestureDetector(
      onTap: () {
        if (!kIsWeb) {
          controller.clearFocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(i18n['title']!),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                if (kIsWeb) {
                  controller.reloadWeb();
                } else {
                  controller.editorController!.reload();
                }
              },
              tooltip: i18n['refresh'],
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.toggleCodeView();
          },
          child: Semantics(
            excludeSemantics: true,
            child: Text(
              r'<\>',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          tooltip: i18n['toggleCodeView'],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              HtmlEditor(
                controller: controller,
                htmlEditorOptions: HtmlEditorOptions(
                  hint: i18n['hint'],
                  shouldEnsureVisible: true,
                  lang: currentLang,
                  //initialText: "<p>text content initial, if any</p>",
                ),
                htmlToolbarOptions: HtmlToolbarOptions(
                  toolbarPosition: ToolbarPosition.aboveEditor, //by default
                  toolbarType: ToolbarType.nativeScrollable, //by default
                  i18n: toolbarI18n,
                  onButtonPressed:
                      (ButtonType type, bool? status, Function? updateStatus) {
                    print(
                        "button '${type.name}' pressed, the current selected status is $status");
                    return true;
                  },
                  onDropdownChanged: (DropdownType type, dynamic changed,
                      Function(dynamic)? updateSelectedItem) {
                    print("dropdown '${type.name}' changed to $changed");
                    return true;
                  },
                  mediaLinkInsertInterceptor:
                      (String url, InsertFileType type) {
                    print(url);
                    return true;
                  },
                  mediaUploadInterceptor:
                      (PlatformFile file, InsertFileType type) async {
                    print(file.name); //filename
                    print(file.size); //size in bytes
                    print(file.extension); //file extension (eg jpeg or mp4)
                    return true;
                  },
                ),
                otherOptions: OtherOptions(height: 550),
                callbacks: Callbacks(onBeforeCommand: (String? currentHtml) {
                  print('html before change is $currentHtml');
                }, onChangeContent: (String? changed) {
                  print('content changed to $changed');
                }, onChangeCodeview: (String? changed) {
                  print('code changed to $changed');
                }, onChangeSelection: (EditorSettings settings) {
                  print('parent element is ${settings.parentElement}');
                  print('font name is ${settings.fontName}');
                }, onDialogShown: () {
                  print('dialog shown');
                }, onEnter: () {
                  print('enter/return pressed');
                }, onFocus: () {
                  print('editor focused');
                }, onBlur: () {
                  print('editor unfocused');
                }, onBlurCodeview: () {
                  print('codeview either focused or unfocused');
                }, onInit: () {
                  print('init');
                  // Inject the language into the WebView's HTML DOM
                  controller.editorController!.evaluateJavascript(
                      source:
                          "document.documentElement.lang = '$currentLang'; document.querySelector('.note-editable').lang = '$currentLang';");
                },
                    //this is commented because it overrides the default Summernote handlers
                    /*onImageLinkInsert: (String? url) {
                    print(url ?? "unknown url");
                  },
                  onImageUpload: (FileUpload file) async {
                    print(file.name);
                    print(file.size);
                    print(file.type);
                    print(file.base64);
                  },*/
                    onImageUploadError: (FileUpload? file, String? base64Str,
                        UploadError error) {
                  print(error.name);
                  print(base64Str ?? '');
                  if (file != null) {
                    print(file.name);
                    print(file.size);
                    print(file.type);
                  }
                }, onKeyDown: (int? keyCode) {
                  print('$keyCode key downed');
                  print(
                      'current character count: ${controller.characterCount}');
                }, onKeyUp: (int? keyCode) {
                  print('$keyCode key released');
                }, onMouseDown: () {
                  print('mouse downed');
                }, onMouseUp: () {
                  print('mouse released');
                }, onNavigationRequestMobile: (String url) {
                  print(url);
                  return NavigationActionPolicy.ALLOW;
                }, onPaste: () {
                  print('pasted into editor');
                }, onScroll: () {
                  print('editor scrolled');
                }),
                plugins: [
                  SummernoteAtMention(
                      getSuggestionsMobile: (String value) {
                        var mentions = <String>['test1', 'test2', 'test3'];
                        return mentions
                            .where((element) => element.contains(value))
                            .toList();
                      },
                      mentionsWeb: ['test1', 'test2', 'test3'],
                      onSelect: (String value) {
                        print(value);
                      }),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16.0,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.undo();
                      },
                      child: Text(i18n['undo']!,
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.clear();
                      },
                      child: Text(i18n['reset']!,
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        var txt = await controller.getText();
                        if (txt.contains('src=\"data:')) {
                          txt =
                              '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                        }
                        setState(() {
                          result = txt;
                        });
                      },
                      child: Text(
                        i18n['submit']!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.redo();
                      },
                      child: Text(
                        i18n['redo']!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(result),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16.0,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.disable();
                      },
                      child: Text(i18n['disable']!,
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        controller.enable();
                      },
                      child: Text(
                        i18n['enable']!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16.0,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.insertText('Google');
                      },
                      child: Text(i18n['insertText']!,
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.insertHtml(
                            '''<p style="color: blue">Google in blue</p>''');
                      },
                      child: Text(i18n['insertHtml']!,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16.0,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        controller.insertLink(
                            'Google linked', 'https://google.com', true);
                      },
                      child: Text(
                        i18n['insertLink']!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.insertNetworkImage(
                            'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png',
                            filename: 'Google network image');
                      },
                      child: Text(
                        i18n['insertNetworkImage']!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16.0,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.addNotification(
                            'Info notification', NotificationType.info);
                      },
                      child: Text(i18n['info']!,
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.addNotification(
                            'Warning notification', NotificationType.warning);
                      },
                      child: Text(i18n['warning']!,
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        controller.addNotification(
                            'Success notification', NotificationType.success);
                      },
                      child: Text(
                        i18n['success']!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.addNotification(
                            'Danger notification', NotificationType.danger);
                      },
                      child: Text(
                        i18n['danger']!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16.0,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.addNotification('Plaintext notification',
                            NotificationType.plaintext);
                      },
                      child: Text(i18n['plaintext']!,
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        controller.removeNotification();
                      },
                      child: Text(
                        i18n['remove']!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
