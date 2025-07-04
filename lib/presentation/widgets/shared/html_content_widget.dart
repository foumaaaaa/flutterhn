import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../core/utils/url_launcher_helper.dart';

class HtmlContentWidget extends StatelessWidget {
  final String htmlContent;
  final TextStyle? textStyle;
  final Map<String, Style>? customStyles;
  final EdgeInsets? padding;

  const HtmlContentWidget({
    super.key,
    required this.htmlContent,
    this.textStyle,
    this.customStyles,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Html(
        data: htmlContent,
        style: {
          "body": Style(
            margin: Margins.zero,
            fontSize: FontSize(textStyle?.fontSize ?? 14),
            lineHeight: LineHeight(textStyle?.height ?? 1.5),
            color: textStyle?.color ?? theme.colorScheme.onSurface,
            fontFamily: textStyle?.fontFamily,
          ),
          "p": Style(margin: Margins.only(bottom: 12)),
          "pre": Style(
            backgroundColor: theme.colorScheme.surfaceContainerHighest
                .withOpacity(0.3),
            padding: HtmlPaddings.all(12),
            margin: Margins.symmetric(vertical: 8),
            fontSize: FontSize(13),
            fontFamily: 'monospace',
          ),
          "code": Style(
            backgroundColor: theme.colorScheme.surfaceContainerHighest
                .withOpacity(0.3),
            padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
            fontSize: FontSize(13),
            fontFamily: 'monospace',
          ),
          "blockquote": Style(
            border: Border(
              left: BorderSide(color: theme.colorScheme.primary, width: 4),
            ),
            padding: HtmlPaddings.only(left: 16),
            margin: Margins.symmetric(vertical: 8),
            fontStyle: FontStyle.italic,
          ),
          "a": Style(
            color: theme.colorScheme.primary,
            textDecoration: TextDecoration.underline,
          ),
          "h1, h2, h3, h4, h5, h6": Style(
            fontWeight: FontWeight.bold,
            margin: Margins.symmetric(vertical: 8),
          ),
          "ul, ol": Style(
            margin: Margins.symmetric(vertical: 8),
            padding: HtmlPaddings.only(left: 20),
          ),
          "li": Style(margin: Margins.only(bottom: 4)),
          ...?customStyles,
        },
        // Correction: utiliser onAnchorTap au lieu de onLinkTap
        onAnchorTap: (url, attributes, element) {
          if (url != null) {
            UrlLauncherHelper.launchUrl(url);
          }
        },
      ),
    );
  }
}
