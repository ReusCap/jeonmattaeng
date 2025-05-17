import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/models/comment_model.dart';
import 'package:jeonmattaeng/services/comment_service.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({super.key});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();
  late final Menu menu;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    menu = ModalRoute.of(context)!.settings.arguments as Menu;
  }

  Future<void> _submitComment() async {
    if (_controller.text.trim().isEmpty) return;
    await CommentService.postComment(menu.id, _controller.text.trim());
    _controller.clear();
    setState(() {}); // 댓글 새로고침
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${menu.name} 후기')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: CommentService.getComments(menu.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final comments = snapshot.data!;
                if (comments.isEmpty) {
                  return const Center(child: Text('아직 후기가 없습니다. 첫 후기를 남겨보세요!'));
                }
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final c = comments[index];
                    return ListTile(
                      title: Text(c.content),
                      subtitle: Text('${c.userName} - ${c.createdAt.toLocal()}'),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '한줄평을 작성하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitComment,
                  child: const Text('등록'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
