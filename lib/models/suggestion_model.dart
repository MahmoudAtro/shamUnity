class SuggestionModel {
  final String type;
  final String content;

  SuggestionModel({
    required this.type,
    required this.content,
  });

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      type: json['type'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
    };
  }
}
