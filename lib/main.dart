import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const DynamicText());
  }
}

class DynamicText extends StatefulWidget {
  final url =
      'https://s3.ap-south-1.amazonaws.com/prod-saas-ots-document-files-public/demo/shashi/2022/9/20/temp.json';

  const DynamicText({Key? key}) : super(key: key);

  @override
  _DynamicTextState createState() => _DynamicTextState();
}

class _DynamicTextState extends State<DynamicText> {
  List _items = [];

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/json/home.json');
    final data = await json.decode(response);
    setState(() {
      _items = data["items"];
    });
  }

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
        } else if (snapshot.hasError) {
          return FutureBuilder(
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: const Text(
                    'Yourpedia',
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      _items.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    margin: const EdgeInsets.all(10),
                                    child: ListTile(
                                      leading: Text(_items[index]["id"]),
                                      title: Text(_items[index]["name"]),
                                      subtitle:
                                          Text(_items[index]["description"]),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
              );
            },
            future: readJson(),
          );
        } else {
          return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text(
                  'Dynamic Widget',
                ),
              ),
              body: const Center(child: CircularProgressIndicator()));
        }
      },
      future: _getWidget(),
    );
  }

  Future<http.Response> _getWidget() async {
    return http.get(Uri.parse(widget.url));
  }
}
