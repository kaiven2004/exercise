import '../models/models.dart';
import 'exercise_repository.dart';

class SampleExerciseRepository implements ExerciseRepository {
  static const List<TrainingCategory> _strengthCategories = [
    TrainingCategory(
      id: 'strength_upper',
      name: '涓婅偄璁粌',
      section: WorkoutSection.strength,
      svgIcon: 'arm',
      subCategories: [
        TrainingCategory(
          id: 'strength_chest',
          name: '鑳搁儴璁粌',
          section: WorkoutSection.strength,
          svgIcon: 'chest',
          subCategories: [
            TrainingCategory(id: 'chest_upper', name: '涓婅兏', section: WorkoutSection.strength, svgIcon: 'chest_upper'),
            TrainingCategory(id: 'chest_middle', name: '涓兏', section: WorkoutSection.strength, svgIcon: 'chest'),
            TrainingCategory(id: 'chest_lower', name: '涓嬭兏', section: WorkoutSection.strength, svgIcon: 'chest_lower'),
          ],
        ),
        TrainingCategory(
          id: 'strength_shoulders',
          name: '鑲╅儴璁粌',
          section: WorkoutSection.strength,
          svgIcon: 'shoulder',
          subCategories: [
            TrainingCategory(id: 'shoulder_front', name: '鍓嶆潫', section: WorkoutSection.strength, svgIcon: 'shoulder_front'),
            TrainingCategory(id: 'shoulder_mid', name: '涓潫', section: WorkoutSection.strength, svgIcon: 'shoulder_mid'),
            TrainingCategory(id: 'shoulder_rear', name: '鍚庢潫', section: WorkoutSection.strength, svgIcon: 'shoulder_rear'),
          ],
        ),
        TrainingCategory(
          id: 'strength_back',
          name: '鑳岄儴璁粌',
          section: WorkoutSection.strength,
          svgIcon: 'back',
          subCategories: [
            TrainingCategory(id: 'back_lats', name: '鑳岄様鑲?, section: WorkoutSection.strength, svgIcon: 'back_lats'),
            TrainingCategory(id: 'back_traps', name: '鏂滄柟鑲?, section: WorkoutSection.strength, svgIcon: 'back_traps'),
          ],
        ),
        TrainingCategory(
          id: 'strength_arms',
          name: '鎵嬭噦璁粌',
          section: WorkoutSection.strength,
          svgIcon: 'arm',
          subCategories: [],
        ),
      ],
    ),
    TrainingCategory(
      id: 'strength_lower',
      name: '涓嬭偄璁粌',
      section: WorkoutSection.strength,
      svgIcon: 'leg',
      subCategories: [
        TrainingCategory(id: 'leg_quads', name: '鑲″洓澶磋倢', section: WorkoutSection.strength, svgIcon: 'leg_quads'),
        TrainingCategory(id: 'leg_hamstrings', name: '鑵樼怀鑲?, section: WorkoutSection.strength, svgIcon: 'leg_hamstrings'),
        TrainingCategory(id: 'leg_glutes', name: '鑷€閮ㄨ缁?, section: WorkoutSection.strength, svgIcon: 'leg_glutes'),
        TrainingCategory(id: 'leg_calves', name: '灏忚吙璁粌', section: WorkoutSection.strength, svgIcon: 'leg'),
      ],
    ),
    TrainingCategory(
      id: 'strength_core',
      name: '鏍稿績璁粌',
      section: WorkoutSection.strength,
      svgIcon: 'core',
      subCategories: [
        TrainingCategory(id: 'core_abs', name: '鑵圭洿鑲?, section: WorkoutSection.strength, svgIcon: 'core_abs'),
        TrainingCategory(id: 'core_obliques', name: '鑵规枩鑲?, section: WorkoutSection.strength, svgIcon: 'core_obliques'),
      ],
    ),
  ];

  static const List<TrainingCategory> _functionalCategories = [
    TrainingCategory(id: 'func_core', name: '鏍稿績绋冲畾', section: WorkoutSection.functional, svgIcon: 'core', subCategories: []),
    TrainingCategory(id: 'func_balance', name: '骞宠　璁粌', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
    TrainingCategory(id: 'func_agility', name: '鐏垫晱璁粌', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
  ];

  static const List<TrainingCategory> _yogaCategories = [
    TrainingCategory(id: 'yoga_hatha', name: '鍝堜粬鐟滀冀', section: WorkoutSection.yoga, svgIcon: 'yoga_hatha', subCategories: []),
    TrainingCategory(id: 'yoga_vinyasa', name: '娴佺憸浼?, section: WorkoutSection.yoga, svgIcon: 'yoga_vinyasa', subCategories: []),
    TrainingCategory(id: 'yoga_ashtanga', name: '闃挎柉姹ゅ姞', section: WorkoutSection.yoga, svgIcon: 'yoga_ashtanga', subCategories: []),
    TrainingCategory(id: 'yoga_restorative', name: '鎭㈠鐟滀冀', section: WorkoutSection.yoga, svgIcon: 'yoga_restorative', subCategories: []),
  ];

  static const List<Exercise> _exercises = [
    // 涓婅兏
    Exercise(id: '1', name: '涓婃枩鏉犻搩鍗ф帹', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳搁儴璁粌 / 涓婅兏', description: '浠板崸浜庝笂鏂滃嚦锛?0-45搴︼級锛屽弻鎵嬫彙鏉犵暐瀹戒簬鑲╋紝涓嬫斁鑷宠兏涓婃部锛屾帹璧锋椂鍛兼皵銆?, tips: ['鑲╄儧楠ㄦ敹绱ц创鍑?, '鏉犻搩涓嬫斁鑷充钩澶翠笂缂?, '鏍稿績鏀剁揣锛屼笉瑕佹嫳鑵?], sets: 4, reps: 8, restSeconds: '90', difficulty: '涓骇', imageSvg: 'chest_upper', videoPath: ''),
    Exercise(id: '2', name: '涓婃枩鍝戦搩鍗ф帹', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳搁儴璁粌 / 涓婅兏', description: '浠板崸涓婃枩鍑筹紝鍙屾墜鎸佸搼閾冿紝浠庤偐閮ㄤ袱渚ф帹璧疯嚦澶撮《涓婃柟锛岀紦鎱笅鏀俱€?, tips: ['鍝戦搩涓嶈纰版挒', '鎺у埗涓嬭惤閫熷害', '椤跺嘲鏀剁缉1绉?], sets: 3, reps: 10, restSeconds: '60', difficulty: '鍒濈骇', imageSvg: 'chest_upper', videoPath: ''),
    // 涓兏
    Exercise(id: '3', name: '骞虫澘鏉犻搩鍗ф帹', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳搁儴璁粌 / 涓兏', description: '浠板崸浜庡钩鍑筹紝鍙岃剼韪╁疄鍦伴潰锛屽弻鎵嬫彙鏉犵暐瀹戒簬鑲╋紝涓嬫斁鑷宠兏涓儴锛屾帹璧枫€?, tips: ['鑲╄儧楠ㄦ敹绱?, '鏉犻搩瑙﹁兏鍚庡揩閫熸帹璧?, '涓嶈瀹屽叏閿佹鑲樺叧鑺?], sets: 4, reps: 8, restSeconds: '90', difficulty: '涓骇', imageSvg: 'chest', videoPath: ''),
    Exercise(id: '4', name: '骞虫澘鍝戦搩鍗ф帹', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳搁儴璁粌 / 涓兏', description: '浠板崸骞冲嚦锛屽弻鎵嬫寔鍝戦搩锛屼粠鑳搁儴涓や晶鎺ㄨ捣鑷冲ご椤讹紝缂撴參涓嬫斁銆?, tips: ['鍝戦搩涓嶈纰版挒', '涓嬫斁鏃舵劅鍙楄兏閮ㄦ媺浼?, '鏍稿績鏀剁揣'], sets: 3, reps: 10, restSeconds: '60', difficulty: '鍒濈骇', imageSvg: 'chest', videoPath: ''),
    Exercise(id: '5', name: '鍝戦搩椋為笩', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳搁儴璁粌 / 涓兏', description: '浠板崸骞冲嚦锛屽弻鎵嬫寔鍝戦搩鍚戜笂浼哥洿锛屽悜涓や晶鎵撳紑鑷宠兏閮ㄦ湁鎷変几鎰燂紝鐒跺悗杩樺師銆?, tips: ['鑲橀儴寰眻', '鎰熷彈鑳搁儴鎷変几', '涓嶈涓嬫斁澶綆'], sets: 3, reps: 12, restSeconds: '45', difficulty: '鍒濈骇', imageSvg: 'chest', videoPath: ''),
    // 涓嬭兏
    Exercise(id: '6', name: '鍙屾潬鑷傚眻浼?, categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳搁儴璁粌 / 涓嬭兏', description: '鍙屾墜鎾戝弻鏉狅紝韬綋鍓嶅€撅紝灞堣倶涓嬫斁鑷宠偐閮ㄤ笌鎵嬪钩锛岀劧鍚庢帹璧枫€?, tips: ['韬綋鍓嶅€句富瑕佺粌鑳?, '涓嬫斁鑷宠偐閮ㄤ笌鎵嬪钩', '涓嶈瀹屽叏閿佹鑲?], sets: 3, reps: 10, restSeconds: '60', difficulty: '涓骇', imageSvg: 'chest_lower', videoPath: ''),
    Exercise(id: '7', name: '涓嬫枩鍗ф帹', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳搁儴璁粌 / 涓嬭兏', description: '浠板崸浜庝笅鏂滃嚦锛屽弻鎵嬫彙鏉狅紝浠庤兏閮ㄤ笅鏂规帹璧疯嚦鎵嬭噦浼哥洿銆?, tips: ['涓嬫枩瑙掑害涓嶈澶ぇ', '鎺у埗鑺傚', '鎰熷彈涓嬭兏鍙戝姏'], sets: 3, reps: 10, restSeconds: '60', difficulty: '涓骇', imageSvg: 'chest_lower', videoPath: ''),
    Exercise(id: '8', name: '缁崇储澶硅兏', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳搁儴璁粌 / 涓嬭兏', description: '绔欑珛浜庨楦熸満涓棿锛屽弻鎵嬫寔鎶婃墜锛屼粠楂樺鍚戜腑闂村す鑳搞€?, tips: ['鎵嬭倶寰眻', '椤跺嘲鏀剁缉1绉?, '涓嶈鍊熷姏鎽嗗姩'], sets: 3, reps: 12, restSeconds: '45', difficulty: '鍒濈骇', imageSvg: 'chest_lower', videoPath: ''),
    // 鍓嶆潫
    Exercise(id: '9', name: '鏉犻搩鐩寸珛鍒掕埞', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑲╅儴璁粌 / 鍓嶆潫', description: '鍙屾墜鎻℃潬锛屼粠浣撳墠鍚戜笂鎻愭媺鑷宠兏閮ㄩ珮搴︼紝鑲橀儴楂樹簬鎵嬭厱銆?, tips: ['鑲橀儴濮嬬粓楂樹簬鎵嬭厱', '涓嶈鎻愭媺杩囬珮', '鏍稿績鏀剁揣'], sets: 3, reps: 10, restSeconds: '60', difficulty: '涓骇', imageSvg: 'shoulder_front', videoPath: ''),
    Exercise(id: '10', name: '鏉犻搩鍓嶅钩涓?, categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑲╅儴璁粌 / 鍓嶆潫', description: '鍙屾墜鎸佹潬閾冧簬浣撳墠锛屽悜鍓嶅钩涓捐嚦涓庤偐鍚岄珮锛岀紦鎱笅鏀俱€?, tips: ['涓嶈鍊熷姏鎽嗗姩', '椤跺嘲鏀剁缉', '鎺у埗涓嬫斁閫熷害'], sets: 3, reps: 12, restSeconds: '45', difficulty: '鍒濈骇', imageSvg: 'shoulder_front', videoPath: ''),
    // 涓潫
    Exercise(id: '11', name: '鍝戦搩渚у钩涓?, categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑲╅儴璁粌 / 涓潫', description: '鍙屾墜鎸佸搼閾冧簬浣撲晶锛屽悜涓や晶涓捐捣鑷充笌鑲╁悓楂橈紝缂撴參涓嬫斁銆?, tips: ['鎵嬭倶寰眻', '涓嶈鍊熷姏', '椤跺嘲鍋滈】1绉?], sets: 4, reps: 12, restSeconds: '45', difficulty: '鍒濈骇', imageSvg: 'shoulder_mid', videoPath: ''),
    Exercise(id: '12', name: '缁崇储渚у钩涓?, categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑲╅儴璁粌 / 涓潫', description: '绔欑珛浜庨楦熸満涓€渚э紝鎵嬫寔鎶婃墜鍚戜晶鏂逛妇璧疯嚦涓庤偐鍚岄珮銆?, tips: ['韬綋寰晶', '鎺у埗鑺傚', '涓嶈鍊熷姏'], sets: 3, reps: 12, restSeconds: '45', difficulty: '鍒濈骇', imageSvg: 'shoulder_mid', videoPath: ''),
    // 鍚庢潫
    Exercise(id: '13', name: '淇韩鍝戦搩椋為笩', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑲╅儴璁粌 / 鍚庢潫', description: '淇韩锛屽弻鎵嬫寔鍝戦搩锛屽悜涓や晶涓捐捣鑷充笌鑲╁悓楂橈紝鎰熷彈鍚庢潫鏀剁缉銆?, tips: ['淇韩绾?5搴?, '鎵嬭倶寰眻', '涓嶈鍊熷姏'], sets: 3, reps: 12, restSeconds: '45', difficulty: '鍒濈骇', imageSvg: 'shoulder_rear', videoPath: ''),
    // 鑳岄様鑲?    Exercise(id: '14', name: '寮曚綋鍚戜笂', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳岄儴璁粌 / 鑳岄様鑲?, description: '姝ｆ墜鎶撴潬锛岃韩浣撴偓鍨傦紝鎷夎嚦涓嬪反瓒呰繃鏉狅紝缂撴參涓嬫斁銆?, tips: ['鍏ㄧ▼鎺у埗', '涓嶈鍊熷姏鎽嗗姩', '涓嬫斁鏃舵劅鍙楄儗閮ㄦ媺浼?], sets: 4, reps: 6, restSeconds: '120', difficulty: '楂樼骇', imageSvg: 'back_lats', videoPath: ''),
    Exercise(id: '15', name: '鏉犻搩鍒掕埞', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳岄儴璁粌 / 鑳岄様鑲?, description: '淇韩绾?5搴︼紝鍙屾墜鎻℃潬锛屽皢鏉犻搩鎷夊悜鑵归儴锛岀紦鎱笅鏀俱€?, tips: ['淇濇寔鑳岄儴骞崇洿', '鑲橀儴璐磋繎韬綋', '鎷夎嚦鑵归儴浣嶇疆'], sets: 4, reps: 8, restSeconds: '90', difficulty: '涓骇', imageSvg: 'back_lats', videoPath: ''),
    Exercise(id: '16', name: '楂樹綅涓嬫媺', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳岄儴璁粌 / 鑳岄様鑲?, description: '鍧愬Э锛屽弻鎵嬪鎻℃妸鎵嬶紝鍚戜笅鎷夎嚦鑳稿墠锛屾劅鍙楄儗閮ㄦ敹缂┿€?, tips: ['涓嶈鍊熷姏鍚庝话', '鎷夎嚦鑳稿墠', '椤跺嘲鏀剁缉'], sets: 3, reps: 10, restSeconds: '60', difficulty: '鍒濈骇', imageSvg: 'back_lats', videoPath: ''),
    // 鏂滄柟鑲?    Exercise(id: '17', name: '鏉犻搩鑰歌偐', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳岄儴璁粌 / 鏂滄柟鑲?, description: '鍙屾墜鎸佹潬閾冧簬浣撳墠锛屽悜涓婅€歌偐鑷虫渶楂樼偣锛岀◢鍋滃悗缂撴參涓嬫斁銆?, tips: ['鍙湁鑲╄儧楠ㄨ繍鍔?, '涓嶈鏃嬭浆鑲╄唨', '椤跺嘲鏀剁缉2绉?], sets: 4, reps: 12, restSeconds: '45', difficulty: '鍒濈骇', imageSvg: 'back_traps', videoPath: ''),
    Exercise(id: '18', name: '鍝戦搩鍗曡噦鍒掕埞', categoryPath: '鍔涢噺璁粌 / 涓婅偄 / 鑳岄儴璁粌 / 鏂滄柟鑲?, description: '鍗曟墜鎾戝嚦锛屽彟涓€鎵嬫寔鍝戦搩鍒掕埞鑷宠叞閮紝鎰熷彈鑳岄儴鏀剁缉銆?, tips: ['鑳岄儴淇濇寔骞崇洿', '鑲橀儴璐磋繎韬綋', '涓嶈鍊熷姏'], sets: 3, reps: 10, restSeconds: '60', difficulty: '鍒濈骇', imageSvg: 'back_traps', videoPath: ''),
    // 鑲″洓澶磋倢
    Exercise(id: '19', name: '鏉犻搩娣辫共', categoryPath: '鍔涢噺璁粌 / 涓嬭偄 / 鑲″洓澶磋倢', description: '鏉犻搩缃簬鑲╁悗锛屽弻鑴氫笌鑲╁悓瀹斤紝涓嬭共鑷冲ぇ鑵夸笌鍦伴潰骞宠锛岀珯璧枫€?, tips: ['鑶濈洊涓嶈鍐呮墸', '涓嬭共鑷冲ぇ鑵垮钩琛?, '鏍稿績鏀剁揣'], sets: 4, reps: 8, restSeconds: '120', difficulty: '楂樼骇', imageSvg: 'leg_quads', videoPath: ''),
    Exercise(id: '20', name: '鏉犻搩鑵垮集涓?, categoryPath: '鍔涢噺璁粌 / 涓嬭偄 / 鑲″洓澶磋倢', description: '淇崸浜庤吙寮妇鏈猴紝灏嗗皬鑵垮悜鍚庡集涓捐嚦澶ц吙鍚庢柟锛岀紦鎱笅鏀俱€?, tips: ['鍔ㄤ綔缂撴參鎺у埗', '涓嶈瀹屽叏浼哥洿', '椤跺嘲鏀剁缉1绉?], sets: 3, reps: 12, restSeconds: '60', difficulty: '鍒濈骇', imageSvg: 'leg_quads', videoPath: ''),
    // 鑵樼怀鑲?    Exercise(id: '21', name: '缃楅┈灏间簹纭媺', categoryPath: '鍔涢噺璁粌 / 涓嬭偄 / 鑵樼怀鑲?, description: '鍙屾墜鎸佹潬閾冿紝寰眻鑶濓紝鍚戝墠閫侀珛鑷冲ぇ鑵垮悗渚ф湁鎷変几鎰燂紝鐒跺悗杩樺師銆?, tips: ['鑳岄儴淇濇寔骞崇洿', '鏉犻搩璐磋繎鑵块儴', '鎰熷彈澶ц吙鍚庝晶鎷変几'], sets: 4, reps: 8, restSeconds: '90', difficulty: '涓骇', imageSvg: 'leg_hamstrings', videoPath: ''),
    Exercise(id: '22', name: '鑵垮集涓?, categoryPath: '鍔涢噺璁粌 / 涓嬭偄 / 鑵樼怀鑲?, description: '淇崸浜庤吙寮妇鏈猴紝灏嗗皬鑵垮悜鍚庡集涓捐嚦澶ц吙鍚庢柟锛岀紦鎱笅鏀俱€?, tips: ['鍔ㄤ綔缂撴參鎺у埗', '涓嶈瀹屽叏浼哥洿', '椤跺嘲鏀剁缉1绉?], sets: 3, reps: 12, restSeconds: '60', difficulty: '鍒濈骇', imageSvg: 'leg_hamstrings', videoPath: ''),
    // 鑷€閮?    Exercise(id: '23', name: '鑷€妗?, categoryPath: '鍔涢噺璁粌 / 涓嬭偄 / 鑷€閮ㄨ缁?, description: '浠板崸锛屽弻鑴氳俯鍦帮紝鑷€閮ㄥ彂鍔涘皢楂嬮儴鎺ㄨ捣鑷宠韩浣撴垚鐩寸嚎锛岄《宄版敹缂┿€?, tips: ['椤跺嘲鏃跺す绱ц噣閮?, '涓嶈杩囧害鎷辫叞', '鎰熷彈鑷€閮ㄥ彂鍔?], sets: 3, reps: 15, restSeconds: '60', difficulty: '鍒濈骇', imageSvg: 'leg_glutes', videoPath: ''),
    Exercise(id: '24', name: '淇濆姞鍒╀簹鍒嗚吙韫?, categoryPath: '鍔涢噺璁粌 / 涓嬭偄 / 鑷€閮ㄨ缁?, description: '鍚庤剼鎶珮缃簬鍑充笂锛屽墠鑴氳共涓嬭嚦澶ц吙涓庡湴闈㈠钩琛岋紝绔欒捣銆?, tips: ['閲嶅績鍦ㄥ墠鑴?, '涓嬭共鏃惰啙鐩栦笉瑕佽秴杩囪剼灏栧お澶?, '淇濇寔韬綋鐩寸珛'], sets: 3, reps: 10, restSeconds: '60', difficulty: '涓骇', imageSvg: 'leg_glutes', videoPath: ''),
    // 鑵圭洿鑲?    Exercise(id: '25', name: '鍗疯吂', categoryPath: '鍔涢噺璁粌 / 鏍稿績璁粌 / 鑵圭洿鑲?, description: '浠板崸锛屽眻鑶濓紝鑲╄儧楠ㄧ鍦帮紝鍗疯捣涓婂崐韬紝鎰熷彈鑵归儴鏀剁缉銆?, tips: ['涓嶈鎶卞ご鐢ㄥ姏', '鐢ㄨ吂閮ㄥ彂鍔涘甫鍔?, '涓嬭儗閮ㄨ创鍦?], sets: 3, reps: 20, restSeconds: '45', difficulty: '鍒濈骇', imageSvg: 'core_abs', videoPath: ''),
    Exercise(id: '26', name: '鎮瀭涓捐吙', categoryPath: '鍔涢噺璁粌 / 鏍稿績璁粌 / 鑵圭洿鑲?, description: '鎮瀭浜庡崟鏉狅紝鍙岃吙骞舵嫝涓捐嚦涓庤韩浣撴垚90搴︼紝缂撴參涓嬫斁銆?, tips: ['涓嶈鍊熷姏鎽嗗姩', '鐢ㄨ吂閮ㄥ彂鍔?, '涓嬫斁鏃舵帶鍒堕€熷害'], sets: 3, reps: 10, restSeconds: '60', difficulty: '楂樼骇', imageSvg: 'core_abs', videoPath: ''),
    // 鑵规枩鑲?    Exercise(id: '27', name: '淇勭綏鏂浆浣?, categoryPath: '鍔涢噺璁粌 / 鏍稿績璁粌 / 鑵规枩鑲?, description: '鍧愬Э灞堣啙锛岃韩浣撳悗鍊撅紝鍙屾墜鎸侀噸鐗╁乏鍙宠浆鍔ㄨ函骞层€?, tips: ['閲嶅績鍦ㄥ潗楠?, '杞姩涓婂崐韬?, '涓嶈鍙姩鎵嬭噦'], sets: 3, reps: 20, restSeconds: '45', difficulty: '鍒濈骇', imageSvg: 'core_obliques', videoPath: ''),
    Exercise(id: '28', name: '骞虫澘鏀拺', categoryPath: '鍔涢噺璁粌 / 鏍稿績璁粌 / 鑵规枩鑲?, description: '淇崸锛屽墠鑷傛拺鍦帮紝韬綋鎴愮洿绾匡紝淇濇寔闈欐銆?, tips: ['韬綋淇濇寔鐩寸嚎', '涓嶈濉岃叞', '鍧囧寑鍛煎惛'], sets: 3, reps: 60, restSeconds: '45', difficulty: '鍒濈骇', imageSvg: 'core_obliques', videoPath: ''),
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
    return _exercises
        .where((e) => e.categoryPath.contains(_getCategoryName(categoryId)))
        .toList();
  }

  @override
  List<Exercise> searchExercises(String query) {
    if (query.isEmpty) return _exercises;
    final q = query.toLowerCase();
    return _exercises
        .where(
          (e) =>
              e.name.toLowerCase().contains(q) ||
              e.categoryPath.toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q),
        )
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
    final map = {
      'chest_upper': '涓婅兏',
      'chest_middle': '涓兏',
      'chest_lower': '涓嬭兏',
      'shoulder_front': '鍓嶆潫',
      'shoulder_mid': '涓潫',
      'shoulder_rear': '鍚庢潫',
      'back_lats': '鑳岄様鑲?,
      'back_traps': '鏂滄柟鑲?,
      'leg_quads': '鑲″洓澶磋倢',
      'leg_hamstrings': '鑵樼怀鑲?,
      'leg_glutes': '鑷€閮?,
      'core_abs': '鑵圭洿鑲?,
      'core_obliques': '鑵规枩鑲?,
    };
    return map[categoryId] ?? categoryId;
  }
}
