import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class CustomListTile extends GetView<ProfileController> {
  final IconData leadingIcon;
  final String title;
  final Color leadingColor;
  final void Function()? onTap;

  const CustomListTile({
    Key? key,
    required this.leadingIcon,
    required this.title,
    required this.leadingColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(leadingIcon, color: leadingColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({Key? key}) : super(key: key);

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
