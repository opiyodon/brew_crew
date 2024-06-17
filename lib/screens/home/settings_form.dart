import 'package:brew_crew/models/brew.dart';
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
  String? _currentProfilePicture;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser?>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user!.uid!).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData? userData = snapshot.data;

          return StreamBuilder<List<Brew>>(
            stream: DatabaseService(uid: user.uid!).brews,
            builder: (context, brewSnapshot) {
              if (brewSnapshot.hasData && brewSnapshot.data!.isNotEmpty) {
                Brew? brewData = brewSnapshot.data!.firstWhere(
                    (brew) => brew.uid == user.uid,
                    orElse: () => Brew(
                        sugars: '0',
                        strength: 100,
                        uid: user.uid!)); // Create a default Brew object

                // Initialize form values if they have not been set yet
                _currentName ??= userData?.username;
                _currentProfilePicture ??= userData?.profilePicture;
                _currentSugars ??= brewData.sugars;
                _currentStrength ??= brewData.strength;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 60.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Update your brew preferences.',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          initialValue: _currentName,
                          decoration:
                              const InputDecoration(hintText: 'Username'),
                          validator: (val) =>
                              val!.isEmpty ? 'Please enter a username' : null,
                          onChanged: (val) =>
                              setState(() => _currentName = val),
                        ),
                        const SizedBox(height: 20.0),
                        DropdownButtonFormField(
                          value: _currentSugars,
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
                          value:
                              (_currentStrength ?? brewData.strength)
                                  .toDouble(),
                          activeColor: Colors
                              .brown[_currentStrength ?? brewData.strength],
                          inactiveColor: Colors
                              .brown[_currentStrength ?? brewData.strength],
                          min: 100.0,
                          max: 900.0,
                          divisions: 8,
                          onChanged: (val) =>
                              setState(() => _currentStrength = val.round()),
                        ),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Update user profile data
                              await DatabaseService(uid: user.uid!)
                                  .updateUserData(
                                _currentName ?? userData!.username,
                                _currentProfilePicture ??
                                    userData!.profilePicture!,
                              );
                              // Update brew data
                              await DatabaseService(uid: user.uid!)
                                  .updateBrewData(
                                _currentSugars ?? '0',
                                _currentStrength ?? 100,
                                user.uid!,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Preferences updated')),
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[400],
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Loading();
              }
            },
          );
        } else {
          return const Loading();
        }
      },
    );
  }
}
