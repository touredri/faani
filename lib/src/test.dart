import 'package:flutter/material.dart';
// import 'package:sliver_tools/sliver_tools.dart';

// class TikTokScrollEffect extends StatefulWidget {
//   @override
//   _TikTokScrollEffectState createState() => _TikTokScrollEffectState();
// }

// class _TikTokScrollEffectState extends State<TikTokScrollEffect> {
//   final List<List<String>> contentList = [
//     [
//       "assets/images/modele1.png",
//       "assets/images/modele1.png",
//       "assets/images/modele1.png"
//     ],
//     ["assets/images/modele1.png", "assets/images/modele1.png"],
//     ["assets/images/modele1.png"],
//     // Ajoutez plus de contenu ici
//   ];

//   int currentContentIndex = 0;
//   int currentImageIndex = 0;

//   PageController pageController = PageController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: <Widget>[
//           // SliverAppBar(
//           //   expandedHeight: 200,
//           //   pinned: true,
//           //   backgroundColor: Colors.blue,
//           //   flexibleSpace: FlexibleSpaceBar(
//           //     title: Text("Titre de l'en-tête"),
//           //   ),
//           // ),
//           SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (BuildContext context, int index) {
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       currentContentIndex = index;
//                     });
//                   },
//                   onHorizontalDragEnd: (details) {
//                     if (details.primaryVelocity! > 0) {
//                       // Glissement vers la droite
//                       if (currentImageIndex <
//                           contentList[currentContentIndex].length - 1) {
//                         setState(() {
//                           currentImageIndex++;
//                         });
//                       }
//                     } else if (details.primaryVelocity! < 0) {
//                       // Glissement vers la gauche
//                       if (currentImageIndex > 0) {
//                         setState(() {
//                           currentImageIndex--;
//                         });
//                       }
//                     }
//                   },
//                   child: Container(
//                     height:
//                         300, // Ajustez la hauteur en fonction de vos besoins
//                     color: Colors.blue,
//                     alignment: Alignment.center,
//                     child: Image.asset(
//                       contentList[currentContentIndex][currentImageIndex],
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 );
//               },
//               childCount: contentList.length,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class HomePAgeView extends StatefulWidget {
  const HomePAgeView({super.key});

  @override
  State<HomePAgeView> createState() => _HomePAgeViewState();
}

class _HomePAgeViewState extends State<HomePAgeView> {
  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return Expanded(
        child: PageView.builder(
      controller: controller,
      scrollDirection: Axis.vertical,
      itemCount: 10,
      itemBuilder: (context, index) {
        return PageView(
          scrollDirection: Axis.vertical,
          children: const [
            Image(
              image: AssetImage('assets/images/modele1.png'),
            ),
            Image(
              image: AssetImage('assets/images/modele1.png'),
            ),
            Image(
              image: AssetImage('assets/images/modele1.png'),
            ),
            Image(
              image: AssetImage('assets/images/modele1.png'),
            ),
            Image(
              image: AssetImage('assets/images/modele1.png'),
            ),
          ],
        );
      },
    ));
  }
}
