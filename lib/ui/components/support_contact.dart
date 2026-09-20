import 'package:url_launcher/url_launcher.dart';

// TODO(admin): replace with the real admin phone / payment contact.
// Shown on the renew wall, settings, and forgot-password screens.
const adminSupportPhone = '+95900000000';

Future<void> contactAdmin() async {
  final uri = Uri.parse('tel:$adminSupportPhone');
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}
