import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:news/app/app.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/Auth/deleteUserCubit.dart';
import 'package:news/cubits/Auth/registerTokenCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/cubits/languageJsonCubit.dart';
import 'package:news/cubits/otherPagesCubit.dart';
import 'package:news/cubits/settingCubit.dart';
import 'package:news/data/repositories/Auth/authLocalDataSource.dart';
import 'package:news/ui/screens/Profile/Widgets/customAlertDialog.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customAppBar.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:news/cubits/themeCubit.dart';
import 'package:news/ui/styles/appTheme.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => const ProfileScreen());
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  File? image;
  String? name, mobile, email, profile;
  TextEditingController? nameC, monoC, emailC = TextEditingController();
  AuthLocalDataSource authLocalDataSource = AuthLocalDataSource();
  bool isEditMono = false;
  bool isEditEmail = false;
  String? updateValue;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  void initState() {
    getOtherPagesData();
    super.initState();
  }

  getOtherPagesData() {
    Future.delayed(Duration.zero, () {
      context.read<OtherPageCubit>().getOtherPage(langId: context.read<AppLocalizationCubit>().state.id);
    });
  }

  Widget pagesBuild() {
    return BlocBuilder<OtherPageCubit, OtherPageState>(builder: (context, state) {
      if (state is OtherPageFetchSuccess) {
        return ScrollConfiguration(
          behavior: GlobalScrollBehavior(),
          child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.otherPage.length,
              itemBuilder: ((context, index) =>
                  setDrawerItem(state.otherPage[index].title!, Icons.info_rounded, false, true, false, 8, image: state.otherPage[index].image!, desc: state.otherPage[index].pageContent))),
        );
      } else {
        //state is OtherPageFetchInProgress || state is OtherPageInitial || state is OtherPageFetchFailure
        return const SizedBox.shrink();
      }
    });
  }

  switchTheme(bool value) async {
    if (value) {
      if (await InternetConnectivity.isNetworkAvailable()) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        context.read<ThemeCubit>().changeTheme(AppTheme.Dark);
        UiUtils.setUIOverlayStyle(appTheme: AppTheme.Dark);
        //for non-appbar screens
      } else {
        showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
      }
    } else {
      if (await InternetConnectivity.isNetworkAvailable()) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        context.read<ThemeCubit>().changeTheme(AppTheme.Light);
        UiUtils.setUIOverlayStyle(appTheme: AppTheme.Light);
        //for non-appbar screens
      } else {
        showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
      }
    }
  }

  bool getTheme() {
    return (context.read<ThemeCubit>().state.appTheme == AppTheme.Dark) ? true : false;
  }

  bool getNotification() {
    if (context.read<SettingsCubit>().state.settingsModel!.notification == true) {
      return true;
    } else {
      return false;
    }
  }

  switchNotification(bool value) {
    if (!value) {
      FirebaseMessaging.instance.deleteToken().then((value) async {
        context.read<RegisterTokenCubit>().registerToken(fcmId: '', context: context);
      });
    } else {
      FirebaseMessaging.instance.getToken().then((value) async {
        context.read<RegisterTokenCubit>().registerToken(fcmId: value!, context: context);
        context.read<SettingsCubit>().changeFcmToken(value);
      });
    }

    context.read<SettingsCubit>().changeNotification(value);
    setState(() {});
  }

  //set drawer item list
  Widget setDrawerItem(String title, IconData? icon, bool isTrailing, bool isNavigate, bool isSwitch, int id, {String? image, String? desc, bool isDeleteAcc = false}) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Container(
          height: 30,
          width: 30,
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(7), color: borderColor.withOpacity(0.2)),
          child: (image != null && image != "")
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.network(
                    image,
                    width: 20,
                    height: 20,
                    color: (image.contains("png")) ? UiUtils.getColorScheme(context).primaryContainer : null,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(icon);
                    },
                  ),
                )
              : Icon(icon, size: 20)),
      iconColor: (isDeleteAcc) ? (context.read<ThemeCubit>().state.appTheme == AppTheme.Dark ? darkIconColor : iconColor) : UiUtils.getColorScheme(context).primaryContainer,
      trailing: (isTrailing)
          ? SizedBox(
              height: 45,
              width: 55,
              child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch.adaptive(
                      onChanged: (id == 0) ? switchTheme : switchNotification,
                      value: (id == 0) ? getTheme() : getNotification(),
                      activeColor: Theme.of(context).primaryColor,
                      activeTrackColor: Theme.of(context).primaryColor,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey)))
          : const SizedBox.shrink(),
      title: CustomTextLabel(
          text: title,
          textStyle: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: (isDeleteAcc) ? (context.read<ThemeCubit>().state.appTheme == AppTheme.Dark ? darkIconColor : iconColor) : UiUtils.getColorScheme(context).primaryContainer)),
      onTap: () {
        if (isNavigate) {
          switch (id) {
            case 2:
              Navigator.of(context).pushNamed(Routes.languageList, arguments: {"from": "profile"});
              break;
            case 3:
              Navigator.of(context).pushNamed(Routes.bookmark);
              break;
            case 4:
              Navigator.of(context).pushNamed(Routes.notification);
              break;
            case 5:
              Navigator.of(context).pushNamed(Routes.addNews, arguments: {"isEdit": false, "from": "profile"});
              break;
            case 6:
              Navigator.of(context).pushNamed(Routes.manageUserNews);
              break;
            case 7:
              Navigator.of(context).pushNamed(Routes.managePref, arguments: {"from": 1});
              break;
            case 8:
              Navigator.of(context).pushNamed(Routes.privacy, arguments: {"from": "setting", "title": title, "desc": desc});
              break;
            case 9:
              _openStoreListing();
              break;
            case 10:
              String str = "$appName\n\n${context.read<AppConfigurationCubit>().getShareAppText()}\n\n${context.read<AppConfigurationCubit>().getAndroidAppLink()}\n";
              bool isIOSAppLive = context.read<AppConfigurationCubit>().getiOSAppLink()?.trim().isNotEmpty ?? false;
              if (isIOSAppLive) str += "\n\n${context.read<AppConfigurationCubit>().getiOSAppLink()}";
              Share.share(str, sharePositionOrigin: Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2));
              break;
            case 12:
              deleteAccount();
              break;
            default:
              break;
          }
        }
      },
    );
  }

  logOutDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
            return CustomAlertDialog(
                isForceAppUpdate: false,
                context: context,
                yesButtonText: 'yesLbl',
                yesButtonTextPostfix: 'logoutLbl',
                noButtonText: 'noLbl',
                imageName: 'logout',
                titleWidget: CustomTextLabel(
                    text: 'logoutLbl', textStyle: Theme.of(this.context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500, color: UiUtils.getColorScheme(context).primaryContainer)),
                messageText: 'logoutTxt',
                onYESButtonPressed: () async {
                  UiUtils.userLogOut(contxt: context);
                });
          });
        });
  }

  //set Delete dialogue
  deleteAccount() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
            return CustomAlertDialog(
                isForceAppUpdate: false,
                context: context,
                yesButtonText: (_auth.currentUser != null) ? 'yesLbl' : 'logoutLbl',
                yesButtonTextPostfix: (_auth.currentUser != null) ? 'deleteTxt' : '',
                noButtonText: (_auth.currentUser != null) ? 'noLbl' : 'cancelBtn',
                imageName: 'deleteAccount',
                titleWidget: (_auth.currentUser != null)
                    ? CustomTextLabel(
                        text: 'deleteAcc', textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: UiUtils.getColorScheme(context).primaryContainer))
                    : CustomTextLabel(
                        text: 'deleteAlertTitle', textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: UiUtils.getColorScheme(context).primaryContainer)),
                messageText: (_auth.currentUser != null) ? 'deleteConfirm' : 'deleteRelogin',
                onYESButtonPressed: () async {
                  (_auth.currentUser != null) ? proceedToDeleteProfile() : askToLoginAgain();
                });
          });
        });
  }

  askToLoginAgain() {
    showSnackBar(UiUtils.getTranslatedLabel(context, 'loginReqMsg'), context);
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
  }

  proceedToDeleteProfile() async {
    //delete user from firebase
    try {
      await _auth.currentUser!.delete().then((value) {
        //delete user prefs from App-local
        context.read<DeleteUserCubit>().deleteUser().then((value) {
          showSnackBar(value["message"], context);
          for (int i = 0; i < AuthProviders.values.length; i++) {
            if (AuthProviders.values[i].name == context.read<AuthCubit>().getType()) {
              context.read<AuthCubit>().signOut(AuthProviders.values[i]).then((value) {
                Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
              });
            }
          }
        });
      });
    } on FirebaseAuthException catch (error) {
      if (error.code == "requires-recent-login") {
        for (int i = 0; i < AuthProviders.values.length; i++) {
          if (AuthProviders.values[i].name == context.read<AuthCubit>().getType()) {
            context.read<AuthCubit>().signOut(AuthProviders.values[i]).then((value) {
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
            });
          }
        }
      } else {
        throw showSnackBar('${error.message}', context);
      }
    } catch (e) {
      debugPrint("unable to delete user - ${e.toString()}");
    }
  }

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(appStoreId: context.read<AppConfigurationCubit>().getAppstoreId(), microsoftStoreId: 'microsoftStoreId');

  Widget setHeader() {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, authState) {
      if (authState is Authenticated && context.read<AuthCubit>().getUserId() != "0") {
        return Container(
          padding: EdgeInsets.all(20),
          color: darkSecondaryColor, //same for both dark and light theme
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: 34,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: (authState.authModel.profile != null && authState.authModel.profile.toString().trim().isNotEmpty)
                        ? Image.network(
                            authState.authModel.profile!,
                            fit: BoxFit.fill,
                            width: 80,
                            height: 80,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person);
                            },
                          )
                        : const Icon(Icons.person, color: secondaryColor)),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 20, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (authState.authModel.name != null && authState.authModel.name != "")
                      CustomTextLabel(
                          text: authState.authModel.name!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: secondaryColor)),
                    const SizedBox(height: 3),
                    if (authState.authModel.mobile != null && authState.authModel.mobile!.trim().isNotEmpty)
                      CustomTextLabel(text: authState.authModel.mobile!, textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: secondaryColor.withOpacity(0.7))),
                    const SizedBox(height: 3),
                    if (authState.authModel.email != null && authState.authModel.email != "")
                      CustomTextLabel(
                          text: authState.authModel.email!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: secondaryColor.withOpacity(0.7))),
                  ],
                ),
              ),
            ),
            Container(
                height: 28,
                width: 28,
                margin: EdgeInsets.symmetric(vertical: 14),
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, color: secondaryColor.withOpacity(0.7)),
                child: GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(Routes.editUserProfile, arguments: {'from': 'profile'}), child: const Icon(Icons.edit_outlined, color: darkSecondaryColor, size: 20)))
          ]),
        );
      } else {
        return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
          //For Guest User
          Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: UiUtils.getColorScheme(context).primaryContainer)),
              alignment: Alignment.center,
              child: Icon(Icons.person, size: 25.0, color: UiUtils.getColorScheme(context).primaryContainer)),

          Expanded(child: setGuestText())
        ]);
      }
    });
  }

  Widget setGuestText() {
    return BlocBuilder<LanguageJsonCubit, LanguageJsonState>(
      builder: (context, langState) {
        return RichText(
          text: TextSpan(
            text: UiUtils.getTranslatedLabel(context, 'plzLbl'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, overflow: TextOverflow.ellipsis),
            children: <TextSpan>[
              TextSpan(
                  text: " ${UiUtils.getTranslatedLabel(context, 'loginBtn')} ",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        setState(() {
                          Navigator.of(context).pushReplacementNamed(Routes.login);
                        });
                      });
                    }),
              TextSpan(
                  text: "${UiUtils.getTranslatedLabel(context, 'firstAccLbl')} ", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)),
              TextSpan(
                  text: UiUtils.getTranslatedLabel(context, 'allFunLbl'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, overflow: TextOverflow.ellipsis))
            ],
          ),
        );
      },
    );
  }

  Widget setBody() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0, top: 15.0),
      child: Container(
          padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), color: Theme.of(context).colorScheme.surface),
          child: ScrollConfiguration(
            behavior: GlobalScrollBehavior(),
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsetsDirectional.only(top: 10.0),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: <Widget>[
                    setDrawerItem('darkModeLbl', Icons.swap_horizontal_circle, true, false, true, 0),
                    setDrawerItem('notificationLbl', Icons.notifications_rounded, true, false, true, 1),
                    setDrawerItem('changeLang', Icons.g_translate_rounded, false, true, false, 2),
                    Divider(thickness: 2),
                    if (context.read<AuthCubit>().getUserId() != "0") setDrawerItem('bookmarkLbl', Icons.bookmarks_rounded, false, true, false, 3),
                    if (context.read<AuthCubit>().getUserId() != "0") setDrawerItem('notificationLbl', Icons.notifications, false, true, false, 4),
                    if (context.read<AuthCubit>().getUserId() != "0" && context.read<AuthCubit>().getRole() != "0") setDrawerItem('createNewsLbl', Icons.add_box_rounded, false, true, false, 5),
                    if (context.read<AuthCubit>().getUserId() != "0" && context.read<AuthCubit>().getRole() != "0") setDrawerItem('manageNewsLbl', Icons.edit_document, false, true, false, 6),
                    if (context.read<AuthCubit>().getUserId() != "0") setDrawerItem('managePreferences', Icons.thumbs_up_down_rounded, false, true, false, 7),
                    if (context.read<AuthCubit>().getUserId() != "0") Divider(thickness: 2),
                    pagesBuild(),
                    setDrawerItem('rateUs', Icons.stars_sharp, false, true, false, 9),
                    setDrawerItem('shareApp', Icons.share_rounded, false, true, false, 10),
                    if (context.read<AuthCubit>().getUserId() != "0") setDrawerItem('deleteAcc', Icons.delete_forever_rounded, false, true, false, 12, isDeleteAcc: true),
                  ],
                );
              },
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: CustomAppBar(
              height: 45,
              isBackBtn: false,
              label: 'myProfile',
              isConvertText: true,
              actionWidget: [if (context.read<AuthCubit>().getUserId() != "0") logoutButton()],
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.only(top: 15.0, bottom: 10.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[setHeader(), setBody()])),
              ],
            )));
  }

  Widget logoutButton() {
    return GestureDetector(
      onTap: () => logOutDialog(),
      child: Container(
          margin: EdgeInsetsDirectional.only(end: 15, top: 12, bottom: 12),
          height: 30,
          width: 30,
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(7), color: Colors.transparent, border: Border.all(width: 2, color: borderColor.withOpacity(0.3))),
          child: Icon(Icons.power_settings_new_rounded, color: UiUtils.getColorScheme(context).primaryContainer, size: 20)),
    );
  }
}
