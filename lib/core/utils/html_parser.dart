// TODO: Implementer le code pour core/utils/html_parser
// core/utils/html_parser.dart
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

class HtmlParser {
  static String parseToPlainText(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  static String removeHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }

  static List<String> extractLinks(String htmlString) {
    final document = html_parser.parse(htmlString);
    final List<Element> links = document.querySelectorAll('a[href]');
    return links.map((link) => link.attributes['href'] ?? '').toList();
  }

  static String truncateHtml(String htmlString, int maxLength) {
    final plainText = parseToPlainText(htmlString);
    if (plainText.length <= maxLength) {
      return htmlString;
    }

    final truncated = plainText.substring(0, maxLength);
    return '$truncated...';
  }
}
