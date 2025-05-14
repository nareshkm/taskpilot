import 'package:hive/hive.dart';
import 'task.dart';
import 'meal_item.dart';
import 'communication_item.dart';
import 'schedule_item.dart';
import 'appointment_item.dart';
import 'expense_item.dart';
import 'note_item.dart';
import 'goal_item.dart';
import 'wellness_item.dart';
/// Hive adapter for [WellnessItem].
class WellnessItemAdapter extends TypeAdapter<WellnessItem> {
  @override
  final int typeId = 10;

  @override
  WellnessItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return WellnessItem(
      id: fields[0] as String,
      date: DateTime.fromMillisecondsSinceEpoch(fields[1] as int),
      productivity: fields[2] as int,
      mood: fields[3] as int,
      health: fields[4] as int,
      fitness: fields[5] as int,
      family: fields[6] as int,
      fun: fields[7] as int,
      spiritual: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WellnessItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(2)
      ..write(obj.productivity)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.health)
      ..writeByte(5)
      ..write(obj.fitness)
      ..writeByte(6)
      ..write(obj.family)
      ..writeByte(7)
      ..write(obj.fun)
      ..writeByte(8)
      ..write(obj.spiritual);
  }
}

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
    final ownerId = fields.containsKey(5) ? fields[5] as String : '';
    return Task(
      id: id,
      title: title,
      completed: completed,
      date: date,
      isRepetitive: isRepetitive,
      ownerId: ownerId,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    // Fields: id(0), title(1), completed(2), date(3), isRepetitive(4), ownerId(5)
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.completed)
      ..writeByte(3)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.isRepetitive)
      ..writeByte(5)
      ..write(obj.ownerId);
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

/// Hive adapter for [CommunicationType] enum.
class CommunicationTypeAdapter extends TypeAdapter<CommunicationType> {
  @override
  final int typeId = 3;

  @override
  CommunicationType read(BinaryReader reader) {
    final index = reader.readByte();
    return CommunicationType.values[index];
  }

  @override
  void write(BinaryWriter writer, CommunicationType obj) {
    writer.writeByte(obj.index);
  }
}

/// Hive adapter for [CommunicationItem].
class CommunicationItemAdapter extends TypeAdapter<CommunicationItem> {
  @override
  final int typeId = 4;

  @override
  CommunicationItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return CommunicationItem(
      id: fields[0] as String,
      type: fields[1] as CommunicationType,
      description: fields[2] as String,
      date: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      completed: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CommunicationItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.completed);
  }
}
 
/// Hive adapter for [ScheduleItem].
class ScheduleItemAdapter extends TypeAdapter<ScheduleItem> {
  @override
  final int typeId = 5;

  @override
  ScheduleItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ScheduleItem(
      id: fields[0] as String,
      start: DateTime.fromMillisecondsSinceEpoch(fields[1] as int),
      end: DateTime.fromMillisecondsSinceEpoch(fields[2] as int),
      title: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.start.millisecondsSinceEpoch)
      ..writeByte(2)
      ..write(obj.end.millisecondsSinceEpoch)
      ..writeByte(3)
      ..write(obj.title);
  }
}

/// Hive adapter for [AppointmentItem].
class AppointmentItemAdapter extends TypeAdapter<AppointmentItem> {
  @override
  final int typeId = 6;

  @override
  AppointmentItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AppointmentItem(
      id: fields[0] as String,
      start: DateTime.fromMillisecondsSinceEpoch(fields[1] as int),
      end: DateTime.fromMillisecondsSinceEpoch(fields[2] as int),
      title: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppointmentItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.start.millisecondsSinceEpoch)
      ..writeByte(2)
      ..write(obj.end.millisecondsSinceEpoch)
      ..writeByte(3)
      ..write(obj.title);
  }
}

/// Hive adapter for [ExpenseItem].
class ExpenseItemAdapter extends TypeAdapter<ExpenseItem> {
  @override
  final int typeId = 7;

  @override
  ExpenseItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ExpenseItem(
      id: fields[0] as String,
      date: DateTime.fromMillisecondsSinceEpoch(fields[1] as int),
      amount: fields[2] as double,
      category: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category);
  }
}

/// Hive adapter for [NoteItem].
class NoteItemAdapter extends TypeAdapter<NoteItem> {
  @override
  final int typeId = 8;

  @override
  NoteItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return NoteItem(
      id: fields[0] as String,
      date: DateTime.fromMillisecondsSinceEpoch(fields[1] as int),
      content: fields[2] as String,
      staffComment: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NoteItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.staffComment);
  }
}

/// Hive adapter for [GoalItem].
class GoalItemAdapter extends TypeAdapter<GoalItem> {
  @override
  final int typeId = 9;

  @override
  GoalItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return GoalItem(
      id: fields[0] as String,
      title: fields[1] as String,
      target: fields[2] as int,
      progress: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GoalItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.target)
      ..writeByte(3)
      ..write(obj.progress);
  }
}