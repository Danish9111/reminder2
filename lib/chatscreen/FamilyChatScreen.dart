// filename: FamilyChatScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle

class FamilyChatScreen extends StatefulWidget {
  const FamilyChatScreen({Key? key}) : super(key: key);

  @override
  State<FamilyChatScreen> createState() => _FamilyChatScreenState();
}

class _FamilyChatScreenState extends State<FamilyChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Color primaryColor = const Color(0xFF9B59B6);

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Hazrat',
      'text': 'Soccer practice ends at 4:30 today, not 5:00!',
      'isMe': false,
      'type': 'text',
      'timestamp': '2:30 PM',
    },
    {
      'sender': 'Mom',
      'text': 'Thanks for letting us know.',
      'isMe': true,
      'type': 'text',
      'timestamp': '2:32 PM',
    },
    {
      'sender': 'Dad',
      'text': 'I can pick him up on my way back.',
      'isMe': false,
      'type': 'text',
      'timestamp': '2:35 PM',
      'aiSuggestion': true,
      'aiAction': 'Create Reminder: Pick up Hazrat @ 4:30 PM',
    },
    {
      'sender': 'Azy',
      'text': '',
      'isMe': false,
      'type': 'image',
      'timestamp': '3:00 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // appBar: AppBar(
      //   backgroundColor: primaryColor,
      //   systemOverlayStyle: SystemUiOverlayStyle.light,
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   title: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         "The Super Family",
      //         style: TextStyle(
      //           fontSize: 18 * textScale,
      //           fontWeight: FontWeight.bold,
      //           color: Colors.white,
      //         ),
      //       ),
      //       Text(
      //         "4 members • Online",
      //         style: TextStyle(
      //           fontSize: 12 * textScale,
      //           color: Colors.white70,
      //         ),
      //       ),
      //     ],
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.call, size: screenWidth * 0.07),
      //       onPressed: () {},
      //     ),
      //     IconButton(
      //       icon: Icon(Icons.more_vert, size: screenWidth * 0.07),
      //       onPressed: () {},
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Column(
                  children: [
                    _buildMessageBubble(msg, screenWidth, textScale),
                    if (msg['aiSuggestion'] == true)
                      _buildAiSuggestionChip(screenWidth, textScale),
                  ],
                );
              },
            ),
          ),
          _buildInputArea(screenWidth, screenHeight, textScale),
        ],
      ),
    );
  }

  Widget _buildAiSuggestionChip(double screenWidth, double textScale) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: screenWidth * 0.01,
          bottom: screenWidth * 0.03,
          left: screenWidth * 0.12,
        ),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Converting to Task... (Opened Add Task Screen)")),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.015,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: screenWidth * 0.03, color: primaryColor),
                SizedBox(width: screenWidth * 0.015),
                Text(
                  "Turn this into a reminder? (Premium)",
                  style: TextStyle(
                    fontSize: 11 * textScale,
                    color: primaryColor.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4),
                const Icon(Icons.star, size: 12, color: Colors.amber),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, double screenWidth, double textScale) {
    final isMe = msg['isMe'];

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isMe)
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.03, bottom: 4, top: 6),
            child: Text(
              msg['sender'],
              style: TextStyle(
                fontSize: 12 * textScale,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Container(
          margin: EdgeInsets.only(
            bottom: screenWidth * 0.01,
            right: isMe ? 0 : screenWidth * 0.2,
            left: isMe ? screenWidth * 0.2 : 0,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.03,
          ),
          decoration: BoxDecoration(
            color: isMe ? primaryColor : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (msg['type'] == 'image')
                Container(
                  height: screenWidth * 0.4,
                  width: screenWidth * 0.55,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
                )
              else
                Text(
                  msg['text'],
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 16 * textScale,
                  ),
                ),
              SizedBox(height: screenWidth * 0.01),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  msg['timestamp'],
                  style: TextStyle(
                    fontSize: 10 * textScale,
                    color: isMe ? Colors.white70 : Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea(double screenWidth, double screenHeight, double textScale) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.025,
          vertical: screenHeight * 0.012,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.grey, size: screenWidth * 0.07),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Attach Photo or PDF")),
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.02),
                child: TextField(
                  controller: _messageController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            CircleAvatar(
              backgroundColor: primaryColor,
              radius: screenWidth * 0.06,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.send, color: Colors.white, size: screenWidth * 0.05),
                onPressed: _handleSendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();

    bool triggerAi = text.toLowerCase().contains("buy") ||
        text.toLowerCase().contains("bring") ||
        text.toLowerCase().contains("appointment");

    setState(() {
      _messages.add({
        'sender': 'Me',
        'text': text,
        'isMe': true,
        'type': 'text',
        'timestamp': 'Now',
        'aiSuggestion': triggerAi,
      });
    });

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
