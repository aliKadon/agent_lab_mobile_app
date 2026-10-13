// Screen-level smoke tests for the redesigned UI.
//
// Each test renders a screen against a fixed, realistic MainState (no network)
// and asserts the key UI is present. Run with `--update-goldens` to also write
// screenshots to test/goldens/ for visual review.

import 'dart:io';

import 'package:agent_lab/models/all_agents_list_model.dart';
import 'package:agent_lab/models/chat_message_model.dart';
import 'package:agent_lab/models/create_agent_chat_message.dart';
import 'package:agent_lab/models/create_agents/answer_and_create_model.dart';
import 'package:agent_lab/models/get_agnts_details_with_code_source_model.dart';
import 'package:agent_lab/providers/main_provider.dart';
import 'package:agent_lab/providers/states/main_state.dart';
import 'package:agent_lab/providers/ui_providers.dart';
import 'package:agent_lab/screens/agent_details_screen.dart';
import 'package:agent_lab/screens/create_agent_screen.dart';
import 'package:agent_lab/screens/main_nav_screen.dart';
import 'package:agent_lab/utils/constants/app_enums.dart';
import 'package:agent_lab/utils/theme/theme.dart';
import 'package:agent_lab/common/widgets/ui/app_snack.dart';
import 'package:agent_lab/providers/common_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// MainProvider with a fixed state and no-op network calls.
class _FakeMainProvider extends MainProvider {
  _FakeMainProvider(MainState initial, {required super.repositoryImpl}) {
    state = initial;
  }

  @override
  Future<void> getAllAgents({bool forceReplace = false}) async {}

  @override
  Future<void> getAgentDetails({required String agentId}) async {}

  @override
  void resetCreationFlow() {}
}

final _agents = [
  AgentModel(
    index: 1,
    name: 'pdf_summarizer',
    description: 'Summarizes long PDF documents into concise bullet points with key takeaways.',
    method: 'summarization',
    input_format: 'pdf',
    active: true,
  ),
  AgentModel(
    index: 2,
    name: 'AudioTranscriber',
    description: 'Transcribes audio recordings into clean, punctuated text.',
    method: 'speech-to-text',
    input_format: 'audio',
    active: true,
  ),
  AgentModel(
    index: 3,
    name: 'review-sentiment',
    description: 'Classifies customer reviews as positive, negative or neutral.',
    method: 'text-classification',
    input_format: 'text',
    active: false,
  ),
  AgentModel(
    index: 4,
    name: 'image captioner',
    description: 'Describes images in detail for accessibility.',
    method: 'image-to-text',
    input_format: 'image',
    active: false,
  ),
];

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'] ?? '/Users/alikadon/development/flutter';
  final dir = '$root/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final file = File('$dir/$f');
      if (file.existsSync()) {
        loader.addFont(Future.value(ByteData.view(file.readAsBytesSync().buffer)));
      }
    }
    await loader.load();
  }

  await load('Roboto', ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf', 'Roboto-Italic.ttf']);
  await load('MaterialIcons', ['MaterialIcons-Regular.otf']);
}

ThemeData _testTheme() {
  final theme = AppTheme.dark();
  // The test engine defaults to a placeholder font; use real Roboto for readable screenshots.
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
    primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'Roboto'),
  );
}

