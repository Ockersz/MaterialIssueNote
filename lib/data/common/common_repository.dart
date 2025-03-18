import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mri/data/mri_items/mri_items_repository.dart';
import 'package:mri/data/user/user_details.dart';
import 'package:mri/data/user/user_repository.dart';

class CommonRepository {
  final String baseURL = 'http://192.168.1.19:5000';
  static const Duration timeoutDuration = Duration(seconds: 10);

  Future checkConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  Future<Map<int, String>> getLocationList() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseURL/mobile/locations'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> locations = jsonDecode(response.body);
        return {
          for (var location in locations)
            int.parse(location['id']): location['locName']
        };
      } else {
        return Future.error('Failed to load locations');
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<Map<int, String>> getGlAccountsList() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseURL/glcharofaccs/companyservice/3'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final glAccounts = data['Glcharofaccs'] as List<dynamic>;

        return {
          for (var glAccount in glAccounts)
            int.parse(glAccount['id']): glAccount['descri']
        };
      } else {
        return Future.error('Failed to load GL Accounts');
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<double> getOnHandQty(locationId, itemId) async {
    try {
      String url = '$baseURL/stocklocinv/checkitem/3/$locationId/$itemId';

      print(url);
      final response = await http
          .get(
            Uri.parse(url),
          )
          .timeout(timeoutDuration);
      print(response.body);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['stocklocinv'] != null && data['stocklocinv'].isNotEmpty) {
          final Map<String, dynamic> stocklocinv = data['stocklocinv'];
          double onhandqty;
          try {
            onhandqty = double.parse(stocklocinv['onhandqty']) ?? 0;
          } catch (e) {
            return Future.error('Invalid on hand quantity format');
          }
          return onhandqty;
        } else {
          return Future.error('Failed to load on hand quantity');
        }
      } else {
        return Future.error('Failed to load on hand quantity');
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<Map<int, String>> getDimensionList() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseURL/mobile/dimensions'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> dimensions = jsonDecode(response.body);
        return {
          for (var dimension in dimensions)
            int.parse(dimension['id']): dimension['descri']
        };
      } else {
        return Future.error('Failed to load dimensions');
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<String> saveMRI(String date, int locationId, String remark,
      String invType, List items, String creationDate) async {
    try {
      UserDetails userDetails = await UserRepository().getUserDetails();

      final response = await http
          .post(
            Uri.parse('$baseURL/mobile/mri/save'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              'date': date,
              'locationId': locationId,
              'remark': remark,
              'invType': invType,
              'items': items,
              'companyId': 3,
              'userId': userDetails.userId,
              'creationDate': creationDate
            }),
          )
          .timeout(const Duration(seconds: 40));
      if (response.statusCode == 200 || response.statusCode == 201) {
        //clear mri_items

        await MriItemsRepository().clearAllItems();

        return response.body;
      } else {
        return Future.error('Failed to save MRI Res');
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
