class SearchProgressEvent {
  final String status;      // planning | searching | analyzing | progress | ranking | done | error
  final String? message;
  final String? sessionId;  // only on status == 'done'
  final List<dynamic>? models; // only on status == 'done'
  final int? code;          // only on status == 'error'

  SearchProgressEvent({
    required this.status,
    this.message,
    this.sessionId,
    this.models,
    this.code,
  });

  factory SearchProgressEvent.fromJson(Map<String, dynamic> json) {
    return SearchProgressEvent(
      status:    json['status']     as String,
      message:   json['message']    as String?,
      sessionId: json['session_id'] as String?,
      models:    json['models']     as List<dynamic>?,
      code:      json['code']       as int?,
    );
  }
}