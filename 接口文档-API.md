# 拍照识别热量 APP 接口文档（API）

文档版本：v1.0  
日期：2026-05-12  
接口风格：REST + JSON  
说明：MVP 以本地能力为主，以下接口适用于可选云端增强与数据同步。

## 1. 通用约定

- Base URL（示例）：`https://api.calorie-app.com/v1`
- 认证方式：`Authorization: Bearer <token>`
- Content-Type：`application/json`
- 时间格式：ISO 8601（UTC）

## 2. 错误码规范

| code | 含义 | 建议处理 |
| --- | --- | --- |
| 0 | 成功 | 正常处理 |
| 1001 | 参数错误 | 提示用户修正输入 |
| 1002 | 未授权 | 触发登录/刷新 token |
| 2001 | 识别失败 | 提示重试或手动输入 |
| 2002 | 数据未找到 | 使用本地兜底 |
| 3001 | 服务超时 | 自动重试 1 次 |
| 5000 | 服务异常 | 提示稍后重试 |

标准响应结构：

```json
{
  "code": 0,
  "message": "ok",
  "request_id": "req_xxx",
  "data": {}
}
```

## 3. 核心接口

## 3.1 食物营养信息查询

- Method：`GET`
- Path：`/nutrition/foods`
- 用途：查询食物单位热量（每克）。

请求参数：

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| name | string | 是 | 食物名称 |
| locale | string | 否 | 地域，如 zh-CN |

响应示例：

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "food_name": "红烧肉",
    "calorie_per_gram": 2.9,
    "source": "cn_food_table"
  }
}
```

## 3.2 批量营养信息查询

- Method：`POST`
- Path：`/nutrition/foods:batchGet`
- 用途：一次查询多个食物，减少请求次数。

请求示例：

```json
{
  "foods": ["红烧肉", "西兰花", "米饭"]
}
```

响应示例：

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "items": [
      { "food_name": "红烧肉", "calorie_per_gram": 2.9 },
      { "food_name": "西兰花", "calorie_per_gram": 0.34 },
      { "food_name": "米饭", "calorie_per_gram": 1.16 }
    ]
  }
}
```

## 3.3 记录同步（可选）

- Method：`POST`
- Path：`/records/sync`
- 用途：用户开启云同步后上传记录摘要（默认关闭）。

请求示例：

```json
{
  "record_id": "rec_001",
  "created_at": "2026-05-12T06:00:00Z",
  "total_calorie": 680.5,
  "items": [
    {
      "food_name": "米饭",
      "weight_grams": 150,
      "item_calorie": 174.0
    }
  ]
}
```

## 3.4 历史记录查询（可选）

- Method：`GET`
- Path：`/records`
- 用途：多设备场景拉取历史记录。

请求参数：

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| start_date | string | 否 | 开始日期（YYYY-MM-DD） |
| end_date | string | 否 | 结束日期（YYYY-MM-DD） |
| page | number | 否 | 页码，默认 1 |
| page_size | number | 否 | 每页条数，默认 20 |

## 4. 客户端接口契约（本地）

## 4.1 识别结果对象

```json
{
  "food_name": "西兰花",
  "confidence": 0.92,
  "weight_grams": 120.0,
  "calorie_per_gram": 0.34,
  "item_calorie": 40.8
}
```

## 4.2 记录对象

```json
{
  "record_id": "rec_001",
  "created_at": "2026-05-12T12:00:00+08:00",
  "image_local_uri": "file:///data/user/0/app/cache/xxx.jpg",
  "total_calorie": 420.5,
  "items": []
}
```

## 5. 重试与幂等

- 查询接口失败：可重试 1 次，退避 500ms。
- 同步接口建议使用 `record_id` 作为幂等键。
- 超时建议：连接 2s，读取 3s。

## 6. 安全要求

- 所有网络接口使用 HTTPS。
- token 过期后返回 1002，不返回业务数据。
- 服务端日志禁止记录完整图片路径和敏感信息。

## 7. 待确认事项

1. 是否在 MVP 即上线云同步接口（当前建议关闭）。
2. 第三方营养数据源优先级与授权限制。
3. 历史查询是否需要餐次维度（早/中/晚/加餐）。
