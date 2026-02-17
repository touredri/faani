import 'dart:async';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/follow.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/profile/widgets/received_request.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TailorProfilePage extends StatefulWidget {
  final UserModel tailor;

  const TailorProfilePage({super.key, required this.tailor});

  @override
  State<TailorProfilePage> createState() => _TailorProfilePageState();
}

class _TailorProfilePageState extends State<TailorProfilePage> {
  final _scrollController = ScrollController();
  final List<Modele> _modeles = [];
  final Set<String> _modeleIds = {};
  final StreamController<List<Modele>> _streamController = StreamController();
  bool _isLoadingMore = false;
  RxInt numberOfWorkers = 0.obs;

  @override
  void initState() {
    super.initState();
    _setupScrollController();
    _fetchInitialModeles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Profil de ${widget.tailor.nomPrenom}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        widget.tailor.profileImage ??
                            'https://via.placeholder.com/100',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.tailor.nomPrenom ?? 'Nom Inconnu',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.tailor.clientCible ?? 'Confection générale',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  ],
                ),
                8.ws,
                // follow stats
                Column(
                  children: [
                    Text(
                      '8',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Clients satisfaits',
                      style:
                          const TextStyle(fontSize: 15, color: Colors.blueGrey),
                    ),
                    3.hs,
                    StreamBuilder<Map<String, int>>(
                        stream:
                            FollowService().getFollowStats(widget.tailor.id!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data?['followers']?.toString() ?? '0',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else {
                            return Text(
                              '0',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        }),
                    Text(
                      'Abonnés',
                      style:
                          const TextStyle(fontSize: 15, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInfoSection(
                    icon: Icons.phone,
                    label: 'Téléphone',
                    value: (() {
                      final phone = widget.tailor.phoneNumber;
                      if (phone == null || phone.isEmpty) {
                        return 'Non renseigné';
                      }
                      if (phone.length <= 8) {
                        return phone;
                      }
                      return '${phone.substring(0, 8)}...';
                    })(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoSection(
                    icon: Icons.location_on,
                    label: 'Adresse',
                    value: widget.tailor.adress ?? 'Non renseignée',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInfoSection(
                    icon: Icons.timer,
                    label: 'Expérience',
                    value: '${3} ans',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => _buildInfoSection(
                        icon: Icons.work,
                        label: 'Atélier',
                        value: '${numberOfWorkers.value} travailleurs',
                      )),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAboutSection(),
            const SizedBox(height: 20),
            _buildPortfolioSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      {required IconData icon, required String label, required String value}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 8),
          child: Text(value, style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'À propos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Ce tailleur n\'a pas encore ajouté de biographie pour le moment..',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portfolio',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildPortfolioStream(),
      ],
    );
  }

  Widget _buildPortfolioStream() {
    return StreamBuilder<List<Modele>>(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_isLoadingMore) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final newModeles = snapshot.data!;
          final uniqueModeles =
              newModeles.where((modele) => _modeleIds.add(modele.id!)).toList();
          _modeles.addAll(uniqueModeles);
          _isLoadingMore = false;
          return _buildModelesGrid();
        }

        return const Center(
          child: Text(
            'Pas de modèles disponibles pour le moment',
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildModelesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _modeles.length,
      itemBuilder: (context, index) {
        final modele = _modeles[index];
        return InkWell(
          onTap: () => Get.to(() => DetailModeleView(modele)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              modele.fichier[0]!,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  void _setupScrollController() {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore) {
        _isLoadingMore = true;
        await _fetchMoreModeles();
      }
    });
  }

  Future<void> _fetchMoreModeles() async {
    final ModeleService modeleService = Get.find<ModeleService>();
    final List<Modele> newModeles = await modeleService.getAllModeleByTailleur(
      widget.tailor.id!,
      Get.find<CommandeController>().listSelectedCategorie,
      lastModele: _modeles.isNotEmpty ? _modeles.last : null,
    );
    _streamController.add(newModeles);
  }

  Future<void> _fetchInitialModeles() async {
    final ModeleService modeleService = Get.find<ModeleService>();
    final List<Modele> initialModeles =
        await modeleService.getAllModeleByTailleur(
      widget.tailor.id!,
      Get.find<CommandeController>().listSelectedCategorie,
    );
    fetchNumberOfWorker();
    _streamController.add(initialModeles);
  }

  Future<void> fetchNumberOfWorker() async {
    final request =
        await TailleurRequestController().getRequest(widget.tailor.id!);
    numberOfWorkers.value = request?.nombreTravailleur ?? 1;
  }
}
