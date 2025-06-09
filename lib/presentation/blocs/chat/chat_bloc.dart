import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/chat/get_direct_chat_messages_usecase.dart';
import '../../../domain/usecases/chat/get_recent_chats_usecase.dart';
import '../../../domain/entities/chat.dart';
import 'chat_event.dart';
import 'chat_state.dart';


class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetRecentChatsUseCase _getRecentChatsUseCase;
  final GetDirectChatMessagesUseCase _getDirectChatMessagesUseCase;

  ChatBloc({
    required GetRecentChatsUseCase getRecentChatsUseCase,
    required GetDirectChatMessagesUseCase getDirectChatMessagesUseCase,
  })  : _getRecentChatsUseCase = getRecentChatsUseCase,
        _getDirectChatMessagesUseCase = getDirectChatMessagesUseCase,
        super(ChatInitial()) {
    print('🎯 [ChatBloc] ChatBloc initialized');
    on<LoadRecentChats>(_onLoadRecentChats);
    on<RefreshChats>(_onRefreshChats);
    on<LoadDirectChatMessages>(_onLoadDirectChatMessages);
    on<LoadMoreDirectChatMessages>(_onLoadMoreDirectChatMessages);
  }

  Future<void> _onLoadRecentChats(
    LoadRecentChats event,
    Emitter<ChatState> emit,
  ) async {
    print('🎯 [ChatBloc] LoadRecentChats event received');
    emit(ChatLoading());
    print('🎯 [ChatBloc] Emitted ChatLoading state');
    
    try {
      print('🎯 [ChatBloc] Calling getRecentChatsUseCase...');
      final chats = await _getRecentChatsUseCase();
      print('🎯 [ChatBloc] UseCase returned ${chats.length} chats');
      emit(ChatLoaded(chats));
      print('🎯 [ChatBloc] Emitted ChatLoaded state with ${chats.length} chats');
    } catch (e) {
      print('❌ [ChatBloc] Error in _onLoadRecentChats: $e');
      emit(ChatError(e.toString()));
      print('🎯 [ChatBloc] Emitted ChatError state');
    }
  }

  Future<void> _onRefreshChats(
    RefreshChats event,
    Emitter<ChatState> emit,
  ) async {
    print('🎯 [ChatBloc] RefreshChats event received');
    try {
      print('🎯 [ChatBloc] Calling getRecentChatsUseCase for refresh...');
      final chats = await _getRecentChatsUseCase();
      print('🎯 [ChatBloc] Refresh returned ${chats.length} chats');
      emit(ChatLoaded(chats));
      print('🎯 [ChatBloc] Emitted ChatLoaded state after refresh');
    } catch (e) {
      print('❌ [ChatBloc] Error in _onRefreshChats: $e');
      emit(ChatError(e.toString()));
      print('🎯 [ChatBloc] Emitted ChatError state after refresh');
    }
  }

  Future<void> _onLoadDirectChatMessages(
    LoadDirectChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    print('🎯 [ChatBloc] LoadDirectChatMessages event received for user: ${event.userId}');
    emit(DirectChatMessagesLoading());
    print('🎯 [ChatBloc] Emitted DirectChatMessagesLoading state');
    
    try {
      print('🎯 [ChatBloc] Calling getDirectChatMessagesUseCase...');
      final result = await _getDirectChatMessagesUseCase(
        event.userId,
        page: event.page,
        limit: event.limit,
      );
      
      final messages = result['messages'] as List<Chat>;
      final total = result['total'] as int;
      final page = result['page'] as int;
      final limit = result['limit'] as int;
      final totalPages = result['totalPages'] as int;
      
      print('🎯 [ChatBloc] UseCase returned ${messages.length} messages');
      emit(DirectChatMessagesLoaded(
        messages: messages,
        total: total,
        page: page,
        limit: limit,
        totalPages: totalPages,
      ));
      print('🎯 [ChatBloc] Emitted DirectChatMessagesLoaded state');
    } catch (e) {
      print('❌ [ChatBloc] Error in _onLoadDirectChatMessages: $e');
      emit(DirectChatMessagesError(e.toString()));
      print('🎯 [ChatBloc] Emitted DirectChatMessagesError state');
    }
  }

  Future<void> _onLoadMoreDirectChatMessages(
    LoadMoreDirectChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    print('🎯 [ChatBloc] LoadMoreDirectChatMessages event received for user: ${event.userId}, page: ${event.page}');
    
    try {
      print('🎯 [ChatBloc] Calling getDirectChatMessagesUseCase for more messages...');
      final result = await _getDirectChatMessagesUseCase(
        event.userId,
        page: event.page,
        limit: event.limit,
      );
      
      final newMessages = result['messages'] as List<Chat>;
      final total = result['total'] as int;
      final page = result['page'] as int;
      final limit = result['limit'] as int;
      final totalPages = result['totalPages'] as int;
      
      // If current state is DirectChatMessagesLoaded, append new messages
      if (state is DirectChatMessagesLoaded) {
        final currentState = state as DirectChatMessagesLoaded;
        final allMessages = [...currentState.messages, ...newMessages];
        
        emit(DirectChatMessagesLoaded(
          messages: allMessages,
          total: total,
          page: page,
          limit: limit,
          totalPages: totalPages,
        ));
      } else {
        emit(DirectChatMessagesLoaded(
          messages: newMessages,
          total: total,
          page: page,
          limit: limit,
          totalPages: totalPages,
        ));
      }
      
      print('🎯 [ChatBloc] Emitted DirectChatMessagesLoaded state with more messages');
    } catch (e) {
      print('❌ [ChatBloc] Error in _onLoadMoreDirectChatMessages: $e');
      emit(DirectChatMessagesError(e.toString()));
      print('🎯 [ChatBloc] Emitted DirectChatMessagesError state');
    }
  }
} 