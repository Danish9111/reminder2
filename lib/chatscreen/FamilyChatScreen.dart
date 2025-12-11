// filename: FamilyChatScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/AppColors/AppColors.dart';
import 'package:reminder_app/models/message_model.dart';
import 'package:reminder_app/providers/chat_provider.dart';
import 'package:reminder_app/providers/family_provider.dart';
import 'package:reminder_app/providers/user_provider.dart';
import 'package:reminder_app/utils/auth_utils.dart';

class FamilyChatScreen extends StatefulWidget {
  const FamilyChatScreen({Key? key}) : super(key: key);

  @override
  State<FamilyChatScreen> createState() => _FamilyChatScreenState();
}

class _FamilyChatScreenState extends State<FamilyChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start listening to messages when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChat();
    });
  }

  void _initChat() {
    final familyProvider = context.read<FamilyProvider>();
    final chatProvider = context.read<ChatProvider>();

    // Load family if not already loaded
    if (familyProvider.family == null) {
      familyProvider.loadFamily().then((_) {
        final familyId = familyProvider.family?.id;
        if (familyId != null) {
          chatProvider.listenToMessages(familyId);
        }
      });
    } else {
      final familyId = familyProvider.family?.id;
      if (familyId != null) {
        chatProvider.listenToMessages(familyId);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.isLoading && chatProvider.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chatProvider.error != null &&
                    chatProvider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load messages',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: _initChat,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (chatProvider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation with your family!',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Messages are in descending order, reverse for display
                final messages = chatProvider.messages.reversed.toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return Column(
                      children: [
                        _buildMessageBubble(msg, screenWidth, textScale),
                        if (_shouldShowAiSuggestion(msg.text))
                          _buildAiSuggestionChip(screenWidth, textScale),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildInputArea(screenWidth, screenHeight, textScale),
        ],
      ),
    );
  }

  /// Check if message text suggests an actionable task
  bool _shouldShowAiSuggestion(String text) {
    final lowerText = text.toLowerCase();
    return lowerText.contains('buy') ||
        lowerText.contains('bring') ||
        lowerText.contains('appointment') ||
        lowerText.contains('pick up') ||
        lowerText.contains('remind');
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
              const SnackBar(
                content: Text("Converting to Task... (Opened Add Task Screen)"),
              ),
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
                  AppColors.primaryColor.withOpacity(0.1),
                  AppColors.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: screenWidth * 0.03,
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: screenWidth * 0.015),
                Text(
                  "Turn this into a reminder? (Premium)",
                  style: TextStyle(
                    fontSize: 11 * textScale,
                    color: AppColors.primaryColor.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star, size: 12, color: Colors.amber),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    MessageModel msg,
    double screenWidth,
    double textScale,
  ) {
    final isMe = msg.isSentBy(currentUid);

    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (!isMe)
          Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.03,
              bottom: 4,
              top: 6,
            ),
            child: Text(
              msg.senderName,
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
            color: isMe ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isMe
                  ? const Radius.circular(20)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (msg.type == 'image' && msg.mediaUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    msg.mediaUrl!,
                    height: screenWidth * 0.4,
                    width: screenWidth * 0.55,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: screenWidth * 0.4,
                      width: screenWidth * 0.55,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Text(
                  msg.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 16 * textScale,
                  ),
                ),
              SizedBox(height: screenWidth * 0.01),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _formatTimestamp(msg.timestamp),
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$hour12:$minute $period';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  Widget _buildInputArea(
    double screenWidth,
    double screenHeight,
    double textScale,
  ) {
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
              icon: Icon(
                Icons.add_circle_outline,
                color: Colors.grey,
                size: screenWidth * 0.07,
              ),
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
              backgroundColor: AppColors.primaryColor,
              radius: screenWidth * 0.06,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: screenWidth * 0.05,
                ),
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

    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendMessage(
      text: text,
      senderName: userProvider.user?.name ?? 'Unknown',
      senderPhotoUrl: userProvider.user?.photoUrl,
    );

    _messageController.clear();

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
