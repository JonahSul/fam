import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:henox/controller/ui/timeline_controller.dart';
import 'package:henox/helpers/theme/app_theme.dart';
import 'package:henox/helpers/utils/mixins/ui_mixin.dart';
import 'package:henox/helpers/utils/my_shadow.dart';
import 'package:henox/helpers/widgets/my_breadcrumb.dart';
import 'package:henox/helpers/widgets/my_breadcrumb_item.dart';
import 'package:henox/helpers/widgets/my_card.dart';
import 'package:henox/helpers/widgets/my_container.dart';
import 'package:henox/helpers/widgets/my_spacing.dart';
import 'package:henox/helpers/widgets/my_text.dart';
import 'package:henox/model/time_line_model.dart';
import 'package:henox/view/layouts/layout.dart';
import 'package:timelines/timelines.dart';

class TimeLineScreen extends StatefulWidget {
  const TimeLineScreen({super.key});

  @override
  State<TimeLineScreen> createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> with SingleTickerProviderStateMixin, UIMixin {
  late TimelineController controller = Get.put(TimelineController());

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Column(
            children: [
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium("Timeline", fontSize: 18, fontWeight: 600),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: 'Pages'),
                        MyBreadcrumbItem(name: 'Timeline'),
                      ],
                    ),
                  ],
                ),
              ),
              MySpacing.height(flexSpacing),
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Column(
                  children: [
                    Timeline.tileBuilder(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shrinkWrap: true,
                      builder: TimelineTileBuilder.fromStyle(
                        indicatorStyle: IndicatorStyle.outlined,
                        itemCount: controller.timeLine.length,
                        contentsAlign: ContentsAlign.alternating,
                        connectorStyle: ConnectorStyle.dashedLine,
                        endConnectorStyle: ConnectorStyle.dashedLine,
                        contentsBuilder: (context, index) {
                          TimeLineModel timeLine = controller.timeLine[index];
                          return MyCard(
                            marginAll: 20,
                            borderRadiusAll: 8,
                            shadow: MyShadow(position: MyShadowPosition.bottom, elevation: .5),
                            paddingAll: 24,
                            child: Column(
                              crossAxisAlignment: index % 2 == 0 ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                              children: [
                                MyText.bodyMedium(timeLine.title, fontWeight: 600, overflow: TextOverflow.ellipsis),
                                MySpacing.height(12),
                                MyText.bodySmall(timeLine.date, muted: true, overflow: TextOverflow.ellipsis),
                                MySpacing.height(12),
                                MyText.bodySmall(timeLine.description, fontWeight: 600,muted:true, textAlign: index % 2 == 0 ? TextAlign.start : TextAlign.end),
                                MySpacing.height(12),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: timeLine.like.map(
                                    (e) {
                                      return MyContainer(
                                        paddingAll: 8,
                                        color: contentTheme.secondary.withAlpha(30),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            MyText.bodyMedium(e.emoji),
                                            MySpacing.width(8),
                                            MyText.bodyMedium(e.count),
                                          ],
                                        ),
                                      );
                                    },
                                  ).toList(),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
