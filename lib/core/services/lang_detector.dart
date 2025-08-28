import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:get/get.dart';

class LanguageDetectorService extends GetxService {
  Future<void> init() async {
    await langdetect.initLangDetect();
  }

  String? detectLanguage(String? text) {
    if (text == null || text.isEmpty) {
      return null;
    }

    try {
      final lang = langdetect.detect(text);
      return lang;
    } catch (error) {
      return null;
    }
  }
}
