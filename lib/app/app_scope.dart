import 'package:flutter/widgets.dart';

import 'package:excise/data/repositories/body_stats_repository.dart';
import 'package:excise/data/repositories/custom_plan_repository.dart';
import 'package:excise/data/repositories/local_repositories.dart';
import 'package:excise/data/repositories/workout_repository.dart';

/// 应用级依赖。main() 里一次性初始化，页面通过 AppScope 读取。
class AppServices {
  final WorkoutRepository workouts;
  final LocalFavoriteRepository favorites;
  final LocalCustomPlanRepository plans;
  final BodyStatsRepository bodyStats;

  const AppServices({
    required this.workouts,
    required this.favorites,
    required this.plans,
    required this.bodyStats,
  });

  static Future<AppServices> create() async {
    final workouts = WorkoutRepository();
    final favorites = LocalFavoriteRepository();
    final plans = LocalCustomPlanRepository();
    final bodyStats = BodyStatsRepository();
    await Future.wait([
      favorites.init(),
      plans.init(),
      bodyStats.init(),
    ]);
    // 先修旧历史里的重复 ID，再让 v2 仓库一次性导入，避免 10053–10061 串到肩部。
    await LocalTrainingHistoryRepository().init();
    await workouts.init();
    return AppServices(
      workouts: workouts,
      favorites: favorites,
      plans: plans,
      bodyStats: bodyStats,
    );
  }
}

class AppScope extends InheritedWidget {
  final AppServices services;

  const AppScope({super.key, required this.services, required super.child});

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.services;
  }

  static AppServices? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()?.services;

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
