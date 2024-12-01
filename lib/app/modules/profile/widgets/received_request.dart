import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/tailleur_request.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/tailleur_request_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:faani/app/data/services/modele_service.dart';

class TailleurRequestController extends GetxController {
  final TailleurRequestService service = TailleurRequestService();

  Stream<List<TailleurRequest>> getRequestsByApprovalStatus(bool status) {
    return service.getRequestsByApprovalStatus(status);
  }

  void updateRequestApprovalStatus(String requestId, bool status) {
    service.updateRequestApprovalStatus(requestId, status);
  }
}

class ReceivedRequest extends StatefulWidget {
  const ReceivedRequest({super.key});

  @override
  _ReceivedRequestState createState() => _ReceivedRequestState();
}

class _ReceivedRequestState extends State<ReceivedRequest>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final tailleurRequestController = Get.put(TailleurRequestController());
    final modeleService = Get.put(ModeleService());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests and Tailors'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Requests'),
            Tab(text: 'Check Models'),
            Tab(text: 'Tailors'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(tailleurRequestController),
          _buildUnapprovedModelsTab(modeleService),
          _buildTailorsTab(),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(
      TailleurRequestController tailleurRequestController) {
    return StreamBuilder<List<TailleurRequest>>(
      stream: tailleurRequestController.getRequestsByApprovalStatus(false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data!;
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return ExpansionTile(
              title: Text(request.nomAtelier),
              children: [
                FutureBuilder<UserModel?>(
                  future: UserService().getUser(request.userId),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final user = userSnapshot.data!;
                    return Column(
                      children: [
                        ListTile(
                          title: Text('User: ${user.nomPrenom}'),
                          subtitle: Text('Phone: ${user.phoneNumber}'),
                        ),
                        ListTile(
                          title: Text('Client Cible: ${request.clientCible}'),
                          subtitle: Text(
                              'Pays: ${request.pays}, Ville: ${request.ville}, Quartier: ${request.quartier}'),
                        ),
                        ListTile(
                          title: Text(
                              'Nombre de Travailleurs: ${request.nombreTravailleur}'),
                          subtitle: Text('Num Atelier: ${request.numAtelier}'),
                        ),
                        OverflowBar(
                          children: [
                            TextButton(
                              onPressed: () {
                                // Appeler le client
                              },
                              child: const Text('Call'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                tailleurRequestController
                                    .updateRequestApprovalStatus(
                                        request.id!, true);
                              },
                              child: const Text('Approve'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTailorsTab() {
    return StreamBuilder<List<UserModel>>(
      stream: UserService().getAllTailleur(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final tailors = snapshot.data!;
        return ListView.builder(
          itemCount: tailors.length,
          itemBuilder: (context, index) {
            final tailor = tailors[index];
            return ExpansionTile(
              title: Text(tailor.nomPrenom ?? 'No Name'),
              children: [
                ListTile(
                  title: Text('Phone: ${tailor.phoneNumber}'),
                ),
                ListTile(
                  title: Text('Email: ${tailor.email}'),
                  subtitle: Text('Address: ${tailor.adress}'),
                ),
                OverflowBar(
                  children: [
                    TextButton(
                      onPressed: () {
                        // Suspendre le compte
                      },
                      child: const Text(
                        'Suspend Account',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        UserService().updateUserIsTailleur(
                            tailor.id!, !tailor.isTailleur);
                      },
                      child: const Text(
                        'Make Not Tailor',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUnapprovedModelsTab(ModeleService modeleService) {
    return StreamBuilder<List<Modele>>(
      stream: modeleService.getUnapprovedModels(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final models = snapshot.data!;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: models.length,
          itemBuilder: (context, index) {
            final model = models[index];
            return InkWell(
              onTap: () {
                Get.to(() => DetailModeleView(model));
              },
              child: Card(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        model.fichier.first!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: OverflowBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 25,
                            child: OutlinedButton(
                              onPressed: () {
                                modeleService.updateModelApprovalStatus(
                                    model.id!, false);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                            child: ElevatedButton(
                              onPressed: () {
                                modeleService.updateModelApprovalStatus(
                                    model.id!, true);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                              ),
                              child: const Text('Approve'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
