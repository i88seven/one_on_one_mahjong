import 'package:flutter/material.dart';

class GameUserNameInput extends StatefulWidget {
  final Function(String name) onSubmit;
  final String? initialName;

  const GameUserNameInput({
    required this.onSubmit,
    this.initialName,
    Key? key,
  }) : super(key: key);

  @override
  _GameUserNameInputState createState() => _GameUserNameInputState();
}

class _GameUserNameInputState extends State<GameUserNameInput> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _myNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _myNameController.text = widget.initialName ?? '';
  }

  @override
  void dispose() {
    _myNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
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
                    child: const Text('名前を決定'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit(_myNameController.text);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
