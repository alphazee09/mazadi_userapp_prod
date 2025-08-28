import 'dart:async';

import 'package:mazadi/theme/extensions/base.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/settings.dart';

class Countdown extends StatefulWidget {
  final Duration duration;
  final FontWeight? fontWeight;
  final double? fontSize;
  final bool withDays;
  final Color? color;

  const Countdown({
    super.key,
    required this.duration,
    this.fontWeight = FontWeight.bold,
    this.fontSize,
    this.color,
    this.withDays = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _Countdown createState() => _Countdown();
}

class _Countdown extends State<Countdown> {
  final settingsController = Get.find<SettingsController>();

  Timer? countdownTimer;
  Duration duration = const Duration(days: 2);

  @override
  void initState() {
    super.initState();
    startTimer();

    duration = widget.duration;
  }

  @override
  void dispose() {
    countdownTimer!.cancel();
    super.dispose();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    if (mounted) {
      setState(() => countdownTimer!.cancel());
    }
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    if (mounted) {
      setState(() {
        final seconds = duration.inSeconds - reduceSecondsBy;
        if (seconds < 0) {
          countdownTimer!.cancel();
        } else {
          duration = Duration(seconds: seconds);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final days = duration.inDays < 0 ? '00' : strDigits(duration.inDays);

    final hoursRemainder = duration.inHours.remainder(
      widget.withDays
          ? 24
          : settingsController.settings.value.auctionActiveTimeInHours,
    );
    final hours = hoursRemainder < 0 ? '00' : strDigits(hoursRemainder);

    final minutesRemainder = duration.inMinutes.remainder(60);
    final minutes = minutesRemainder < 0
        ? '00'
        : strDigits(duration.inMinutes.remainder(60));

    final secondsRemainder = duration.inSeconds.remainder(60);
    final seconds = secondsRemainder < 0 ? '00' : strDigits(secondsRemainder);

    var textStyle =
        Theme.of(context).extension<CustomThemeFields>()!.title.copyWith(
              fontWeight: widget.fontWeight,
              color: widget.color ??
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              fontSize: widget.fontSize ?? 14,
            );

    if (int.parse(days) > 3) {
      return Row(
        children: [
          Text(
            'generic.days_no',
            style: textStyle,
          ).tr(namedArgs: {'no': days})
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.withDays == true
            ? SizedBox(
                child: Center(
                  child: Text(
                    days,
                    style: textStyle,
                    textAlign: TextAlign.start,
                  ),
                ),
              )
            : Container(),
        widget.withDays == true
            ? Container(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  ' : ',
                  style: textStyle,
                  textAlign: TextAlign.start,
                ),
              )
            : Container(),
        SizedBox(
          child: Center(
            child: Text(
              hours,
              style: textStyle,
              textAlign: TextAlign.start,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            ' : ',
            style: textStyle,
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(
          child: Center(
            child: Text(
              minutes,
              style: textStyle,
              textAlign: TextAlign.start,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            ' : ',
            style: textStyle,
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(
          child: Text(
            seconds,
            style: textStyle,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
