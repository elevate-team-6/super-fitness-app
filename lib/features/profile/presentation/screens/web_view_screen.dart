import 'package:flutter/material.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/core/widgets/custom_error_state_view.dart';
import 'package:super_fitness/core/widgets/custom_loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({super.key, required this.title, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Without this the view flashes white before the page paints, which is
      // jarring against the app's dark chrome.
      ..setBackgroundColor(AppColors.black90)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _update(isLoading: true, hasError: false),
          onPageFinished: (_) => _update(isLoading: false),
          onWebResourceError: (error) {
            // Sub-resources (favicons, fonts) fail routinely without breaking
            // the page, so only a main-frame failure counts as an error.
            if (error.isForMainFrame ?? true) {
              _update(isLoading: false, hasError: true);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _update({bool? isLoading, bool? hasError}) {
    if (!mounted) return;

    setState(() {
      _isLoading = isLoading ?? _isLoading;
      _hasError = hasError ?? _hasError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black90,
      appBar: CustomAppBar(
        title: widget.title,
        centerTitle: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: _hasError
            ? CustomErrorStateView(
                message: AppStrings.pageFailedToLoad,
                onRetry: () {
                  _update(isLoading: true, hasError: false);
                  _controller.loadRequest(Uri.parse(widget.url));
                },
              )
            : Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading) const CustomLoading(),
                ],
              ),
      ),
    );
  }
}
