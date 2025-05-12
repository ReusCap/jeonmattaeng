import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/services/comment_service.dart';

class CommentPage extends StatefulWidget {
  final Menu menu;
  CommentPage({required this.menu});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<String>> _comments;

  @override
  void initState() {
    super.initState();
    _comments = CommentService.fetchComments(widget.menu.id);
  }

  void _addComment() async {
    if (_controller.text.trim().isEmpty) return;

    final success = await CommentService.submitComment(
      menuId: widget.menu.id,
      comment: _controller.text.trim(),
    );

    if (success) {
      setState(() {
        _comments = CommentService.fetchComments(widget.menu.id);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.menu.name)),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _comments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return Center(child: Text('후기가 없습니다'));

                return ListView(
                  children: snapshot.data!
                      .map((c) => ListTile(title: Text(c)))
                      .toList(),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: '한줄평 입력'),
                  ),
                ),
                ElevatedButton(onPressed: _addComment, child: Text('등록')),
              ],
            ),
          )
        ],
      ),
    );
  }
}
