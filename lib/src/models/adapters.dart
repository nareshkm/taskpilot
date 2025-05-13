import 'package:hive/hive.dart';
import 'task.dart';
import 'meal_item.dart';

/// Hive adapter for [Task].
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    // Read mandatory fields
    final id = fields[0] as String;
    final title = fields[1] as String;
    final completed = fields[2] as bool;
    // Optional new fields
    final dateMillis = fields.containsKey(3)
        ? fields[3] as int
        : DateTime.now().millisecondsSinceEpoch;
    final date = DateTime.fromMillisecondsSinceEpoch(dateMillis);
    final isRepetitive = fields.containsKey(4) ? fields[4] as bool : false;
    return Task(
      id: id,
      title: title,
      completed: completed,
      date: date,
      isRepetitive: isRepetitive,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    // Total fields: id(0), title(1), completed(2), date(3), isRepetitive(4)
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.completed)
      ..writeByte(3)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.isRepetitive);
  }
}

/// Hive adapter for [MealType] enum.
class MealTypeAdapter extends TypeAdapter<MealType> {
  @override
  final int typeId = 1;

  @override
  MealType read(BinaryReader reader) {
    final index = reader.readByte();
    return MealType.values[index];
  }

  @override
  void write(BinaryWriter writer, MealType obj) {
    writer.writeByte(obj.index);
  }
}

/// Hive adapter for [MealItem].
class MealItemAdapter extends TypeAdapter<MealItem> {
  @override
  final int typeId = 2;

  @override
  MealItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return MealItem(
      id: fields[0] as String,
      type: fields[1] as MealType,
      description: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MealItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.description);
  }
}