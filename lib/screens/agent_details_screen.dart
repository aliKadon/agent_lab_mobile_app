import 'package:agent_lab/models/get_agnts_details_with_code_source_model.dart';
import 'package:agent_lab/providers/main_provider.dart';
import 'package:agent_lab/utils/constants/pallete.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AgentDetailsScreen extends ConsumerStatefulWidget {
  final String agentId;
  final String agentName;

  const AgentDetailsScreen({
    super.key,
    required this.agentId,
    required this.agentName,
  });

  @override
  ConsumerState<AgentDetailsScreen> createState() => _AgentDetailsScreenState();
}

class _AgentDetailsScreenState extends ConsumerState<AgentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mainProviderStateProvider.notifier).getAgentDetails(agentId: widget.agentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainProviderStateProvider);
    final details = state.selectedAgentDetails;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.agentName),
      ),
      body: state.isLoadingDetails
          ? const Center(child: CircularProgressIndicator())
          : details == null
              ? const Center(child: Text('No details available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(details),
                      const SizedBox(height: 20),
                      _buildDetailsCard(details),
                      if (details.source_code != null && details.source_code!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSourceCodeCard(details.source_code!),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(GetAgentsDetailsWithCodeSource details) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Pallete.lighterPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.smart_toy_outlined, color: Pallete.primary, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.name ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: details.active == true ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    details.active == true ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 13,
                      color: details.active == true ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(GetAgentsDetailsWithCodeSource details) {
    return Card(
      color: Pallete.grey19,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Description', value: details.description),
            _DetailRow(label: 'Method', value: details.method),
            _DetailRow(label: 'Input Format', value: details.input_format),
            _DetailRow(label: 'File Path', value: details.file_path),
            _DetailRow(label: 'Synced At', value: details.synced_at),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCodeCard(String sourceCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Source Code',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Pallete.darkGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              sourceCode,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Pallete.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const _DetailRow({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Pallete.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value!, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}