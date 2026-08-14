import '../models/models.dart';
import 'exercise_repository.dart';

class SampleExerciseRepository implements ExerciseRepository {
  static const List<TrainingCategory> _strengthCategories = [
    TrainingCategory(
      id: 'strength_upper',
      name: '上肢训练',
      section: WorkoutSection.strength,
      svgIcon: 'arm',
      subCategories: [
        TrainingCategory(
          id: 'strength_chest',
          name: '胸部训练',
          section: WorkoutSection.strength,
          svgIcon: 'chest',
          subCategories: [
            TrainingCategory(id: 'chest_upper', name: '上胸', section: WorkoutSection.strength, svgIcon: 'chest_upper'),
            TrainingCategory(id: 'chest_middle', name: '中胸', section: WorkoutSection.strength, svgIcon: 'chest'),
            TrainingCategory(id: 'chest_lower', name: '下胸', section: WorkoutSection.strength, svgIcon: 'chest_lower'),
          ],
        ),
        TrainingCategory(
          id: 'strength_shoulders',
          name: '肩部训练',
          section: WorkoutSection.strength,
          svgIcon: 'shoulder',
          subCategories: [
            TrainingCategory(id: 'shoulder_front', name: '前束', section: WorkoutSection.strength, svgIcon: 'shoulder_front'),
            TrainingCategory(id: 'shoulder_mid', name: '中束', section: WorkoutSection.strength, svgIcon: 'shoulder_mid'),
            TrainingCategory(id: 'shoulder_rear', name: '后束', section: WorkoutSection.strength, svgIcon: 'shoulder_rear'),
            TrainingCategory(id: 'shoulder_rotator', name: '肩袖肌群', section: WorkoutSection.strength, svgIcon: 'shoulder_rotator'),
          ],
        ),
        TrainingCategory(
          id: 'strength_back',
          name: '背部训练',
          section: WorkoutSection.strength,
          svgIcon: 'back',
          subCategories: [
            TrainingCategory(id: 'back_lats', name: '背阔肌', section: WorkoutSection.strength, svgIcon: 'back_lats'),
            TrainingCategory(id: 'back_upper', name: '上背厚度', section: WorkoutSection.strength, svgIcon: 'back_upper'),
            TrainingCategory(id: 'back_traps_lower', name: '斜方下束', section: WorkoutSection.strength, svgIcon: 'back_traps_lower'),
            TrainingCategory(id: 'back_lower', name: '下背/竖脊肌', section: WorkoutSection.strength, svgIcon: 'back_lower'),
          ],
        ),
        TrainingCategory(
          id: 'strength_arms',
          name: '手臂训练',
          section: WorkoutSection.strength,
          svgIcon: 'arm',
          subCategories: [
            TrainingCategory(id: 'arms_biceps', name: '肱二头肌', section: WorkoutSection.strength, svgIcon: 'biceps'),
            TrainingCategory(id: 'arms_triceps', name: '肱三头肌', section: WorkoutSection.strength, svgIcon: 'triceps'),
            TrainingCategory(id: 'arms_forearm', name: '前臂', section: WorkoutSection.strength, svgIcon: 'forearm'),
          ],
        ),
      ],
    ),
    TrainingCategory(
      id: 'strength_lower',
      name: '下肢训练',
      section: WorkoutSection.strength,
      svgIcon: 'leg',
      subCategories: [
        TrainingCategory(id: 'leg_quads', name: '股四头肌', section: WorkoutSection.strength, svgIcon: 'leg_quads'),
        TrainingCategory(id: 'leg_hamstrings', name: '腘绳肌', section: WorkoutSection.strength, svgIcon: 'leg_hamstrings'),
        TrainingCategory(id: 'leg_glutes', name: '臀部训练', section: WorkoutSection.strength, svgIcon: 'leg_glutes'),
        TrainingCategory(id: 'leg_calves', name: '小腿训练', section: WorkoutSection.strength, svgIcon: 'leg'),
      ],
    ),
    TrainingCategory(
      id: 'strength_core',
      name: '核心训练',
      section: WorkoutSection.strength,
      svgIcon: 'core',
      subCategories: [
        TrainingCategory(id: 'core_abs', name: '腹直肌', section: WorkoutSection.strength, svgIcon: 'core_abs'),
        TrainingCategory(id: 'core_obliques', name: '腹斜肌', section: WorkoutSection.strength, svgIcon: 'core_obliques'),
      ],
    ),
  ];























