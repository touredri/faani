import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar('A Propos de Faani'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction Section
            const Text(
              'Bienvenue chez Faani',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                // color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Nous sommes dédiés à promouvoir les talents des tailleurs à travers notre application. '
              'Faani facilite la prise de mesures, la gestion des commandes et la création de vêtements sur mesure.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            // Strengths Section
            _buildSectionTitle('Nos Points Forts'),
            const SizedBox(height: 10),
            _buildStrengthItem('📏 Prise de Mesures Précise',
                'Notre application permet une prise de mesures précise et facile pour garantir des vêtements parfaitement ajustés.'),
            _buildStrengthItem('🛠 Gestion des Commandes',
                'Gérez vos commandes de manière efficace et suivez l\'état d\'avancement de chaque projet.'),
            _buildStrengthItem('🎨 Création Personnalisée',
                'Offrez à vos clients des options de personnalisation infinies pour leurs vêtements.'),
            _buildStrengthItem('📅 Planification et Suivi',
                'Planifiez vos projets et suivez les délais de livraison pour une meilleure organisation.'),

            const SizedBox(height: 20),

            // Conclusion Section
            const Text(
              'Notre Engagement',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                // color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Nous croyons en un avenir où les tailleurs peuvent facilement gérer et promouvoir leurs talents. '
              'Avec Faani, nous nous engageons à fournir des outils de qualité pour améliorer l\'efficacité et la créativité dans la confection de vêtements.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        // color: primaryColor,
      ),
    );
  }

  // Strength Item Widget
  Widget _buildStrengthItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10), // Space for the icon
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    // fontWeight: FontWeight.bold,
                    // color: Colors.blue,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
