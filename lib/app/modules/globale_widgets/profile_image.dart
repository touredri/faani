import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/my_theme.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../firebase_get_all_data.dart';

class ProfileImage extends StatelessWidget {
  final double width, height;
  const ProfileImage({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final String imgUrl = getRandomProfileImageUrl();
    return user?.photoURL != null
        ? CachedNetworkImage(
            imageUrl: user!.photoURL!,
            imageBuilder: (context, imageProvider) => Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: primaryColor, width: 2),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        : Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: primaryColor, width: 2)),
            child: Image.network(imgUrl));
  }
}

class BuildProfileImage extends StatefulWidget {
  final double width, height;
  const BuildProfileImage(
      {super.key, required this.width, required this.height});

  @override
  State<BuildProfileImage> createState() => _BuildProfileImageState();
}

class _BuildProfileImageState extends State<BuildProfileImage> {
  void changeProfileImage() async {
    // Get the URL of the current profile image
    String? oldImageUrl = user!.photoURL;

    // Open the image picker
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Create a reference to the location you want to upload to in Firebase Storage
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(image.path.split('/').last);

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(File(image.path));

      // Get the URL of the uploaded image
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Update the user's profile with the new image URL
      await user!.updatePhotoURL(imageUrl);
      
      // Delete the old image from Firebase Storage
      if (oldImageUrl != null) {
        Reference oldImageRef =
            FirebaseStorage.instance.refFromURL(oldImageUrl);
        try {
          await oldImageRef.delete();
        } catch (e) {
          // Handle the error here
          // print('Failed to delete the image: $e');
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ProfileImage(
          width: widget.width,
          height: widget.height,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(70),
            ),
            child: IconButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
              ),
              onPressed: changeProfileImage,
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
