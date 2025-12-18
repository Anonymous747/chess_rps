import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedChannel = 0;
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Palette.background,
              Palette.backgroundSecondary,
              Palette.backgroundTertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Palette.backgroundSecondary.withOpacity(0.95),
                  border: Border(
                    bottom: BorderSide(color: Palette.glassBorder),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Palette.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.search, color: Palette.textSecondary),
                          style: IconButton.styleFrom(
                            backgroundColor: Palette.backgroundTertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Palette.glassBorder),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.edit_square, color: Palette.purpleAccent),
                          style: IconButton.styleFrom(
                            backgroundColor: Palette.purpleAccent.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Palette.purpleAccent.withOpacity(0.2)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChannelTab('Global Lobby', 0, _selectedChannel == 0),
                          const SizedBox(width: 12),
                          _buildChannelTab('Clan', 1, _selectedChannel == 1),
                          const SizedBox(width: 12),
                          _buildChannelTab('Friends', 2, _selectedChannel == 2, hasNotification: true),
                          const SizedBox(width: 12),
                          _buildChannelTab('Mentions', 3, _selectedChannel == 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildDateDivider('Today'),
                    const SizedBox(height: 20),
                    _buildWelcomeMessage(),
                    const SizedBox(height: 20),
                    _buildMessage(
                      'Grandmaster_Flash',
                      'Does anyone have a good counter for the Queen\'s Gambit in the new patch? The win rates are insane right now.',
                      '10:42 AM',
                      false,
                      Palette.gold,
                    ),
                    const SizedBox(height: 12),
                    _buildMessage(
                      'RookKnight99',
                      'Just play the Slav Defense. Solid as a rock. 🧱 The key is to control the center early.',
                      '10:44 AM',
                      false,
                      Palette.success,
                    ),
                    const SizedBox(height: 12),
                    _buildMessage(
                      'You',
                      'I\'ve been trying the Albin Countergambit. It\'s risky but catches people off guard in blitz!',
                      '10:45 AM',
                      true,
                      null,
                    ),
                    const SizedBox(height: 12),
                    _buildMessage(
                      'Grandmaster_Flash',
                      'Interesting! I\'ll give it a shot. Want to play a practice match? ⚔️',
                      '10:46 AM',
                      false,
                      Palette.gold,
                      isReply: true,
                    ),
                    const SizedBox(height: 12),
                    _buildMessage(
                      'You',
                      'Sure, send the invite!',
                      '10:46 AM',
                      true,
                      null,
                      isRead: true,
                    ),
                  ],
                ),
              ),

              // Input Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Palette.backgroundSecondary.withOpacity(0.8),
                  border: Border(
                    top: BorderSide(color: Palette.glassBorder),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add_circle, color: Palette.textSecondary),
                      style: IconButton.styleFrom(
                        backgroundColor: Palette.backgroundTertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Palette.glassBorder),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Palette.backgroundTertiary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Palette.glassBorder),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: TextStyle(color: Palette.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Palette.textSecondary),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        _messageController.clear();
                      },
                      icon: Icon(Icons.send, color: Palette.textPrimary),
                      style: IconButton.styleFrom(
                        backgroundColor: Palette.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelTab(String label, int index, bool isActive, {bool hasNotification = false}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedChannel = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [Palette.purpleAccent, Palette.purpleAccentDark],
                )
              : null,
          color: isActive ? null : Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.transparent : Palette.glassBorder,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Palette.textPrimary : Palette.textSecondary,
              ),
            ),
            if (hasNotification) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Palette.onlineGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.onlineGreen.withOpacity(0.8),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateDivider(String date) {
    return Row(
      children: [
        Expanded(child: Divider(color: Palette.glassBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Palette.textTertiary,
            ),
          ),
        ),
        Expanded(child: Divider(color: Palette.glassBorder)),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Palette.purpleAccentDark.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Palette.purpleAccent.withOpacity(0.2)),
        ),
        child: Text(
          'Welcome to the Global Strategy Channel',
          style: TextStyle(
            fontSize: 11,
            color: Palette.purpleAccentLight,
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(
    String username,
    String message,
    String time,
    bool isMe,
    Color? usernameColor, {
    bool isReply = false,
    bool isRead = false,
  }) {
    if (isMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Palette.purpleAccent, Palette.purpleAccentDark],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(color: Palette.purpleAccent.withOpacity(0.2)),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Palette.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Palette.textTertiary,
                  ),
                ),
                if (isRead) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, size: 14, color: Palette.purpleAccent),
                ],
              ],
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: usernameColor != null
                    ? [usernameColor, usernameColor.withOpacity(0.7)]
                    : [Palette.backgroundSecondary, Palette.backgroundTertiary],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: usernameColor != null
                ? Icon(Icons.person, color: Palette.textPrimary, size: 20)
                : Center(
                    child: Text(
                      username.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: usernameColor ?? Palette.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: Palette.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Palette.backgroundTertiary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: Palette.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isReply)
                        Container(
                          padding: const EdgeInsets.only(bottom: 8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Palette.glassBorder),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 2,
                                height: 12,
                                color: Palette.purpleAccent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Replying to you',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Palette.purpleAccentLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

