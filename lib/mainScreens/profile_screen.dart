import 'package:flutter/material.dart';
import 'package:uber_user/main.dart';

import '../global/global.dart';
import '../widgets/info_design_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              
              // Avatar or Icon
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white12,
                child: Icon(Icons.person, size: 80, color: Colors.white70),
              ),
              
              const SizedBox(height: 20),

              // Name
              Text(
                userModelCurrentInfo?.name ?? "User",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 40.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
                width: 200,
                child: Divider(
                  color: Colors.white24,
                  height: 2,
                  thickness: 1,
                ),
              ),

              const SizedBox(height: 40),

              // Phone
              InfoDesignUIWidget(
                textInfo: userModelCurrentInfo?.phone ?? "No Phone",
                iconData: Icons.phone_iphone,
              ),

              // Email
              InfoDesignUIWidget(
                textInfo: userModelCurrentInfo?.email ?? "No Email",
                iconData: Icons.email,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(150, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "Back",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
