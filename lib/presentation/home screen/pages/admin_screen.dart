import 'package:flutter/material.dart';
import 'package:notficationalarm/presentation/home%20screen/cubit/home_cubit.dart';

import '../../../resources/routes_maneger.dart';
import '../../login/cubit/cubit.dart';
import '../widgets/requests_list.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    HomeCubit.get(context).getRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Page'),
          actions: [
            IconButton(
              onPressed: () {
                AuthCubit.get(context).logOut(context);
              },
              icon: const Icon(Icons.logout),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.sendAlarm);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: const RequestsList(),
      ),
    );
  }
}
