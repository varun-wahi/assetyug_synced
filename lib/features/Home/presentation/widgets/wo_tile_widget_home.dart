//WORK ORDER DASHBPARD TILES
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Work Orders/presentation/riverpod/wo_filter_notifier.dart';
import '../../../Main/presentation/riverpod/tab_notifier.dart';
import '../../../Work Orders/data/repository/work_orders_mongodb.dart';
import '../../../../core/utils/constants/sizes.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/utils/widgets/loading_animated_container.dart';

class BuildWorkOrderTile extends ConsumerWidget {
  final Color colorByStatus;
  final String category;
  final String value;
  final IconData? myIcon;
  final Color? iconColor;
  final bool isLoading;

  const BuildWorkOrderTile(
      {super.key,
      required this.colorByStatus,
      required this.category,
      required this.value,
      this.myIcon = Icons.timer,
      this.iconColor = tBlack,
      required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        //TODO: ADD FILTER TO WORK ORDER SCREEN

        ref.read(tabProvider.notifier).setTab(2);
        ref.read(woFiltersProvider.notifier)
            .updateFilter({"$category": "$value"});
      },
      // Change to desired tab index,
      child: Container(
        margin: const EdgeInsets.all(dPadding),
        decoration: BoxDecoration(
            color: tWhite,
            borderRadius: BorderRadius.circular(dBorderRadius),
            border: Border.all(width: 1.2, color: tGreyLight)),
        child: FutureBuilder(
          future: WorkOrdersMongodb.fetchWorkOrdersByCategory(category, value),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              if (isLoading) {
                return const LoadingAnimatedContainer();
              } else {
                return const LoadingAnimatedContainer();
              }
            } else if (snapshot.hasData) {
              final workOrders = snapshot.data as List<Map<String, dynamic>>;
              return Container(
                  padding: const EdgeInsets.all(dPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //ROW CHILD 1
                      //STATUS COLOR
                      Container(
                        height: 90,
                        width: 5,
                        decoration: BoxDecoration(color: colorByStatus),
                      ),

                      //ROW CHILD 2

                      //STATUS TITLE
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            myIcon,
                            size: 20,
                            color: iconColor,
                          ),
                          const SizedBox(
                            height: dGap,
                          ),
                          Text(
                            "${workOrders.length}",
                            style: boldHeading(
                              size: 18,
                            ),
                          ),

                          const SizedBox(
                            height: dGap,
                          ),

                          //T I T L E
                          Text(
                            value,
                            style: body(size: 16),
                          ),
                        ],
                      ),

                      const SizedBox(
                        width: 5,
                      ),
                      //ROW CHILD 3
                    ],
                  ));
            } else {
              return const LoadingAnimatedContainer();
            }
          },
        ),
      ),
    );
  }
}