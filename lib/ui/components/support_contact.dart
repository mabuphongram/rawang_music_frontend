import 'package:url_launcher/url_launcher.dart';

// Community support contact — email only.
// No payment information of any kind lives in the app.
const supportEmail = 'rawangmelodies@gmail.com';

Future<void> contactSupport() async {
  final uri = Uri(
    scheme: 'mailto',
    path: supportEmail,
    query: 'subject=Rawang Melodies support',
  );
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}
