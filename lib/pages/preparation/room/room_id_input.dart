import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class RoomIdInput extends StatefulWidget {
  final Function(String roomId) onSubmit;
  final String buttonText;

  const RoomIdInput({
    required this.onSubmit,
    required this.buttonText,
    Key? key,
  }) : super(key: key);

  @override
  _RoomIdInputState createState() => _RoomIdInputState();
}

class _RoomIdInputState extends State<RoomIdInput> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _roomIdController = TextEditingController();
  final LocalStorage _storage = LocalStorage('one_one_one_mahjong');

  @override
  void initState() {
    super.initState();

    Future(() async {
      await _storage.ready;
      _roomIdController.text = _storage.getItem('myRoomId');
    });
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _roomIdController,
                decoration: const InputDecoration(labelText: '部屋ID'),
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
                  child: Text(widget.buttonText),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _storage.setItem('myRoomId', _roomIdController.text);
                      widget.onSubmit(_roomIdController.text);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
