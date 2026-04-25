import 'package:clubship/colors.dart';
import 'package:clubship/domain/common_web_view_model.dart';
import 'package:clubship/domain/common_web_view_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CommonWebView extends ConsumerStatefulWidget {
  const CommonWebView({
    super.key,
    required this.urlParameter,
  });

  final String urlParameter;

  @override
  ConsumerState<CommonWebView> createState() => _CommonWebViewState();
}

class _CommonWebViewState extends ConsumerState<CommonWebView> {
  CommonWebViewNotifier get webViewNotifier =>
      ref.read(commonWebViewNotifierProvider.notifier);
  late WebViewController controller;
  double navigationBarIconsSize = 20;
  String url = '';
  String currentWebPageUrl = '';
  bool webViewFinishedLoading = false;
  double opacityLevel = 1.0;

  @override
  void initState() {
    super.initState();
    debugPrint('initState url ${widget.urlParameter}');
    url = widget.urlParameter.removeLastSlash();
    currentWebPageUrl = url;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (!mounted) return;
            debugPrint('onProgress $progress');
            if (progress > 10) {
              _hideLoaderIndicator();
            }
          },
          onPageStarted: (String url) async {
            debugPrint('onPageStarted $url');
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            debugPrint('onPageFinished $url');
            _hideLoaderIndicator();
            _updateBackForwardEvents();
          },
          onWebResourceError: (WebResourceError error) {
            if (!mounted) return;
            debugPrint('onWebResourceError ${error.toString()}');
            _hideLoaderIndicator();
            _updateBackForwardEvents();
          },
          onUrlChange: (changeUrl) {
            if (!mounted) return;
            debugPrint('onUrlChange $changeUrl)}');
            currentWebPageUrl = changeUrl.url.toString();
            _updateBackForwardEvents();
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _hideLoaderIndicator() {
    if (!webViewFinishedLoading) {
      setState(() => opacityLevel = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final webViewState = ref.watch(commonWebViewNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                _buildLeadingExitButton1(context),
                const Spacer(),
                ..._buildNavigationIcons(webViewState),
              ],
            ),
            Container(
              color: Colors.white,
              child: _buildUrlView(),
            ),
            Expanded(
              child: Stack(
                children: [
                  _buildWebView(),
                  // The following is a countermeasure to avoid black screen when
                  // opening a web-view. Currently an issue in web_view_flutter plugin (2024/02/22)
                  // https://github.com/flutter/flutter/issues/30111
                  if (!webViewFinishedLoading)
                    AnimatedOpacity(
                      opacity: opacityLevel,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        color: Colors.white,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      onEnd: () {
                        setState(() {
                          webViewFinishedLoading = true;
                        });
                      },
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Made back button tappable in an area of 44x44
  /// Left padding 6, to make it look as per design
  ///
  Widget _buildLeadingExitButton1(BuildContext context) => Row(
        children: [
          const SizedBox(width: 6),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: const Icon(
                Icons.close,
                color: ColorPallete.black10,
              ),
            ),
          ),
        ],
      );

  Widget _buildUrlView() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock,
            color: ColorPallete.black10,
          ),
          const SizedBox(
            width: 3,
          ),
          Text(
            url.getDomain(),
          ),
        ],
      );

  WebViewWidget _buildWebView() => WebViewWidget(
        controller: controller,
      );
}

extension _CommonWebViewStateNavigationIcons on _CommonWebViewState {
  List<Widget> _buildNavigationIcons(CommonWebViewModel webViewState) {
    final isEnableForward = webViewState.canGoForward;
    final isEnableBackward = webViewState.canGoBackward;
    return [
      buildIconButton(const Icon(Icons.arrow_back_rounded),
          () => _handleGoBack(webViewState), isEnableBackward),
      buildIconButton(
          const Icon(
            Icons.arrow_forward,
            color: ColorPallete.black10,
          ),
          () => _handleGoForward(
                webViewState,
              ),
          isEnableForward),
      buildIconButton(
        const Icon(
          Icons.refresh,
          color: ColorPallete.black10,
        ),
        () => controller.reload(),
        true,
      ),
      _buildBrowserButton(),
    ];
  }

  IconButton _buildBrowserButton() => buildIconButton(
        const Icon(
          Icons.open_in_browser,
          color: ColorPallete.black10,
        ),
        () async {
          await launchExternalBrowser(currentWebPageUrl);
        },
        true,
      );

  IconButton buildIconButton(
          Widget icon, VoidCallback onPressed, bool isEnable) =>
      IconButton(
        onPressed: isEnable ? onPressed : null,
        icon: icon,
      );
}

extension _CommonWebViewStateFunctions on _CommonWebViewState {
  Future<void> _handleGoBack(CommonWebViewModel webViewState) async {
    if (await controller.canGoBack()) {
      controller.goBack();
    }
  }

  Future<void> _handleGoForward(CommonWebViewModel webViewState) async {
    if (await controller.canGoForward()) {
      controller.goForward();
    }
  }

  Future<void> _updateBackForwardEvents() async {
    webViewNotifier.updateCanGoForwardState(await controller.canGoForward());
    webViewNotifier.updateCanGoBackwardState(await controller.canGoBack());
  }

  Future<void> launchExternalBrowser(String stringUrl) async {
    try {
      Uri uri = Uri.parse(stringUrl);
      debugPrint('launchExternalBrowser launching URL: ${uri.toString()}');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint('launchExternalBrowser URL launched successfully');
    } catch (e) {
      debugPrint('launchExternalBrowser Error launching URL: $e');
    }
  }
}

extension StringExtensions on String {
  String getDomain() {
    try {
      Uri uri = Uri.parse(this);
      return '${uri.scheme}://${uri.host}';
    } catch (e) {
      return '';
    }
  }

  String removeLastSlash() {
    String url = '';
    if (endsWith('/')) {
      url = substring(0, length - 1);
    } else {
      url = this;
    }
    return url;
  }

  bool get isValidEmail {
    final emailRegex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    return emailRegex.hasMatch(this);
  }

  String hidePassword() => '*' * length;

  String get asDoubleDigitNumber => length == 1 ? '0$this' : this;
}
