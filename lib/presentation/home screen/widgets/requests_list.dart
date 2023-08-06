// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:notficationalarm/resources/responsive.dart';

import '../../../model/request_model.dart';
import '../../../resources/strings_maneger.dart';
import '../cubit/home_cubit.dart';

class RequestsList extends StatelessWidget {
  const RequestsList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
      final cubit = HomeCubit.get(context);
      if (state is HomeGetRequestsLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is HomeGetRequestsFailure) {
        return const Center(
          child: Text(AppStrings.errorMsg),
        );
      }

      final reports = cubit.reports;

      if (reports.isEmpty) {
        return Center(
          child: Text(
            "No Reports Available",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await cubit.getRequests();
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(10.0),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            int index = reports.length - i - 1;

            final acceptedRequests =
                reports[reports.keys.elementAt(index)]?['accepted'];
            final rejectedRequests =
                reports[reports.keys.elementAt(index)]?['rejected'];
            if (acceptedRequests == null && rejectedRequests == null) {
              return Container();
            }

            return Material(
              elevation: 5.0,
              child: ExpansionTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (acceptedRequests?.first.title) ??
                          (rejectedRequests?.first.title) ??
                          '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      (acceptedRequests?.first.body) ??
                          (rejectedRequests?.first.body) ??
                          '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      (acceptedRequests?.first.mainCategoryName) ??
                          (rejectedRequests?.first.mainCategoryName) ??
                          '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      notificationTime(acceptedRequests, rejectedRequests),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (acceptedRequests?.last.mainCategoryName == 'all' ||
                        rejectedRequests?.last.mainCategoryName == 'all')
                      if ((acceptedRequests?.last.acceptedCategoriesOfAll !=
                              null &&
                          acceptedRequests!
                              .last.acceptedCategoriesOfAll!.isNotEmpty))
                        ...categoriesOfAll(
                          acceptedRequests.last.acceptedCategoriesOfAll!,
                          true,
                        ),
                    if (rejectedRequests?.last.rejectedCategoriesOfAll !=
                            null &&
                        rejectedRequests!
                            .last.rejectedCategoriesOfAll!.isNotEmpty)
                      ...categoriesOfAll(
                        rejectedRequests.last.rejectedCategoriesOfAll!,
                        false,
                      ),
                    Text(
                      "Total accepts: ${acceptedRequests?.length ?? 0}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Total rejects: ${rejectedRequests?.length ?? 0}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Total: ${(rejectedRequests?.length ?? 0) + (acceptedRequests?.length ?? 0)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                children: [
                  if (acceptedRequests != null &&
                      acceptedRequests.isNotEmpty) ...[
                    const Text(
                      "Accepted",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    responsive.sizedBoxH10,
                    ...reports[reports.keys.elementAt(index)]!['accepted']!.map(
                      (request) => ReportCard(
                        requestModel: request,
                      ),
                    ),
                  ],
                  if (rejectedRequests != null &&
                      rejectedRequests.isNotEmpty) ...[
                    const Text(
                      "Rejected",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    responsive.sizedBoxH10,
                    ...reports[reports.keys.elementAt(index)]!['rejected']!.map(
                      (request) => ReportCard(
                        requestModel: request,
                      ),
                    ),
                  ]
                ],
              ),
            );
          },
          separatorBuilder: (context, i) => responsive.sizedBoxH20,
          itemCount: reports.length,
        ),
      );
    });
  }

  List<Widget> categoriesOfAll(Map<String, int> categories, bool isAccepted) {
    List<Widget> children = [];
    categories.forEach((key, value) {
      children.add(
        Text(
          "Total ${(isAccepted ? 'accepts' : 'rejects')} from $key: $value",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    });

    return children;
  }

  String notificationTime(List<RequestModel>? acceptedRequests,
      List<RequestModel>? rejectedRequests) {
    return (DateFormat.yMEd().add_jms().format(
          DateTime.parse(
            acceptedRequests?.first.time ??
                (rejectedRequests?.first.time) ??
                DateTime.now().toString(),
          ),
        ));
  }
}

class ReportCard extends StatelessWidget {
  final RequestModel requestModel;
  const ReportCard({
    Key? key,
    required this.requestModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 20.0,
        left: 10.0,
        right: 10.0,
      ),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.black, width: 1)),
      child: Card(
        margin: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Name: ${requestModel.name}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              responsive.sizedBoxH10,
              Text(
                "Category: ${requestModel.category}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              responsive.sizedBoxH10,
              Text(
                "Time: ${DateFormat.yMEd().add_jms().format(DateTime.parse(requestModel.userActiontime))}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
