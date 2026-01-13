import 'package:flutter/material.dart';

class HeaderDesktop extends StatelessWidget {
  const HeaderDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.dashboard_customize, color: Colors.grey[800]),
            const SizedBox(width: 10),
            Text(
              "Dashboard",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          ],
        )
      ],
    );
  }
}