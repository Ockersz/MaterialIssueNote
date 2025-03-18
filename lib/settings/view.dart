import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mri/custom_alert/custom_alert.dart';
import 'package:mri/data/fa_items/fa_items_repository.dart';

class Settings extends StatefulWidget {
  static const routeName = '/settings';

  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  late bool isSubmit = false;

  @override
  void initState() {
    super.initState();

    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
    // ignore: avoid_print
    print('Connectivity changed: $_connectionStatus');
  }

  Future<void> _downloadFaItems() async {
    try {
      setState(() {
        isSubmit = true;
      });
      bool connection = _connectionStatus.contains(ConnectivityResult.none);
      if (connection) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomAlert(
              title: 'Sorry !',
              message: 'No Internet Connection',
              icon: Icons.fmd_bad_outlined,
              iconColor: Colors.red,
            );
          },
        );
        return;
      }

      final bool donwloaded = await FaItemsRepository().downloadFAItems();

      if (donwloaded) {
        showDialog(
          context: context,
          builder: (context) {
            return const CustomAlert(
              title: 'Success !',
              message: 'FA Items downloaded successfully',
              icon: Icons.done,
              iconColor: Colors.green,
              titleColor: Colors.black,
              messageColor: Colors.black54,
              backgroundColor: Colors.white,
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return const CustomAlert(
              title: 'Warning !',
              message: 'Failed to download FA Items',
              icon: Icons.error,
              iconColor: Colors.red,
              titleColor: Colors.black,
              messageColor: Colors.black54,
              backgroundColor: Colors.white,
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          final errorMessage = 'Failed to download FA Items ${e.toString()}';
          return CustomAlert(
            title: 'Warning !',
            message: errorMessage,
            icon: Icons.error,
            iconColor: Colors.red,
            titleColor: Colors.black,
            messageColor: Colors.black54,
            backgroundColor: Colors.white,
          );
        },
      );
    } finally {
      setState(() {
        isSubmit = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/material_issue_note');
          },
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
      body: Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    isSubmit ? null : _downloadFaItems();
                  },
                  label: isSubmit
                      ? const CircularProgressIndicator()
                      : const Text('Download FA Items'),
                  icon: isSubmit ? null : const Icon(Icons.download)),
            ],
          ),
        ),
      ),
    );
  }
}
