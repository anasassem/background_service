import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../model/request_model.dart';
import '../../../resources/responsive.dart';
import '../../../resources/strings_maneger.dart';
import '../../login/cubit/cubit.dart';
import '../cubit/home_cubit.dart';

class FireFighterScreen extends StatelessWidget {
  const FireFighterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = HomeCubit.get(context);
    log("lksnkofndnfdlo");
    log(cubit.user.category.toString());
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .where('category', isEqualTo: 'all')
            .snapshots(),
        builder: (context, snapshotAll) {
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('categories')
                .where('category', isEqualTo: cubit.user.category)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError || snapshotAll.hasError) {
                return const Scaffold(
                    body: Center(child: Text(AppStrings.errorMsg)));
              } else if ((snapshot.connectionState == ConnectionState.done ||
                      snapshot.connectionState == ConnectionState.active) &&
                  (snapshotAll.connectionState == ConnectionState.done ||
                      snapshotAll.connectionState == ConnectionState.active)) {
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: isAlarmed(snapshotAll, snapshot, cubit)
                          ? Colors.red
                          : Colors.green,
                      title: isAlarmed(snapshotAll, snapshot, cubit)
                          ? const Text("Emergency")
                          : const Text("Normal"),
                      actions: [
                        IconButton(
                          onPressed: () {
                            AuthCubit.get(context).logOut(
                              context,
                              cubit.user.category!.replaceAll(' ', ''),
                            );
                          },
                          icon: const Icon(Icons.logout),
                        ),
                      ],
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Welcome: ',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: cubit.user.name,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: responsive.sHeight(context) * 0.3,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isAlarmed(
                                    snapshotAll, snapshot, cubit)) ...[
                                  Text(
                                    (checkIsAlarmedForAll(snapshotAll, cubit)
                                            ? snapshotAll.data!.docs.last
                                                .data()['title']
                                            : null) ??
                                        snapshot.data!.docs.last
                                            .data()['title'],
                                    style: const TextStyle(
                                      fontSize: 30,
                                      color: Colors.red,
                                    ),
                                  ),
                                  responsive.sizedBoxH10,
                                  Text(
                                    (checkIsAlarmedForAll(snapshotAll, cubit)
                                            ? snapshotAll.data!.docs.last
                                                .data()['body']
                                            : null) ??
                                        snapshot.data!.docs.last.data()['body'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      color: Colors.red,
                                    ),
                                  ),
                                  responsive.sizedBoxH20,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(Colors.green)
                                          ),
                                          onPressed: () {
                                            if (checkIsAlarmedForAll(
                                                snapshotAll, cubit)) {
                                              cubit.addRequest(
                                                true,
                                                snapshotAll
                                                    .data!.docs.first['time'],
                                                category: 'all',
                                                title: snapshotAll
                                                    .data!.docs.first['title'],
                                                body: snapshotAll
                                                    .data!.docs.first['body'],
                                              );
                                            } else {
                                              cubit.addRequest(
                                                true,
                                                snapshot
                                                    .data!.docs.first['time'],
                                                title: snapshot
                                                    .data!.docs.first['title'],
                                                body: snapshot
                                                    .data!.docs.first['body'],
                                              );
                                            }
                                          },
                                          child: const Text('Accept'),
                                        ),
                                      ),
                                      responsive.sizedBoxW15,
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.red)
                                          ),
                                          onPressed: () {
                                            if (checkIsAlarmedForAll(
                                                snapshotAll, cubit)) {
                                              cubit.addRequest(
                                                  false,
                                                  snapshotAll
                                                      .data!.docs.first['time'],
                                                  category: 'all',
                                                  title: snapshotAll.data!.docs
                                                      .first['title'],
                                                  body: snapshotAll.data!.docs
                                                      .first['body']);
                                            } else {
                                              cubit.addRequest(
                                                  false,
                                                  snapshot
                                                      .data!.docs.first['time'],
                                                  title: snapshot.data!.docs
                                                      .first['title'],
                                                  body: snapshot.data!.docs
                                                      .first['body']);
                                            }
                                          },
                                          child: const Text('Reject'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else
                                  const Center(
                                      child: Text(
                                    "Everything is ok",
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.green,
                                    ),
                                  ))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            },
          );
        });
  }

  bool isAlarmed(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshotAll,
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      HomeCubit cubit) {
    return checkIsAlarmedForAll(snapshotAll, cubit) ||
        checkIsAlarmedForMyCategory(snapshot, cubit);
  }

  bool checkIsAlarmedForMyCategory(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      HomeCubit cubit) {
    return (snapshot.data!.docs.first.data()['alarm'] &&
        !hasAcceptedRequest(
          (snapshot.data!.docs.first.data()['accepted'] as List)
              .map((e) => RequestModel.fromMap(e))
              .toList(),
          cubit.user.uId!,
          snapshot.data!.docs.first.data()['time'],
        ) &&
        !hasRejectedRequest(
          (snapshot.data!.docs.first.data()['rejected'] as List)
              .map((e) => RequestModel.fromMap(e))
              .toList(),
          cubit.user.uId!,
          snapshot.data!.docs.first.data()['time'],
        ));
  }

  bool checkIsAlarmedForAll(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshotAll,
      HomeCubit cubit) {
    return (snapshotAll.data!.docs.first.data()['alarm'] &&
        !hasAcceptedRequest(
          (snapshotAll.data!.docs.first.data()['accepted'] as List)
              .map((e) => RequestModel.fromMap(e))
              .toList(),
          cubit.user.uId!,
          snapshotAll.data!.docs.first.data()['time'],
        ) &&
        !hasRejectedRequest(
          (snapshotAll.data!.docs.first.data()['rejected'] as List)
              .map((e) => RequestModel.fromMap(e))
              .toList(),
          cubit.user.uId!,
          snapshotAll.data!.docs.first.data()['time'],
        ));
  }

  bool hasRejectedRequest(
      List<RequestModel> rejected, String userId, String time) {
    bool isRejected = false;

    for (var e in rejected) {
      if (e.time == time && e.id == userId) {
        isRejected = true;
      }
    }

    return isRejected;
  }

  bool hasAcceptedRequest(
      List<RequestModel> accepted, String userId, String time) {
    bool isAccepted = false;

    for (var e in accepted) {
      if (e.time == time && e.id == userId) {
        isAccepted = true;
      }
    }

    return isAccepted;
  }
}
