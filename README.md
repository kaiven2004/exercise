# Excise - 健身训练应用

力量训练 · 功能训练 · 瑜伽训练 · 自定义计划

## 功能

### 三大训练板块
- 力量训练 - 按部位分类（上肢/下肢/核心），细分到肌肉群
- 功能训练 - 核心稳定、平衡、灵敏训练
- 瑜伽训练 - 哈他、流瑜伽、阿斯汤加、恢复瑜伽

### 自定义训练计划
- 在自定义标签页创建个性化训练方案
- 自由添加任意多个动作，可从力量/功能/瑜伽三个板块选择
- 每个动作可自定义组数、次数、组间休息
- 支持拖拽排序动作顺序
- 训练时显示进度条、倒计时、完成统计

### 其他功能
- 搜索动作（名称/部位/要领）
- 收藏动作
- 训练历史记录
- 动作详情页含视频播放器（可插入讲解视频）
- 纯 SVG 图标，无 Emoji

## 添加视频

将 MP4 视频放入 assets/videos/ 目录，然后在 sample_repository.dart 中为动作设置 videoPath。

## 技术栈

- Flutter 3.x
- video_player + chewie（视频播放）
- shared_preferences（本地存储）
- flutter_svg（图标）

## 构建

    flutter build apk --debug
    adb install -r build/app/outputs/flutter-apk/app-debug.apk