import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/services/database.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  String? _currentName;
  String? _currentSugars;
  int? _currentStrength;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser?>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user?.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData? userData = snapshot.data;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Update your brew preferences.',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  initialValue: userData?.name,
                  decoration: const InputDecoration(hintText: 'Name'),
                  validator: (val) =>
                  val!.isEmpty ? 'Please enter a name' : null,
                  onChanged: (val) => setState(() => _currentName = val),
                ),
                const SizedBox(height: 20.0),
                DropdownButtonFormField(
                  value: _currentSugars ?? userData?.sugars,
                  items: sugars.map((sugar) {
                    return DropdownMenuItem(
                      value: sugar,
                      child: Text('$sugar sugars'),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() => _currentSugars = value);
                  },
                ),
                const SizedBox(height: 20.0),
                Slider(
                  value: (_currentStrength?.toDouble() ?? userData?.strength?.toDouble() ?? 100.0),
                  activeColor: Colors.brown[_currentStrength ?? 100],
                  inactiveColor: Colors.brown[_currentStrength ?? 100],
                  min: 100.0,
                  max: 900.0,
                  divisions: 8,
                  onChanged: (val) => setState(() => _currentStrength = val.round()),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[400],
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await DatabaseService(uid: user?.uid).updateUserData(
                        _currentSugars ?? userData?.sugars ?? '0',
                        _currentName ?? userData?.name ?? '',
                        _currentStrength ?? userData?.strength ?? 100,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data updated')),
                      );
                    }
                  },
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Loading();
        }
      },
    );
  }
}