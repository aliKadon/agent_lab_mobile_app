import 'dart:async';
import 'dart:io';

import 'package:agent_lab/models/all_agents_list_model.dart';
import 'package:agent_lab/models/chat_message_model.dart';
import 'package:agent_lab/models/chat_model.dart';
import 'package:agent_lab/models/create_agent_chat_message.dart';
import 'package:agent_lab/models/create_agents/answer_and_create_model.dart';
import 'package:agent_lab/models/create_agents/pick_a_model.dart';
import 'package:agent_lab/models/get_agnts_details_with_code_source_model.dart';
import 'package:agent_lab/providers/states/main_state.dart';
import 'package:agent_lab/utils/constants/app_enums.dart';
import 'package:agent_lab/utils/extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../services/error/failure.dart';
import '../services/repository/repository_impl.dart';
import 'common_providers.dart';

class MainProvider extends StateNotifier<MainState> {
  final RepositoryImpl _repositoryImpl;
  StreamSubscription<dynamic>? _chatStreamSubscription;

  MainProvider({
    required RepositoryImpl repositoryImpl,
  })  : _repositoryImpl = repositoryImpl,
        super(MainState());

  ValueChanged<String>? errorMessages;
  ValueChanged<String>? successMessage;

  void handleError(Either<Failure, dynamic> either) {
    either.fold((l) {
      l.checkAndTakeAction(onError: errorMessages);
    }, (r) => null);
  }

