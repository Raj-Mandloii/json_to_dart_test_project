import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TimeKeeper.enabled = true;

  // if (!kIsWeb &&
  //     (Platform.isLinux ||
  //         Platform.isFuchsia ||
  //         Platform.isMacOS ||
  //         Platform.isWindows)) {
  //   await DesktopWindow.setWindowSize(const Size(1024, 768));
  // }

  // Logger.root.onRecord.listen((record) {
  //   debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  //   if (record.error != null) {
  //     debugPrint('${record.error}');
  //   }
  //   if (record.stackTrace != null) {
  //     debugPrint('${record.stackTrace}');
  //   }
  // });

  final navigatorKey = GlobalKey<NavigatorState>();

  // // This is needed to adding custom schema validations
  // final schemaCache = SchemaCache();
  // schemaCache.addSchema(SvgSchema.id, SvgSchema.schema);
  // schemaCache.addSchema(DottedBorderSchema.id, DottedBorderSchema.schema);

  final registry = JsonWidgetRegistry.instance;
  registry.navigatorKey = navigatorKey;
  // registry.registerCustomBuilder(
  //   DottedBorderBuilder.type,
  //   const JsonWidgetBuilderContainer(
  //     builder: DottedBorderBuilder.fromDynamic,
  //     schemaId: DottedBorderSchema.id,
  //   ),
  // );
  // registry.registerCustomBuilder(
  //   SvgBuilder.type,
  //   const JsonWidgetBuilderContainer(
  //     builder: SvgBuilder.fromDynamic,
  //     schemaId: SvgSchema.id,
  //   ),
  // );

  // registry.registerFunction('navigatePage', ({args, required registry}) async {
  //   final jsonStr =
  //       await rootBundle.loadString('assets/pages/${args![0]}.json');
  //   final jsonData = json.decode(jsonStr);
  //   await navigatorKey.currentState!.push(
  //     MaterialPageRoute(
  //       builder: (BuildContext context) => FullWidgetPage(
  //         data: JsonWidgetData.fromDynamic(
  //           jsonData,
  //           registry: registry,
  //         )!,
  //       ),
  //     ),
  //   );
  // });
  registry.registerFunctions({
    'getImageAsset': ({args, required registry}) =>
        'assets/images/image${args![0]}.jpg',
    'getImageId': ({args, required registry}) => 'image${args![0]}',
    // 'getImageNavigator': ({args, required registry}) => () async {
    //       registry.setValue('index', args![0]);
    //       final dataStr =
    //           await rootBundle.loadString('assets/pages/image_page.json');
    //       final imagePageJson = Map.unmodifiable(json.decode(dataStr));
    //       final imgRegistry = JsonWidgetRegistry(
    //         debugLabel: 'ImagePage',
    //         values: {
    //           'imageAsset': 'assets/images/image${args[0]}.jpg',
    //           'imageTag': 'image${args[0]}',
    //         },
    //       );

    //       await navigatorKey.currentState!.push(
    //         MaterialPageRoute(
    //           builder: (BuildContext context) => FullWidgetPage(
    //             data: JsonWidgetData.fromDynamic(
    //               imagePageJson,
    //               registry: imgRegistry,
    //             )!,
    //           ),
    //         ),
    // );
    // },
    'noop': ({args, required registry}) => () {},
    'validateForm': ({args, required registry}) => () {
          final BuildContext context = registry.getValue(args![0]);

          final valid = Form.of(context).validate();
          registry.setValue('form_validation', valid);
        },
    'updateCustomTextStyle': ({args, required registry}) => () {
          registry.setValue(
            'customTextStyle',
            const TextStyle(
              color: Colors.black,
            ),
          );
        },
    'getCustomTweenBuilder': ({args, required registry}) =>
        (BuildContext context, dynamic size, Widget? child) {
          return IconButton(
            icon: child!,
            iconSize: size,
            onPressed: () {
              final current = registry.getValue('customSize');
              final size = current == 50.0 ? 100.0 : 50.0;
              registry.setValue('customSize', size);
            },
          );
        },
    'getCustomTween': ({args, required registry}) {
      return Tween<double>(begin: 0, end: args![0]);
    },
    'setWidgetByKey': ({args, required registry}) => () {
          final replace = registry.getValue(args![1]);
          registry.setValue(args[0], replace);
        },
    'simplePrintMessage': ({args, required registry}) => () {
          var message = 'This is a simple print message';
          if (args?.isEmpty == false) {
            for (var arg in args!) {
              message += ' $arg';
            }
          }
          // ignore: avoid_print
          print(message);
        },
    'negateBool': ({args, required registry}) => () {
          final bool value = registry.getValue(args![0]);
          registry.setValue(args[0], !value);
        },
    'buildPopupMenu': ({args, required registry}) {
      const choices = ['First', 'Second', 'Third'];
      return (BuildContext context) {
        return choices
            .map(
              (choice) => PopupMenuItem(
                value: choice,
                child: Text(choice),
              ),
            )
            .toList();
      };
    },
    // show_dialog_fun.key: show_dialog_fun.body,
    // 'setBooleanValue': ({args, required registry}) {
    //   return (bool? onChangedValue) {
    //     final variableName = args![0];
    //     registry.setValue(variableName, onChangedValue);
    //   };
    // },
  });

  // registry.setValue('customRect', Rect.largest);
  // registry.setValue('clipper', Clipper());

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyApp(),
      navigatorKey: navigatorKey,
      theme: ThemeData.light(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const DynamicText();
  }
}

class DynamicText extends StatefulWidget {
  // final url = 'https://mocki.io/v1/86eec17c-336a-47ac-a988-5f5afe8e90a8';
  final url = 'https://mocki.io/v1/294ec659-4ba8-45ac-a222-1add53b8641f';

  const DynamicText({super.key});

  @override
  _DynamicTextState createState() => _DynamicTextState();
}

class _DynamicTextState extends State<DynamicText> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, AsyncSnapshot<http.Response> snapshot) {
        if (snapshot.hasData) {
          var widgetJson = json.decode(snapshot.data!.body);
          var widget = JsonWidgetData.fromDynamic(
            widgetJson,
          );
          return widget!.build(context: context);
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
      future: _getWidget(),
    );
  }

  Future<http.Response> _getWidget() async {
    var url = Uri.parse(widget.url);
    return http.get(url);
  }
}
