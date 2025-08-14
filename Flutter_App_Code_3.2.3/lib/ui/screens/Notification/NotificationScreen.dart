import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/UserNotification/userNotificationCubit.dart';
import 'package:news/ui/screens/Notification/Widgets/userNotificationWidget.dart';
import 'package:news/ui/widgets/customAppBar.dart';
import 'package:news/ui/widgets/customTextLabel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => const NotificationScreen());
  }
}

class NotificationScreenState extends State<NotificationScreen> with TickerProviderStateMixin {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    getNotification();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void getNotification() {
    Future.delayed(Duration.zero, () {
      if (context.read<AuthCubit>().getUserId() != "0") context.read<UserNotificationCubit>().getUserNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Scaffold(
            appBar: CustomAppBar(height: 45, isBackBtn: true, label: 'notificationLbl', horizontalPad: 15, isConvertText: true),
            body: (context.read<AuthCubit>().getUserId() != "0") ? const UserNotificationWidget() : Center(child: CustomTextLabel(text: 'notificationLogin', textAlign: TextAlign.center)));
      },
    );
  }
}
