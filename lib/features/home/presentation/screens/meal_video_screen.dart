import 'package:flutter/material.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/core/widgets/custom_web_view.dart';

/// Hosts the YouTube embed for a recipe. Kept as its own route rather than
/// inlined in the details screen so the WebView is only built once the user
/// actually asks for the video.
class MealVideoScreen extends StatelessWidget {
  final String embedUrl;
  final String title;

  const MealVideoScreen({
    super.key,
    required this.embedUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black90,
      appBar: CustomAppBar(
        title: title,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: CustomWebView(url: embedUrl),
    );
  }
}
