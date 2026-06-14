import 'package:agent_lab/models/all_agents_list_model.dart';
import 'package:agent_lab/providers/main_provider.dart';
import 'package:agent_lab/screens/agent_details_screen.dart';
import 'package:agent_lab/screens/create_agent_screen.dart';
import 'package:agent_lab/utils/constants/pallete.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mainProviderStateProvider.notifier).getAllAgents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainProviderStateProvider);
    final agents = state.allAgentsList?.agents ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agents'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateAgentScreen()),
        ),
        backgroundColor: Pallete.primary,
        icon: const Icon(Icons.add, color: Pallete.white),
        label: const Text(
          'Create Agent',
          style: TextStyle(color: Pallete.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : agents.isEmpty
              ? const Center(child: Text('No agents found'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: agents.length,
                  itemBuilder: (context, index) {
                    return _AgentCard(agent: agents[index]);
                  },
                ),
    );
  }
}

class _AgentCard extends ConsumerStatefulWidget {
  final AgentModel agent;

  const _AgentCard({required this.agent});

  @override
  ConsumerState<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends ConsumerState<_AgentCard> {
  bool _isLoading = false;

  Future<void> _handleDelete(BuildContext context) async {
    if (widget.agent.index == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Pallete.grey19,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Agent', style: TextStyle(color: Pallete.white, fontSize: 16)),
        content: Text(
          'Delete "${widget.agent.name ?? 'this agent'}"? This cannot be undone.',
          style: const TextStyle(color: Pallete.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Pallete.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isLoading = true);
    await ref.read(mainProviderStateProvider.notifier).deleteAgent(
          agentId: widget.agent.index!.toString(),
        );
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleToggleChat() async {
    if (widget.agent.name == null) return;
    setState(() => _isLoading = true);
    final notifier = ref.read(mainProviderStateProvider.notifier);
    if (widget.agent.active == true) {
      await notifier.removeAgentFromChat(agentName: widget.agent.name!);
    } else {
      await notifier.addAgentToChat(agentName: widget.agent.name!);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Pallete.grey19,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isLoading
            ? null
            : () {
                if (widget.agent.index == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AgentDetailsScreen(
                      agentId: widget.agent.index!.toString(),
                      agentName: widget.agent.name ?? 'Agent',
                    ),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Pallete.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.smart_toy_outlined, color: Pallete.primary, size: 22),
                  ),
                  const Spacer(),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: Pallete.primary),
                      ),
                    )
                  else
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert, size: 16, color: Pallete.grey),
                        color: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onSelected: (value) {
                          if (value == 'chat') _handleToggleChat();
                          if (value == 'delete') _handleDelete(context);
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'chat',
                            child: Row(
                              children: [
                                Icon(
                                  widget.agent.active == true
                                      ? Icons.chat_bubble_outline
                                      : Icons.add_comment_outlined,
                                  size: 15,
                                  color: widget.agent.active == true ? Colors.orange : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.agent.active == true ? 'Remove from Chat' : 'Add to Chat',
                                  style: const TextStyle(fontSize: 13, color: Pallete.white),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: const [
                                Icon(Icons.delete_outline_rounded, size: 15, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.agent.name ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Pallete.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.agent.active == true ? Colors.green : Pallete.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.agent.active == true ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.agent.active == true ? Colors.green : Pallete.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}