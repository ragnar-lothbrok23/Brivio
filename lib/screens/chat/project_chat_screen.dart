import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/chat_message.dart';
import '../../models/project.dart';
import '../../services/chat_service.dart';
import '../../services/project_service.dart';
import '../auth/auth_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/project_picker_field.dart';
import '../widgets/skeleton_list.dart';

/// One shared chat per project — every role assigned to the project
/// (Site Engineer/Supervisor/Vendor/Contractor) plus Builder/PM, who see
/// every project. Membership mirrors exactly who can already see the
/// project elsewhere in the app (`streamProjectsForUser`).
class ProjectChatScreen extends StatefulWidget {
  const ProjectChatScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<ProjectChatScreen> createState() => _ProjectChatScreenState();
}

class _ProjectChatScreenState extends State<ProjectChatScreen> {
  final _projectService = ProjectService();
  final _chatService = ChatService();
  final _messageController = TextEditingController();

  Project? _selectedProject;
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedProject == null) return;
    setState(() => _isSending = true);
    try {
      await _chatService.sendMessage(
        projectId: _selectedProject!.id,
        senderUid: widget.user.uid,
        senderName: widget.user.name,
        senderRole: widget.user.roleLabel,
        text: text,
      );
      _messageController.clear();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Chat')),
      body: Column(
        children: [
          ProjectPickerField(
            projectsStream: _projectService.streamProjectsForUser(widget.user),
            onChanged: (project) => setState(() => _selectedProject = project),
          ),
          if (_selectedProject != null) ...[
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _chatService.streamForProject(_selectedProject!.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SkeletonList();
                  }
                  final messages = snapshot.data!;
                  if (messages.isEmpty) {
                    return const EmptyState(
                      icon: Icons.forum_outlined,
                      message: 'No messages yet — say hello to the team',
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMine = message.senderUid == widget.user.uid;
                      return _ChatBubble(message: message, isMine: isMine);
                    },
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Message the team...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _isSending ? null : _send,
                      style: IconButton.styleFrom(backgroundColor: kAuthNavy),
                      icon: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? kAuthNavy : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '${message.senderName} • ${message.senderRole}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isMine ? Colors.white70 : kAuthNavyMuted,
                  ),
                ),
              ),
            Text(
              message.text,
              style: TextStyle(color: isMine ? Colors.white : null),
            ),
          ],
        ),
      ),
    );
  }
}