Future<void> _pumpScreen(
  WidgetTester tester,
  MainState state, {
  Widget home = const MainNavScreen(),
  int tab = 0,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mainProviderStateProvider.overrideWith(
          (ref) => _FakeMainProvider(state, repositoryImpl: ref.watch(repositoryProvider)),
        ),
        navIndexProvider.overrideWith((ref) => tab),
      ],
      child: MaterialApp(
        theme: _testTheme(),
        scaffoldMessengerKey: rootMessengerKey,
        debugShowCheckedModeBanner: false,
        home: home,
      ),
    ),
  );
  // Let entrance animations and staggered delays finish (repeating ones keep going).
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _snapshot(WidgetTester tester, String name) async {
  if (autoUpdateGoldenFiles) {
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
  }
  // Unmount so repeating animations don't leave pending timers.
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('Agents home shows stats, search and agent cards', (tester) async {
    await _pumpScreen(tester, MainState(allAgentsList: AllAgentsList(total: 4, agents: _agents)));

    expect(find.text('Your agent lab'), findsOneWidget);
    expect(find.text('pdf_summarizer'), findsOneWidget);
    expect(find.text('Search agents'), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);
    await _snapshot(tester, 'home');
  });

  testWidgets('In-chat stat tile filters the list', (tester) async {
    await _pumpScreen(tester, MainState(allAgentsList: AllAgentsList(total: 4, agents: _agents)));

    await tester.tap(find.text('In chat').first);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('review-sentiment'), findsNothing);
    expect(find.text('pdf_summarizer'), findsOneWidget);
    await _snapshot(tester, 'home_filtered');
  });

  testWidgets('Empty lab invites the user to create an agent', (tester) async {
    await _pumpScreen(tester, MainState(allAgentsList: AllAgentsList(total: 0, agents: [])));

    expect(find.text('Create your first agent'), findsOneWidget);
    await _snapshot(tester, 'home_empty');
  });

  testWidgets('Empty chat shows ready agents and suggestions', (tester) async {
    await _pumpScreen(tester, MainState(allAgentsList: AllAgentsList(total: 4, agents: _agents)), tab: 1);

    expect(find.text('2 agents listening'), findsOneWidget);
    expect(find.text('Summarize'), findsOneWidget);
    await _snapshot(tester, 'chat_empty');
  });

  testWidgets('Chat with no active agents asks to invite some', (tester) async {
    final idle = _agents.map((a) => AgentModel(index: a.index, name: a.name, description: a.description, active: false)).toList();
    await _pumpScreen(tester, MainState(allAgentsList: AllAgentsList(total: 4, agents: idle)), tab: 1);

    expect(find.text('Invite agents to the chat'), findsOneWidget);
    await _snapshot(tester, 'chat_no_agents');
  });

  testWidgets('Chat conversation renders markdown, attachments, errors and retry', (tester) async {
    await _pumpScreen(
      tester,
      MainState(
        allAgentsList: AllAgentsList(total: 4, agents: _agents),
        chatMessages: const [
          ChatMessageModel(
            isUser: true,
            text: 'Summarize this report for me',
            fileName: 'Q3-financial-report.pdf',
            attachmentType: ChatAttachmentType.document,
          ),
          ChatMessageModel(
            isUser: false,
            text: '## Q3 at a glance\n\n- **Revenue** grew **18%** year over year\n- Operating margin improved to *24%*\n- Two new markets launched\n\nWant me to compare it with Q2?',
          ),
          ChatMessageModel(isUser: true, text: 'Yes, and transcribe the earnings call too'),
          ChatMessageModel(isUser: false, text: 'Connection timed out', isError: true),
        ],
      ),
      tab: 1,
    );

    expect(find.text('Q3-financial-report.pdf'), findsOneWidget);
    expect(find.text('Message not delivered'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    await _snapshot(tester, 'chat_conversation');
  });

  testWidgets('Create agent intro shows step tracker and templates', (tester) async {
    await _pumpScreen(tester, MainState(), home: const CreateAgentScreen());

    expect(find.text('Describe'), findsOneWidget);
    expect(find.text('PDF summarizer'), findsOneWidget);
    await tester.tap(find.text('Translator'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('English and Arabic'), findsWidgets);
    await _snapshot(tester, 'create_intro');
  });

  testWidgets('Create agent groups streamed events into a live activity card', (tester) async {
    await _pumpScreen(
      tester,
      MainState(
        creationStep: AgentCreationStep.streaming,
        agentChatMessages: const [
          CreateAgentChatMessage(content: 'An agent that summarizes legal contracts and flags risky clauses', isUser: true),
          CreateAgentChatMessage(content: 'Planning the search strategy', isUser: false, isActivity: true),
          CreateAgentChatMessage(content: 'Searching Hugging Face for summarization models', isUser: false, isActivity: true),
          CreateAgentChatMessage(content: 'Analyzing 42 candidates…', isUser: false, isActivity: true, isProgress: true),
        ],
      ),
      home: const CreateAgentScreen(),
    );

    expect(find.text('Working on it'), findsOneWidget);
    expect(find.text('3 steps'), findsOneWidget);
    await _snapshot(tester, 'create_streaming');
  });

  testWidgets('Create agent model picker requires a selection', (tester) async {
    await _pumpScreen(
      tester,
      MainState(
        creationStep: AgentCreationStep.modelSelection,
        creationSessionId: 's1',
        availableModels: [
          {'index': 0, 'name': 'facebook/bart-large-cnn', 'provider': 'hf-inference', 'license': 'mit'},
          {'index': 1, 'name': 'google/pegasus-xsum', 'provider': 'hf-inference', 'license': 'apache-2.0'},
          {'index': 2, 'name': 'meta-llama/Llama-3.1-8B', 'provider': 'together', 'gated': true},
        ],
        agentChatMessages: const [
          CreateAgentChatMessage(content: 'An agent that summarizes legal contracts', isUser: true),
          CreateAgentChatMessage(content: 'Planning the search strategy', isUser: false, isActivity: true),
          CreateAgentChatMessage(content: 'Ranking 3 models', isUser: false, isActivity: true),
          CreateAgentChatMessage(content: 'Found 3 models for your agent. Please select one below.', isUser: false),
        ],
      ),
      home: const CreateAgentScreen(),
    );

    expect(find.text('Best match'), findsOneWidget);
    expect(find.text('Select a model to continue'), findsOneWidget);
    await tester.tap(find.text('google/pegasus-xsum'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Use google/pegasus-xsum'), findsOneWidget);
    await _snapshot(tester, 'create_models');
  });

  testWidgets('Create agent done state offers to add the agent to chat', (tester) async {
    await _pumpScreen(
      tester,
      MainState(
        creationStep: AgentCreationStep.done,
        createdAgent: AnswerAndCreateModel(name: 'contract_reviewer'),
        agentChatMessages: const [
          CreateAgentChatMessage(content: 'An agent that summarizes legal contracts', isUser: true),
          CreateAgentChatMessage(content: 'Your agent "contract_reviewer" has been created successfully!', isUser: false),
        ],
      ),
      home: const CreateAgentScreen(),
    );

    expect(find.text('contract_reviewer is ready'), findsOneWidget);
    expect(find.text('Add to chat & start'), findsOneWidget);
    await _snapshot(tester, 'create_done');
  });

  testWidgets('Agent details shows hero, specs and source code', (tester) async {
    await _pumpScreen(
      tester,
      MainState(
        allAgentsList: AllAgentsList(total: 4, agents: _agents),
        selectedAgentDetails: GetAgentsDetailsWithCodeSource(
          index: 1,
          name: 'pdf_summarizer',
          description: 'Summarizes long PDF documents into concise bullet points with key takeaways.',
          method: 'summarization',
          input_format: 'pdf',
          file_path: 'agents/pdf_summarizer.py',
          synced_at: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
          active: true,
          source_code: List.generate(24, (i) => i == 0 ? 'from transformers import pipeline' : '    step_$i = run(step_${i - 1})').join('\n'),
        ),
      ),
      home: const AgentDetailsScreen(agentId: '1', agentName: 'pdf_summarizer'),
    );

    expect(find.text('Open chat'), findsOneWidget);
    expect(find.text('3 h ago'), findsOneWidget);
    expect(find.text('Show all 24 lines'), findsOneWidget);
    await _snapshot(tester, 'details');
  });
}
