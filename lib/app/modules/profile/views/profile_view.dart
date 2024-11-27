import 'package:faani/app/data/services/favorite_service.dart';
import 'package:faani/app/data/services/follow.dart';
import 'package:faani/app/data/services/mesure_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/profile_image.dart';
import 'package:faani/app/modules/profile/widgets/build_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import '../../../style/my_theme.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: primaryColor,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 160),
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                      ),
                      child: listBuild(controller, context),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Card(
                    color: Colors.blueGrey[50],
                    elevation: 5,
                    margin: const EdgeInsets.only(left: 1, right: 1),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 18.0, left: 10, bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const BuildProfileImage(width: 100, height: 100),
                          Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    auth.currentUser!.displayName ?? 'Anonyme',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  1.hs,
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${controller.userController.currentUser.value.adress ?? 'Bamako, Mali'} ',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  1.hs,
                                  // activity metrics
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          StreamBuilder<Map<String, int>>(
                                              stream: FollowService()
                                                  .getFollowStats(
                                                      auth.currentUser!.uid),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  int followCount = controller
                                                          .isTailleur.value
                                                      ? (snapshot.data?[
                                                              'followers'] ??
                                                          0)
                                                      : (snapshot.data?[
                                                              'following'] ??
                                                          0);
                                                  return Text(
                                                    followCount.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                } else {
                                                  return Text(
                                                    '0',
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }
                                              }),
                                          Text(
                                            'Suivie',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      5.ws,
                                      Column(
                                        children: [
                                          StreamBuilder<Object>(
                                              stream: MesureService()
                                                  .getMesureCount(
                                                      auth.currentUser!.uid),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Text(
                                                    snapshot.data.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                } else {
                                                  return Text(
                                                    '0',
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }
                                              }),
                                          Text(
                                            'Mesures',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      5.ws,
                                      Column(
                                        children: [
                                          controller.isTailleur.value
                                              ? FutureBuilder<int>(
                                                  future: ModeleService()
                                                      .getTotalModeleCount(auth
                                                          .currentUser!.uid),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      return Text(
                                                        snapshot.data
                                                            .toString(),
                                                      );
                                                    } else if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Text('0');
                                                    } else {
                                                      return Text(
                                                        '0',
                                                      );
                                                    }
                                                  })
                                              : StreamBuilder<int>(
                                                  stream: FavorieService()
                                                      .getFavorieCount(auth
                                                          .currentUser!.uid),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      return Text(
                                                        snapshot.data
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      );
                                                    } else if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return Text(
                                                        '0',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      );
                                                    } else {
                                                      return Text(
                                                        '0',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      );
                                                    }
                                                  }),
                                          Text(
                                            'Favories',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
