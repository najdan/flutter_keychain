import 'package:flutter/material.dart';
import 'package:flutter_keychain/flutter_keychain.dart';

const String _KEY = "example_key";
void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // String _firstStart = 'Unknown';
  String _key_chain_value = '';

  @override
  void initState() {
    super.initState();
    // get initial values
    _handleRead();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: const Text('Plugin example app')),
          body: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 24,
              children: [
                Spacer(flex: 2),

                // VALUE
                Text('Keychain Value: $_key_chain_value'),
                Spacer(flex: 2),
                // UPDATE
                ElevatedButton(
                  onPressed: _handleUpdate,
                  child: Text('Update Keychain Value'),
                ),
                // READ
                ElevatedButton(
                  onPressed: _handleRead,
                  child: Text('Read Keychain Value'),
                ),
                // DELETE
                ElevatedButton(
                  onPressed: _handleDelete,
                  child: Text('Delete Keychain Value'),
                ),
                // CLEAR
                ElevatedButton(
                  onPressed: _handleClear,
                  child: Text('Clear All Keychain Values'),
                ),
                ElevatedButton(
                  onPressed: () => _forceError(ERROR_TYPE.KEYCHAIN_EMPTY_VALUE),
                  child: Text('Force Error empty value'),
                ),
                ElevatedButton(
                  onPressed: () => _forceError(ERROR_TYPE.KEYCHAIN_EMPTY_KEY),
                  child: Text('Force Error empty key'),
                ),
                ElevatedButton(
                  onPressed: () => _forceError(ERROR_TYPE.KEYCHAIN_NULL_KEY),
                  child: Text('Force Error null key'),
                ),
                ElevatedButton(
                  onPressed: () => _forceError(ERROR_TYPE.KEYCHAIN_NULL_VALUE),
                  child: Text('Force Error null value'),
                ),

                Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// `_handleUpdate`
  void _handleUpdate() async {
    try {
      setState(() {
        _key_chain_value = DateTime.now().toIso8601String();
      });
      await FlutterKeychain.put(key: _KEY, value: _key_chain_value);
    } catch (e) {
      debugPrint("_handleUpdate... Error: $e");
    }
  }

  /// `_handleRead`
  void _handleRead() async {
    try {
      String? value = await FlutterKeychain.get(key: _KEY);
      setState(() {
        _key_chain_value = value ?? 'No value found';
      });
    } catch (e) {
      debugPrint("_handleRead... Error: $e");
    }
  }

  /// `_handleDelete`
  void _handleDelete() async {
    try {
      await FlutterKeychain.remove(key: _KEY);
      setState(() {
        _key_chain_value = 'Value deleted';
      });
    } catch (e) {
      debugPrint("_handleDelete... Error: $e");
    }
  }

  /// `_handleClear`
  void _handleClear() async {
    try {
      await FlutterKeychain.clear();
      setState(() {
        _key_chain_value = 'All values cleared';
      });
    } catch (e) {
      debugPrint("_handleClear... Error: $e");
    }
  }

  /// `_forceError`
  void _forceError(ERROR_TYPE errorType) async {
    try {
      switch (errorType) {
        case ERROR_TYPE.KEYCHAIN_EMPTY_KEY:
          await FlutterKeychain.put(key: '', value: 'force error');
          break;
        case ERROR_TYPE.KEYCHAIN_EMPTY_VALUE:
          await FlutterKeychain.put(key: _KEY, value: '');
          break;
        case ERROR_TYPE.KEYCHAIN_NULL_KEY:
          String? _nullKey;
          await FlutterKeychain.put(key: _nullKey!, value: 'force error');
          break;
        case ERROR_TYPE.KEYCHAIN_NULL_VALUE:
          String? _nullValue;
          await FlutterKeychain.put(key: _KEY, value: _nullValue!);
          break;
      }
    } catch (e) {
      debugPrint("_forceError... Error: $e");
    }
  }
}

enum ERROR_TYPE {
  KEYCHAIN_EMPTY_KEY,
  KEYCHAIN_EMPTY_VALUE,
  KEYCHAIN_NULL_KEY,
  KEYCHAIN_NULL_VALUE,
}
