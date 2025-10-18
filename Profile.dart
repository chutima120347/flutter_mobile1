import 'package:flutter/material.dart';
import 'ProfileCard.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 134, 119, 119),
      body: const Center(
        child: ProfileCard(
          name: 'Chutima Sahapornudomkan',
          position: 'Programmer',
          email: 'sahapornudomkan_c2@su.ac.th',
          phoneNumber: '094-7816344',
          imageUrl: 'https://picsum.photos/200',
        ),
      ),
    );
  }
}