  Future<void> getAllAgents({bool forceReplace = false}) async {
    state = state.copyWith(isLoading: true);

    try {
      final listOfAgentsEither = await _repositoryImpl.getAllAgents();
      if (listOfAgentsEither.isLeft()) {
        state = state.copyWith(isLoading: false);
        handleError(listOfAgentsEither);
        return;
      }
      final AllAgentsList? newAgents = listOfAgentsEither.toOption().toNullable();

      if (newAgents == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final existingAgents = forceReplace ? <AgentModel>[] : (state.allAgentsList?.agents ?? <AgentModel>[]);
      final mergedAgents = <AgentModel>[...existingAgents, ...(newAgents.agents ?? <AgentModel>[])];

      state = state.copyWith(
        isLoading: false,
        allAgentsList: AllAgentsList(
          total: newAgents.total,
          agents: mergedAgents,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint("this is error from getAllAgents: $e");
    }
  }

  Future<void> getAgentDetails({required String agentId}) async {
    state = state.copyWith(isLoadingDetails: true);

    try {
      final agentDetailsEither = await _repositoryImpl.getAgentDetails(agentId: agentId);
      if (agentDetailsEither.isLeft()) {
        state = state.copyWith(isLoadingDetails: false);
        handleError(agentDetailsEither);
        return;
      }
      final GetAgentsDetailsWithCodeSource? details = agentDetailsEither.toOption().toNullable();

      if (details == null) {
        state = state.copyWith(isLoadingDetails: false);
        return;
      }

      state = state.copyWith(
        isLoadingDetails: false,
        selectedAgentDetails: details,
      );
    } catch (e) {
      state = state.copyWith(isLoadingDetails: false);
      debugPrint("this is error from getAgentDetails: $e");
    }
  }

  // ─── Agent Creation Flow ───────────────────────────────────────────────────

  Future<void> startFetchChatStream({required String description}) async {
    state = state.copyWith(
      creationStep: AgentCreationStep.streaming,
      agentChatMessages: [
        ...state.agentChatMessages,
        CreateAgentChatMessage(content: description, isUser: true),
      ],
    );

    final result = await _repositoryImpl.fetchChatStream(description: description);

    result.fold(
      (failure) {
        state = state.copyWith(
          creationStep: AgentCreationStep.error,
          creationError: failure.message,
        );
      },
      (stream) {
        _chatStreamSubscription?.cancel();
        _chatStreamSubscription = stream.listen(
          (event) {
            if (event.status == 'done') {
              final models = event.models ?? [];
              state = state.copyWith(
                creationStep: AgentCreationStep.modelSelection,
                creationSessionId: event.sessionId,
                availableModels: models,
                agentChatMessages: [
                  ...state.agentChatMessages,
                  CreateAgentChatMessage(
                    content: 'Found ${models.length} model${models.length == 1 ? '' : 's'} for your agent. Please select one below.',
                    isUser: false,
                  ),
                ],
              );
            } else if (event.status == 'error') {
              state = state.copyWith(
                creationStep: AgentCreationStep.error,
                creationError: event.message ?? 'An error occurred during search.',
              );
            } else if (event.message != null) {
              final isProgress = event.status == 'progress';
              final current = state.agentChatMessages;
              final updated = isProgress && current.isNotEmpty && current.last.isProgress
                  ? [
                      ...current.sublist(0, current.length - 1),
                      CreateAgentChatMessage(content: event.message!, isUser: false, isProgress: true),
                    ]
                  : [
                      ...current,
                      CreateAgentChatMessage(content: event.message!, isUser: false, isProgress: isProgress),
                    ];
              state = state.copyWith(agentChatMessages: updated);
            }
          },
          onError: (e) {
            state = state.copyWith(
              creationStep: AgentCreationStep.error,
              creationError: e.toString(),
            );
          },
        );
      },
    );
  }

  Future<void> pickModel({required int modelChoice, required String modelName}) async {
    if (state.creationSessionId == null) return;

    state = state.copyWith(
      creationStep: AgentCreationStep.pickingModel,
      agentChatMessages: [
        ...state.agentChatMessages,
        CreateAgentChatMessage(content: 'Selected: $modelName', isUser: true),
      ],
    );

    final body = PickAModelBody(
      session_id: state.creationSessionId,
      model_choice: modelChoice,
    );

    final result = await _repositoryImpl.getMessagesFromSession(body: body);

    result.fold(
      (failure) {
        state = state.copyWith(
          creationStep: AgentCreationStep.error,
          creationError: failure.message,
        );
      },
      (pickAModel) {
        final questions = pickAModel.clarifying_questions ?? [];
        final tools = pickAModel.suggested_tools ?? [];

        if (questions.isEmpty) {
          if (tools.isNotEmpty) {
            state = state.copyWith(
              creationStep: AgentCreationStep.toolSelection,
              pickAModelResult: pickAModel,
              userAnswers: [],
              agentChatMessages: [
                ...state.agentChatMessages,
                const CreateAgentChatMessage(
                  content: 'Choose the tools you want your agent to use. You can skip this step if you prefer none.',
                  isUser: false,
                ),
              ],
            );
          } else {
            state = state.copyWith(
              creationStep: AgentCreationStep.creating,
              pickAModelResult: pickAModel,
              userAnswers: [],
              agentChatMessages: [
                ...state.agentChatMessages,
                const CreateAgentChatMessage(content: 'Creating your agent, please wait...', isUser: false),
              ],
            );
            _createAgentWithAnswers(answers: [], toolChoices: []);
          }
        } else {
          state = state.copyWith(
            creationStep: AgentCreationStep.answering,
            pickAModelResult: pickAModel,
            currentQuestionIndex: 0,
            userAnswers: [],
            agentChatMessages: [
              ...state.agentChatMessages,
              CreateAgentChatMessage(content: questions[0], isUser: false),
            ],
          );
        }
      },
    );
  }

  void submitAnswer({required String answer}) {
    final questions = state.pickAModelResult?.clarifying_questions ?? [];
    final newAnswers = [...state.userAnswers, answer];
    final nextIndex = state.currentQuestionIndex + 1;

    final messagesWithAnswer = [
      ...state.agentChatMessages,
      CreateAgentChatMessage(content: answer, isUser: true),
    ];

    if (nextIndex < questions.length) {
      state = state.copyWith(
        userAnswers: newAnswers,
        currentQuestionIndex: nextIndex,
        agentChatMessages: [
          ...messagesWithAnswer,
          CreateAgentChatMessage(content: questions[nextIndex], isUser: false),
        ],
      );
    } else {
      final tools = state.pickAModelResult?.suggested_tools ?? [];
      if (tools.isNotEmpty) {
        state = state.copyWith(
          userAnswers: newAnswers,
          creationStep: AgentCreationStep.toolSelection,
          agentChatMessages: [
            ...messagesWithAnswer,
            const CreateAgentChatMessage(
              content: 'Choose the tools you want your agent to use. You can skip this step if you prefer none.',
              isUser: false,
            ),
          ],
        );
      } else {
        state = state.copyWith(
          userAnswers: newAnswers,
          creationStep: AgentCreationStep.creating,
          agentChatMessages: [
            ...messagesWithAnswer,
            const CreateAgentChatMessage(content: 'Creating your agent, please wait...', isUser: false),
          ],
        );
        _createAgentWithAnswers(answers: newAnswers, toolChoices: []);
      }
    }
  }

  void confirmToolSelection({required List<String> toolChoices}) {
    final label = toolChoices.isEmpty
        ? 'No tools selected'
        : 'Tools selected: ${toolChoices.join(', ')}';

    state = state.copyWith(
      creationStep: AgentCreationStep.creating,
      agentChatMessages: [
        ...state.agentChatMessages,
        CreateAgentChatMessage(content: label, isUser: true),
        const CreateAgentChatMessage(content: 'Creating your agent, please wait...', isUser: false),
      ],
    );
    _createAgentWithAnswers(answers: state.userAnswers, toolChoices: toolChoices);
  }

  Future<void> _createAgentWithAnswers({
    required List<String> answers,
    required List<String> toolChoices,
  }) async {
    final questions = state.pickAModelResult?.clarifying_questions ?? [];
    final answersMap = <String, String>{
      for (int i = 0; i < answers.length && i < questions.length; i++)
        questions[i]: answers[i],
    };

    final body = AnswerAndCreateModelBody(
      session_id: state.creationSessionId,
      answers: answersMap.isEmpty ? null : answersMap,
      tool_choices: toolChoices.isEmpty ? null : toolChoices,
    );

    final result = await _repositoryImpl.createAndAnswer(body: body);

    result.fold(
      (failure) {
        state = state.copyWith(
          creationStep: AgentCreationStep.error,
          creationError: failure.message,
        );
      },
      (created) {
        state = state.copyWith(
          creationStep: AgentCreationStep.done,
          createdAgent: created,
          agentChatMessages: [
            ...state.agentChatMessages,
            CreateAgentChatMessage(
              content: 'Your agent "${created.name ?? 'Agent'}" has been created successfully!',
              isUser: false,
            ),
          ],
        );
        getAllAgents(forceReplace: true);
      },
    );
  }

  // ─── Agent Actions ────────────────────────────────────────────────────────

  Future<void> deleteAgent({required String agentId}) async {
    final result = await _repositoryImpl.deleteAgent(agentId: agentId);
    result.fold(
      (failure) => failure.checkAndTakeAction(onError: errorMessages),
      (_) {
        final updatedAgents = state.allAgentsList?.agents
                ?.where((a) => a.index?.toString() != agentId)
                .toList() ??
            [];
        state = state.copyWith(
          allAgentsList: AllAgentsList(
            total: (state.allAgentsList?.total ?? 1) - 1,
            agents: updatedAgents,
          ),
        );
      },
    );
  }

  Future<void> addAgentToChat({required String agentName}) async {
    final result = await _repositoryImpl.addAgentFromChat(agentName: agentName);
    result.fold(
      (failure) => failure.checkAndTakeAction(onError: errorMessages),
      (_) {
        final updatedAgents = state.allAgentsList?.agents?.map((a) {
              if (a.name == agentName) {
                return AgentModel(
                  index: a.index, name: a.name, description: a.description,
                  method: a.method, input_format: a.input_format,
                  file_path: a.file_path, synced_at: a.synced_at, active: true,
                );
              }
              return a;
            }).toList() ??
            [];
        state = state.copyWith(
          allAgentsList: AllAgentsList(
            total: state.allAgentsList?.total,
            agents: updatedAgents,
          ),
        );
      },
    );
  }

  Future<void> removeAgentFromChat({required String agentName}) async {
    final result = await _repositoryImpl.deleteAgentFromChat(agentName: agentName);
    result.fold(
      (failure) => failure.checkAndTakeAction(onError: errorMessages),
      (_) {
        final updatedAgents = state.allAgentsList?.agents?.map((a) {
              if (a.name == agentName) {
                return AgentModel(
                  index: a.index, name: a.name, description: a.description,
                  method: a.method, input_format: a.input_format,
                  file_path: a.file_path, synced_at: a.synced_at, active: false,
                );
              }
              return a;
            }).toList() ??
            [];
        state = state.copyWith(
          allAgentsList: AllAgentsList(
            total: state.allAgentsList?.total,
            agents: updatedAgents,
          ),
        );
      },
    );
  }

  Future<void> uploadFile({required File file}) async {
    final result = await _repositoryImpl.uploadFile(file: file);
    result.fold(
      (failure) => failure.checkAndTakeAction(onError: errorMessages),
      (_) {},
    );
  }

  // ─── Chat Screen ──────────────────────────────────────────────────────────

  Future<void> uploadChatAttachment({
    required File file,
    required void Function(bool success) onResult,
  }) async {
    state = state.copyWith(isUploadingFile: true);
    final result = await _repositoryImpl.uploadFile(file: file);
    state = state.copyWith(isUploadingFile: false);
    result.fold(
      (failure) {
        failure.checkAndTakeAction(onError: errorMessages);
        onResult(false);
      },
      (_) => onResult(true),
    );
  }

  Future<void> sendChatMessage({
    required String message,
    String? attachmentName,
    ChatAttachmentType? attachmentType,
  }) async {
    final userMsg = ChatMessageModel(
      text: message.isEmpty ? null : message,
      isUser: true,
      fileName: attachmentName,
      attachmentType: attachmentType,
    );
    const loadingMsg = ChatMessageModel(isUser: false, isLoading: true);

    state = state.copyWith(
      isSendingMessage: true,
      chatMessages: [...state.chatMessages, userMsg, loadingMsg],
    );

    final body = ChatBody(
      session_id: "test",
      message: message.isEmpty ? null : message,
    );

    final result = await _repositoryImpl.getChat(body: body);

    final msgs = List<ChatMessageModel>.from(state.chatMessages)..removeLast();
    result.fold(
      (failure) {
        failure.checkAndTakeAction(onError: errorMessages);
        state = state.copyWith(
          isSendingMessage: false,
          chatMessages: [...msgs, ChatMessageModel(text: 'Failed to get a response.', isUser: false)],
        );
      },
      (chatResponse) {
        state = state.copyWith(
          isSendingMessage: false,
          chatSessionId: chatResponse.session_id ?? state.chatSessionId,
          chatMessages: [...msgs, ChatMessageModel(text: chatResponse.reply, isUser: false)],
        );
      },
    );
  }

  void resetCreationFlow() {
    _chatStreamSubscription?.cancel();
    _chatStreamSubscription = null;
    state = MainState(
      isLoading: state.isLoading,
      isLoadingDetails: state.isLoadingDetails,
      allAgentsList: state.allAgentsList,
      selectedAgentDetails: state.selectedAgentDetails,
    );
  }

  @override
  void dispose() {
    _chatStreamSubscription?.cancel();
    super.dispose();
  }
}

final mainProviderStateProvider = StateNotifierProvider<MainProvider, MainState>(
  (ref) => MainProvider(
    repositoryImpl: ref.watch(repositoryProvider),
  ),
);