import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de Confidentialité'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.privacy_tip,
                size: 80,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Bienvenue chez Faani",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Nous sommes engagés à protéger votre vie privée. Cette politique explique comment nous collectons, utilisons, divulguons et protégeons vos données lorsque vous utilisez notre application.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: "1. Informations Collectées",
              content:
                  "Nous recueillons des informations pour améliorer nos services et personnaliser votre expérience. Ces informations comprennent :\n\n"
                  "- **Informations personnelles** : nom, email, numéro de téléphone, etc.\n"
                  "- **Données d'utilisation** : interactions avec l'application.\n"
                  "- **Informations sur l'appareil** : type d'appareil, système d'exploitation, etc.",
            ),
            _buildSection(
              title: "2. Utilisation de Vos Informations",
              content:
                  "Les informations collectées sont utilisées pour :\n\n"
                  "- Fournir, maintenir et améliorer nos services.\n"
                  "- Personnaliser votre expérience utilisateur.\n"
                  "- Protéger Faani et ses utilisateurs contre la fraude et les abus.",
            ),
            _buildSection(
              title: "3. Partage des Informations",
              content:
                  "Nous ne partageons vos informations qu'en cas de nécessité :\n\n"
                  "- **Avec des prestataires** pour gérer certaines fonctions.\n"
                  "- **Pour des raisons légales** en cas d'obligation.\n"
                  "- **Avec votre consentement** pour des cas particuliers.",
            ),
            _buildSection(
              title: "4. Vos Choix",
              content:
                  "- **Mise à jour des données** : accédez à vos données et mettez-les à jour dans les paramètres.\n"
                  "- **Gestion des notifications** : personnalisez les alertes dans les paramètres.\n"
                  "- **Suppression de compte** : contactez le support pour supprimer votre compte.",
            ),
            _buildSection(
              title: "5. Sécurité de Vos Données",
              content:
                  "Nous appliquons des mesures de sécurité pour protéger vos données :\n\n"
                  "- **Chiffrement** des données pendant la transmission.\n"
                  "- **Contrôle d'accès** pour éviter tout accès non autorisé.\n"
                  "- **Surveillance** régulière des systèmes pour détecter les failles potentielles.",
            ),
            _buildSection(
              title: "6. Liens et Services Externes",
              content:
                  "Faani peut contenir des liens vers des sites et services externes. Nous ne sommes pas responsables des pratiques de ces sites tiers. Consultez leurs politiques de confidentialité pour en savoir plus.",
            ),
            _buildSection(
              title: "7. Confidentialité des Enfants",
              content:
                  "Faani est destiné aux utilisateurs de 16 ans et plus. Nous ne collectons pas d'informations d'enfants de moins de 16 ans sans le consentement parental.",
            ),
            _buildSection(
              title: "8. Transferts Internationaux",
              content:
                  "Vos données peuvent être transférées et stockées sur des serveurs en dehors de votre pays de résidence. Nous prenons les mesures nécessaires pour garantir la protection de vos données.",
            ),
            _buildSection(
              title: "9. Modifications de Cette Politique",
              content:
                  "Cette politique peut être mise à jour pour refléter les changements dans nos pratiques. Nous vous en informerons en cas de modifications importantes.",
            ),
            _buildSection(
              title: "10. Contactez-nous",
              content:
                  "Pour toute question concernant cette politique ou nos pratiques en matière de données :\n\n"
                  "- **Email** : support@faaniapp.com\n"
                  "- **Téléphone** : +123456789\n"
                  "- **Adresse** : Équipe Confidentialité Faani, [Votre Adresse ICI]",
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                "Merci de faire confiance à Faani !",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal[800],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
