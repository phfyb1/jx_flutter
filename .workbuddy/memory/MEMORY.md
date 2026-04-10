# 项目长期记忆

## 开发工程路径

- **原工程（只读参考）**：`d:\flutterTest\jx_flutter`
- **开发工程（新功能开发）**：`d:\flutterTest\jx_flutter_dev`
  - 初始化自 jx_flutter 完整复制（2026-04-09）
  - 独立 git 仓库，初始提交 `init: copy from jx_flutter`
  - 确认功能正常后，由用户主动要求再同步回老工程

## jx_flutter 工程概况

- **项目定位**：面向物联网设备对接/运维开发的工具箱 Flutter 应用
- **应用标题**：协议解析
- **Flutter SDK**：Dart >=3.0.6
- **架构**：GetX MVC（pages / binding / controller / util 四层）
- **主要平台**：优先 Web（使用 dart:html Blob 下载文件），同时支持移动端（path_provider 写文件）

## 功能模块

| 模块 | 类型 | 说明 |
|------|------|------|
| JT809解析 | 协议解析 | 交通部车联网协议十六进制报文解析，支持1001/1002/1200三种消息类型 |
| ModBus解析 | 协议解析 | 标准/非标准两种模式，按寄存器地址解析 |
| ModBusServer解析 | 协议解析 | 服务器响应报文，支持4种字节序（大端DCBA/大端反转BADC/小端ABCD/小端反转CDAB）转float32 |
| HJ212造数据 | 数据生成 | 生成 TSDB 格式测试数据文件（支持Rtd/Avg类型） |
| 加氢站建表SQL | SQL生成 | 生成 TDengine 9类子表 CREATE TABLE 语句 |
| MQTT SQL生成 | SQL生成 | 生成 EMQX mqtt_user + mqtt_acl 的 INSERT SQL，SHA256加密密码 |
| 报警规则SQL工具（AlarmTool） | SQL生成 | 上传XLSX+JSON，生成4个IoT报警规则SQL文件 |
| 传感器报警规则SQL（SensorAlarmRule） | SQL生成 | AlarmTool重构版，仅上传XLSX，结果预览+导出 |

## 关键依赖

- `get: ^4.6.5` —— 状态管理/路由/依赖注入全家桶
- `excel: ^2.1.0` —— 解析 .xlsx 文件
- `file_picker: ^5.5.0` —— 文件选择
- `uuid: ^3.0.7` —— 生成 UUID v4
- `crypto: ^3.0.3` —— SHA256 加密
- `path_provider: ^2.1.1` —— 移动端文件保存
- `intl: ^0.18.1` —— 日期格式化

## 注意事项

- `HydrogenController` 和 `HJ212Controller` 直接使用 `dart:html`（仅限Web）
- `ModBusServer` 路由已注册但首页按钮被注释掉
- AlarmTool 和 SensorAlarmRule 功能高度重叠，前者分4个文件下载，后者预览+单文件导出
- `ControllerUtils.getSafeStringValue()` 是处理 excel package Cell 类型的核心安全函数
