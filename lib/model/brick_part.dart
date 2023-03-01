// This file is "main.dart"
import 'package:brick_converter/model/rebrickable_part.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'brick_part.freezed.dart';

// optional: Since our BrickPart class is serializable, we must add this line.
// But if BrickPart was not serializable, we could skip it.
part 'brick_part.g.dart';

@unfreezed
class BrickPart with _$BrickPart {
  // Added constructor. Must not have any parameter
  const BrickPart._();

  factory BrickPart({
    required String part,
    required String color,
    required int quantity,
    required String colorName,
    required String gobricksColor,
    required String bricklinkColor,
    required String? bricklinkId,
    required String rgb,
    required String? goBrickPart,
    required String? name,
    RebrickablePart? details,
  }) = _BrickPart;

  bool get noMapping => goBrickPart == null || goBrickPart?.isEmpty == true;

  factory BrickPart.fromJson(Map<String, Object?> json) => _$BrickPartFromJson(json);
}
