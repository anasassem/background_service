// import 'dart:convert';
// import 'package:background/shared/network/cache_helper.dart';
// import 'package:background/shared/network/local_db.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:math';
//
//
// part 'home_state.dart';
//
// class HomeCubit extends Cubit<HomeState> {
//
//   HomeCubit() : super(HomeInitial());
//
//   static HomeCubit get(context) => BlocProvider.of(context);
//   List<Map> re = [];
//
//   getNotification2()async{
//      re = await SqlDb().readData("SELECT * FROM 'notifications2'");
//      print(re.length);
//      emit(GetSuccess());
//     return 're';
//   }
//
//   getLocations() async {
//     await http.get(
//         Uri.parse(
//             "https://app01.cloud-systems.org/demo-hamada/api/v3/app/warehouses"),
//         headers: {"X-Api-Key": "Fekra1895478683IT"}).then((value) {
//       // print(jsonDecode(value.body)["data"]["warehouses"]);
//       jsonDecode(value.body)["data"]["warehouses"].forEach((element) async {
//         if (CacheHelper.list.containsKey(element["id"]) == false) {
//         // if (element["id"] == "1") {
//           CacheHelper.list[element["id"]] = {
//             "name": element["name"],
//             "lat": "28.5024428",
//             "lng": "30.8059445"
//           };
//           var sharedPreferences = await SharedPreferences.getInstance();
//           await sharedPreferences.setString(
//               "locations", jsonEncode(CacheHelper.list));
//         }
//         //   if(CacheHelper.list.where((element1) => element1.id == element["id"]).isEmpty){
//         //     CacheHelper.list.add(LocationModel.fromJson(element));
//         //     var sharedPreferences = await SharedPreferences.getInstance();
//         //     await sharedPreferences.setString( "locations", jsonEncode(CacheHelper.list));
//         //   }
//         emit(ChangedSuccess());
//       });
//       emit(ChangedSuccess());
//     });
//     emit(ChangedSuccess());
//   }
//
//   getNotification() async {
//     await http.get(
//         Uri.parse(
//             "https://app01.cloud-systems.org/demo-hamada/api/v3/app/warehouse_ads"),
//         headers: {"X-Api-Key": "Fekra1895478683IT"}).then((value) async {
//       List data = jsonDecode(value.body)["data"]["warehouse_ads"];
//       for (var element in data) {
//         // List<Map> hh = await SqlDb().readData("SELECT * FROM 'notifications' WHERE id LIKE ${element["id"]}");
//         List<Map> hh2 = await SqlDb().readData("SELECT * FROM 'notifications'");
//         if (hh2
//             .where((element1) =>
//                 element1["id"].toString() == element["id"].toString())
//             .isEmpty) {
//           await SqlDb().insertData(
//               "INSERT INTO notifications('id', 'title', 'text', 'url', 'image_full_link', 'warehouses_ids','repeated','showed') VALUES (${int.parse(element["id"])}, '${element["title"]}','${element["text"]}','${element["url"]}','${element["image_full_link"]}','${element["warehouses_ids"].join(',')}','${int.parse(element["repeated"])}',0)");
//           print('added ' + element["id"]);
//         }
//         for (var element in hh2) {
//           if (data
//               .where((element1) => element1["id"] == element["id"].toString())
//               .isEmpty) {
//             await SqlDb().deleteData(
//                 "DELETE FROM 'notifications' WHERE id = ${element["id"]} ");
//             print('deleted' + element["id"].toString());
//           }
//         }
//         emit(ChangedSuccess());
//       }
//       emit(ChangedSuccess());
//     });
//     emit(ChangedSuccess());
//   }
//
//   sm() async{
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
//
//     CacheHelper.list.forEach((key, value) async {
//       var mis = Geolocator.distanceBetween(double.parse(value["lat"]), double.parse(value["lng"]),
//           position.latitude, position.longitude);
//       List<Map> re = await SqlDb().readData("SELECT * FROM 'notifications'");
//       if (mis <= 100) {
//         for (var element in re){
//           element["warehouses_ids"].toString().split(',').forEach((element2)async {
//             if(element2.toString() == key){
//               if(element["showed"] == 0){
//                 // send
//                 if(element["image_full_link"] != "null"){
//                   final http.Response response = await http.get(Uri.parse(element["image_full_link"]));
//                   BigPictureStyleInformation bigPictureStyleInformation =
//                   BigPictureStyleInformation(
//                     ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
//                     largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
//                   );
//                   await flutterLocalNotificationsPlugin.show(
//                     Random().nextInt(1000),
//                     element["title"],
//                     element["text"],
//                     payload: element["url"].toString(),
//                     NotificationDetails(
//                       android: AndroidNotificationDetails(
//                           'notification',
//                           'MY notification',
//                           priority: Priority.min,
//                           importance: Importance.max,
//                           styleInformation: bigPictureStyleInformation
//                       ),
//                     ),
//                   );
//                 }else{
//                   await flutterLocalNotificationsPlugin.show(
//                     Random().nextInt(1000),
//                     element["title"],
//                     element["text"],
//                     payload: "test",
//                     const NotificationDetails(
//                       android: AndroidNotificationDetails(
//                         'notification',
//                         'MY notification',
//                         priority: Priority.min,
//                         importance: Importance.max,
//                       ),
//                     ),
//                   );
//                 }
//                 await SqlDb().insertData("INSERT INTO notifications2('id', 'title', 'text', 'url', 'image_full_link') VALUES (${(element["id"])}, '${element["title"]}','${element["text"]}','${element["url"]}','${element["image_full_link"]}')");
//                 HomeCubit().getNotification2();
//
//                 await SqlDb().updateData("UPDATE 'notifications' SET 'showed' = 1 WHERE id = ${element["id"]}");
//               }
//             }
//           });
//         }
//       }else{
//         for (var element in re)
//           if(element["repeated"] == 1)
//             await SqlDb().updateData("UPDATE 'notifications' SET 'showed' = 0 WHERE id = ${element["id"]}");
//       }
//     }
//     );
//   }
//
// }
