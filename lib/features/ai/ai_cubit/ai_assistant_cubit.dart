import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import '../services/ai_service.dart';

class AiAssistantCubit extends Cubit<AiAssistantState> {
  final AiService? _aiService;

  AiAssistantCubit({this._aiService}) : super(const AiAssistantState());

  Future<void> sendMessage(String text) async {
    final messages = List<AiMessage>.from(state.messages);
    messages.add(AiMessage(role: 'user', content: text));
    emit(AiAssistantState(messages: messages, loading: true));

    if (_aiService == null) {
      messages.add(const AiMessage(role: 'assistant', content: 'Connect the AI gateway for real responses.'));
      if (!isClosed) emit(AiAssistantState(messages: messages, loading: false));
      return;
    }

    try {
      final result = await _aiService.parseExpense(text, AiContext(now: DateTime.now()));
      final draft = _aiService.parseExpenseToDraft(result);
      if (draft != null) {
        final decimals = draft.currency.toUpperCase() == 'KWD' ? 3 : 2;
        messages.add(AiMessage(role: 'assistant', content: 'Found: ${draft.description} — ${draft.amount.toStringAsFixed(decimals)} ${draft.currency} in ${draft.category.name}'));
        if (!isClosed) emit(AiAssistantState(messages: messages, loading: false, parsedExpense: draft));
      } else {
        messages.add(const AiMessage(role: 'assistant', content: 'Could not parse an expense from your input. Try a format like "lunch 15 at restaurant".'));
        if (!isClosed) emit(AiAssistantState(messages: messages, loading: false));
      }
    } catch (e) {
      messages.add(const AiMessage(role: 'assistant', content: 'AI service is unavailable. You can still enter the expense manually below.'));
      if (!isClosed) emit(AiAssistantState(messages: messages, loading: false));
    }
  }

  void clearMessages() => emit(const AiAssistantState());

  void clearParsedExpense() => emit(AiAssistantState(messages: state.messages, loading: false));
}

class AiAssistantState {
  final List<AiMessage> messages;
  final bool loading;
  final Expense? parsedExpense;
  const AiAssistantState({this.messages = const [], this.loading = false, this.parsedExpense});
}

class AiMessage {
  final String role;
  final String content;
  const AiMessage({required this.role, required this.content});
}
