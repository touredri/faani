import 'package:faani/app/modules/globale_widgets/profile_image.dart';
import 'package:faani/app/modules/profile/widgets.dart/build_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import '../../../style/my_theme.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    return Scaffold(
      backgroundColor: primaryColor,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: primaryColor,
            automaticallyImplyLeading: false,
            expandedHeight: 180.0,
            toolbarHeight: 100,
            flexibleSpace: Card(
              color: Colors.blueGrey[50],
              elevation: 5,
              margin: const EdgeInsets.only(top: 50, left: 6, right: 6),
              child: Padding(
                padding: const EdgeInsets.only(top: 28.0, left: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    3.ws,
                    const BuildProfileImage(width: 120, height: 120),
                    8.ws,
                    Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${controller.userController.currentUser.value.nomPrenom}',
                              style: const TextStyle(
                                // color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // 3.hs,
                            const Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  // color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Bamako, Mali',
                                  style: TextStyle(
                                    // color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            3.hs,
                            // activity metrics
                            Row(
                              children: [
                                const Column(
                                  children: [
                                    Text(
                                      '21',
                                      style: TextStyle(
                                        // color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Suivie',
                                      style: TextStyle(
                                        // color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                5.ws,
                                const Column(
                                  children: [
                                    Text(
                                      '6',
                                      style: TextStyle(
                                        // color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Mesures',
                                      style: TextStyle(
                                        // color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                5.ws,
                                const Column(
                                  children: [
                                    Text(
                                      '10',
                                      style: TextStyle(
                                        // color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Modèles',
                                      style: TextStyle(
                                        // color: Colors.white,
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
            floating: false,
            pinned: false,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                1.5.hs,
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: listBuild(controller),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}