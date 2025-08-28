import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/filter.dart';
import '../../../../widgets/common/custom_search_input.dart';

class PriceFilter extends StatefulWidget {
  final Function onFilterChange;
  const PriceFilter({
    super.key,
    required this.onFilterChange,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PriceFilterState createState() => _PriceFilterState();
}

class _PriceFilterState extends State<PriceFilter> {
  final filterController = Get.find<FilterController>();

  final Rx<bool> _pointerDownInner = false.obs;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final minValueController = TextEditingController();
  final maxValueController = TextEditingController();

  var minValueKey = GlobalKey<FormFieldState>();
  var maxValueKey = GlobalKey<FormFieldState>();

  String minValue = '';
  String maxValue = '';

  late StreamSubscription<String> _minPriceSubscription;
  late StreamSubscription<String> _maxPriceSubscription;

  @override
  void initState() {
    super.initState();

    _minPriceSubscription = filterController.minPrice.listen((String newValue) {
      if (!mounted || newValue == minValue) {
        return;
      }

      setState(() {
        minValueKey = GlobalKey<FormFieldState>();
        minValue = newValue;
      });
    });

    _maxPriceSubscription = filterController.maxPrice.listen((String newValue) {
      if (!mounted || newValue == maxValue) {
        return;
      }

      setState(() {
        maxValueKey = GlobalKey<FormFieldState>();
        maxValue = newValue;
      });
    });
  }

  @override
  void dispose() {
    _minPriceSubscription.cancel();
    _maxPriceSubscription.cancel();
    super.dispose();
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'home.filter.price',
              style: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .subtitle
                  .copyWith(fontWeight: FontWeight.w300),
            ).tr(),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => CustomInput(
                        key: minValueKey,
                        keyboardType: TextInputType.number,
                        initialSearchQuery: filterController.minPrice.value,
                        handleInputPointerDown: () {
                          _pointerDownInner.value = true;
                        },
                        maxLines: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          }

                          var valueIsNotInt = int.tryParse(value) == null;
                          if (valueIsNotInt) {
                            return tr('home.filter.invalid_number');
                          }

                          return null;
                        },
                        verticalPadding: 16,
                        placeholder: tr('home.filter.min_price'),
                        withPrefixIcon: false,
                        withClearSearchKey: true,
                        withSufixIcon: filterController.minPrice.value == ''
                            ? false
                            : true,
                        onChanged: (value) {
                          if (mounted) {
                            var valid = _formKey.currentState?.validate();
                            setState(() {
                              minValue = value;
                            });

                            if (valid == true) {
                              filterController.minPrice.value = value;
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 16,
                  ),
                  Expanded(
                    child: Obx(
                      () => CustomInput(
                        key: maxValueKey,
                        keyboardType: TextInputType.number,
                        initialSearchQuery: filterController.maxPrice.value,
                        handleInputPointerDown: () {
                          _pointerDownInner.value = true;
                        },
                        maxLines: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          }

                          var valueIsNotInt = int.tryParse(value) == null;
                          if (valueIsNotInt) {
                            return tr('home.filter.invalid_number');
                          }

                          return null;
                        },
                        verticalPadding: 16,
                        withClearSearchKey: true,
                        withSufixIcon: filterController.maxPrice.value == ''
                            ? false
                            : true,
                        placeholder: tr('home.filter.max_price'),
                        withPrefixIcon: false,
                        onChanged: (value) {
                          if (mounted) {
                            var valid = _formKey.currentState?.validate();
                            setState(() {
                              maxValue = value;
                            });

                            if (valid == true) {
                              filterController.maxPrice.value = value;
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
