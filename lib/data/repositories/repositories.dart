import '../models/models.dart';

/// 收藏仓库接口
abstract class FavoriteRepository {
  List<Exercise> getFavorites(List<Exercise> allExercises);
  void toggleFavorite(Exercise exercise);
  bool isFavorite(Exercise exercise);
}

/// 训练历史仓库接口
abstract class TrainingHistoryRepository {
  List<TrainingSession> getHistory();
  void addSession(TrainingSession session);
  void clearHistory();
}

/// 自定义计划仓库接口
abstract class CustomPlanRepository {
  List<CustomPlan> getPlans();
  CustomPlan? getPlan(String id);
  Future<void> savePlan(CustomPlan plan);
  Future<void> deletePlan(String id);
  Future<void> duplicatePlan(CustomPlan plan);
}