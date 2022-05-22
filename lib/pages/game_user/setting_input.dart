import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingInput extends StatefulWidget {
  final Function(String name, bool isPlayMusic) onSubmit;
  final String? initialName;
  final bool? initialIsPlayMusic;

  const SettingInput({
    required this.onSubmit,
    this.initialName,
    this.initialIsPlayMusic,
    Key? key,
  }) : super(key: key);

  @override
  _SettingInputState createState() => _SettingInputState();
}

class _SettingInputState extends State<SettingInput> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _myNameController = TextEditingController();
  late bool _isPlayMusic;

  @override
  void initState() {
    super.initState();
    _myNameController.text = widget.initialName ?? '';
    _isPlayMusic = widget.initialIsPlayMusic ?? true;
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text("BGMの再生"),
                    CupertinoSwitch(
                      value: _isPlayMusic,
                      onChanged: (isPlayMusic) {
                        setState(() {
                          _isPlayMusic = isPlayMusic;
                        });
                      },
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    child: const Text('決定'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit(_myNameController.text, _isPlayMusic);
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
