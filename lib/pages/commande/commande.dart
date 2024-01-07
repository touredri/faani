import 'package:faani/app_state.dart';
import 'package:faani/constants/styles.dart';
import 'package:faani/pages/commande/widget/circle_indicator.dart';
import 'package:faani/pages/commande/widget/finish.dart';
import 'package:faani/pages/commande/widget/receive.dart';
import 'package:faani/pages/commande/widget/save.dart';
import 'package:faani/pages/commande/widget/tailleurs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommandePage extends StatefulWidget {
  const CommandePage({super.key});

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isTailleur = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    isTailleur = Provider.of<ApplicationState>(context).isTailleur;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commandes',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Colors.white, fontSize: 22),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_sharp, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              )
            ],
          ),
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
                    isTailleur
                        ? const Icon(Icons.call_received)
                        : const Icon(Icons.send),
                    isTailleur ? const Text('Réçu') : const Text('Envoyer'),
                  ],
                )),
                Tab(
                    child: Column(
                  children: [
                    isTailleur
                        ? const Icon(Icons.save_alt)
                        : const Icon(Icons.people_alt),
                    isTailleur
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
        body: TabBarView(
          controller: _tabController,
          children: [
            const ReceivedCommande(),
            isTailleur ? const SavedCommande() : const ListTailleur(),
            const CommandeLivrer(),
          ],
        ));
  }
}
