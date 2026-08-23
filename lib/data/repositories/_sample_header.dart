import '../models/models.dart';
import 'exercise_repository.dart';

class SampleExerciseRepository implements ExerciseRepository {
  static const List<TrainingCategory> _strengthCategories = [
    TrainingCategory(
      id: '''strength_upper''',
      name: '''上肢训练''',
      section: WorkoutSection.strength,
      svgIcon: '''arm''',
      subCategories: [
        TrainingCategory(
          id: '''strength_chest''',
          name: '''胸部训练''',
          section: WorkoutSection.strength,
          svgIcon: '''chest''',
          subCategories: [
            TrainingCategory(id: '''chest_upper''', name: '''上胸''', section: WorkoutSection.strength, svgIcon: '''chest_upper'''),
            TrainingCategory(id: '''chest_middle''', name: '''中胸''', section: WorkoutSection.strength, svgIcon: '''chest'''),
            TrainingCategory(id: '''chest_lower''', name: '''下胸''', section: WorkoutSection.strength, svgIcon: '''chest_lower'''),
          ],
        ),
        TrainingCategory(
          id: '''strength_shoulders''',
          name: '''肩部训练''',
          section: WorkoutSection.strength,
          svgIcon: '''shoulder''',
          subCategories: [
            TrainingCategory(id: '''shoulder_front''', name: '''前束''', section: WorkoutSection.strength, svgIcon: '''shoulder_front'''),
            TrainingCategory(id: '''shoulder_mid''', name: '''中束''', section: WorkoutSection.strength, svgIcon: '''shoulder_mid'''),
            TrainingCategory(id: '''shoulder_rear''', name: '''后束''', section: WorkoutSection.strength, svgIcon: '''shoulder_rear'''),
          ],
        ),
        TrainingCategory(
          id: '''strength_back''',
          name: '''背部训练''',
          section: WorkoutSection.strength,
          svgIcon: '''back''',
          subCategories: [
            TrainingCategory(id: '''back_lats''', name: '''背阔肌''', section: WorkoutSection.strength, svgIcon: '''back_lats'''),
            TrainingCategory(id: '''back_traps''', name: '''斜方肌''', section: WorkoutSection.strength, svgIcon: '''back_traps'''),
          ],
        ),
        TrainingCategory(
          id: '''strength_arms''',
          name: '''手臂训练''',
          section: WorkoutSection.strength,
          svgIcon: '''arm''',
          subCategories: [
            TrainingCategory(id: '''arms_biceps''', name: '''肱二头肌''', section: WorkoutSection.strength, svgIcon: '''biceps'''),
            TrainingCategory(id: '''arms_triceps''', name: '''肱三头肌''', section: WorkoutSection.strength, svgIcon: '''triceps'''),
          ],
        ),
      ],
    ),
    TrainingCategory(
      id: '''strength_lower''',
      name: '''下肢训练''',
      section: WorkoutSection.strength,
      svgIcon: '''leg''',
      subCategories: [
        TrainingCategory(id: '''leg_quads''', name: '''股四头肌''', section: WorkoutSection.strength, svgIcon: '''leg_quads'''),
        TrainingCategory(id: '''leg_hamstrings''', name: '''腘绳肌''', section: WorkoutSection.strength, svgIcon: '''leg_hamstrings'''),
        TrainingCategory(id: '''leg_glutes''', name: '''臀部训练''', section: WorkoutSection.strength, svgIcon: '''leg_glutes'''),
        TrainingCategory(id: '''leg_calves''', name: '''小腿训练''', section: WorkoutSection.strength, svgIcon: '''leg'''),
      ],
    ),
    TrainingCategory(
      id: '''strength_core''',
      name: '''核心训练''',
      section: WorkoutSection.strength,
      svgIcon: '''core''',
      subCategories: [
        TrainingCategory(id: '''core_abs''', name: '''腹直肌''', section: WorkoutSection.strength, svgIcon: '''core_abs'''),
        TrainingCategory(id: '''core_obliques''', name: '''腹斜肌''', section: WorkoutSection.strength, svgIcon: '''core_obliques'''),
      ],
    ),
  ];
}
