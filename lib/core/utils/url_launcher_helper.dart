import 'package:url_launcher/url_launcher.dart' as launcher;

class UrlLauncherHelper {
  // Utilise le prefix launcher pour éviter les conflits
  static Future<void> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await launcher.canLaunchUrl(uri)) {
        await launcher.launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      throw 'Error launching URL: $e';
    }
  }

  static Future<void> openEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    await launcher.launchUrl(uri);
  }

  static Future<void> openPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    await launcher.launchUrl(uri);
  }

  static Future<void> openSms(String phoneNumber, {String? body}) async {
    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: body != null ? {'body': body} : null,
    );
    await launcher.launchUrl(uri);
  }

  // Garde l'ancienne méthode pour compatibilité
  static Future<void> launchUrl(String url) => openUrl(url);
}
