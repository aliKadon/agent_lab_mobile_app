import 'package:agent_lab/models/all_agents_list_model.dart';
import 'package:agent_lab/models/chat_message_model.dart';
import 'package:agent_lab/models/create_agent_chat_message.dart';
import 'package:agent_lab/models/create_agents/answer_and_create_model.dart';
import 'package:agent_lab/models/create_agents/pick_a_model.dart';
import 'package:agent_lab/models/get_agnts_details_with_code_source_model.dart';
import 'package:agent_lab/utils/constants/app_enums.dart';

class MainState {
  bool isLoading;
  bool isLoadingDetails;
  AllAgentsList? allAgentsList;
  GetAgentsDetailsWithCodeSource? selectedAgentDetails;

  // Chat screen
  bool isSendingMessage;
  bool isUploadingFile;
  List<ChatMessageModel> chatMessages;
  String? chatSessionId;

  // Agent creation flow
  AgentCreationStep creationStep;
  List<CreateAgentChatMessage> agentChatMessages;
  String? creationSessionId;
  List<dynamic> availableModels;
  PickAModel? pickAModelResult;
  int currentQuestionIndex;
  List<String> userAnswers;
  AnswerAndCreateModel? createdAgent;
  String? creationError;

  MainState({
    this.isLoading = false,
    this.isLoadingDetails = false,
    this.allAgentsList,
    this.selectedAgentDetails,
    this.isSendingMessage = false,
    this.isUploadingFile = false,
    List<ChatMessageModel>? chatMessages,
    this.chatSessionId,
    this.creationStep = AgentCreationStep.idle,
    List<CreateAgentChatMessage>? agentChatMessages,
    this.creationSessionId,
    List<dynamic>? availableModels,
    this.pickAModelResult,
    this.currentQuestionIndex = 0,
    List<String>? userAnswers,
    this.createdAgent,
    this.creationError,
  })  : chatMessages = chatMessages ?? [],
        agentChatMessages = agentChatMessages ?? [],
        availableModels = availableModels ?? [],
        userAnswers = userAnswers ?? [];

  MainState copyWith({
    bool? isLoading,
    bool? isLoadingDetails,
    AllAgentsList? allAgentsList,
    GetAgentsDetailsWithCodeSource? selectedAgentDetails,
    bool? isSendingMessage,
    bool? isUploadingFile,
    List<ChatMessageModel>? chatMessages,
    String? chatSessionId,
    AgentCreationStep? creationStep,
    List<CreateAgentChatMessage>? agentChatMessages,
    String? creationSessionId,
    List<dynamic>? availableModels,
    PickAModel? pickAModelResult,
    int? currentQuestionIndex,
    List<String>? userAnswers,
    AnswerAndCreateModel? createdAgent,
    String? creationError,
  }) {
    return MainState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      allAgentsList: allAgentsList ?? this.allAgentsList,
      selectedAgentDetails: selectedAgentDetails ?? this.selectedAgentDetails,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      isUploadingFile: isUploadingFile ?? this.isUploadingFile,
      chatMessages: chatMessages ?? this.chatMessages,
      chatSessionId: chatSessionId ?? this.chatSessionId,
      creationStep: creationStep ?? this.creationStep,
      agentChatMessages: agentChatMessages ?? this.agentChatMessages,
      creationSessionId: creationSessionId ?? this.creationSessionId,
      availableModels: availableModels ?? this.availableModels,
      pickAModelResult: pickAModelResult ?? this.pickAModelResult,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      createdAgent: createdAgent ?? this.createdAgent,
      creationError: creationError ?? this.creationError,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isLoading': isLoading,
      'isLoadingDetails': isLoadingDetails,
      'allAgentsList': allAgentsList,
      'selectedAgentDetails': selectedAgentDetails,
    };
  }
}