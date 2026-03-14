import 'package:flutter_test/flutter_test.dart';
import 'src/decoder_test.dart' as decoder_test;
import 'src/sd_action_test.dart' as sd_action_test;
import 'src/sd_widgets_test.dart' as sd_widgets_test;
import 'src/widget_test.dart' as widget_test;

void main() {
  group('decoder', decoder_test.main);
  group('sd_action', sd_action_test.main);
  group('sd_widgets', sd_widgets_test.main);
  group('widget_test', widget_test.main);
}
