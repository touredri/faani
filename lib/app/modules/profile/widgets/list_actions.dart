import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class CustomListTile extends GetView<ProfileController> {
  final Widget leadingIcon;
  final String title;
  // final Color leadingColor;
  final String subTitle;
  final void Function()? onTap;

  const CustomListTile({
    Key? key,
    required this.leadingIcon,
    required this.title,
    // required this.leadingColor,
    this.subTitle = '',
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: leadingIcon,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            subTitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[800]),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[500]),
          onTap: onTap,
        ),
      ],
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Divider(
        height: 20,
        thickness: 1,
        color: Colors.grey,
      ),
    );
  }
}
