import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mri/custom_alert/custom_alert.dart';
import 'package:mri/data/common/common_repository.dart';
import 'package:mri/data/fa_items/fa_items_repository.dart';
import 'package:mri/data/mri_items/mri_items_details.dart';
import 'package:mri/data/mri_items/mri_items_repository.dart';
import 'package:mri/data/user/user_repository.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:search_choices/search_choices.dart';

class MaterialIssueNote extends StatefulWidget {
  const MaterialIssueNote({Key? key}) : super(key: key);

  static const routeName = '/material-issue-note';

  @override
  _MaterialIssueNoteState createState() => _MaterialIssueNoteState();
}

class _MaterialIssueNoteState extends State<MaterialIssueNote> {
  TextEditingController dateController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController remarksController = TextEditingController();

  TextEditingController invTypController = TextEditingController();
  TextEditingController glAccountController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController itemRemarksController = TextEditingController();
  TextEditingController faItemController = TextEditingController();
  TextEditingController dimensionController = TextEditingController();
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  TextEditingController _itemIdController = TextEditingController();
  TextEditingController _itemOnHandQtyController = TextEditingController();

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  late double onHandQty = 0;
  late bool isEdit = false;
  late bool isSubmit = false;
  CommonRepository commonRepository = CommonRepository();

  late Map<int, String> locations = {};
  late Map<int, String> glAccounts = {};
  late Map<int, String> faItems = {};
  late Map<int, String> dimensions = {};
  late List<DropdownMenuEntry<String>> faItemsList = [];
  List<String> invTypes = ['FA', 'Stock'];

  @override
  void initState() {
    super.initState();
    setState(() {
      isSubmit = true;
    });

    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _loadLocations();
    _loadGlAccounts();
    _loadFAItems();
    _loadDimensions();

    setState(() {
      isSubmit = false;
    });
  }

