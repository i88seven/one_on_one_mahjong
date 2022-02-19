import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:one_on_one_mahjong/pages/login/login_page.dart';
import 'package:one_on_one_mahjong/pages/preparation/room/create.dart';
import 'package:one_on_one_mahjong/pages/preparation/room/search.dart';

class PreparationMainPage extends StatefulWidget {
  const PreparationMainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PreparationMainPageState();
}

class _PreparationMainPageState extends State<PreparationMainPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _myNameController = TextEditingController();
  final LocalStorage _storage = LocalStorage('one_one_one_mahjong');

  @override
  void initState() {
    super.initState();

    Future(() async {
      await _storage.ready;
      _myNameController.text = _storage.getItem('myName');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('タイマン麻雀'),
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: const EdgeInsets.all(8),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _myNameController,
                        decoration: const InputDecoration(labelText: 'あなたの名前'),
                        maxLength: 10,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) return '入力してください';
                          return null;
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 16.0),
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          child: const Text('部屋を立てる'),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _createRoom();
                            }
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 16.0),
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          child: const Text('部屋を探す'),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _searchRoom();
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                              return const LoginPage();
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _myNameController.dispose();
    super.dispose();
  }

  void _createRoom() async {
    try {
      _storage.setItem('myName', _myNameController.text);

      Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (_) => RoomCreatePage(myName: _myNameController.text)),
      );
    } catch (e) {}
  }

  void _searchRoom() async {
    try {
      _storage.setItem('myName', _myNameController.text);

      Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (_) => RoomSearchPage(myName: _myNameController.text)),
      );
    } catch (e) {}
  }
}
