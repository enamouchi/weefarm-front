import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chatbot_controller.dart';

class ChatbotView extends StatelessWidget {
  final controller = Get.put(ChatbotController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المساعد الزراعي الذكي'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: controller.clearChat,
            tooltip: 'مسح المحادثة',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickTopics(),
          Expanded(child: _buildMessagesList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildQuickTopics() {
    final topics = ['زراعة الزيتون', 'الطماطم', 'الري', 'الآفات', 'الأسمدة', 'الطقس'];
    
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(left: 8),
            child: ActionChip(
              label: Text(topics[index], style: TextStyle(fontSize: 12)),
              onPressed: () => controller.sendQuickQuestion(topics[index]),
              backgroundColor: Colors.green[100],
              side: BorderSide(color: Colors.green[300]!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList() {
    return Obx(() => ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        return _buildMessageBubble(message);
      },
    ));
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: Get.width * 0.75),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.green[700] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            if (!message.isUser) ...[
              SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.confidence != null) ...[
                    Icon(
                      message.confidence == 'high' ? Icons.psychology : Icons.help_outline,
                      size: 12,
                      color: message.confidence == 'high' ? Colors.green : Colors.orange,
                    ),
                    SizedBox(width: 4),
                  ],
                  GestureDetector(
                    onTap: () => controller.speakMessage(message.content),
                    child: Icon(Icons.volume_up, size: 16, color: Colors.blue[700]),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Obx(() => IconButton(
            onPressed: controller.speechEnabled.value 
                ? (controller.isListening.value 
                    ? controller.stopListening 
                    : controller.startListening)
                : null,
            icon: Icon(
              controller.isListening.value ? Icons.mic : Icons.mic_none,
              color: controller.isListening.value ? Colors.red : Colors.green[700],
            ),
          )),
          Expanded(
            child: TextField(
              controller: controller.textController,
              decoration: InputDecoration(
                hintText: 'اسأل عن الزراعة...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              textAlign: TextAlign.right,
              onSubmitted: (_) => controller.sendMessage(),
              maxLines: null,
            ),
          ),
          SizedBox(width: 8),
          Obx(() => IconButton(
            onPressed: controller.isLoading.value ? null : controller.sendMessage,
            icon: controller.isLoading.value 
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.send),
            color: Colors.green[700],
          )),
        ],
      ),
    );
  }
}