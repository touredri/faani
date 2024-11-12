import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';

class AideView extends StatelessWidget {
  const AideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBack,
      appBar: customAppBar('Centre d\'Aide'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section with Icon
            Row(
              children: [
                _buildIcon(Icons.help),
                const SizedBox(width: 10),
                _buildSectionTitle('Bienvenue dans l\'Aide'),
              ],
            ),
            _buildSectionText(
                'Bienvenue sur Faani, votre application dédiée à la promotion des vêtements '
                'pour tailleurs. Découvrez comment utiliser notre plateforme pour ajouter '
                'vos créations, les partager avec le monde et attirer plus de clients. '
                'Faani vous offre une vitrine numérique pour exposer vos talents et '
                'faciliter la gestion de vos commandes.'),
            const SizedBox(height: 20),

            // FAQ Section with Icon
            Row(
              children: [
                _buildIcon(Icons.question_answer),
                const SizedBox(width: 10),
                _buildSectionTitle('FAQ'),
              ],
            ),
            _buildFAQItem(
                'Comment créer un compte ?',
                'Allez à la page d\'inscription, entrez vos informations personnelles, '
                    'et suivez les instructions pour valider votre compte. Un compte validé '
                    'vous permet d\'accéder à toutes les fonctionnalités de Faani, y compris '
                    'la gestion de vos créations et de vos commandes.'),
            _buildFAQItem(
                'Comment ajouter un modèle ?',
                'Une fois connecté, cliquez sur le bouton "Ajouter un modèle", téléchargez '
                    'les photos de vos créations et remplissez les détails nécessaires. '
                    'Assurez-vous de fournir des descriptions détaillées et des photos de haute qualité '
                    'pour attirer plus de clients.'),
            _buildFAQItem(
                'Comment promouvoir mes créations ?',
                'Utilisez les options de partage pour promouvoir vos créations sur les réseaux '
                    'sociaux et attirer plus de clients. Vous pouvez également utiliser les outils '
                    'de marketing intégrés pour atteindre un public plus large et augmenter vos ventes.'),
            _buildFAQItem(
                'Comment gérer mes commandes ?',
                'Accédez à la section "Commandes" pour voir et gérer toutes les commandes '
                    'reçues de vos clients. Vous pouvez suivre l\'état de chaque commande, '
                    'communiquer avec vos clients et mettre à jour les informations de livraison.'),
            _buildFAQItem(
                'Que faire en cas de problème technique ou d\'erreur ?',
                'Si vous rencontrez des problèmes, vous pouvez contacter notre support via '
                    'la section "Contact". Notre équipe est disponible pour vous aider à résoudre '
                    'tout problème technique ou répondre à vos questions.'),
            const SizedBox(height: 20),

            // Contact Section with Icon
            Row(
              children: [
                _buildIcon(Icons.contact_support),
                const SizedBox(width: 10),
                _buildSectionTitle('Besoin d\'aide supplémentaire ?'),
              ],
            ),
            _buildSectionText(
                'Si votre question n\'a pas été résolue dans la FAQ, vous pouvez nous '
                'contacter à l\'adresse suivante : support@faaniapp.com. Nous sommes là pour '
                'vous aider et nous assurer que vous tirez le meilleur parti de notre application.'),
            const SizedBox(height: 20),

            // Feedback Section with Icon
            Row(
              children: [
                _buildIcon(Icons.feedback),
                const SizedBox(width: 10),
                _buildSectionTitle('Vos retours'),
              ],
            ),
            _buildSectionText(
                'Nous sommes à l\'écoute de vos suggestions pour améliorer cette application. '
                'N\'hésitez pas à nous envoyer vos idées et vos commentaires. Votre feedback est '
                'précieux pour nous aider à créer une meilleure expérience utilisateur et à '
                'répondre à vos besoins.'),
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
        fontSize: 17,
      ),
    );
  }

  Icon _buildIcon(IconData iconData) {
    return Icon(
      iconData,
      color: Colors.grey,
      size: 30,
    );
  }

  // Section Text Widget
  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  // FAQ Item Widget with Icon in ExpansionTile
  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ExpansionTile(
          leading: const Icon(
            Icons.info_outline,
          ),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                answer,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
