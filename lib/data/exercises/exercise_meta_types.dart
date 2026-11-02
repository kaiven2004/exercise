/// 动作的器械类型与派生属性。
///
/// 具体取值放在 exercise_meta_table.dart，这里只定义类型。
enum Equipment {
  barbell,
  dumbbell,
  kettlebell,
  machine,
  cable,
  band,
  bodyweight,
  other,
}

extension EquipmentLabel on Equipment {
  String get label {
    switch (this) {
      case Equipment.barbell:
        return '杠铃';
      case Equipment.dumbbell:
        return '哑铃';
      case Equipment.kettlebell:
        return '壶铃';
      case Equipment.machine:
        return '器械';
      case Equipment.cable:
        return '绳索';
      case Equipment.band:
        return '弹力带';
      case Equipment.bodyweight:
        return '自重';
      case Equipment.other:
        return '其他';
    }
  }
}

/// 动作的派生属性。
class ExerciseMeta {
  final Equipment equipment;
  final bool compound;
  final String primaryMuscle;

  const ExerciseMeta({
    required this.equipment,
    required this.compound,
    required this.primaryMuscle,
  });

  @override
  String toString() =>
      'ExerciseMeta(equipment: ${equipment.name}, compound: $compound, primaryMuscle: $primaryMuscle)';
}
