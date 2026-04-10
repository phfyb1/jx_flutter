import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/SensorAlarmRuleController.dart';

class SensorAlarmRulePage extends StatefulWidget {
  const SensorAlarmRulePage({super.key});

  @override
  State<SensorAlarmRulePage> createState() => _SensorAlarmRulePageState();
}

class _SensorAlarmRulePageState extends State<SensorAlarmRulePage> {
  final SensorAlarmRuleController controller =
      Get.put(SensorAlarmRuleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('传感器和报警规则SQL生成工具'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('传感器和报警规则SQL生成工具',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 30),
                // 文件上传区域
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('上传Excel文件',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 20),
                        Obx(() => Text(
                              controller.xlsxFileName.value.isEmpty
                                  ? '未选择文件'
                                  : '已选择: ${controller.xlsxFileName.value}',
                              style: TextStyle(
                                  color: controller.xlsxFileName.value.isEmpty
                                      ? Colors.grey
                                      : Colors.black87),
                            )),
                        const SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            labelText: '公司名称',
                            hintText: '请输入公司名称',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 12),
                          ),
                          onChanged: (value) =>
                              controller.companyName.value = value,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file, size: 20),
                          label: const Text('选择Excel文件',
                              style: TextStyle(fontSize: 16)),
                          onPressed: controller.pickXlsxFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_circle, size: 20),
                          label: const Text('开始生成SQL',
                              style: TextStyle(fontSize: 16)),
                          onPressed: controller.processFiles,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // 状态显示区域
                Obx(() => controller.statusMessage.value.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(controller.statusType.value),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _getStatusIcon(controller.statusType.value),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(controller.statusMessage.value)),
                          ],
                        ),
                      )
                    : const SizedBox.shrink()),
                const SizedBox(height: 30),
                // SQL预览和导出区域
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SQL预览',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Obx(
                          () => controller.isGenerating.value
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 3),
                                ))
                              : Container(
                                  height: 250,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[50],
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      controller.sqlResult.value.isEmpty
                                          ? '请上传Excel文件并点击"开始生成SQL"按钮以查看结果'
                                          : controller.sqlResult.value,
                                      style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: controller.sqlResult.value.isEmpty
                                  ? null
                                  : controller.downloadFile,
                              child: const Text('导出SQL到文件'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 12),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: controller.jsonResult.value.isEmpty
                                  ? null
                                  : () => controller.downloadFile(
                                      type: 'json',
                                      fileName: 'alarm_rules.json'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 12),
                              ),
                              child: const Text('导出JSON到文件'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // JSON预览区域
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('JSON预览',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Obx(
                          () => controller.isGenerating.value
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 3),
                                ))
                              : Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[50],
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      controller.jsonResult.value.isEmpty
                                          ? '请上传Excel文件并点击"开始生成SQL"按钮以查看结果'
                                          : controller.jsonResult.value,
                                      style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(StatusType status) {
    switch (status) {
      case StatusType.success:
        return Colors.green[100]!;
      case StatusType.error:
        return Colors.red[100]!;
      case StatusType.info:
        return Colors.blue[50]!;
      default:
        return Colors.transparent;
    }
  }

  Widget _getStatusIcon(StatusType status) {
    switch (status) {
      case StatusType.success:
        return Icon(Icons.check_circle, color: Colors.green[700], size: 20);
      case StatusType.error:
        return Icon(Icons.error, color: Colors.red[700], size: 20);
      case StatusType.info:
        return Icon(Icons.info, color: Colors.blue[700], size: 20);
      default:
        return Container();
    }
  }
}
