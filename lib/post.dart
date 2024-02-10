import 'package:hive/hive.dart';
import 'dart:io';

part 'post.g.dart';

@HiveType(typeId: 0)
class PostModel {
  @HiveField(0)
  final String? caption;
  @HiveField(1)
  final String? imagePath;
  @HiveField(2)
  final String? createdAt;

  PostModel({this.caption, this.imagePath, this.createdAt});
}
