import '../models/models.dart';

/// 训练动作数据仓库接口
/// 后续可替换为远程 API 或本地数据库实现
abstract class ExerciseRepository {
  List<WorkoutSection> getSections();
  List<TrainingCategory> getCategories(WorkoutSection section);
  List<Exercise> getExercises(String categoryId);
  List<Exercise> searchExercises(String query);
  Exercise? getExerciseById(String id);
}
