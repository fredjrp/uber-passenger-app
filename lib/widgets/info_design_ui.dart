import 'package:flutter/material.dart';

class InfoDesignUIWidget extends StatelessWidget {
  final String? textInfo;
  final IconData? iconData;

  const InfoDesignUIWidget({super.key, this.textInfo, this.iconData});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: ListTile(
        leading: Icon(
          iconData,
          color: Colors.white70,
        ),
        title: Text(
          textInfo ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
