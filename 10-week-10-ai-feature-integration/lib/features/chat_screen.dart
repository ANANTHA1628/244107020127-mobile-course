import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ai/ai_service.dart';

enum ChatRole { user, assistant, system }

class ChatMessage {
  final String text;
  final ChatRole role;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
    this.isError = false,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.aiService});

  final AiService? aiService;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final AiService _aiService;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _streamingAnswer;
  String _lastQuestion = '';

  final List<String> _suggestedPrompts = [
    'Jadwal kuliah hari ini?',
    'Cara mencatat di menu Notes?',
    'Bagaimana melihat pengumuman kampus?',
    'Format NIK (Uji Privasi)',
  ];

  @override
  void initState() {
    super.initState();
    _aiService = widget.aiService ?? AiService();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isLoading) return;

    _inputController.clear();
    _lastQuestion = query;

    setState(() {
      _messages.add(ChatMessage(
        text: query,
        role: ChatRole.user,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _streamingAnswer = null;
    });
    _scrollToBottom();

    try {
      // 1. Validasi privasi lokal terlebih dahulu
      _aiService.validatePrivacy(query);

      // 2. Stream respons AI
      String latestAccumulation = '';
      await for (final chunk in _aiService.askStream(query)) {
        if (!mounted) return;
        setState(() {
          _streamingAnswer = chunk;
        });
        _scrollToBottom();
        latestAccumulation = chunk;
      }

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: latestAccumulation,
          role: ChatRole.assistant,
          timestamp: DateTime.now(),
        ));
        _streamingAnswer = null;
        _isLoading = false;
      });
      _scrollToBottom();
    } on PrivacyException catch (pe) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: pe.message,
          role: ChatRole.system,
          timestamp: DateTime.now(),
          isError: true,
        ));
        _streamingAnswer = null;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _streamingAnswer = null;
        _isLoading = false;
      });
      _showFallbackDialog(e.toString());
    }
  }

  void _showFallbackDialog(String errorMsg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Layanan AI Sibuk'),
          ],
        ),
        content: Text(
          'Gagal menghubungi server AI: $errorMsg\n\n'
          'Coba lagi nanti atau beralih ke Mode Cadangan (Offline).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.offline_pin_outlined),
            label: const Text('Mode Offline'),
            onPressed: () {
              Navigator.pop(ctx);
              _useOfflineFallback();
            },
          ),
        ],
      ),
    );
  }

  void _useOfflineFallback() {
    final fallbackReply = _aiService.getOfflineFallbackResponse(_lastQuestion);
    setState(() {
      _messages.add(ChatMessage(
        text: fallbackReply,
        role: ChatRole.assistant,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  Future<void> _showApiKeyDialog() async {
    final currentKey = await _aiService.getApiKey() ?? '';
    if (!mounted) return;
    final textEdit = TextEditingController(text: currentKey);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pengaturan API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Google Gemini API Key Anda. Kunci ini akan disimpan aman di FlutterSecureStorage.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textEdit,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _aiService.saveApiKey(textEdit.text);
              if (!ctx.mounted || !mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API Key berhasil disimpan!')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Campus Assistant', style: TextStyle(fontSize: 18)),
            Text(
              'Gemini AI & Smart Offline Fallback',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pengaturan API Key',
            icon: const Icon(Icons.vpn_key_outlined),
            onPressed: _showApiKeyDialog,
          ),
          IconButton(
            tooltip: 'Bersihkan Riwayat',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _messages.clear();
                _streamingAnswer = null;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // List percakapan atau Empty State
            Expanded(
              child: _messages.isEmpty && _streamingAnswer == null && !_isLoading
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: _messages.length +
                          (_streamingAnswer != null || _isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _messages.length) {
                          return _buildMessageItem(_messages[index]);
                        } else {
                          // Streaming chunk atau Indikator Mengetik
                          return _buildStreamingBubble();
                        }
                      },
                    ),
            ),

            // Input Bar
            _buildInputArea(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  size: 54, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            const Text(
              'Halo, Mahasiswa Polinema!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Saya asisten AI kampus cerdas. Tanyakan seputar perkuliahan, jadwal, atau gunakan contoh saran prompt di bawah ini:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _suggestedPrompts.map((prompt) {
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  avatar: const Icon(Icons.chat_bubble_outline, size: 14),
                  onPressed: () => _sendMessage(prompt),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    final isUser = msg.role == ChatRole.user;
    final isSystem = msg.role == ChatRole.system;

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.security, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg.text,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue.shade600 : Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  if (!isUser) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: msg.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Teks disalin ke papan klip'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.copy, size: 12, color: Colors.black45),
                              SizedBox(width: 4),
                              Text('Salin',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.black45)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        InkWell(
                          onTap: () {
                            if (_lastQuestion.isNotEmpty) {
                              _sendMessage(_lastQuestion);
                            }
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.refresh,
                                  size: 12, color: Colors.black45),
                              SizedBox(width: 4),
                              Text('Regenerate',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.black45)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreamingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue,
            child: Icon(Icons.smart_toy, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: _streamingAnswer != null && _streamingAnswer!.isNotEmpty
                  ? Text(
                      _streamingAnswer!,
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 14, height: 1.35),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI sedang mengetik...',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Ketik pertanyaan kampus...',
                hintStyle: const TextStyle(fontSize: 14),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send, size: 20),
            onPressed:
                _isLoading ? null : () => _sendMessage(_inputController.text),
          ),
        ],
      ),
    );
  }
}
