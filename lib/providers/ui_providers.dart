import 'package:hooks_riverpod/legacy.dart';

/// Index of the selected bottom-navigation tab (0 = Agents, 1 = Chat).
final navIndexProvider = StateProvider<int>((ref) => 0);
