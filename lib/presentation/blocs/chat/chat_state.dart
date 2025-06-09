import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Chat> chats;

  const ChatLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class DirectChatMessagesLoading extends ChatState {}

class DirectChatMessagesLoaded extends ChatState {
  final List<Chat> messages;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasMore;

  const DirectChatMessagesLoaded({
    required this.messages,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  }) : hasMore = page < totalPages;

  @override
  List<Object?> get props => [messages, total, page, limit, totalPages, hasMore];
}

class DirectChatMessagesError extends ChatState {
  final String message;

  const DirectChatMessagesError(this.message);

  @override
  List<Object?> get props => [message];
} 