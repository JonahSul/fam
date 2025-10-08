import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helpers/widgets/my_responsive.dart';
import 'left_bar.dart';
import 'right_bar.dart';
import 'top_bar.dart';

class Layout extends StatelessWidget {
  final Widget? child;

  const Layout({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return MyResponsive(builder: (BuildContext context, _, screenMT) {
      return Scaffold(
        body: Row(
          children: [
            // Left Sidebar
            if (!screenMT.isMobile && !screenMT.isTablet)
              LeftBar(),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  TopBar(),

                  // Main Content
                  Expanded(
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: child ?? Container(),
                    ),
                  ),
                ],
              ),
            ),

            // Right Sidebar
            if (!screenMT.isMobile && !screenMT.isTablet)
              RightBar(),
          ],
        ),
      );
    });
  }
}
