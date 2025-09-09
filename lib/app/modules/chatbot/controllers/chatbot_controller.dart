// lib/modules/chatbot/controllers/chatbot_controller.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/services/api_service.dart';
import 'dart:math';

class ChatbotController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final textController = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  
  var messages = <ChatMessage>[].obs;
  var isLoading = false.obs;
  var isListening = false.obs;
  var speechEnabled = false.obs;
  
  // FIXED: Changed to variable instead of getter
  String conversationId = '';

  @override
  void onInit() {
    super.onInit();
    conversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    _initSpeech();
    _initTts();
    _addWelcomeMessage();
  }

  Future<void> _initSpeech() async {
    speechEnabled.value = await _speech.initialize(
      onError: (error) => print('Speech error: $error'),
    );
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ar');
    await _tts.setSpeechRate(0.8);
    await _tts.setPitch(1.0);
  }

  void _addWelcomeMessage() {
    messages.add(ChatMessage(
      content: 'مرحبا بك في مساعد المزارع الذكي! أنا هنا لمساعدتك في جميع أمور الزراعة.\n\nيمكنني مساعدتك في:\n• زراعة المحاصيل\n• مكافحة الآفات\n• الري والتسميد\n• نصائح موسمية\n\nكيف يمكنني مساعدتك اليوم؟',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> startListening() async {
    if (!speechEnabled.value) return;
    
    isListening.value = true;
    await _speech.listen(
      onResult: (result) {
        textController.text = result.recognizedWords;
      },
      localeId: 'ar',
      listenMode: ListenMode.dictation,
    );
  }

  Future<void> stopListening() async {
    isListening.value = false;
    await _speech.stop();
  }

  Future<void> speakMessage(String message) async {
    await _tts.speak(message);
  }

  void sendQuickQuestion(String topic) {
    final questions = {
      'زراعة الزيتون': 'كيف أزرع الزيتون في تونس؟',
      'الطماطم': 'ما أفضل وقت لزراعة الطماطم؟',
      'الري': 'كيف أوفر المياه في الري؟',
      'الآفات': 'كيف أكافح آفات النباتات؟',
      'الأسمدة': 'متى أستخدم السماد؟',
      'الطقس': 'كيف أحمي النباتات من الحر؟',
    };
    
    final question = questions[topic] ?? topic;
    textController.text = question;
    sendMessage();
  }

  Future<void> sendMessage() async {
    if (textController.text.trim().isEmpty) return;

    final userMessage = textController.text.trim();
    
    // Add user message
    messages.add(ChatMessage(
      content: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    
    textController.clear();
    isLoading.value = true;
    
    try {
      // FIXED: Use correct API service method signature
      final response = await _apiService.post(
        '/chatbot/chat',
        data: {
          'message': userMessage,
          'conversationId': conversationId,
        },
      );
      
      final responseData = response.data;
      if (responseData['success'] == true) {
        final botResponse = responseData['response']['content'] as String;
        
        messages.add(ChatMessage(
          content: botResponse,
          isUser: false,
          timestamp: DateTime.now(),
          confidence: responseData['confidence'],
        ));
      } else {
        throw Exception('فشل في الحصول على رد');
      }
      
    } catch (e) {
      print('Chatbot error: $e');
      messages.add(ChatMessage(
        content: 'عذرا، حدث خطأ في الاتصال. تأكد من اتصالك بالإنترنت وحاول مرة أخرى.',
        isUser: false,
        timestamp: DateTime.now(),
        confidence: 'error',
      ));
    } finally {
      isLoading.value = false;
    }
  }

  void clearChat() {
    messages.clear();
    _addWelcomeMessage();
  }

  @override
  void onClose() {
    textController.dispose();
    _speech.cancel();
    _tts.stop();
    super.onClose();
  }
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? confidence;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.confidence,
  });
}