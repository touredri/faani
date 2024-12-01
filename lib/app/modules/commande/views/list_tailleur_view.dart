import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/commande/views/tailor_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListTailleurView extends GetView {
  const ListTailleurView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: UserService().getAllTailleur(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Une erreur est survenue ${snapshot.error}'));
          } else {
            final List users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final UserModel tailleur = users[index];
                return ListTile(
                  title: Text(tailleur.nomPrenom!),
                  subtitle: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 23,
                      ),
                      Text(' 125 | ',style: TextStyle(fontSize: 14),),
                      FutureBuilder<int>(
                          future:
                              ModeleService().getTotalModeleCount(tailleur.id!),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                style: TextStyle(fontSize: 14),
                                "Modèles: ${snapshot.data.toString()}",
                              );
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Modèles: ...',
                                  style: TextStyle(fontSize: 14));
                            } else {
                              return Text(
                                'Modèles: 0',style: TextStyle(fontSize: 14),
                              );
                            }
                          })
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        tailleur.profileImage!.isNotEmpty ||
                                tailleur.profileImage != null
                            ? tailleur.profileImage!
                            : getRandomProfileImageUrl()),
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 25,
                      ),
                      Text(
                        tailleur.adress!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => TailorProfilePage(tailor: tailleur));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
