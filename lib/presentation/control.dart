import 'dart:convert';


import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:background/shared/network/local_db.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
class Controller extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
  List re = [].obs ;
  var count = 0;
  void increment() {
    count++;
    update();
  }
  getNotification2()async{
    re = await SqlDb().readData("SELECT * FROM 'notifications2'");
    update();
    return re;
  }

  getLocations() async {
    try{
      await http.get(
          Uri.parse(
              "https://app01.cloud-systems.org/demo-hamada/api/v3/app/warehouses"),
          headers: {"X-Api-Key": "Fekra1895478683IT"}).then((value) {
        jsonDecode(value.body)["data"]["warehouses"].forEach((element) async {
          if (list.containsKey(element["id"]) == false) {
            list[element["id"]] = {
              "name": element["name"],
              "lat": "28.5024428",
              "lng": "30.8059445"
            };
            var sharedPreferences = await SharedPreferences.getInstance();
            await sharedPreferences.setString(
                "locations", jsonEncode(list));
          }
        });
      });
    }catch(e){
      print('error in getLocations$e');
    }

  }

  getNotification() async {
    try{
      await http.get(
          Uri.parse(
              "https://app01.cloud-systems.org/demo-hamada/api/v3/app/warehouse_ads"),
          headers: {"X-Api-Key": "Fekra1895478683IT"}).then((value) async {
        List data = jsonDecode(value.body)["data"]["warehouse_ads"];
        for (var element in data) {
          // List<Map> hh = await SqlDb().readData("SELECT * FROM 'notifications' WHERE id LIKE ${element["id"]}");
          List<Map> hh2 = await SqlDb().readData("SELECT * FROM 'notifications'");
          if (hh2
              .where((element1) =>
          element1["id"].toString() == element["id"].toString())
              .isEmpty) {
            await SqlDb().insertData(
                "INSERT INTO notifications('id', 'title', 'text', 'url', 'image_full_link', 'warehouses_ids','repeated','showed') VALUES (${int.parse(element["id"])}, '${element["title"]}','${element["text"]}','${element["url"]}','${element["image_full_link"]}','${element["warehouses_ids"].join(',')}','${int.parse(element["repeated"])}',0)");
            print('added ${element["id"]}');
          }
          for (var element in hh2) {
            if (data
                .where((element1) => element1["id"] == element["id"].toString())
                .isEmpty) {
              await SqlDb().deleteData(
                  "DELETE FROM 'notifications' WHERE id = ${element["id"]} ");
              print('deleted${element["id"]}');
            }
          }
        }
      });
    }catch(e){
      print('error in get Notification$e');
    }

  }
  static Map list = {};
  getList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    var list = await jsonDecode(preferences.getString("locations") ?? "{}");
    return list;
  }
  sm() async{
    Position position;
    try{
      if (await Geolocator.isLocationServiceEnabled()) {
        position = await Geolocator.getCurrentPosition();
        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
        list.forEach((key, value) async {
          print('object1');
          var mis = Geolocator.distanceBetween(
              double.parse(value["lat"]), double.parse(value["lng"]),
              position.latitude, position.longitude);
          List<Map> re = await SqlDb().readData(
              "SELECT * FROM 'notifications'");
          if (mis <= 100) {
            for (var element in re) {
              element["warehouses_ids"].toString().split(',').forEach((
                  element2) async {
                if (element2.toString() == key) {
                  if (element["showed"] == 0) {
                    print('object');

                    // send
                    if (element["image_full_link"] != "null") {
                      final http.Response response = await http.get(Uri.parse(
                          element["image_full_link"]));
                      BigPictureStyleInformation bigPictureStyleInformation =
                      BigPictureStyleInformation(
                        ByteArrayAndroidBitmap.fromBase64String(base64Encode(
                            response.bodyBytes)),
                        largeIcon: ByteArrayAndroidBitmap.fromBase64String(
                            base64Encode(response.bodyBytes)),
                      );
                      await flutterLocalNotificationsPlugin.show(
                        Random().nextInt(1000),
                        element["title"],
                        element["text"],
                        payload: element["url"].toString(),
                        NotificationDetails(
                          android: AndroidNotificationDetails(
                              'notification',
                              'MY notification',
                              priority: Priority.min,
                              importance: Importance.max,
                              styleInformation: bigPictureStyleInformation
                          ),
                        ),
                      ).then((value) async {
                        await SqlDb()
                            .insertData(
                            "INSERT INTO notifications2('id', 'title', 'text', 'url', 'image_full_link') VALUES (${(element["id"])}, '${element["title"]}','${element["text"]}','${element["url"]}','${element["image_full_link"]}')")
                            .then((value) async {
                          await getNotification2();
                        });

                        await SqlDb().updateData(
                            "UPDATE 'notifications' SET 'showed' = 1 WHERE id = ${element["id"]}");
                      });
                    } else {
                      await flutterLocalNotificationsPlugin.show(
                        Random().nextInt(1000),
                        element["title"],
                        element["text"],
                        payload: "test",
                        const NotificationDetails(
                          android: AndroidNotificationDetails(
                            'notification',
                            'MY notification',
                            priority: Priority.min,
                            importance: Importance.max,
                          ),
                        ),
                      ).then((value) async {
                        await SqlDb()
                            .insertData(
                            "INSERT INTO notifications2('id', 'title', 'text', 'url', 'image_full_link') VALUES (${(element["id"])}, '${element["title"]}','${element["text"]}','${element["url"]}','${element["image_full_link"]}')")
                            .then((value) async {
                          await getNotification2();
                        });

                        await SqlDb().updateData(
                            "UPDATE 'notifications' SET 'showed' = 1 WHERE id = ${element["id"]}");
                      });
                    }
                  }
                }
              });
            }
          } else {
            for (var element in re)
              if (element["repeated"] == 1)
                await SqlDb().updateData(
                    "UPDATE 'notifications' SET 'showed' = 0 WHERE id = ${element["id"]}");
          }
        }
        );
      }
    }catch(e){
      print("error in notifications $e");
    }


  }

}
