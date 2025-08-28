import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/controllers/chat.dart';
import '../../../core/controllers/flash.dart';
import '../../../core/models/account.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/navigator.dart';
import '../../../core/services/lang_detector.dart';
import '../../../theme/colors.dart';
import '../../../utils/generic.dart';
import '../../../widgets/common/image_error.dart';
import '../../profile/details/index.dart';
import 'assets_message_content.dart';

class ChatMessageWidget extends StatefulWidget {
  final Account loggedAccount;
  final Account sender;
  final Rx<ChatMessage> message;
  final List selectedMessages;
  final Function handleSelect;

  ChatMessageWidget({
    super.key,
    required this.selectedMessages,
    required this.sender,
    required this.loggedAccount,
    required this.message,
    required this.handleSelect,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ChatMessageWidgetState createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  final navigatorService = Get.find<NavigatorService>();
  final flashController = Get.find<FlashController>();
  final chatController = Get.find<ChatController>();
  final languageDetectorService = Get.find<LanguageDetectorService>();

  var _translationInProgress = false;
  var _showingTranslation = false;
  var _translatedMessage = '';

  Future<void> _handleTranslateMessage() async {
    if (_translationInProgress) {
      return;
    }

    if (_showingTranslation) {
      setState(() {
        _showingTranslation = false;
      });
      return;
    }

    if (!_showingTranslation && _translatedMessage.isNotEmpty) {
      setState(() {
        _showingTranslation = true;
      });
      return;
    }

    setState(() {
      _translationInProgress = true;
    });

    try {
      var translation = await chatController.translate(
        widget.message.value.id,
        context.locale.languageCode,
      );

      if (translation == null) {
        flashController.showMessageFlash(tr('generic.error'));
        return;
      }

      setState(() {
        _translatedMessage = translation;
        _showingTranslation = true;
      });
    } catch (error) {
      flashController.showMessageFlash(tr('generic.error'));
    } finally {
      if (mounted) {
        setState(() {
          _translationInProgress = false;
        });
      }
    }
  }

  Future<void> _handleOpenLink(LinkableElement link) async {
    var url = Uri.parse(link.url);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      flashController.showMessageFlash('Could not open link');
    }
  }

  Widget _renderAssetsMessageContent(BuildContext context) {
    return AssetsMessageContent(
      message: widget.message,
    );
  }

  Widget _renderMessageContent(BuildContext context) {
    var containsUrl =
        GenericUtils.textContainsUrl(widget.message.value.message!);
    var firstUrl = containsUrl
        ? GenericUtils.extractFirstUrlFromText(widget.message.value.message!)
        : null;

    var messageLanguage = languageDetectorService.detectLanguage(
      widget.message.value.message,
    );

    var translationEnabled = messageLanguage != null &&
        messageLanguage != context.locale.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.all(16),
          child: Linkify(
            text: _showingTranslation
                ? _translatedMessage
                : widget.message.value.message!,
            style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            linkStyle: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.none,
            ),
            onOpen: _handleOpenLink,
          ),
        ),
        if (firstUrl != null)
          ClipRRect(
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: AnyLinkPreview(
                link: firstUrl,
                displayDirection: UIDirection.uiDirectionHorizontal,
                showMultimedia: true,
                bodyMaxLines: 5,
                bodyTextOverflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        translationEnabled
            ? GestureDetector(
                onTap: () {
                  _handleTranslateMessage();
                },
                child: Container(
                  padding: EdgeInsets.only(
                      left: 16, right: 16, bottom: 8, top: containsUrl ? 8 : 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _translationInProgress
                          ? const SpinKitThreeBounce(
                              color: DarkColors.font_1,
                              size: 17,
                            )
                          : Flexible(
                              child: Text(
                                _showingTranslation
                                    ? 'generic.see_original'
                                    : 'generic.translate',
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .smallest,
                              ).tr(),
                            ),
                    ],
                  ),
                ),
              )
            : Container(
                width: 0,
              ),
      ],
    );
  }

  Widget _renderAccountAvatar(BuildContext context, Account account) {
    return GestureDetector(
      onTap: () {
        navigatorService.push(
          ProfileDetailsScreen(
            accountId: account.id,
          ),
          NavigationStyle.SharedAxis,
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color:
                Theme.of(context).extension<CustomThemeFields>()!.background_2,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          child: account.picture == ''
              ? Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: Svg(
                        'assets/icons/svg/user.svg',
                      ),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: account.picture,
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                  maxWidthDiskCache: 40,
                  maxHeightDiskCache: 40,
                  errorWidget: (context, url, error) =>
                      const ImageErrorWidget(),
                ),
        ),
      ),
    );
  }

  Widget _renderMessageStatus(BuildContext context) {
    return SizedBox(
      width: 22,
      child: Obx(
        () => widget.message.value.status == ChatMessageStatus.pending
            ? SpinKitThreeBounce(
                color: DarkColors.font_1,
                size: 14,
              )
            : widget.message.value.status == ChatMessageStatus.error
                ? Icon(
                    Icons.error,
                    size: 16,
                    color: Colors.red,
                  )
                : Icon(
                    Icons.done_all,
                    size: 16,
                    color: Colors.blue,
                  ),
      ),
    );
  }

  Widget _renderMessageFromLoggedUser(BuildContext context) {
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());
    var currentLanguage = context.locale.toString();

    return Material(
      color: widget.selectedMessages.contains(
        widget.message.value.id,
      )
          ? Theme.of(context).extension<CustomThemeFields>()!.background_3
          : const Color.fromARGB(0, 7, 4, 4),
      child: InkWell(
        onTap: () {
          if (widget.selectedMessages.isNotEmpty) {
            widget.handleSelect();
          }
        },
        onLongPress: () {
          widget.handleSelect();
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.selectedMessages.contains(
                  widget.message.value.id,
                )
                    ? Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_2
                    : Colors.transparent,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          margin: const EdgeInsets.only(top: 4),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.only(start: 10.0, top: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          GenericUtils.getFormattedDate(
                            widget.message.value.createdAt,
                            currentLanguage,
                          ),
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smallest,
                        ),
                        Container(
                          width: 8,
                        ),
                        _renderMessageStatus(context),
                        const SizedBox(width: 16), // Time
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .background_2,
                      borderRadius: BorderRadius.only(
                        topLeft:
                            isRTL ? Radius.circular(0) : Radius.circular(16),
                        topRight:
                            isRTL ? Radius.circular(16) : Radius.circular(0),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: widget.message.value.type == 'text'
                        ? _renderMessageContent(context)
                        : _renderAssetsMessageContent(context),
                  ),
                  Obx(
                    () => widget.message.value.status == ChatMessageStatus.error
                        ? Container(
                            margin:
                                EdgeInsets.only(bottom: 8, left: 8, right: 8),
                            child: Row(
                              children: [
                                Text(
                                  'generic.short_error',
                                  style: Theme.of(context)
                                      .extension<CustomThemeFields>()!
                                      .smallest
                                      .copyWith(
                                        color: Theme.of(context)
                                            .extension<CustomThemeFields>()!
                                            .action,
                                      ),
                                ).tr(),
                              ],
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
              _renderAccountAvatar(context, widget.loggedAccount),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loggedAccount.id == widget.sender.id) {
      return _renderMessageFromLoggedUser(context);
    }

    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());
    var currentLanguage = context.locale.toString();

    return Material(
      color: widget.selectedMessages.contains(
        widget.message.value.id,
      )
          ? Theme.of(context).extension<CustomThemeFields>()!.background_3
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (widget.selectedMessages.isNotEmpty) {
            widget.handleSelect();
          }
        },
        onLongPress: () {
          widget.handleSelect();
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.selectedMessages.contains(
                  widget.message.value.id,
                )
                    ? Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_2
                    : Colors.transparent,
              ),
            ),
          ),
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _renderAccountAvatar(context, widget.sender),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 10.0, top: 5.0),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              GenericUtils.generateNameForAccount(
                                  widget.sender),
                              textAlign: TextAlign.right,
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            GenericUtils.getFormattedDate(
                              widget.message.value.createdAt,
                              currentLanguage,
                            ),
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smallest,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .background_2,
                        borderRadius: BorderRadius.only(
                          topRight:
                              isRTL ? Radius.circular(0) : Radius.circular(16),
                          topLeft:
                              isRTL ? Radius.circular(16) : Radius.circular(0),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: widget.message.value.type == 'text'
                          ? _renderMessageContent(context)
                          : _renderAssetsMessageContent(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
