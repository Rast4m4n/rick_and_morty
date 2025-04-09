// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'info_model.g.dart';

@JsonSerializable()
class InfoModel {
  InfoModel({required this.count, required this.pages, this.next, this.prev});

  final int count;
  final int pages;
  final String? next;
  final String? prev;

  factory InfoModel.fromJson(Map<String, dynamic> json) =>
      _$InfoModelFromJson(json);

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => _$InfoModelToJson(this);

  factory InfoModel.fromMap(Map<String, dynamic> map) {
    return InfoModel(
      count: map['count'] as int,
      pages: map['pages'] as int,
      next: map['next'] != null ? map['next'] as String : null,
      prev: map['prev'] != null ? map['prev'] as String : null,
    );
  }
}