  static const List<TrainingCategory> _functionalCategories = [
    TrainingCategory(id: 'func_core', name: '核心稳定', section: WorkoutSection.functional, svgIcon: 'core', subCategories: []),
    TrainingCategory(id: 'func_balance', name: '平衡训练', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
    TrainingCategory(id: 'func_agility', name: '灵敏训练', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
  ];

  static const List<TrainingCategory> _yogaCategories = [
    TrainingCategory(id: 'yoga_hatha', name: '哈他瑜伽', section: WorkoutSection.yoga, svgIcon: 'yoga_hatha', subCategories: []),
    TrainingCategory(id: 'yoga_vinyasa', name: '流瑜伽', section: WorkoutSection.yoga, svgIcon: 'yoga_vinyasa', subCategories: []),
    TrainingCategory(id: 'yoga_ashtanga', name: '阿斯汤加', section: WorkoutSection.yoga, svgIcon: 'yoga_ashtanga', subCategories: []),
    TrainingCategory(id: 'yoga_restorative', name: '恢复瑜伽', section: WorkoutSection.yoga, svgIcon: 'yoga_restorative', subCategories: []),
  ];


  static const List<Exercise> _exercises = [
    Exercise(id: '10001', name: '上斜杠铃卧推（30-35度）', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '角度：凳30-35度，不要调太陡。要点：杠铃落在锁骨/上胸位置，而不是中下胸乳头；手肘45度外展，不要贴身体也不要大开90度；起杠垂直推向上胸正上方。特点：大重量复合，整体上胸厚度，力量基础，上胸第一代表性动作。', tips: ['凳调至30-35度','杠铃落在锁骨/上胸位置','手肘45度外展','垂直推向上胸正上方'], sets: 4, reps: 8, restSeconds: '60', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10002', name: '窄距上斜杠铃卧推', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '握距略窄于常规卧推，依然30-35度凳。特点：缩短力臂，减少肩膀压力，增加上胸内侧刺激，适合大重量肩膀不舒服时备选。', tips: ['握距略窄于常规卧推','凳保持30-35度','减少肩膀压力','增加上胸内侧刺激'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10003', name: '上斜哑铃卧推（30-35度）', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '要点：哑铃下放要低于肩，充分拉开上胸，底部感受上胸拉伸；顶峰不要完全锁死肘关节，保持肌肉张力。对比杠铃：左右独立，纠正力量不对称，上胸拉伸感强，是仅次于杠铃上斜的主力动作。', tips: ['凳调至30-35度','哑铃下放低于肩','底部充分拉伸上胸','顶峰不完全锁死肘关节'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10004', name: '高角度上斜哑铃卧推（45度）', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '凳子调到45度，重量要降一档，前束参与会变多。用途：专门针对锁骨最上端的上胸，不适合大重量，适合中等重量增肌。', tips: ['凳调至45度','重量降一档','针对锁骨最上端上胸','中等重量增肌'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10005', name: '上斜哑铃飞鸟（30度）', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '手肘微弯固定角度，不要屈伸手臂；轨迹圆弧向斜上方合拢，不是正上方。重点：底部充分拉开上胸，顶峰轻碰哑铃即可，不要大力相撞。专门打磨上胸轮廓、外沿。', tips: ['凳调至30度','手肘微弯固定角度','轨迹圆弧向斜上方合拢','底部充分拉伸顶峰轻碰'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10006', name: '地板上斜哑铃卧推', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '没有上斜凳时，把上背部垫哑铃垫，制造轻微上斜角度。特点：限制下放幅度，保护肩，适合肩有旧伤。', tips: ['上背部垫哑铃垫制造上斜','限制下放幅度','保护肩膀','适合肩有旧伤人群'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10007', name: '上斜哑铃旋转飞鸟', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '下放掌心朝下，合拢时掌心相对，旋转可以强化上胸肌纤维收缩，高阶孤立变式。', tips: ['凳调至30度','下放时掌心朝下','合拢时掌心相对旋转','高阶孤立变式'], sets: 3, reps: 12, restSeconds: '45', difficulty: '高级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10008', name: '上斜角度俯卧撑', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '垫高臀部/降低脚位，身体形成头高脚低，相当于上斜推。要点：手放在胸上部两侧，身体一条直线。适合热身、高次数充血，也可以负重背上杠铃片。', tips: ['垫高臀部降低脚位','手放胸上部两侧','身体保持一条直线','适合热身高次数充血'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10009', name: '壶铃上斜卧推', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '上斜凳，双手壶铃，轨迹和哑铃一致；壶铃重心偏下，对肩关节更友好，适合肩膀容易弹响人群。', tips: ['凳调至30-35度','双手持壶铃','轨迹和哑铃卧推一致','壶铃对肩关节更友好'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10010', name: '上斜器械推胸', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '机器本身轨道是向上斜，座椅高度调至把手对齐上胸锁骨位置。优点：不用平衡，可冲大重量，力竭时更安全，适合主力复合。', tips: ['座椅调至把手对齐上胸锁骨','机器轨道向上斜','可冲大重量','力竭时更安全'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10011', name: '坐姿下握式胸推器械', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '把手位置调到偏下，推起轨迹向上，被动强化上胸；很多综合器械没有专门上斜凳，用这个替代。', tips: ['把手调至偏低位置','推起轨迹斜向上','替代上斜凳','被动强化上胸'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10012', name: '哈克推胸', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '身体背靠斜板，座椅调低，让把手落点对准上胸；推的轨迹斜向上。特点：超级稳定，可以上很大重量，几乎不用考虑平衡，适合上胸堆厚度。', tips: ['身体背靠斜板','座椅调低让把手对准上胸','推的轨迹斜向上','超级稳定可上很大重量'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10013', name: '蝴蝶机夹胸（高位把手）', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '把手调到高位，略高于肩膀，坐姿身体微微后仰；夹的时候向斜下方合拢，目标上胸。注意：不要耸肩，肩膀沉住，顶峰收缩停留1-2秒，雕刻上胸中缝轮廓。', tips: ['把手调至高位略高于肩','坐姿身体微微后仰','夹时向斜下方合拢','顶峰收缩停留1-2秒'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10014', name: '高位绳索夹胸', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '两个滑轮调至最高位，站姿身体微微前倾，双手握D把手，从高处向斜下方做夹胸，终点双手在腹部前侧交汇。关键点：手肘保持微弯不变，全程不变角度；不是推，是夹。从上胸拉伸到收缩，全程持续张力，很多人上胸缺轮廓必做。', tips: ['滑轮调至最高位','站姿身体微微前倾','手肘微弯不变角度','不是推是夹全程持续张力'], sets: 3, reps: 15, restSeconds: '30', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10015', name: '低位绳索上斜推', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '滑轮放最低，躺30度上斜凳，双手握住低位绳索把手，向上斜上方推，模拟哑铃上斜卧推。特点：下放时持续张力，底部不会卸力，和哑铃杠铃互补。', tips: ['滑轮放最低位','躺30度上斜凳','双手握低位绳索把手','向上斜上方推模拟哑铃上斜'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10016', name: '单臂高位绳索夹胸', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '单侧训练，纠正左右上胸不对称，孤立感受单侧收缩，适合弱侧补强。', tips: ['单侧训练纠正左右不对称','滑轮调至最高位','身体微微前倾','适合弱侧补强'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10017', name: '上斜哑铃地板飞鸟', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '躺在地板，背部垫薄垫制造微小上斜，做飞鸟；限制过度下放，保护肩，侧重顶峰收缩。', tips: ['背部垫薄垫制造微小上斜','限制过度下放保护肩','侧重顶峰收缩','飞鸟轨迹向斜上方'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10018', name: '上斜卧推停顿版', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '杠铃或哑铃上斜，下放到上胸位置停1-2秒再推起，消除惯性，强化离心，突破平台期。', tips: ['杠铃或哑铃上斜','下放到上胸位置停顿1-2秒','再推起消除惯性','强化离心阶段突破平台期'], sets: 4, reps: 8, restSeconds: '60', difficulty: '高级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10019', name: '上斜卧推离心慢放', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '不增加重量，刻意拉长离心阶段，4秒下放，上胸肌纤维破坏更强，适合增肌周期。', tips: ['不增加重量','刻意拉长离心阶段','4秒缓慢下放','适合增肌周期'], sets: 3, reps: 10, restSeconds: '60', difficulty: '高级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10020', name: '反向上斜俯卧撑', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '脚放低臀部垫高头高于脚形成上斜推角度练上胸注意与脚抬高的下胸动作区分。', tips: ['脚放低臀部垫高','头高于脚形成上斜','练上胸不是下胸','注意与脚抬高的下胸动作区分'], sets: 3, reps: 12, restSeconds: '30', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10021', name: '平板杠铃卧推', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '凳面完全水平，杠铃下落到乳头连线位置，垂直向上推起。握距略宽于肩，小臂垂直地面。特点：胸部整体力量、中胸厚度的标杆动作，可以上大重量，几乎所有训练周期必用。', tips: ['凳面完全水平','杠铃落到乳头连线位置','握距略宽于肩小臂垂直地面','垂直向上推起'], sets: 4, reps: 8, restSeconds: '60', difficulty: '中级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10022', name: '地板杠铃卧推', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '躺在地板上，背部无倾角，下放被地板限制，减少肩膀过度拉伸。适合肩有不适，侧重中胸向心收缩，少拉伸。', tips: ['躺在地板背部无倾角','下放被地板限制','减少肩膀过度拉伸','侧重中胸向心收缩'], sets: 3, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10023', name: '宽握平板卧推', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '握距明显宽于肩，更多刺激胸外侧，加宽胸板，肩关节压力会变大，重量要下调。', tips: ['握距明显宽于肩','刺激胸外侧加宽胸板','肩关节压力大重量下调','适合加宽胸板训练'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10024', name: '窄握平板卧推', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '握距略窄，侧重胸中内侧，同时带入三头，适合强化胸中缝，但三头容易疲劳抢力。', tips: ['握距略窄于常规','侧重胸中内侧','同时带入三头','注意三头疲劳抢力'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10025', name: '平板哑铃卧推', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '平板凳，哑铃下放位置略低于肩，充分拉开中胸，底部拉伸感强。优势：左右独立，修正力量不平衡，活动幅度比杠铃更大，中胸拉伸更充分。', tips: ['平板凳完全水平','哑铃下放略低于肩','底部充分拉伸中胸','左右独立修正不平衡'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10026', name: '平板哑铃飞鸟', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '手肘固定微弯，不要弯肘举哑铃；沿圆弧向两侧下放，再向上向内合拢。顶峰哑铃不要大力相撞，轻触即可，重点感受胸外侧-中胸的拉伸与挤压，雕刻胸轮廓。', tips: ['手肘固定微弯','沿圆弧向两侧下放再合拢','顶峰轻触不要相撞','感受拉伸与挤压'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10027', name: '地板哑铃飞鸟', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '躺在地板做飞鸟，限制下放幅度，保护肩关节，适合大重量飞鸟容易肩痛的人。', tips: ['躺在地板做飞鸟','限制下放幅度','保护肩关节','适合肩痛人群'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10028', name: '负重平板俯卧撑', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '身体水平，背部放杠铃片/负重背心。高次数充血、热身，也可以做力竭组；脚与身体同一平面才是中胸，脚抬高偏下胸，脚放低偏上胸。', tips: ['身体保持水平','背部可加杠铃片负重','脚与身体同一平面','高次数充血热身'], sets: 3, reps: 15, restSeconds: '30', difficulty: '中级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10029', name: '平板器械推胸', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '座椅高度调至把手对齐乳头（中胸高度）。背靠实，不要过度后仰；推出去不要锁死手肘。优势：不需要平衡，能安全做力竭，适合大重量堆中胸厚度，也适合主项后补容量。', tips: ['座椅调至把手对齐乳头','背靠实不要过度后仰','推起不锁死手肘','可安全做力竭组'], sets: 4, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10030', name: '哈克推胸（平板模式）', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '调低靠背，身体近乎平躺，把手落点对准中胸。极其稳定，可以上很重，几乎不消耗核心，适合平台期堆容量。', tips: ['调低靠背身体近乎平躺','把手对准中胸位置','极其稳定可上大重量','几乎不消耗核心'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10031', name: '蝴蝶机夹胸（中位把手）', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '把手调到与肩膀齐平，身体轻靠靠背，沉肩，双手向前做合拢夹胸，顶峰停留1-2秒。强化胸中缝、胸外侧轮廓，复合动作后做孤立收尾。', tips: ['把手调至与肩齐平','身体轻靠靠背沉肩','双手向前合拢顶峰停留1-2秒','复合动作后孤立收尾'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10032', name: '中位绳索夹胸', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '滑轮调至与胸部齐平高度，站姿微微前倾，手肘保持固定微弯，双手从两侧向前做夹胸，手在胸前交汇。不是推，是夹！全程中胸持续受力，底部不卸力，非常适合胸中缝、胸外侧塑形。', tips: ['滑轮调至胸部齐平高度','站姿微微前倾','手肘固定微弯','不是推是夹全程持续受力'], sets: 3, reps: 15, restSeconds: '30', difficulty: '中级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10033', name: '低位绳索平板推胸', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '滑轮最低，躺平板凳，握住绳索把手做类似平板哑铃卧推的推起。下放时绳索持续拉扯，中胸离心张力很强，弥补哑铃杠铃底部容易卸力的缺点。', tips: ['滑轮放最低位','躺平板凳','下放时绳索持续拉扯','弥补底部卸力缺点'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10034', name: '单臂中位绳索夹胸', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '单侧孤立，补强弱侧中胸，感受单侧胸部收缩，改善左右胸不对称。', tips: ['单侧训练','滑轮调至胸部齐平','身体微微前倾','改善左右胸不对称'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10035', name: '平板卧推底部停顿', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '下放到中胸位置停顿1-2秒，消除惯性，强迫中胸发力，突破平台。', tips: ['杠铃或哑铃平板','下放到中胸位置停顿1-2秒','消除惯性强迫中胸发力','突破平台期'], sets: 4, reps: 8, restSeconds: '60', difficulty: '高级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10036', name: '慢离心平板卧推', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '不加大重量，拉长离心阶段3-4秒下放，提升肌纤维刺激，增肌周期优先。', tips: ['不加大重量','刻意拉长离心阶段','3-4秒缓慢下放','增肌周期优先'], sets: 3, reps: 10, restSeconds: '60', difficulty: '高级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10037', name: '哑铃旋转平板飞鸟', categoryPath: '力量训练 / 胸部训练 / 中胸', description: '下放掌心朝下，向中间合拢时掌心转为相对，增加胸肌旋转收缩，强化胸中缝。', tips: ['平板凳完全水平','下放掌心朝下','合拢时掌心转为相对','增加旋转收缩强化胸中缝'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '中胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10038', name: '下斜杠铃卧推（15-25度）', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '凳子向下倾斜15-25度，脚勾住挡板固定身体。杠铃下放到胸口下沿/乳头偏下位置，小臂垂直地面，向斜上方推起。特点：可上大重量，强化下胸整体厚度，下胸第一复合动作。角度别调太陡，20度左右收益最高。', tips: ['凳调至15-25度下斜','脚勾住挡板固定身体','杠铃落到胸口下沿','垂直推起不要超过35度'], sets: 4, reps: 8, restSeconds: '60', difficulty: '中级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10039', name: '窄握下斜杠铃卧推', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '握距略窄，强化下胸内侧和胸下沿中缝，三头参与变多。适合肩膀不舒服、想减少肩关节压力时用。', tips: ['握距略窄于常规','强化下胸内侧中缝','三头参与变多','减少肩关节压力'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10040', name: '下斜哑铃卧推', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '下斜凳15-25度，脚勾稳挡板。哑铃下放充分，向身体两侧下方打开，感受下胸拉伸。优势：两侧独立，活动幅度更大，比杠铃更容易找到下胸拉伸感，修正左右力量差。', tips: ['凳调至15-25度下斜','脚勾稳挡板','哑铃下放充分向两侧打开','修正左右力量差'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10041', name: '下斜哑铃飞鸟', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '手肘维持固定微弯，不要弯肘做功。哑铃轨迹向斜下方打开，再向内向上合拢。重点：不要把哑铃举到脸上方，合拢终点在胸下沿正上方。专门打磨胸下缘轮廓，改善胸的分离度。', tips: ['凳调至15-25度下斜','手肘固定微弯','合拢终点在胸下沿正上方','不要举到脸上方'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10042', name: '脚抬高负重俯卧撑', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '脚垫高（箱子/凳子），头低脚高，身体形成下斜。背部放置杠铃片、负重背心增加负荷。适合热身、高次数充血，没有下斜凳的首选替代。脚抬得越高倾斜越大，注意不要腰塌。', tips: ['脚垫高头低脚高','背部可加杠铃片负重','注意不要腰塌','高次数充血热身'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10043', name: '下斜器械推胸', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '专门的下斜推胸器械，座椅调低，把手对齐胸下部。背靠实，推起轨迹斜向上。不用维持平衡，安全做大重量力竭组，适合主项后堆容量。', tips: ['座椅调低把手对齐胸下部','背靠实推起轨迹斜向上','不用维持平衡','可安全做力竭组'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10044', name: '哈克推胸（下胸模式）', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '靠背放低，座椅调高，身体略微倒向下方，把手落点对准胸下沿。极其稳定，可上很大重量，核心消耗小，平台期堆下胸厚度非常好用。', tips: ['靠背放低座椅调高','把手对准胸下沿','极其稳定可上大重量','核心消耗小'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10045', name: '蝴蝶机夹胸（低位把手）', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '把手调至低于肩膀高度，身体微微后仰，手臂从高位向下前方合拢，顶峰挤压胸下缘1-2秒。雕刻胸下沿、胸外侧下沿分离度，复合动作后收尾。', tips: ['把手调至低于肩','身体微微后仰','手臂从高位向下前方合拢','顶峰挤压胸下缘1-2秒'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10046', name: '低位绳索夹胸', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '滑轮调到最低位置，站姿身体微微前倾，手肘保持微弯固定。双手从下方向上向内夹，双手交汇点大约在胸口下方。重点：不要耸肩，靠胸下缘收缩把把手往上捞，不是手臂用力提拉。下胸全程都有张力，对胸下缘线条提升效果极强。', tips: ['滑轮调至最低位','站姿微微前倾','双手从下方向上向内夹','不要耸肩靠胸下缘收缩'], sets: 3, reps: 15, restSeconds: '30', difficulty: '中级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10047', name: '高位绳索下斜推胸', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '滑轮调最高，躺15-25度下斜凳，握住高位把手，向斜下方推，复刻下斜哑铃卧推轨迹。绳索会持续拉扯，离心阶段下胸持续受力，弥补哑铃杠铃底部容易卸力的短板。', tips: ['滑轮调至最高位','躺15-25度下斜凳','向斜下方推','离心阶段持续张力'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10048', name: '单臂低位绳索夹胸', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '单侧孤立训练，弥补下胸左右不对称，帮助找到单侧下胸收缩感。', tips: ['单侧训练','滑轮调至最低位','身体微微前倾','改善左右下胸不对称'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10049', name: '下斜卧推底部停顿', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '负重下放到胸下沿，停顿1-2秒再推起，消除惯性，强迫下胸发力，突破平台。', tips: ['杠铃或哑铃下斜','下放到胸下沿停顿1-2秒','消除惯性强迫下胸发力','突破平台期'], sets: 4, reps: 8, restSeconds: '60', difficulty: '高级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10050', name: '慢离心下斜卧推', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '不增加重量，拉长离心时间，3-4秒下放，强化下胸肌纤维刺激，增肌周期优先。', tips: ['不增加重量','3-4秒缓慢下放','强化下胸肌纤维','增肌周期优先'], sets: 3, reps: 10, restSeconds: '60', difficulty: '高级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10051', name: '下斜哑铃旋转飞鸟', categoryPath: '力量训练 / 胸部训练 / 下胸', description: '下放掌心朝下，合拢时掌心相对，增加胸肌旋转收缩，强化下胸中缝。', tips: ['凳调至15-25度下斜','下放掌心朝下','合拢时掌心转为相对','强化下胸中缝'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '下胸', imageUrl: '', videoPath: '', weight: '0'),

    Exercise(id: '10052', name: '站姿杠铃推举', categoryPath: '力量训练 / 肩部训练 / 前束', description: '站姿，杠铃锁骨位置起，垂直向上推起。复合动作，前束主导，兼顾中束，全身参与，提升肩部整体力量。', tips: ['杠铃放锁骨位置','垂直向上推起','前束主导兼顾中束','不要过度后仰'], sets: 4, reps: 8, restSeconds: '60', difficulty: '中级', imageSvg: '前束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10053', name: '坐姿哑铃推举', categoryPath: '力量训练 / 肩部训练 / 前束', description: '坐姿，哑铃从肩两侧向上推。相比杠铃活动更自由，左右平衡，前束占比很高。', tips: ['坐姿背部贴紧','哑铃从肩两侧向上推','左右平衡修正','前束占比很高'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '前束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10054', name: '杠铃前平举', categoryPath: '力量训练 / 肩部训练 / 前束', description: '握距与肩同宽，杠铃沿身体前侧抬到眼睛高度，缓慢下放。孤立前束，不要甩腰借力。', tips: ['握距与肩同宽','抬到眼睛高度','缓慢下放','不要甩腰借力'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '前束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10055', name: '哑铃前平举', categoryPath: '力量训练 / 肩部训练 / 前束', description: '单/双手，哑铃由大腿前方向上抬至肩高。可以交替做，减少身体摆动。', tips: ['哑铃由大腿前方向上抬','抬至肩高即可','可交替进行','减少身体摆动'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '前束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10056', name: '坐姿器械肩推', categoryPath: '力量训练 / 肩部训练 / 前束', description: '固定轨迹，把手落在锁骨高度，向上推。安全冲重量，减少核心代偿，前束参与高。', tips: ['把手对齐锁骨高度','固定轨迹安全','减少核心代偿','前束参与高'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '前束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10057', name: '绳索前平举', categoryPath: '力量训练 / 肩部训练 / 前束', description: '滑轮调最低，站姿，握把手向前抬至肩高。全程持续张力，孤立打磨前束。', tips: ['滑轮调至最低位','向前抬至肩高','全程持续张力','孤立打磨前束'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '前束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10058', name: '哑铃侧平举', categoryPath: '力量训练 / 肩部训练 / 中束', description: '站姿，轻-中等重量，手肘微弯固定，向两侧抬起至肩高，缓慢控制下放。不要耸肩、不要甩惯性。中束标杆孤立动作，决定肩宽。', tips: ['手肘微弯固定','抬至肩高即可不要过耳','不要耸肩','不要甩惯性'], sets: 4, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '中束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10059', name: '俯身30度哑铃侧平举', categoryPath: '力量训练 / 肩部训练 / 中束', description: '身体微微前倾，大臂略微向前，进一步把发力锁定中束，减少斜方代偿。', tips: ['身体前倾30度','大臂略微向前','锁定中束发力','减少斜方代偿'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '中束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10060', name: '哑铃阿诺德推举', categoryPath: '力量训练 / 肩部训练 / 中束', description: '坐姿，哑铃在肩前掌心朝自己，推起同时外旋手腕。推举复合同时强化中束，兼顾一点前束。', tips: ['坐姿','推起时外旋手腕','掌心从朝己到朝前','强化中束兼顾前束'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '中束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10061', name: '绳索侧平举', categoryPath: '力量训练 / 肩部训练 / 中束', description: '滑轮调至最低，站在器械侧面，握把手向侧上方抬至肩高。下放也有持续张力，底部不会卸力，增肌效果优于哑铃。', tips: ['滑轮调至最低','站在器械侧面','抬至肩高','下放也有持续张力'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '中束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10062', name: '器械侧平举', categoryPath: '力量训练 / 肩部训练 / 中束', description: '坐姿固定，大臂托在靠垫上，向两侧打开。强制轨迹，极大抑制斜方上束借力，弱侧中束补强神器。', tips: ['坐姿大臂托在靠垫上','向两侧打开','强制轨迹抑制斜方','弱侧补强神器'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '中束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10063', name: '单臂绳索侧平举', categoryPath: '力量训练 / 肩部训练 / 中束', description: '单侧训练，修正左右肩膀不对称。', tips: ['单侧训练','滑轮调至最低','身体站直','修正左右不对称'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '中束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10064', name: '俯身哑铃反向飞鸟', categoryPath: '力量训练 / 肩部训练 / 后束', description: '上半身俯身接近平行地面，腰背平直，手肘微弯，哑铃向两侧向后打开，感受肩膀后侧收缩，慢下放。不要抬哑铃过高。后束经典标杆动作。', tips: ['上半身俯身接近平行地面','腰背平直','向两侧向后打开','不要抬过高'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '后束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10065', name: '俯卧上斜凳反向飞鸟', categoryPath: '力量训练 / 肩部训练 / 后束', description: '趴在45度上斜凳上做反向飞鸟，身体被凳子固定，杜绝弯腰借力，后束感受极强。', tips: ['趴在45度上斜凳','身体被固定杜绝借力','后束感受极强','反向飞鸟轨迹'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '后束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10066', name: '哑铃面拉（自由版）', categoryPath: '力量训练 / 肩部训练 / 后束', description: '坐姿，哑铃从下颌位置向两侧拉开，肘部向外向后。', tips: ['坐姿','哑铃从下颌向两侧拉开','肘部向外向后','强化后束'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '后束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10067', name: '绳索面拉', categoryPath: '力量训练 / 肩部训练 / 后束', description: '滑轮调至额头高度，绳索握把拉向额头，肘高于手，肘部向两侧向后打开。不光练后束，同时强化冈下肌，保护肩关节，预防肩撞击。后束+肩袖之王，必练动作。', tips: ['滑轮调至额头高度','拉向额头肘高于手','肘部向两侧向后打开','保护肩关节预防撞击'], sets: 3, reps: 15, restSeconds: '30', difficulty: '中级', imageSvg: '后束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10068', name: '器械反向飞鸟', categoryPath: '力量训练 / 肩部训练 / 后束', description: '蝴蝶机把手调高位，面对机器坐，双手向后做开胸动作。固定轨迹，容易找后束发力，新手老手都适用。', tips: ['把手调至高位','面对机器坐','双手向后开胸','固定轨迹易找发力'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '后束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10069', name: '单臂绳索反向飞鸟', categoryPath: '力量训练 / 肩部训练 / 后束', description: '单侧，站姿俯身，单握绳索把手向后外展开，纠正后束左右差距。', tips: ['单侧训练','站姿俯身','向后外展开','纠正左右差距'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '后束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10070', name: '绳索外旋', categoryPath: '力量训练 / 肩部训练 / 肩袖肌群', description: '大臂贴紧身体，手肘夹紧肋骨不动，小臂向外旋转打开。强化冈下肌、小圆肌，保护肩关节。', tips: ['大臂贴紧身体','手肘夹紧肋骨','小臂向外旋转打开','轻重量高次数'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '肩袖肌群', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10071', name: '绳索内旋', categoryPath: '力量训练 / 肩部训练 / 肩袖肌群', description: '大臂贴身体，小臂向内旋转。强化肩胛下肌，平衡肩袖肌群。', tips: ['大臂贴紧身体','小臂向内旋转','强化肩胛下肌','轻重量'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '肩袖肌群', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10072', name: '空罐动作', categoryPath: '力量训练 / 肩部训练 / 肩袖肌群', description: '哑铃，拇指朝下，手臂斜向上抬30度，轻重量，康复强化冈上肌。', tips: ['拇指朝下','手臂斜向上抬30度','轻重量','强化冈上肌'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '肩袖肌群', imageUrl: '', videoPath: '', weight: '0'),

    Exercise(id: '10073', name: '宽握引体向上', categoryPath: '力量训练 / 背部训练 / 背阔肌', description: '双手宽握单杠，起始完全悬挂，肩胛骨下沉；把胸口往单杠方向拉，不要只靠手臂拽；顶峰胸打开，慢下放。侧重腋下上部背阔，打造背的最宽点。可腰间挂负重片做负重引体。', tips: ['双手宽握单杠','起始完全悬挂肩胛骨下沉','胸口往单杠方向拉','顶峰胸打开慢下放'], sets: 4, reps: 8, restSeconds: '60', difficulty: '中级', imageSvg: '背阔肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10074', name: '窄握对握引体向上', categoryPath: '力量训练 / 背部训练 / 背阔肌', description: '对握（手掌相对）握距与肩同宽。发力轨迹更靠身体两侧偏下，强化下部背阔、大圆肌，让背下沿收紧，V形底部更清晰，二头参与会增加。', tips: ['对握手掌相对','握距与肩同宽','强化下部背阔大圆肌','二头参与增加'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '背阔肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10075', name: '反手引体向上', categoryPath: '力量训练 / 背部训练 / 背阔肌', description: '反手握，更多带入肱二头肌，下背阔同样刺激，适合相对力量不足时。', tips: ['反手握杠','带入肱二头肌','下背阔同样刺激','适合力量不足者'], sets: 3, reps: 8, restSeconds: '60', difficulty: '中级', imageSvg: '背阔肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10076', name: '宽握高位下拉', categoryPath: '力量训练 / 背部训练 / 背阔肌', description: '握距宽于肩，拉杆落到锁骨上方；启动先沉肩，再把拉杆向下拉至上胸位置，不要拉到肚子。主打上部背阔、宽度，引体向上的替代主力动作。', tips: ['握距宽于肩','拉杆落到锁骨上方','先沉肩再下拉','不要拉到肚子'], sets: 4, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: '背阔肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10077', name: '窄握对握高位下拉', categoryPath: '力量训练 / 背部训练 / 背阔肌', description: '对握把手，拉杆拉至胸口，手肘贴着身体两侧向下，重点刺激腰上方两侧的下背阔，收紧背的下缘轮廓。', tips: ['对握把手','拉杆拉至胸口','手肘贴身体两侧','收紧背下缘轮廓'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '背阔肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10078', name: '直臂绳索下压', categoryPath: '力量训练 / 背部训练 / 背阔肌', description: '站姿，大臂角度基本固定微弯，不要屈肘；把横杆从高处往大腿方向压。几乎不练二头，纯孤立背阔肌，复合动作之后补背阔收缩感，改善背阔末端发力。', tips: ['大臂固定微弯','把横杆往大腿方向压','几乎不练二头','纯孤立背阔肌'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '背阔肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10079', name: '单臂绳索下拉', categoryPath: '力量训练 / 背部训练 / 背阔肌', description: '单侧绳索把手，单臂向下拉，改善左右背阔不对称，感受单侧背阔收缩。', tips: ['单侧绳索把手','改善左右不对称','感受单侧收缩','单臂向下拉'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '背阔肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10080', name: '俯身杠铃划船', categoryPath: '力量训练 / 背部训练 / 上背厚度', description: '躯干俯身约45-60度，腰背刚性，不要塌腰；杠铃从大腿位置向下腹部提拉，手肘向后向外，肩胛骨夹紧，慢下放。整体轰炸上背厚度，斜方中束、菱形肌、大圆肌，可上大重量。', tips: ['躯干俯身45-60度','腰背刚性不要塌腰','肩胛骨夹紧','慢下放'], sets: 4, reps: 8, restSeconds: '60', difficulty: '中级', imageSvg: '上背厚度', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10081', name: '俯身哑铃单臂划船', categoryPath: '力量训练 / 背部训练 / 上背厚度', description: '一手撑凳，躯干接近平行地面，另一手把哑铃往髋部提拉，肘部向后。单侧独立，修正左右背部不平衡，拉伸收缩幅度更大。', tips: ['一手撑凳躯干平行地面','哑铃往髋部提拉','修正左右不平衡','拉伸收缩幅度大'], sets: 3, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: '上背厚度', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10082', name: 'T杠划船（地雷管划船）', categoryPath: '力量训练 / 背部训练 / 上背厚度', description: '杠铃一端固定，手握另一端，俯身划船。轨迹稳定，对腕关节友好，可以持续大重量堆上背厚度。', tips: ['杠铃一端固定','轨迹稳定','对腕关节友好','持续大重量堆厚度'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '上背厚度', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10083', name: '俯身哑铃双哑铃划船', categoryPath: '力量训练 / 背部训练 / 上背厚度', description: '双手握哑铃，俯身平行地面，双哑铃向腰侧提拉；比杠铃自由度更高，适合寻找肩胛骨夹紧的挤压感。', tips: ['双手握哑铃俯身平行地面','双哑铃向腰侧提拉','自由度更高','寻找肩胛骨夹紧感'], sets: 3, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: '上背厚度', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10084', name: '坐姿绳索划船', categoryPath: '力量训练 / 背部训练 / 上背厚度', description: '坐姿，脚掌踩实，挺胸沉肩，把手往下腹部拉，肩胛骨向后夹紧，顶峰停顿1秒。持续张力强，打造中上背厚度，对腰部压力比杠铃划船更小。', tips: ['脚掌踩实挺胸沉肩','把手拉向下腹部','肩胛骨夹紧顶峰停顿1秒','对腰部压力更小'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上背厚度', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10085', name: '高位坐姿划船器械', categoryPath: '力量训练 / 背部训练 / 上背厚度', description: '把手高度对齐胸口，拉向胸的位置，侧重斜方中束、菱形肌，改善肩胛骨中间薄弱，强化后背铠甲中间厚度。', tips: ['把手对齐胸口高度','拉向胸的位置','侧重斜方中束菱形肌','强化后背铠甲厚度'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上背厚度', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10086', name: '单臂绳索划船', categoryPath: '力量训练 / 背部训练 / 上背厚度', description: '单握绳索把手，身体侧站，把手拉向髋部，补强单侧上背薄弱。', tips: ['单握绳索把手','身体侧站','把手拉向髋部','补强单侧薄弱'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '上背厚度', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10087', name: '海豹划船（俯卧器械划船）', categoryPath: '力量训练 / 背部训练 / 上背厚度', description: '身体趴在斜垫上，手臂向下抓把手，向身体方向拉；躯干被垫子承托，腰部几乎零压力，腰容易酸的人绝佳选择。', tips: ['身体趴在斜垫上','手臂向下抓把手','腰部几乎零压力','腰容易酸人群首选'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上背厚度', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10088', name: '坐姿器械划船机', categoryPath: '力量训练 / 背部训练 / 上背厚度', description: '固定轨迹，背靠或不靠背；不靠背版本会更多调用背部稳定，靠背版更孤立上背，适合力竭组堆容量。', tips: ['固定轨迹','不靠背版调用稳定性','靠背版更孤立','适合力竭组堆容量'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上背厚度', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10089', name: '俯身Y字飞鸟（哑铃）', categoryPath: '力量训练 / 背部训练 / 斜方下束', description: '身体俯身平行地面，双手呈Y字形向斜上方抬起，拇指朝上，感受肩胛骨向下向外展开。强化斜方下束，改善圆肩头前伸。', tips: ['身体俯身平行地面','双手呈Y字形抬起','拇指朝上','感受肩胛骨向下向外展开'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '斜方下束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10090', name: '绳索Y型下拉', categoryPath: '力量训练 / 背部训练 / 斜方下束', description: '滑轮高位，握把手向斜下方向拉，手肘微弯，激活斜方下束。', tips: ['滑轮调至高位','向斜下方向拉','手肘微弯','激活斜方下束'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '斜方下束', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10091', name: '传统硬拉 / 罗马尼亚硬拉RDL', categoryPath: '力量训练 / 背部训练 / 下背/竖脊肌', description: '传统硬拉：整体后链，竖脊肌、臀腿，全身力量动作。RDL罗马尼亚硬拉：膝盖微弯，臀部向后推，杠铃沿大腿下放至小腿中段，重点拉伸刺激竖脊肌、腘绳肌。', tips: ['传统硬拉整体后链','RDL膝盖微弯臀部后推','杠铃沿大腿下放','重点刺激竖脊肌腘绳肌'], sets: 4, reps: 6, restSeconds: '90', difficulty: '高级', imageSvg: '下背/竖脊肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10092', name: '山羊挺身（背屈伸）', categoryPath: '力量训练 / 背部训练 / 下背/竖脊肌', description: '俯卧山羊挺身凳，髋部抵住软垫，上半身向下再向上抬起，不要过度超伸腰椎。强化竖脊肌耐力，不要猛甩身体。', tips: ['髋部抵住软垫','上半身向下再向上抬','不要过度超伸腰椎','不要猛甩身体'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '下背/竖脊肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10093', name: '早安式躬身', categoryPath: '力量训练 / 背部训练 / 下背/竖脊肌', description: '杠铃置于上背，膝盖微屈，臀部向后坐，躯干向前俯身再回正，强化下背稳定。', tips: ['杠铃置于上背','膝盖微屈臀部后坐','躯干向前俯身再回正','强化下背稳定'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '下背/竖脊肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10094', name: '45度背伸器械', categoryPath: '力量训练 / 背部训练 / 下背/竖脊肌', description: '固定轨迹山羊挺身，限制过度后伸，安全做高次数，强化竖脊肌。', tips: ['固定轨迹限制过度后伸','安全做高次数','强化竖脊肌','45度背伸器械'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '下背/竖脊肌', imageUrl: '', videoPath: '', weight: '0'),

    Exercise(id: '10095', name: '杠铃站姿弯举', categoryPath: '力量训练 / 手臂训练 / 肱二头肌', description: '站姿，大臂夹紧身体不动，只弯小臂，把杠铃举到胸前，慢下放。大臂不要前后甩。二头王牌动作，侧重短头。', tips: ['大臂夹紧身体不动','只弯小臂','举到胸前慢下放','大臂不要前后甩'], sets: 4, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: '肱二头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10096', name: '哑铃交替弯举', categoryPath: '力量训练 / 手臂训练 / 肱二头肌', description: '双手哑铃交替弯举，可以轻微旋转手腕，顶峰掌心朝上，纠正左右力量差。', tips: ['双手交替弯举','顶峰掌心朝上','轻微旋转手腕','纠正左右力量差'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '肱二头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10097', name: '牧师凳弯举', categoryPath: '力量训练 / 手臂训练 / 肱二头肌', description: '上臂贴在牧师凳斜垫上，大臂被固定，完全杜绝借力，短头刺激极强。', tips: ['上臂贴牧师凳斜垫','大臂被固定杜绝借力','短头刺激极强','孤立弯举'], sets: 3, reps: 10, restSeconds: '45', difficulty: '初级', imageSvg: '肱二头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10098', name: '上斜凳哑铃弯举', categoryPath: '力量训练 / 手臂训练 / 肱二头肌', description: '躺在30-45度上斜凳，大臂垂向身体后方做弯举。大臂向后，长头被拉开，专门强化二头肌长头，很多人二头尖弱就靠它。', tips: ['躺在30-45度上斜凳','大臂垂向身体后方','长头被充分拉伸','强化二头肌长头'], sets: 3, reps: 10, restSeconds: '45', difficulty: '中级', imageSvg: '肱二头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10099', name: '绳索杠铃弯举', categoryPath: '力量训练 / 手臂训练 / 肱二头肌', description: '滑轮低位，直杆，站姿弯举。全程持续张力，底部不会卸力，增肌效果优秀。', tips: ['滑轮调至最低位','直杆握把','全程持续张力','底部不卸力'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '肱二头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10100', name: '绳索锤式弯举', categoryPath: '力量训练 / 手臂训练 / 肱二头肌', description: '握对握把手，掌心相对，不旋转手腕。重点练肱肌（二头下方，让手臂围度变大的关键肌肉），同时刺激肱桡肌。', tips: ['对握把手掌心相对','不旋转手腕','重点练肱肌','增加手臂围度'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '肱二头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10101', name: '器械二头弯举机', categoryPath: '力量训练 / 手臂训练 / 肱二头肌', description: '固定轨迹，适合力竭组，不用平衡，安全冲容量。', tips: ['固定轨迹安全','适合力竭组','不用平衡','安全冲容量'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '肱二头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10102', name: '窄距杠铃卧推', categoryPath: '力量训练 / 手臂训练 / 肱三头肌', description: '握距略窄于肩，平板凳。既是胸辅助动作，也是三头大重量复合，可以上大重量堆围度。侧重外侧和内侧头。', tips: ['握距略窄于肩','平板凳','三头大重量复合','侧重外侧内侧头'], sets: 4, reps: 8, restSeconds: '60', difficulty: '中级', imageSvg: '肱三头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10103', name: '哑铃颈后臂屈伸', categoryPath: '力量训练 / 手臂训练 / 肱三头肌', description: '坐姿/站姿，单/双手，哑铃举过头顶，向颈后下放，再向上伸直。长头必练动作，想要手臂后侧饱满不能少。', tips: ['哑铃举过头顶','向颈后下放','再向上伸直','长头必练动作'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '肱三头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10104', name: '俯身哑铃臂屈伸（单臂）', categoryPath: '力量训练 / 手臂训练 / 肱三头肌', description: '身体俯身，大臂抬至与地面平行固定，小臂向后伸。孤立外侧、内侧头。', tips: ['身体俯身大臂平行地面','大臂固定不动','小臂向后伸','孤立外侧内侧头'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '肱三头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10105', name: '绳索下压（直杆）', categoryPath: '力量训练 / 手臂训练 / 肱三头肌', description: '滑轮高位，大臂夹紧肋骨不动，只做小臂向下压，顶峰手臂几乎打直但不锁死。最常用三头动作，外侧头为主。', tips: ['滑轮调至高位','大臂夹紧肋骨','小臂向下压','顶峰不锁死'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '肱三头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10106', name: '绳索V把下压', categoryPath: '力量训练 / 手臂训练 / 肱三头肌', description: 'V型把手，手腕略微内扣，侧重内侧头，改善手肘上方那块薄弱。', tips: ['V型把手手腕内扣','侧重内侧头','改善手肘上方薄弱','三头标杆动作'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '肱三头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10107', name: '绳索过头臂屈伸', categoryPath: '力量训练 / 手臂训练 / 肱三头肌', description: '滑轮调最低，背对器械，双手抓绳索举过头顶，向脑后弯曲再伸直。长头持续张力，效果优于哑铃颈后臂屈伸。', tips: ['滑轮调至最低','背对器械双手举过头顶','向脑后弯曲再伸直','长头持续张力'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '肱三头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10108', name: '双杠臂屈伸（三头版）', categoryPath: '力量训练 / 手臂训练 / 肱三头肌', description: '身体垂直、手肘贴紧身体，就是练三头。自重，可腰间挂负重片。', tips: ['身体保持垂直','手肘贴紧身体','练三头不是胸','可挂负重片'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '肱三头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10109', name: '器械三头屈伸机', categoryPath: '力量训练 / 手臂训练 / 肱三头肌', description: '坐姿固定轨迹，适合力竭收尾。', tips: ['坐姿固定轨迹','适合力竭组','安全冲容量','三头收尾动作'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '肱三头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10110', name: '杠铃坐姿腕弯举', categoryPath: '力量训练 / 手臂训练 / 前臂', description: '前臂放在凳上，手腕悬空，只活动手腕向上卷。练小臂内侧屈肌。', tips: ['前臂放凳上','手腕悬空','向上卷腕','练小臂内侧屈肌'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '前臂', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10111', name: '反向腕弯举', categoryPath: '力量训练 / 手臂训练 / 前臂', description: '掌心朝下握杠铃，手腕向上抬。练小臂伸肌，平衡避免网球肘。', tips: ['掌心朝下握杠','手腕向上抬','练小臂伸肌','平衡避免网球肘'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '前臂', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10112', name: '农夫行走', categoryPath: '力量训练 / 手臂训练 / 前臂', description: '双手握重哑铃/杠铃片行走，整体增厚小臂，同时强化握力。', tips: ['双手握重物行走','整体增厚小臂','强化握力','保持躯干稳定'], sets: 3, reps: 20, restSeconds: '60', difficulty: '中级', imageSvg: '前臂', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10113', name: '锤式弯举', categoryPath: '力量训练 / 手臂训练 / 前臂', description: '掌心相对握哑铃做弯举，顺带大量刺激肱桡肌（小臂外侧大块）。', tips: ['掌心相对握哑铃','做弯举动作','刺激肱桡肌','小臂外侧增厚'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '前臂', imageUrl: '', videoPath: '', weight: '0'),

    Exercise(id: '10114', name: '杠铃背深蹲', categoryPath: '力量训练 / 下肢训练 / 股四头肌', description: '杠铃架在斜方上束，挺胸，髋向后坐，膝盖跟随脚尖方向；下蹲至大腿平行地面或略低于平行。重点刺激股四，兼顾臀、腘绳、核心。决定下肢整体力量。', tips: ['杠铃架斜方上束','挺胸髋向后坐','膝盖跟随脚尖方向','下蹲至大腿平行'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: '股四头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10115', name: '杠铃前深蹲', categoryPath: '力量训练 / 下肢训练 / 股四头肌', description: '杠铃放在肩前锁骨位置，手肘抬起来。躯干更直立，股四头肌占比大幅提高，对踝关节灵活度要求高，腰压力更小。', tips: ['杠铃放肩前锁骨','手肘抬起来','躯干更直立','腰压力更小'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: '股四头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10116', name: '高脚杯深蹲', categoryPath: '力量训练 / 下肢训练 / 股四头肌', description: '抱壶铃于胸前，躯干直立，适合打磨深蹲模式，也可以做高次数充血。', tips: ['壶铃抱胸前','躯干直立','打磨深蹲模式','高次数充血'], sets: 3, reps: 12, restSeconds: '60', difficulty: '初级', imageSvg: '股四头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10117', name: '哑铃箭本蹲', categoryPath: '力量训练 / 下肢训练 / 股四头肌', description: '向前跨步下蹲，前后腿膝盖接近90度。单侧，修正左右腿力量差，股四刺激很强，兼顾臀部。', tips: ['向前跨步下蹲','前后腿膝盖90度','修正左右力量差','股四刺激强'], sets: 3, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: '股四头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10118', name: '保加利亚分腿蹲', categoryPath: '力量训练 / 下肢训练 / 股四头肌', description: '后脚搭凳子，身体下沉。单侧王牌，稳定要求高，股四+臀，可以不用大重量但刺激极强。', tips: ['后脚搭凳子','身体下沉','单侧王牌动作','股四臀刺激极强'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '股四头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10119', name: '哈克深蹲', categoryPath: '力量训练 / 下肢训练 / 股四头肌', description: '脚放在踏板偏下，站距与肩同宽，脚尖微外八。膝盖向前送出，躯干背靠靠背。脚位越低股四越强，腰椎压力远小于杠铃深蹲，可以上大重量。', tips: ['脚放踏板偏下','站距与肩同宽','膝盖向前送出','腰椎压力小'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '股四头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10120', name: '腿举机', categoryPath: '力量训练 / 下肢训练 / 股四头肌', description: '双脚放踏板中下区域，推起不锁膝，大重量堆股四围度。', tips: ['脚放踏板中下区域','推起不锁膝','大重量堆股四','腰部压力小'], sets: 4, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: '股四头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10121', name: '器械箭本蹲机', categoryPath: '力量训练 / 下肢训练 / 股四头肌', description: '固定轨迹单侧训练，省去平衡负担。', tips: ['固定轨迹','单侧训练','省去平衡负担','股四孤立'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '股四头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10122', name: '坐姿腿屈伸', categoryPath: '力量训练 / 下肢训练 / 股四头肌', description: '股四孤立动作，重点强化股内侧肌，中等重量控制，保护髌骨。', tips: ['孤立伸膝','强化股内侧肌','中等重量控制','保护髌骨'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '股四头肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10123', name: '罗马尼亚硬拉RDL', categoryPath: '力量训练 / 下肢训练 / 腘绳肌', description: '膝盖微弯固定不变，臀部向后推，杠铃贴着大腿向下滑，感受大腿后侧强烈拉伸，再收紧臀腘回到直立。重点腘绳，兼顾臀大肌。', tips: ['膝盖微弯固定','臀部向后推','杠铃贴大腿下滑','感受大腿后侧拉伸'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: '腘绳肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10124', name: '直腿硬拉', categoryPath: '力量训练 / 下肢训练 / 腘绳肌', description: '膝盖比RDL更直，腘绳拉伸更强，但对后侧柔韧性要求高，不要锁死膝盖。', tips: ['膝盖更直一些','腘绳拉伸更强','不要锁死膝盖','注意柔韧性'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '腘绳肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10125', name: '俯卧腿弯举', categoryPath: '力量训练 / 下肢训练 / 腘绳肌', description: '趴在器械上，脚踝勾住滚垫，脚跟向臀部勾，顶峰收缩。练腘绳首选器械。', tips: ['趴在器械上','脚踝勾住滚垫','脚跟向臀部勾','顶峰收缩'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '腘绳肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10126', name: '坐姿腿弯举', categoryPath: '力量训练 / 下肢训练 / 腘绳肌', description: '坐姿版本，屈膝，同样刺激腘绳；部分人俯卧腰不舒服就用坐姿。', tips: ['坐姿版本','屈膝刺激腘绳','俯卧腰不适者首选','同样有效'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '腘绳肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10127', name: '45度背伸器械', categoryPath: '力量训练 / 下肢训练 / 腘绳肌', description: '固定轨迹山羊挺身，限制过度后伸，安全做高次数，强化腘绳和竖脊肌。', tips: ['固定轨迹限制过度后伸','安全做高次数','强化腘绳竖脊肌','45度背伸'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '腘绳肌', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10128', name: '杠铃臀推', categoryPath: '力量训练 / 下肢训练 / 臀部训练', description: '上背靠凳子，杠铃放在髋部，脚掌踩实地面；向下落，然后发力顶髋至身体平直，顶峰夹紧臀部停留1-2秒。髋主导，臀大肌占比极高。', tips: ['上背靠凳子','杠铃放髋部','顶髋至身体平直','顶峰夹紧臀部1-2秒'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '臀部训练', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10129', name: '单腿哑铃髋桥', categoryPath: '力量训练 / 下肢训练 / 臀部训练', description: '单侧补强，改善臀两侧不平衡。', tips: ['仰卧单腿发力','改善臀两侧不平衡','替代臀推','孤立臀大肌'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '臀部训练', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10130', name: '自由相扑深蹲', categoryPath: '力量训练 / 下肢训练 / 臀部训练', description: '宽站距、脚尖外展，复合刺激臀大肌，顺带大腿内收。', tips: ['宽站距','脚尖外展','刺激臀大肌','顺带内收肌'], sets: 3, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: '臀部训练', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10131', name: '哈克深蹲臀主导高脚位', categoryPath: '力量训练 / 下肢训练 / 臀部训练', description: '双脚踩踏板上半部分，站距略宽脚尖外八；下蹲以臀部向后向下为主，减少膝盖前送。脚往上移，发力由股四转向臀大肌+腘绳肌。', tips: ['脚放踏板上半部分','站距略宽脚尖外八','臀部向后向下','减少膝盖前送'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '臀部训练', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10132', name: '相扑哈克深蹲', categoryPath: '力量训练 / 下肢训练 / 臀部训练', description: '哈克器械，宽站距，脚尖大幅外八，强化臀大肌与大腿内收。', tips: ['哈克器械宽站距','脚尖大幅外八','强化臀大肌','刺激内收肌'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '臀部训练', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10133', name: '哈克臀推', categoryPath: '力量训练 / 下肢训练 / 臀部训练', description: '斜躺哈克器械，脚掌踩踏板做顶髋，骨盆压力小于杠铃臀推，适合大重量轰炸臀部。', tips: ['斜躺哈克器械','脚掌踩踏板顶髋','骨盆压力小','大重量轰炸臀部'], sets: 4, reps: 10, restSeconds: '60', difficulty: '高级', imageSvg: '臀部训练', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10134', name: '专用器械臀推机', categoryPath: '力量训练 / 下肢训练 / 臀部训练', description: '固定轨迹，顶峰挤压臀部。', tips: ['固定轨迹','顶峰挤压臀部','安全冲重量','臀大肌王牌'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '臀部训练', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10135', name: '绳索跪姿后踢腿', categoryPath: '力量训练 / 下肢训练 / 臀部训练', description: '跪姿，脚踝扣绳索，向后上方踢腿，孤立臀大肌，减少大腿代偿。', tips: ['跪姿脚踝扣绳索','向后上方踢腿','孤立臀大肌','减少大腿代偿'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '臀部训练', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10136', name: '坐姿髋内收器械', categoryPath: '力量训练 / 下肢训练 / 内收肌群', description: '器械把双腿向外撑开，发力向内夹紧。专门练大腿内侧。', tips: ['双腿向外撑开','发力向内夹紧','专门练大腿内侧','改善内收肌弱'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '内收肌群', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10137', name: '站姿哑铃提踵', categoryPath: '力量训练 / 下肢训练 / 小腿训练', description: '站台阶边缘，脚跟往下放充分拉伸，向上顶起，顶峰挤压停顿。膝盖伸直，主攻腓肠肌。', tips: ['站台阶边缘','脚跟充分下放','膝盖伸直','主攻腓肠肌'], sets: 4, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '小腿训练', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10138', name: '站姿提踵机', categoryPath: '力量训练 / 下肢训练 / 小腿训练', description: '大重量堆腓肠肌，下放一定要做满拉伸。', tips: ['站姿提踵','大重量堆腓肠肌','下放做满拉伸','膝盖伸直'], sets: 4, reps: 12, restSeconds: '30', difficulty: '初级', imageSvg: '小腿训练', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10139', name: '哈克提踵', categoryPath: '力量训练 / 下肢训练 / 小腿训练', description: '哈克器械背靠靠背，脚掌踩踏板下沿做提踵，可以承受很大负重练腓肠肌。', tips: ['哈克器械背靠靠背','脚掌踩踏板下沿','大负重练腓肠肌','膝盖伸直'], sets: 4, reps: 12, restSeconds: '30', difficulty: '中级', imageSvg: '小腿训练', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10140', name: '坐姿提踵机', categoryPath: '力量训练 / 下肢训练 / 小腿训练', description: '膝盖弯曲状态做提踵。比目鱼肌占小腿体积很大，绝大多数人完全忽略这个动作。', tips: ['坐姿膝盖弯曲','练比目鱼肌','小腿体积很大','多数人忽略'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '小腿训练', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10141', name: '传统硬拉', categoryPath: '力量训练 / 下肢训练 / 后侧链综合', description: '全身动作，臀、腘绳、竖脊肌、股四都参与，后链力量之王。', tips: ['全身复合动作','后链力量之王','臀腘绳竖脊肌股四参与','大重量动作'], sets: 4, reps: 5, restSeconds: '120', difficulty: '高级', imageSvg: '后侧链综合', imageUrl: '', videoPath: '', weight: '0'),

  ];

  @override
  List<WorkoutSection> getSections() => WorkoutSection.values;

  @override
  List<TrainingCategory> getCategories(WorkoutSection section) {
    switch (section) {
      case WorkoutSection.strength:
        return _strengthCategories;
      case WorkoutSection.functional:
        return _functionalCategories;
      case WorkoutSection.yoga:
        return _yogaCategories;
    }
  }

  @override
  List<Exercise> getExercises(String categoryId) {
    if (categoryId == 'all') return List.from(_exercises);
    return _exercises
        .where((e) => e.categoryPath.contains(_getCategoryName(categoryId)))
        .toList();
  }

  @override
  List<Exercise> searchExercises(String query) {
    if (query.isEmpty) return _exercises;
    final q = query.toLowerCase();
    return _exercises
        .where((e) =>
            e.name.toLowerCase().contains(q) ||
            e.categoryPath.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  String _getCategoryName(String categoryId) {
    final map = <String, String>{
      'strength_upper': '上肢训练', 'strength_lower': '下肢训练', 'strength_core': '核心训练',
      'strength_chest': '胸部训练', 'strength_shoulders': '肩部训练', 'strength_back': '背部训练', 'strength_arms': '手臂训练',
      'chest_upper': '上胸', 'chest_middle': '中胸', 'chest_lower': '下胸',
      'shoulder_front': '前束', 'shoulder_mid': '中束', 'shoulder_rear': '后束', 'shoulder_rotator': '肩袖肌群',
      'back_lats': '背阔肌', 'back_upper': '上背厚度', 'back_traps_lower': '斜方下束', 'back_lower': '下背/竖脊肌',
      'arms_biceps': '肱二头肌', 'arms_triceps': '肱三头肌', 'arms_forearm': '前臂',
      'leg_quads': '股四头肌', 'leg_hamstrings': '腘绳肌', 'leg_glutes': '臀部', 'leg_calves': '小腿', 'leg_adductors': '内收肌群',
      'core_abs': '腹直肌', 'core_obliques': '腹斜肌',
      'func_core': '核心稳定', 'func_balance': '平衡训练', 'func_agility': '灵敏训练',
      'yoga_hatha': '哈他瑜伽', 'yoga_vinyasa': '流瑜伽', 'yoga_ashtanga': '阿斯汤加', 'yoga_restorative': '恢复瑜伽',
    };
    return map[categoryId] ?? categoryId;
  }
}
