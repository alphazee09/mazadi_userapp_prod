import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/flash.dart';
import '../../../theme/colors.dart';
import '../../../widgets/common/simple_button.dart';

class ReportDialogContent extends StatefulWidget {
  final Function onConfirm;
  final String entityName;

  const ReportDialogContent({
    super.key,
    required this.onConfirm,
    required this.entityName,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AcceptBidDialogContent createState() => _AcceptBidDialogContent();
}

class _AcceptBidDialogContent extends State<ReportDialogContent> {
  final flashController = Get.find<FlashController>();
  final _detailsController = TextEditingController();

  bool _reportInProgress = false;
  String _selectedReportOption = '';
  final Rx<bool> _pointerDownInner = false.obs;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void handleSetOption(String optionValue) {
    if (mounted) {
      setState(() {
        _selectedReportOption =
            _selectedReportOption == optionValue ? '' : optionValue;
      });
    }
    _detailsController.text = '';
  }

  Future<void> handleReport() async {
    if (_reportInProgress || _selectedReportOption.isEmpty) {
      return;
    }
    if (mounted) {
      setState(() {
        _reportInProgress = true;
      });
    }

    var created = await widget.onConfirm(
      _selectedReportOption,
      _detailsController.text,
    );

    if (mounted) {
      setState(() {
        _reportInProgress = false;
      });
    }

    if (!created) {
      flashController.showMessageFlash(
        tr("generic.something_went_wrong"),
        FlashMessageType.error,
      );
      return;
    }

    flashController.showMessageFlash(
      tr("reports.was_reported"),
      FlashMessageType.success,
    );
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Widget _renderReportOptionItem(String title, String optionValue) {
    return InkWell(
      onTap: () {
        handleSetOption(optionValue);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ),
            ),
            Checkbox(
              side: BorderSide(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .fontColor_1,
              ),
              checkColor: DarkColors.font_1,
              activeColor:
                  Theme.of(context).extension<CustomThemeFields>()!.action,
              value: _selectedReportOption == optionValue,
              onChanged: (bool? value) {
                handleSetOption(optionValue);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _renderReportOptions() {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _renderReportOptionItem(
                tr("reports.misleading_or_scam"), 'misleading_or_scam'),
            _renderReportOptionItem(
                tr("reports.sexually_inappropriate"), 'sexually_inappropriate'),
            _renderReportOptionItem(
                tr("reports.offensive_content"), 'offensive'),
            _renderReportOptionItem(tr("reports.other"), 'other'),
          ],
        ),
      ),
    );
  }

  Widget _renderDetailsInput() {
    if (_selectedReportOption != 'other') {
      return Container();
    }

    var hintMessage = tr("reports.like_to_give_details");
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          _pointerDownInner.value = true;
        },
        child: TextField(
          maxLines: 4,
          minLines: 4,
          maxLength: 200,
          controller: _detailsController,
          style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
          scrollPadding: const EdgeInsets.only(
            bottom: 130,
          ),
          decoration: InputDecoration(
            hintText: hintMessage,
            counterText: '',
            fillColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_3,
            hintStyle:
                Theme.of(context).extension<CustomThemeFields>()!.smaller,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .background_2,
                  width: 0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .fontColor_1,
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        if (_pointerDownInner.value) {
          _pointerDownInner.value = false;
          return;
        }

        _pointerDownInner.value = false;
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: AlertDialog(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_2,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  widget.entityName == 'account'
                      ? 'reports.sure_to_report_2'
                      : 'reports.sure_to_report',
                  textAlign: TextAlign.center,
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.title,
                ).tr(namedArgs: {
                  'name': tr('reports.sure_to_report_${widget.entityName}')
                }),
              ),
              Container(
                height: 16,
              ),
              _renderReportOptions(),
              _renderDetailsInput()
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          Row(
            children: [
              Expanded(
                child: SimpleButton(
                  background: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .separator,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  height: 42,
                  child: Text(
                    'generic.cancel',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                  ).tr(),
                ),
              ),
              Container(
                width: 8,
              ),
              Expanded(
                child: SimpleButton(
                  borderColor: _selectedReportOption == ''
                      ? Colors.transparent
                      : Colors.red,
                  background: _selectedReportOption == ''
                      ? Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .background_3
                      : Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .separator,
                  isLoading: _reportInProgress,
                  onPressed: () {
                    handleReport();
                  },
                  height: 42,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/svg/report.svg',
                        height: 24,
                        semanticsLabel: 'Report',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                      ),
                      Container(
                        width: 8,
                      ),
                      Text('reports.report_action',
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller)
                          .tr(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
