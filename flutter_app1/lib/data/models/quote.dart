import 'package:objectbox/objectbox.dart';

@Entity()
class QuoteSource {
  @Id()
  int id = 0;

  String name; // 來源名稱 (例如檔名)
  bool isEnabled; // 是否啟用
  DateTime importedAt; // 匯入時間

  @Backlink('source')
  final quotes = ToMany<Quote>();

  QuoteSource({
    required this.name,
    this.isEnabled = true,
    required this.importedAt,
  });
}

@Entity()
class Quote {
  @Id()
  int id = 0;

  @Index()
  String category; // 對應 Mood 的 name (happy, sad...)

  String content;
  String? author;

  final source = ToOne<QuoteSource>();

  Quote({
    required this.content,
    required this.category,
    this.author,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'category': category,
        'author': author,
      };
}