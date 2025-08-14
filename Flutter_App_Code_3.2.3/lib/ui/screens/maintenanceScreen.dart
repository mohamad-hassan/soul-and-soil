import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/ui/screens/auth/Widgets/svgPictureWidget.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  MaintenanceScreenState createState() => MaintenanceScreenState();
}

class MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0, top: 10.0, bottom: 10.0),
      child: BlocBuilder<AppConfigurationCubit, AppConfigurationState>(
        builder: (context, state) {
          if (state is AppConfigurationFetchSuccess && state.appConfiguration.maintenanceMode == "1") {
            return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SvgPictureWidget(assetName: "maintenance"),
              const SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CustomTextLabel(
                      textStyle: TextStyle(color: Theme.of(context).colorScheme.primaryContainer, fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      text: 'maintenanceMessageLbl'))
            ]);
          } else if (state is AppConfigurationFetchSuccess && state.appConfiguration.maintenanceMode == "0") {
            Navigator.of(context).pop();
          }
          //default/Processing state
          return Padding(padding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0), child: CircularProgressIndicator());
        },
      ),
    ));
  }
}
