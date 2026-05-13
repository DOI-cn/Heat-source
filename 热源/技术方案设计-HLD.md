# 拍照识别热量 APP 技术方案设计（HLD）

文档版本：v1.0  
日期：2026-05-12  
状态：草案（评审版）

## 1. 目标与约束

- 目标：实现端侧拍照识别、估重、热量计算与历史记录闭环。
- 约束：
  - 首期兼容 iOS 14+、Android 9+。
  - 主流程端到端 < 3 秒。
  - 默认本地处理图片数据，保护隐私。

## 2. 总体架构

```text
UI Layer（Flutter / React Native）
  -> 业务逻辑层（识别编排、估重、热量计算、历史管理）
    -> AI 推理层（TFLite / Core ML）
      -> 数据层（SQLite + 可选第三方营养 API）
```

## 3. 模块设计

## 3.1 UI 层

- 页面：
  - 首页（拍照入口、最近记录）
  - 识别结果页（食物明细、估重修正、总热量）
  - 历史页（日历/列表）
- 状态管理：
  - 建议使用单向数据流（如 Provider/Bloc/Redux 任一一致方案）。

## 3.2 业务逻辑层

- `RecognitionOrchestrator`：串联图片预处理、模型推理、后处理。
- `WeightEstimator`：优先自动估重，失败则走兜底。
- `CalorieCalculator`：统一热量计算口径。
- `RecordService`：保存/查询/删除本地记录。

## 3.3 AI 推理层

- 模型结构：目标检测（YOLOv8/YOLOv11）+ 实例分割（Mask R-CNN）。
- 推理框架：
  - Android：TFLite。
  - iOS：Core ML（或统一 TFLite，视性能结果）。
- 优化策略：
  - 量化（INT8/FP16）、
  - 输入尺寸裁剪、
  - 机型分层策略（低端机降级）。

## 3.4 数据层

- 本地数据库：SQLite。
- 数据实体：
  - `records`（记录头）
  - `record_items`（食物明细）
  - `food_nutrition`（食物营养表缓存）
- 第三方 API：仅补充本地缺失项，设置超时与缓存兜底。

## 4. 关键流程设计

## 4.1 主流程（拍照到保存）
1. 用户拍照/上传。
2. 执行推理，输出食物类别与分割结果。
3. 估算重量（自动或手动兜底）。
4. 查询营养库并计算热量。
5. 用户确认并保存记录。

## 4.2 异常流程

- 推理超时：提示重试并保留原图。
- 识别为空：引导手动添加条目。
- 营养库缺失：提示并允许仅保存重量信息。

## 5. 数据库草案

## 5.1 records
- id (TEXT, PK)
- created_at (DATETIME)
- image_local_uri (TEXT)
- total_calorie (REAL)

## 5.2 record_items
- id (TEXT, PK)
- record_id (TEXT, FK -> records.id)
- food_name (TEXT)
- confidence (REAL)
- weight_grams (REAL)
- calorie_per_gram (REAL)
- item_calorie (REAL)

## 5.3 food_nutrition
- food_name (TEXT, PK)
- calorie_per_gram (REAL)
- source (TEXT)
- updated_at (DATETIME)

## 6. 性能设计

- 目标：推理 < 2 秒，端到端 < 3 秒。
- 手段：
  - 首帧压缩与尺寸规范化；
  - 模型热启动；
  - 数据库批量写入减少 IO。

## 7. 安全与隐私

- 原图默认仅本地存储。
- 第三方同步关闭为默认态，需显式授权开启。
- 提供本地数据一键清理接口。

## 8. 可观测性与埋点

- 埋点事件：
  - `capture_started`
  - `recognition_succeeded/failed`
  - `weight_manual_fallback`
  - `record_saved`
- 指标：
  - 识别成功率
  - 主流程完成率
  - 平均耗时与分位耗时（P50/P95）

## 9. 发布与回滚

- 模型与 App 解耦版本管理（模型版本号独立）。
- 灰度发布：先内部 100 人，再扩大比例。
- 回滚策略：
  - 识别准确率显著下降；
  - 推理耗时超阈值；
  - 崩溃率异常上涨。

## 10. 技术风险与缓解

- 模型精度不足：增加中餐数据与用户纠错闭环。
- 估重误差偏大：引入参考物引导与分场景策略。
- 低端机性能不足：降级模型或分辨率策略。
