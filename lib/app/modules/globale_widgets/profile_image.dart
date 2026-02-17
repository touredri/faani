import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImage extends StatelessWidget {
  final double width, height;
  const ProfileImage({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final String imgUrl = getRandomProfileImageUrl();
    final theme = Theme.of(context);

    return user?.photoURL != null
        ? CachedNetworkImage(
            imageUrl: user!.photoURL!,
            imageBuilder: (context, imageProvider) => Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => SizedBox(
              width: width,
              height: height,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => _FallbackAvatar(
              width: width,
              height: height,
            ),
          )
        : Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  size: width * 0.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.width, required this.height});
  final double width, height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
      child: Icon(
        Icons.person,
        size: width * 0.5,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class BuildProfileImage extends StatefulWidget {
  final double width, height;
  final bool showIcon;
  const BuildProfileImage({
    super.key,
    required this.width,
    required this.height,
    this.showIcon = false,
  });

  @override
  State<BuildProfileImage> createState() => _BuildProfileImageState();
}

class _BuildProfileImageState extends State<BuildProfileImage> {
  void changeProfileImage() async {
    String? oldImageUrl = user!.photoURL;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(image.path.split('/').last);

      UploadTask uploadTask = storageReference.putFile(File(image.path));

      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      await user!.updatePhotoURL(imageUrl);

      final UserModel? checkUser = await UserService().getIfUser(user!.uid);
      if (checkUser != null) {
        checkUser.profileImage = imageUrl;
        await UserService().updateUser(user!.uid, checkUser);
      }

      if (oldImageUrl != null) {
        Reference oldImageRef =
            FirebaseStorage.instance.refFromURL(oldImageUrl);
        try {
          await oldImageRef.delete();
        } catch (e) {
          // Silently handle deletion failure
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        ProfileImage(
          width: widget.width,
          height: widget.height,
        ),
        if (widget.showIcon)
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: theme.colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: changeProfileImage,
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
