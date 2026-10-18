import 'package:flutter/material.dart';
import 'package:my_app/generated/app_colors.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.primary,
                    size: 42,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'No messages yet',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Your conversations with doctors will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSub),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
