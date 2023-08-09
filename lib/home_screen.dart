import 'package:background/presentation/control.dart';
import 'package:background/shared/network/local_db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final controller = Get.put(Controller());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.getNotification2();
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<Controller>(
        builder: (_) => Column(
          children: [
            Text(controller.re.length.toString()),
            Expanded(
              child:ListView.builder(
                itemBuilder: (d,f){
                  return Dismissible(
                    onDismissed: (ff)async{
                      await SqlDb().deleteData("DELETE FROM 'notifications2' WHERE id = ${controller.re[f]["id"]} ");
                      await controller.getNotification2();
                    },
                    key: Key(f.toString()),
                    child: Card(
                      color: Colors.grey.shade200,
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Column(children: [
                        Text(controller.re[f]["title"].toString()),
                        Text(controller.re[f]["text"].toString()??""),
                        Text(controller.re[f]["url"].toString()??""),
                      ],
                      ),
                    ),
                  );
                },
                itemCount: controller.re.length,
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.add),
      //   onPressed: () async{
      //     // CacheHelper().getList();
      //     // print(await SqlDb().insertData("INSERT INTO notifications2('id', 'title', 'text', 'url', 'image_full_link') VALUES (7, '8','ksls','slsl','sskoksoks')"));
      //     // await SqlDb().deleteData("DELETE FROM 'notifications' WHERE id = 1 ");
      //     // await SqlDb().deleteData("DELETE FROM 'notifications' WHERE id = 2 ");
      //     // await SqlDb().deleteData("DELETE FROM 'notifications' WHERE id = 3 ");
      //     // await SqlDb().deleteData("DELETE FROM 'notifications' WHERE id = 4 ");
      //
      //     // re.forEach((element)async {
      //     //   if(element["id"] == 2)
      //     //     await SqlDb().deleteData("DELETE FROM 'notifications' WHERE id = 2 ");
      //     // });
      //     // await SqlDb().updateData("UPDATE 'notifications' SET 'showed' = 0 WHERE id = 1 ");
      //     // await SqlDb().updateData("UPDATE 'notifications' SET 'showed' = 0 WHERE id = 2 ");
      //     // await SqlDb().updateData("UPDATE 'notifications' SET 'showed' = 0 WHERE id = 3 ");
      //     // await SqlDb().updateData("UPDATE 'notifications' SET 'showed' = 0 WHERE id = 4 ");
      //     // await SqlDb().updateData("UPDATE 'notifications' SET 'showed' = 0 WHERE id = 5 ");
      //     // await SqlDb().updateData("UPDATE 'notifications' SET 'showed' = 0 WHERE id = 6 ");
      //     // await SqlDb().updateData("UPDATE 'notifications' SET 'showed' = 0 WHERE id = 7 ");
      //     // await SqlDb().updateData("UPDATE 'notifications' SET 'showed' = 0 WHERE id = 8 ");
      //     // List<Map> hh = await SqlDb().readData("SELECT * FROM 'notifications' WHERE id LIKE 5");
      //     // for(int i=1;i<9;i++)
      //     //   await SqlDb().deleteData("UPDATE 'notifications' SET 'showed' = 0 WHERE id = $i ");
      //     // List<Map> re = await SqlDb().readData("SELECT * FROM 'notifications2'");
      //     print(controller.getNotification2());
      //     // controller.increment();
      //     },
      // ),
    );
  }

}