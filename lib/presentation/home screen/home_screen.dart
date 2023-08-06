import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notficationalarm/presentation/home%20screen/pages/admin_screen.dart';
import 'package:notficationalarm/presentation/home%20screen/pages/fire_fighter_screen.dart';
import 'package:notficationalarm/resources/strings_maneger.dart';

import 'cubit/home_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    HomeCubit.get(context).getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final cubit = HomeCubit.get(context);
              if (state is HomeGetUserDataLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is HomeGetUserDataFailure) {
                return const Center(
                  child: Text(AppStrings.errorMsg),
                );
              }
              return cubit.user.isAdmin == true
                  ? const AdminScreen()
                  : const FireFighterScreen();
            },
          ),
        ),
      ),
    );
  }
}
