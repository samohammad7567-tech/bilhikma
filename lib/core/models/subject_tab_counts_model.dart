import '../network/json_reader.dart';

class SubjectTabCountsModel {
  const SubjectTabCountsModel({
    this.videos = 0,
    this.audios = 0,
    this.articles = 0,
    this.albums = 0,
    this.liveSessions = 0,
    this.textbooks = 0,
  });

  final int videos;
  final int audios;
  final int articles;
  final int albums;
  final int liveSessions;
  final int textbooks;

  int get total =>
      videos + audios + articles + albums + liveSessions + textbooks;

  bool get isEmpty => total == 0;

  factory SubjectTabCountsModel.fromJson(Map<String, dynamic> json) =>
      SubjectTabCountsModel(
        videos: Json.asInt(json['videos']),
        audios: Json.asInt(json['audios']),
        articles: Json.asInt(json['articles']),
        albums: Json.asInt(json['albums']),
        liveSessions: Json.asInt(json['live_sessions']),
        textbooks: Json.asInt(json['textbooks']),
      );
}
