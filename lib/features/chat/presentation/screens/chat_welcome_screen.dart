import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';

import '../view_model/chat_cubit.dart';
import '../view_model/chat_event.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/welcome_view.dart';

class ChatWelcomeScreen extends StatefulWidget {
  const ChatWelcomeScreen({super.key});

  @override
  State<ChatWelcomeScreen> createState() => _ChatWelcomeScreenState();
}

class _ChatWelcomeScreenState extends State<ChatWelcomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const ChatDrawer(),
      body: AppScaffold(
        backgroundImage: AppImages.chatBackground,
        appBar: CustomAppBar(
          actions: [
            GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: SvgPicture.asset(
                AppIcons.menu,
                width: 24.w,
                height: 24.w,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        body: WelcomeView(
          onGetStarted: () {
            context.read<ChatCubit>().doEvent(const StartNewSessionEvent());
            Navigator.pushNamed(context, AppRoutes.chat);
          },
        ),
      ),
    );
  }
}
