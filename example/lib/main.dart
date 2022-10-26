import 'package:flutter/material.dart';
import 'package:multi_select_search/multi_select_search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multiselect Search',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        chipTheme: const ChipThemeData(
          deleteIconColor: Color.fromARGB(255, 61, 61, 61),
          backgroundColor: Color(0xFFF9F7F3),
        ),
      ),
      home: const MyExampleApp(),
    );
  }
}

class MyExampleApp extends StatefulWidget {
  const MyExampleApp({Key? key}) : super(key: key);

  @override
  State<MyExampleApp> createState() => _MyExampleAppState();
}

class _MyExampleAppState extends State<MyExampleApp> {
  List<Contact> selectedItems = [];
  @override
  Widget build(BuildContext context) {
    var list = [
      Contact(1, "Joel McHale"),
      Contact(2, "Danny Pudi"),
      Contact(3, "Donald Glover"),
      Contact(4, "Gillian Jacobs"),
      Contact(5, "Alison Brie"),
      Contact(6, "Chevy Chase"),
      Contact(7, "Jim Rush"),
      Contact(8, "Yvette Nicole Brown"),
      Contact(9, "Jeff Winger"),
      Contact(10, "Abed Nadir"),
      Contact(11, "Troy Barnes"),
      Contact(12, "Britta Perry"),
      Contact(13, "Annie Edison"),
    ];

    List<Contact> initial = [
      list.first,
      list[1],
      list.last,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Multi Select Search Menu"),
      ),
      body: Column(
        children: [
          Expanded(
            child: MultiSelectSearch<Contact>(
              itemBuilder: (Contact item) => ListTile(
                key: ObjectKey(item),
                leading: const Icon(Icons.person),
                title: Text(item.name),
              ),
              chipLabelKey: 'name',
              items: list,
              initialValue: initial,
              onChanged: (List<Contact> items) =>
                  setState(() => selectedItems = items),
              decoration: BoxDecoration(
                color: const Color(0xFFF7A072).withOpacity(0.6),
                border: const Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              clearAll: const Padding(
                padding: EdgeInsets.only(top: 10.0, right: 6.0),
                child: Icon(Icons.clear),
              ),
            ),
          ),
          Wrap(
            children: [
              for (var i = 0; i < selectedItems.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(selectedItems[i].name),
                )
            ],
          )
        ],
      ),
    );
  }
}

class Contact {
  final int id;
  final String name;

  Contact(
    this.id,
    this.name,
  );

  Contact.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
