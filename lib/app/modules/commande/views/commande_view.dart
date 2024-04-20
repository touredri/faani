import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/views/ajouter_commande.dart';
import 'package:faani/app/modules/commande/widgets/choose_modele.dart';
import 'package:faani/app/modules/globale_widgets/animated_seach.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/message/views/message_view.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:faani/app/modules/commande/widgets/circle_indicator.dart';
import 'package:faani/app/modules/commande/widgets/list_commande.dart';
import 'package:faani/pages/commande/widget/tailleurs.dart';

class CommandeView extends StatefulWidget {
  const CommandeView({super.key});

  @override
  State<CommandeView> createState() => _CommandeViewState();
}

class _CommandeViewState extends State<CommandeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.find();
    final CommandeController commandeController = Get.put(CommandeController());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'A Coudre',
          style: Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(color: Colors.white, fontSize: 22),
        ),
        actions: [
          GetBuilder<CommandeController>(
            init: CommandeController(),
            initState: (_) {},
            id: 'search',
            builder: (_) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedSearchBar(
                  textEditingController:
                      commandeController.textEditingController,
                  isSearching: commandeController.isSearching,
                  onSearch: commandeController.toggleSearch,
                  controller: commandeController,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
        backgroundColor: primaryColor,
        bottom: TabBar(
            controller: _tabController,
            indicator: CircleTabIndicator(
              color: Colors.white,
              radius: 3,
            ),
            indicatorPadding: const EdgeInsets.only(bottom: 45),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6),
            tabs: [
              Tab(
                  child: Column(
                children: [
                  controller.isTailleur.value
                      ? const Icon(Icons.call_received)
                      : const Icon(Icons.send),
                  controller.isTailleur.value
                      ? const Text('Réçu')
                      : const Text('Envoyer'),
                ],
              )),
              Tab(
                  child: Column(
                children: [
                  controller.isTailleur.value
                      ? const Icon(Icons.save_alt)
                      : const Icon(Icons.people_alt),
                  controller.isTailleur.value
                      ? const Text('Enregistrer')
                      : const Text('Tailleurs'),
                ],
              )),
              const Tab(
                  child: Column(
                children: [
                  Icon(Icons.done_all),
                  Text('Terminer'),
                ],
              ))
            ]),
      ),
      body: GestureDetector(
        onTap: () {
          if (commandeController.isSearching.value) {
            commandeController.toggleSearch();
            commandeController.textEditingController.clear();
            FocusScope.of(context).unfocus();
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            const ListCommande(
              status: 'receive',
            ),
            controller.isTailleur.value
                ? const ListCommande(status: 'save')
                : const ListTailleur(),
            const ListCommande(
              status: 'finish',
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.001),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "fab1",
                backgroundColor: Colors.grey,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(15)),
                onPressed: () {
                  Get.to(() => const MessageView(),
                      transition: Transition.downToUp);
                },
                child: const Icon(Icons.sms, color: Colors.white),
              ),
              2.5.hs,
              FloatingActionButton(
                heroTag: "fab2",
                onPressed: () {
                  Get.to(() => const ChooseModeleView(),
                      transition: Transition.downToUp);
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