  Future<void> refreshAll() async {
    setState(() {
      isSubmit = true;
      dateController.clear();
      locationController.clear();
      remarksController.clear();
      invTypController.clear();
      glAccountController.clear();
      qtyController.clear();
      itemRemarksController.clear();
      faItemController.clear();
      dimensionController.clear();
      _itemIdController.clear();
      _itemOnHandQtyController.clear();
      onHandQty = 0;
      isEdit = false;
    });

    await _loadLocations();
    await _loadGlAccounts();
    await _loadFAItems();
    await _loadDimensions();

    setState(() {
      isSubmit = false;
    });
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

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

  Future<void> _loadLocations() async {
    try {
      await commonRepository.getLocationList().then((value) {
        setState(() {
          locations = value;
        });
      }).catchError((error) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const CustomAlert(
                title: 'Sorry !',
                message: 'Failed to Load Locations',
                icon: Icons.fmd_bad_outlined,
                iconColor: Colors.red,
              );
            });
      });
    } catch (error) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomAlert(
              title: 'Sorry !',
              message: 'Failed to Load Locations',
              icon: Icons.fmd_bad_outlined,
              iconColor: Colors.red,
            );
          });
    }
  }

  Future<void> _loadGlAccounts() async {
    try {
      await commonRepository.getGlAccountsList().then((value) {
        setState(() {
          glAccounts = value;
        });
      }).catchError((error) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const CustomAlert(
                title: 'Sorry !',
                message: 'Failed to Load GL Accounts',
                icon: Icons.fmd_bad_outlined,
                iconColor: Colors.red,
              );
            });
      });
    } catch (error) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomAlert(
              title: 'Sorry !',
              message: 'Failed to Load GL Accounts',
              icon: Icons.fmd_bad_outlined,
              iconColor: Colors.red,
            );
          });
    }
  }

  Future<void> _scanQrBarCode() async {
    setState(() {
      _itemIdController.clear();
      _itemOnHandQtyController.clear();
      onHandQty = 0;
      isEdit = false;
      isSubmit = true;
    });

    try {
      _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
        context: context,
        onCode: (code) async {
          _itemIdController.text = code.toString();

          if (locationController.text.isEmpty) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const CustomAlert(
                  title: 'Sorry !',
                  message: 'Location not found',
                  icon: Icons.fmd_bad_outlined,
                  iconColor: Colors.red,
                );
              },
            );
            return;
          }

          if (!locations.containsKey(int.parse(locationController.text))) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const CustomAlert(
                  title: 'Sorry !',
                  message: 'Location not found',
                  icon: Icons.fmd_bad_outlined,
                  iconColor: Colors.red,
                );
              },
            );
            return;
          }

          if (!code.toString().isNotEmpty) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const CustomAlert(
                  title: 'Sorry !',
                  message: 'Item not found',
                  icon: Icons.fmd_bad_outlined,
                  iconColor: Colors.red,
                );
              },
            );
            return;
          }
          try {
            //Add search Item by ID logic here

            bool connection =
                _connectionStatus.contains(ConnectivityResult.none);
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

            double onhandqty = await commonRepository.getOnHandQty(
              locationController.text,
              code.toString(),
            );

            if (onhandqty == 0) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const CustomAlert(
                    title: 'Sorry !',
                    message: 'Item not found',
                    icon: Icons.fmd_bad_outlined,
                    iconColor: Colors.red,
                  );
                },
              );
              return;
            }

            setState(() {
              _itemOnHandQtyController.text = onhandqty.toString();
              onHandQty = onhandqty;
            });
          } catch (e) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const CustomAlert(
                  title: 'Sorry !',
                  message: 'Failed to Load On Hand Quantity',
                  icon: Icons.fmd_bad_outlined,
                  iconColor: Colors.red,
                );
              },
            );
          }
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomAlert(
            title: 'Sorry !',
            message: 'Failed to Scan QR',
            icon: Icons.fmd_bad_outlined,
            iconColor: Colors.red,
          );
        },
      );
    } finally {
      setState(() {
        isSubmit = false;
      });
    }
  }

  Future<void> _loadFAItems() async {
    await FaItemsRepository().getFAItems().then((value) {
      setState(() {
        faItems = value;
      });

      faItemsList = value.entries.map((entry) {
        return DropdownMenuEntry<String>(
            value: entry.key.toString(),
            label: '${entry.key} - ${entry.value}');
      }).toList();
    }).catchError((error) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomAlert(
              title: 'Sorry !',
              message: 'Failed to Load FA Items',
              icon: Icons.fmd_bad_outlined,
              iconColor: Colors.red,
            );
          });
    });
  }

  Future<void> _loadDimensions() async {
    try {
      final Map<int, String> dimensions =
          await commonRepository.getDimensionList();
      setState(() {
        this.dimensions = dimensions;
      });
    } catch (error) {
      String errors = error.toString();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Sorry !',
              message: 'Failed to Load Dimensions $errors',
              icon: Icons.fmd_bad_outlined,
              iconColor: Colors.red,
            );
          });
    }
  }

  void clearAll() {
    setState(() {
      glAccountController.clear();
      qtyController.clear();
      itemRemarksController.clear();
      faItemController.clear();
      dimensionController.clear();
      _itemIdController.clear();
      _itemOnHandQtyController.clear();
      onHandQty = 0;
      isEdit = false;
    });
  }

  Future<void> addItem(BuildContext context) async {
    // Add item to the list with enhanced validation and duplicate prevention
    try {
      // Validation function
      setState(() {
        isSubmit = true;
      });
      Future<void> showValidationDialog(String message) async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Sorry!',
              message: message,
              icon: Icons.fmd_bad_outlined,
              iconColor: Colors.red,
            );
          },
        );
      }

      // Check required fields
      if (_itemIdController.text.isEmpty) {
        await showValidationDialog('Item ID is required');
        return;
      }
      if (glAccountController.text.isEmpty) {
        await showValidationDialog('GL Account is required');
        return;
      }
      if (qtyController.text.isEmpty) {
        await showValidationDialog('Quantity is required');
        return;
      }

      // Parse values with error handling
      final int itemId = int.tryParse(_itemIdController.text) ?? 0;
      final double onHandQty =
          double.tryParse(_itemOnHandQtyController.text) ?? 0.0;
      final int glAccountId = int.tryParse(glAccountController.text) ?? 0;
      final double qty = double.tryParse(qtyController.text) ?? 0.0;
      final String itemRemark = itemRemarksController.text;
      final int faItemId = int.tryParse(faItemController.text) ?? 0;
      final int dimensionId = int.tryParse(dimensionController.text) ?? 0;

      // Check if the quantity to add is within on-hand quantity
      if (qty > onHandQty) {
        await showValidationDialog('Quantity is greater than On Hand Quantity');
        return;
      }

      // Check if the item already exists in the repository
      final existingItems = await MriItemsRepository().getAllItems();
      if (existingItems.any((item) => item.itemId == itemId)) {
        await showValidationDialog('Item with this ID already exists');
        return;
      }

      // Add item to the repository
      final bool added = await MriItemsRepository().addItem(
        itemId,
        onHandQty,
        glAccountId,
        qty,
        itemRemark,
        faItemId,
        dimensionId,
      );

      // Feedback to user
      if (added) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomAlert(
              title: 'Success!',
              message: 'Item Added',
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            );
          },
        );
        clearAll(); // Clear fields after successful addition
      } else {
        await showValidationDialog('Failed to Add Item');
      }
    } catch (error) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlert(
            title: 'Sorry!',
            message: 'Failed to Add Item: $error',
            icon: Icons.fmd_bad_outlined,
            iconColor: Colors.red,
          );
        },
      );
    } finally {
      setState(() {
        isSubmit = false;
      });
    }
  }

  Future<void> viewItems(BuildContext context) async {
    try {
      List items = await MriItemsRepository().getAllItems();
      if (items.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Items',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          'Item ID: ${item.itemId}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('On Hand Qty: ${item.onHandQty}'),
                            Text('Qty: ${item.qty}'),
                            Text('FA Item ID: ${item.faItemId}'),
                            Text('Dimension ID: ${item.dimensionId}'),
                            Text('Remark: ${item.itemRemark}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                setState(() {
                                  isEdit = true;

                                  _itemIdController.text =
                                      item.itemId.toString();
                                  _itemOnHandQtyController.text =
                                      item.onHandQty.toString();
                                  glAccountController.text =
                                      item.glAccountId.toString();
                                  qtyController.text = item.qty.toString();
                                  itemRemarksController.text = item.itemRemark;
                                  faItemController.text =
                                      item.faItemId.toString();
                                  dimensionController.text =
                                      item.dimensionId.toString();
                                });

                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await MriItemsRepository()
                                    .deleteItem(item.itemId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Item deleted"),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomAlert(
              title: 'Sorry!',
              message: 'No Items Found',
              icon: Icons.fmd_bad_outlined,
              iconColor: Colors.red,
            );
          },
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlert(
            title: 'Sorry!',
            message: 'Failed to Load Items $error',
            icon: Icons.fmd_bad_outlined,
            iconColor: Colors.red,
          );
        },
      );
    }
  }

  Future<void> updateItem(BuildContext context) async {
    try {
      // Validation function
      Future<void> showValidationDialog(String message) async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Sorry!',
              message: message,
              icon: Icons.fmd_bad_outlined,
              iconColor: Colors.red,
            );
          },
        );
      }

      // Check required fields
      if (_itemIdController.text.isEmpty) {
        await showValidationDialog('Item ID is required');
        return;
      }
      if (glAccountController.text.isEmpty) {
        await showValidationDialog('GL Account is required');
        return;
      }
      if (qtyController.text.isEmpty) {
        await showValidationDialog('Quantity is required');
        return;
      }

      // Parse values with error handling
      final int itemId = int.tryParse(_itemIdController.text) ?? 0;
      final double onHandQty =
          double.tryParse(_itemOnHandQtyController.text) ?? 0.0;
      final int glAccountId = int.tryParse(glAccountController.text) ?? 0;
      final double qty = double.tryParse(qtyController.text) ?? 0.0;
      final String itemRemark = itemRemarksController.text;
      final int faItemId = int.tryParse(faItemController.text) ?? 0;
      final int dimensionId = int.tryParse(dimensionController.text) ?? 0;

      // Check if the quantity to add is within on-hand quantity
      if (qty > onHandQty) {
        await showValidationDialog('Quantity is greater than On Hand Quantity');
        return;
      }

      // Update item in the repository
      final bool updated = await MriItemsRepository().updateItem(
        itemId,
        onHandQty,
        glAccountId,
        qty,
        itemRemark,
        faItemId,
        dimensionId,
      );

      // Feedback to user
      if (updated) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomAlert(
              title: 'Success!',
              message: 'Item Updated',
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            );
          },
        );
        clearAll(); // Clear fields after successful addition
        setState(() {
          isEdit = false;
        });
      } else {
        await showValidationDialog('Failed to Update Item $itemId');
      }
    } catch (error) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlert(
            title: 'Sorry!',
            message: 'Failed to Update Item: $error',
            icon: Icons.fmd_bad_outlined,
            iconColor: Colors.red,
          );
        },
      );
    }
  }

  Future<void> saveMri() async {
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

    //Validation
    if (dateController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomAlert(
            title: 'Sorry !',
            message: 'Date is required',
            icon: Icons.fmd_bad_outlined,
            iconColor: Colors.red,
          );
        },
      );
      return;
    }

    if (locationController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomAlert(
            title: 'Sorry !',
            message: 'Location is required',
            icon: Icons.fmd_bad_outlined,
            iconColor: Colors.red,
          );
        },
      );
      return;
    }

    //select inventory type
    if (invTypController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomAlert(
            title: 'Sorry !',
            message: 'Inventory Type is required',
            icon: Icons.fmd_bad_outlined,
            iconColor: Colors.red,
          );
        },
      );
      return;
    }
    try {
      //set the date in yyyy-MM-dd format
      String dateFormat = 'yyyy-MM-dd';
      DateTime dateString = DateFormat('dd/MM/yyyy').parse(dateController.text);
      String date = DateFormat(dateFormat).format(dateString);
      int locationId = int.parse(locationController.text ?? '0');
      String remark = remarksController.text;
      String invType = invTypController.text;
      String creationDate = DateFormat(dateFormat).format(DateTime.now());

      //Fetch all the items
      List<MriItemsDetails> items = await MriItemsRepository().getAllItems();

      //Check if there are any items to save
      if (items.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomAlert(
              title: 'Sorry !',
              message: 'No Items to Save',
              icon: Icons.fmd_bad_outlined,
              iconColor: Colors.red,
            );
          },
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      String saved = await commonRepository.saveMRI(
        date,
        locationId,
        remark,
        invType,
        items,
        creationDate,
      );

      Navigator.pop(context);

      if (saved.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'MRI Saved Successfully',
              message: 'MRI$saved',
              icon: Icons.done,
              iconColor: Colors.green,
              titleColor: Colors.black,
              messageColor: Colors.black54,
              backgroundColor: Colors.white,
            );
          },
        );
        clearAll();
        await MriItemsRepository().clearAllItems();
        await refreshAll();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomAlert(
              title: 'Sorry !',
              message: 'Failed to Save MRI',
              icon: Icons.fmd_bad_outlined,
              iconColor: Colors.red,
            );
          },
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlert(
            title: 'Sorry !',
            message: 'Failed to Save MRI $error',
            icon: Icons.fmd_bad_outlined,
            iconColor: Colors.red,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Issue Note'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                UserRepository().logout();
                Navigator.pushNamed(context, '/login');
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16, 8, 8),
                        child: GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2015, 8),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              setState(() {
                                // Format the date to dd/MM/yyyy
                                String dateFormat = 'dd/MM/yyyy';
                                DateTime dateString = picked.toLocal();
                                dateController.text =
                                    DateFormat(dateFormat).format(dateString);
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: dateController,
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                hintText: 'Select Date',
                                suffixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 16, 16, 8),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'Select Location',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                        ),
                        isExpanded: true,
                        value: locationController.text.isNotEmpty
                            ? locationController.text
                            : null,
                        items: locations.isNotEmpty
                            ? locations.entries
                                .map((MapEntry<int, String> entry) {
                                return DropdownMenuItem(
                                  value: entry.key.toString(),
                                  child: Text(entry.value),
                                );
                              }).toList()
                            : [],
                        onChanged: (Object? value) {
                          setState(() {
                            locationController.text =
                                value != null ? value.toString() : '';
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 8),
                  child: TextField(
                    controller: remarksController,
                    decoration: const InputDecoration(
                      labelText: 'Remarks',
                      hintText: 'Enter Remarks',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    minLines: 2,
                  )),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 8),
                          child: DropdownMenu(
                            initialSelection:
                                invTypes.contains(invTypController.text)
                                    ? invTypes.indexOf(invTypController.text)
                                    : null,
                            controller: invTypController,
                            requestFocusOnTap: true,
                            label: const Text('Select Inventory Type'),
                            onSelected: (Object? value) {
                              setState(() {
                                invTypController.text =
                                    value != null ? value as String : '';
                              });
                            },
                            enableFilter: true,
                            width: constraints.maxWidth - 32,
                            dropdownMenuEntries: invTypes
                                .map<DropdownMenuEntry<String>>((String inv) {
                              return DropdownMenuEntry(
                                value: inv,
                                label: inv,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        viewItems(context);
                      },
                      icon: const Icon(Icons.view_list_outlined),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 6.0),
                        child: Text(
                          'View Items',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (isEdit) {
                          updateItem(context);
                          return;
                        }
                        addItem(context);
                      },
                      icon: const Icon(Icons.add),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 6.0),
                        child: isEdit
                            ? const Text('Edit Item',
                                style: TextStyle(fontSize: 18))
                            : const Text(
                                'Add Row',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Container(
                  height: 650,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        Colors.grey[200], // Specify color within BoxDecoration
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                                onPressed: () {
                                  _scanQrBarCode();
                                },
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 6.0),
                                  child: Text(
                                    'Scan Item',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                icon: const Icon(Icons.qr_code_scanner),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.grey),
                                )),
                            ElevatedButton(
                                onPressed: () {
                                  clearAll();
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 6.0),
                                  child: Text(
                                    'Clear',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Item ID : ${_itemIdController.text}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'On Hand Qty : ${_itemOnHandQtyController.text}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SearchChoices.single(
                          items: glAccounts.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key.toString(),
                              child: Text(
                                  '${entry.key.toString()} - ${entry.value}'),
                            );
                          }).toList(),
                          value: glAccountController.text.isNotEmpty &&
                                  glAccountController.text != '' &&
                                  glAccounts.containsKey(
                                      int.parse(glAccountController.text))
                              ? glAccountController.text
                              : null,
                          hint: "Select GL Account",
                          searchHint: "Search GL Account",
                          onChanged: (value) {
                            setState(() {
                              glAccountController.text = value ?? '';
                            });
                          },
                          dialogBox: true,
                          isExpanded: true,
                          menuBackgroundColor: Colors.white,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          searchFn: (String keyword, items) {
                            List<int> ret = [];

                            if (keyword.isNotEmpty) {
                              keyword = keyword.toLowerCase();
                              for (int i = 0; i < items.length; i++) {
                                if (items[i]
                                    .child
                                    .toString()
                                    .toLowerCase()
                                    .contains(keyword)) {
                                  ret.add(i);
                                }
                              }
                            } else {
                              items.asMap().forEach((i, item) {
                                ret.add(i);
                              });
                            }
                            return (ret);
                          },
                          searchInputDecoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: qtyController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            hintText: 'Enter Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onEditingComplete: () {
                            if (qtyController.text.isEmpty) {
                              qtyController.text = '0';
                            }

                            if (qtyController.text.isNotEmpty &&
                                double.parse(qtyController.text) > onHandQty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const CustomAlert(
                                    title: 'Sorry !',
                                    message:
                                        'Quantity is greater than On Hand Quantity',
                                    icon: Icons.fmd_bad_outlined,
                                    iconColor: Colors.red,
                                  );
                                },
                              );
                              qtyController.text = '0';
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: itemRemarksController,
                          decoration: const InputDecoration(
                            labelText: 'Remarks',
                            hintText: 'Enter Remarks',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
                          minLines: 2,
                        ),
                        const SizedBox(height: 16),
                        SearchChoices.single(
                          items: faItemsList.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.value,
                              child: Text(entry.label),
                            );
                          }).toList(),
                          value: faItemController.text.isNotEmpty
                              ? faItemController.text
                              : null,
                          hint: "Select FA Item",
                          searchHint: null,
                          onChanged: (value) {
                            setState(() {
                              faItemController.text = value.toString();
                            });
                          },
                          dialogBox: true,
                          isExpanded: true,
                          menuBackgroundColor: Colors.white,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          searchInputDecoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          searchFn: (String keyword, items) {
                            List<int> ret = [];

                            if (keyword.isNotEmpty) {
                              keyword = keyword.toLowerCase();
                              for (int i = 0; i < items.length; i++) {
                                if (items[i]
                                    .child
                                    .toString()
                                    .toLowerCase()
                                    .contains(keyword)) {
                                  ret.add(i);
                                }
                              }
                            } else {
                              items.asMap().forEach((i, item) {
                                ret.add(i);
                              });
                            }
                            return (ret);
                          },
                        ),
                        const SizedBox(height: 16),
                        SearchChoices.single(
                          items: dimensions.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key.toString(),
                              child: Text('${entry.key} - ${entry.value}'),
                            );
                          }).toList(),
                          value: dimensionController.text.isNotEmpty
                              ? dimensionController.text
                              : null,
                          hint: "Select Dimension",
                          searchHint: null,
                          onChanged: (value) {
                            setState(() {
                              dimensionController.text = value.toString();
                            });
                          },
                          dialogBox: true,
                          isExpanded: true,
                          menuBackgroundColor: Colors.white,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          underline: Container(
                            height: 1.0,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          searchInputDecoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          searchFn: (String keyword, items) {
                            List<int> ret = [];

                            if (keyword.isNotEmpty) {
                              keyword = keyword.toLowerCase();
                              for (int i = 0; i < items.length; i++) {
                                if (items[i]
                                    .child
                                    .toString()
                                    .toLowerCase()
                                    .contains(keyword)) {
                                  ret.add(i);
                                }
                              }
                            } else {
                              items.asMap().forEach((i, item) {
                                ret.add(i);
                              });
                            }
                            return (ret);
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: isSubmit
                                  ? null
                                  : () {
                                      refreshAll();
                                    },
                              label: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 6.0),
                                child: Text(
                                  'Refresh',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              icon: const Icon(Icons.refresh_outlined),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                backgroundColor:
                                    isSubmit ? Colors.grey : Colors.blue[200],
                                side: const BorderSide(color: Colors.grey),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: isSubmit
                                  ? null
                                  : () {
                                      saveMri();
                                    },
                              label: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 6.0),
                                child: Text(
                                  'Save Changes',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              icon: const Icon(Icons.save_outlined),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                backgroundColor: Colors.green[300],
                                side: const BorderSide(color: Colors.grey),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
