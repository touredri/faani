import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:faani/app/modules/mesures/views/ajouter_mesure.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/services/mesure_service.dart';
import '../../../firebase/global_function.dart';
import '../controllers/mesures_controller.dart';
import 'detail_mesure.dart';

class MesuresView extends GetView<MesuresController> {
  const MesuresView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: scaffoldBack,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: primaryColor,
          title: const Text(
            'Mes Mesures',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          leading: const BackButton(
            color: Colors.white,
          ),
        ),
        body: StreamBuilder<List<Mesure>>(
          stream: MesureService().getAllUserMesure(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Oups !! Une erreur est survenue');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.isEmpty) {
              return const Center(
                  child: Text(
                'Aucune mesure disponible! Ajouter pour voir la liste',
                textAlign: TextAlign.center,
                // style: TextStyle(fontSize: 30),
              ));
            }
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final mesure = data[index];
                return GestureDetector(
                  onTap: () {
                    Get.to(() => DetailMesure(id: mesure.id!),
                        transition: Transition.rightToLeft);
                  },
                  child: ListTile(
                    title: Text(
                      mesure.nom!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd').format(mesure.date!).toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AjoutMesure()));
          },
          child: const Icon(Icons.add),
        ));
  }
}
