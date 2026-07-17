import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFF3F2FF),
      body: Stack(
        children: [
          // Background Shapes
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9F69).withOpacity(isDark ? 0.2 : 0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            right: -50,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF66D1A4).withOpacity(isDark ? 0.2 : 0.8),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                      ),
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // App Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D3B8E),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.description, color: Colors.white, size: 60),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Invoicely',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontFamily: 'Serif',
                    ),
                  ),
                  Text(
                    'Version 1.0.0 (build 12)',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 40),
                  
                  // Developer Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Color(0xFFF3F2FF),
                          child: Icon(Icons.person_outline, size: 45, color: Color(0xFF3D3B8E)),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Awais Tariq',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Text(
                          'Flutter Developer',
                          style: TextStyle(color: Color(0xFFFF9F69), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Built with Flutter, Dart, and a lot of coffee. Passionate about creating clean and efficient mobile solutions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF6C699E), height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        
                        // Social Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialIcon(FontAwesomeIcons.github, 'https://github.com/awaist618'),
                            _buildSocialIcon(FontAwesomeIcons.linkedin, 'https://www.linkedin.com/in/awais-tariq-87b64a28a/'),
                            _buildSocialIcon(FontAwesomeIcons.envelope, 'mailto:at2544344@gmail.com'),
                            _buildSocialIcon(FontAwesomeIcons.globe, 'https://awais-portfolio0.vercel.app/'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Actions Card
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        _buildActionTile(Icons.star_outline, 'Rate this app', () {}),
                        _buildDivider(isDark),
                        _buildActionTile(Icons.chat_bubble_outline, 'Send feedback', () => _launchUrl('mailto:at2544344@gmail.com?subject=Feedback for Invoicely')),
                        _buildDivider(isDark),
                        _buildActionTile(Icons.shield_outlined, 'Privacy policy', () => _launchUrl('https://awais-portfolio0.vercel.app/privacy')),
                        _buildDivider(isDark),
                        _buildActionTile(Icons.file_copy_outlined, 'Open-source licenses', () {
                          showLicensePage(
                            context: context,
                            applicationName: 'Invoicely',
                            applicationVersion: '1.0.0',
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Made with using Flutter • © 2026',
                    style: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.6), fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(dynamic icon, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, size: 20, color: const Color(0xFF3D3B8E)),
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF9F69)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, indent: 60, endIndent: 20, color: isDark ? Colors.white10 : Colors.grey.shade100);
  }
}
