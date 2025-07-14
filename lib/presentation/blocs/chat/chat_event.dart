import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecentChats extends ChatEvent {}

class RefreshChats extends ChatEvent {}

class LoadDirectChatMessages extends ChatEvent {
  final String userId;
  final int page;
  final int limit;

  const LoadDirectChatMessages({
    required this.userId,
    this.page = 1,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [userId, page, limit];
}

class LoadMoreDirectChatMessages extends ChatEvent {
  final String userId;
  final int page;
  final int limit;

  const LoadMoreDirectChatMessages({
    required this.userId,
    required this.page,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [userId, page, limit];
}

class SendDirectMessage extends ChatEvent {
  final String receiverId;
  final String content;
  final String currentUserId;

  const SendDirectMessage({
    required this.receiverId,
    required this.content,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [receiverId, content, currentUserId];
} 