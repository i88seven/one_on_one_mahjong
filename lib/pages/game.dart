import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _counter = 0;

  void  _incrementCounter() async {
    setState(() {
      _counter++;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc()
        .set({'name': '鈴木', 'age': 40});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Expanded(child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<QueryDocumentSnapshot>? documents = snapshot.data?.docs;
                  if (documents == null) {
                    return const Text('エラーだよ');
                  }
                  return ListView(
                      children: documents
                          .map((doc) => Card(
                        child: ListTile(
                          title: Text(doc['name']),
                          subtitle: Text(doc['age'].toString()),
                        ),
                      ))
                          .toList());
                } else if (snapshot.hasError) {
                  return const Text('エラーだよ');
                }
                return const Text('');
              },
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
