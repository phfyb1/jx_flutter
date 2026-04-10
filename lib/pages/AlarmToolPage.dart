import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controller/AlarmToolController.dart';

class _StatusConfig {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  _StatusConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}

const Color warningColor = Color(0xFFF59E0B);

enum StatusType { none, info, success, error }

class AlarmToolPage extends StatefulWidget {
  @override
  _AlarmToolPageState createState() => _AlarmToolPageState();
}

class _AlarmToolPageState extends State<AlarmToolPage> {
  bool _generateButtonHovered = false;
  final Map<int, bool> _fileHoverStates = {};

  late final AlarmToolController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AlarmToolController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('报警规则SQL生成工具'),
          // backgroundColor: Colors.white,
          // elevation: 0,
          // centerTitle: true,
          // titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
          // iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
            child: Center(
                child: Container(
          padding: EdgeInsets.all(20),
          constraints: BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('报警规则SQL生成工具',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildFileUploadSection(
                  '上传XLSX文件', controller.pickXlsxFile, controller.xlsxFileName),
              _buildFileUploadSection('上传iot_device_sensor.json文件',
                  controller.pickJsonFile, controller.jsonFileName),
              _buildCompanyNameInput(),
              SizedBox(height: 30),
              _buildGenerateButton(),
              SizedBox(height: 20),
              Obx(() => _buildStatusDisplay(
                  controller.status.value, controller.statusType.value)),
              SizedBox(height: 20),
              Obx(() => _buildDownloadSection(controller.sqlFiles))
            ],
          ),
        ))));
  }

  // 生成按钮
  Widget _buildGenerateButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _generateButtonHovered = true),
      onExit: (_) => setState(() => _generateButtonHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: _handleGenerateSql,
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('3. 生成SQL文件',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
          ),
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF4CAF50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  // 处理SQL生成
  void _handleGenerateSql() {
    if (controller.companyName.value.isEmpty) {
      Get.dialog(AlertDialog(
        title: Text('错误'),
        content: Text('请输入公司名称'),
        actions: [
          TextButton(
            child: Text('确定'),
            onPressed: () => Get.back(),
          )
        ],
      ));
      return;
    }
    controller.processFiles();
  }

  Widget _buildCompanyNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('公司名称',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800])),
        SizedBox(height: 12),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[100]!),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              onChanged: (value) => controller.companyName.value = value,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '请输入公司名称',
                hintStyle: TextStyle(color: Colors.grey[400]),
                contentPadding: EdgeInsets.symmetric(vertical: 18),
                prefixIcon:
                    Icon(Icons.business, color: Colors.grey[400], size: 20),
              ),
              style: TextStyle(fontSize: 15, color: Colors.grey[800]),
            ),
          ),
        ),
        SizedBox(height: 28),
      ],
    );
  }

  Widget _buildFileUploadSection(
      String label, VoidCallback onPressed, RxString fileName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
        SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Obx(() => Text(
                    fileName.value.isEmpty ? '未选择文件' : fileName.value,
                    style: TextStyle(
                      color: fileName.value.isEmpty
                          ? Colors.grey[500]
                          : Colors.black,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: onPressed,
                child: Text('选择文件'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF4CAF50),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatusDisplay(String message, String type) {
    final statusConfig = _getStatusConfig(type);
    if (statusConfig == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: statusConfig.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusConfig.textColor.withOpacity(0.2)),
        boxShadow: [_statusBoxShadow],
      ),
      child: Row(
        children: [
          Icon(statusConfig.icon, color: statusConfig.textColor, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: SelectableText(
              message,
              style: TextStyle(
                color: statusConfig.textColor,
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 状态颜色常量
  static const Color primaryColor = Color(0xFF3B82F6);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);

  // 获取状态配置
  _StatusConfig? _getStatusConfig(String type) {
    switch (type) {
      case 'success':
        return _StatusConfig(
          backgroundColor: successColor.withOpacity(0.15),
          textColor: Color(0xFF059669),
          icon: Icons.check_circle,
        );
      case 'error':
        return _StatusConfig(
          backgroundColor: errorColor.withOpacity(0.15),
          textColor: Color(0xFFDC2626),
          icon: Icons.error,
        );
      case 'processing':
        return _StatusConfig(
          backgroundColor: primaryColor.withOpacity(0.15),
          textColor: Color(0xFF1E40AF),
          icon: Icons.info,
        );
      default:
        return null;
    }
  }

  // 状态卡片阴影
  final BoxShadow _statusBoxShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: Offset(0, 3),
  );

  Widget _buildDownloadSection(List<Map<String, dynamic>> files) {
    if (files.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('生成的SQL文件:',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800])),
        const SizedBox(height: 16),
        ...files.map((file) => _buildFileItem(file)).toList(),
      ],
    );
  }

  // 构建文件项（有效文件或无效文件卡片）
  Widget _buildFileItem(Map<String, dynamic> file) {
    // 添加额外的空值和类型检查
    if (file == null || file['name'] is! String || file['content'] is! String) {
      return _buildInvalidFileCard();
    }
    return _buildFileDownloadCard(file);
  }

  // 无效文件卡片
  Widget _buildInvalidFileCard() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[100]!),
      ),
      child: ListTile(
        title: Text('无效文件', style: TextStyle(color: errorColor, fontSize: 15)),
        subtitle: Text('文件格式不正确或内容缺失',
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        trailing: Icon(Icons.error, color: errorColor, size: 22),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  // 文件下载卡片
  Widget _buildFileDownloadCard(Map<String, dynamic> file) {
    final fileId = file.hashCode;
    _fileHoverStates.putIfAbsent(fileId, () => false);

    return MouseRegion(
      onEnter: (_) => setState(() => _fileHoverStates[fileId] = true),
      onExit: (_) => setState(() => _fileHoverStates[fileId] = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 16),
        child: Card(
          elevation: _fileHoverStates[fileId]! ? 6 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: _fileHoverStates[fileId]!
                    ? Color(0xFF1E40AF).withOpacity(0.2)
                    : Colors.grey[100]!),
          ),
          child: ListTile(
            key: ValueKey('${file['name']}_${fileId}'),
            title: Text(file['name']?.toString() ?? '未知文件',
                style: TextStyle(fontSize: 15, color: Colors.grey[800])),
            onTap: () async => await _handleFileDownload(file),
            trailing: Icon(Icons.download, color: Color(0xFF1E40AF), size: 22),
            hoverColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  // 处理文件下载
  Future<void> _handleFileDownload(Map<String, dynamic> file) async {
    try {
      HapticFeedback.mediumImpact();
      final String fileName =
          file['name'].isNotEmpty ? file['name'] as String : 'alarm_rule.sql';
      final String fileContent = file['content'] as String;
      final String fileType = (file['type'] as String?)?.isNotEmpty == true
          ? file['type'] as String
          : 'sql';
      await controller.downloadFile(
        fileName: fileName,
        content: fileContent,
        type: fileType,
      );
    } catch (e) {
      Get.dialog(AlertDialog(
        title: Text('下载失败'),
        content: SelectableText(e.toString()),
        actions: [
          TextButton(
            child: Text('确定'),
            onPressed: () => Get.back(),
          )
        ],
      ));
    }
  }
}
