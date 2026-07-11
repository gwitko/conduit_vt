import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:conduit_vt/xterm.dart';

@GenerateNiceMocks([MockSpec<EscapeHandler>()])
import 'parser_test.mocks.dart';

void main() {
  group('EscapeParser', () {
    test('can parse window manipulation', () {
      final parser = EscapeParser(MockEscapeHandler());
      parser.write('\x1b[8;24;80t');
      verify(parser.handler.resize(80, 24));
    });

    test('applies unprefixed SGR', () {
      final parser = EscapeParser(MockEscapeHandler());
      parser.write('\x1b[4m');
      verify(parser.handler.setCursorUnderline());
    });

    test('does not apply XTMODKEYS as SGR', () {
      final parser = EscapeParser(MockEscapeHandler());
      parser.write('\x1b[>4;2m');
      verifyNever(parser.handler.setCursorUnderline());
      verifyNever(parser.handler.setCursorFaint());
      verify(parser.handler.unknownCSI('m'.codeUnitAt(0)));
    });

    test('does not apply XTMODKEYS reset as SGR', () {
      final parser = EscapeParser(MockEscapeHandler());
      parser.write('\x1b[>4;0m');
      verifyNever(parser.handler.setCursorUnderline());
      verifyNever(parser.handler.resetCursorStyle());
    });

    test('applies unprefixed DECSTBM', () {
      final parser = EscapeParser(MockEscapeHandler());
      parser.write('\x1b[2;10r');
      verify(parser.handler.setMargins(1, 9));
    });

    test('does not apply XTRESTORE as DECSTBM', () {
      final handler = MockEscapeHandler();
      final parser = EscapeParser(handler);
      parser.write('\x1b[?1049r');
      verifyNever(handler.setMargins(any, any));
    });

    test('does not apply XTSMGRAPHICS as scroll up', () {
      final handler = MockEscapeHandler();
      final parser = EscapeParser(handler);
      parser.write('\x1b[?1;1;256S');
      verifyNever(handler.scrollUp(any));
    });
  });
}
