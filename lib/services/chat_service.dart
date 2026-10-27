import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';

class ChatService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('chat_messages');

  Future<void> sendMessage({
    required String projectId,
    required String senderUid,
    required String senderName,
    required String senderRole,
    required String text,
  }) {
    return _collection.add({
      'projectId': projectId,
      'senderUid': senderUid,
      'senderName': senderName,
      'senderRole': senderRole,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  /// Newest first, sorted client-side (same composite-index reasoning as
  /// the rest of the app's services) — pairs with a `reverse: true`
  /// `ListView` so the newest message sits at the bottom like a normal chat.
  Stream<List<ChatMessage>> streamForProject(String projectId) {
    return _collection.where('projectId', isEqualTo: projectId).snapshots().map((snapshot) {
      final messages = snapshot.docs.map(ChatMessage.fromDoc).toList();
      messages.sort((a, b) => _compareNewestFirst(a.sentAt, b.sentAt));
      return messages;
    });
  }

  // A just-sent message has a null `sentAt` until the server timestamp
  // round-trips back, so null sorts as "newest" — matching the rest of the
  // app's services — otherwise a message you just sent would briefly jump
  // to the wrong end of the list.
  int _compareNewestFirst(Timestamp? a, Timestamp? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return b.compareTo(a);
  }
}
