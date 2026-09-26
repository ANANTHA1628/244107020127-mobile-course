import 'package:flutter/material.dart';
import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;

  const NoteTile({
    super.key,
    required this.note,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        note.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${note.body.isNotEmpty ? "${note.body}\n" : ""}${note.updatedAt.toLocal()}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: note.dirty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Belum tersinkron',
                    style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : const Icon(Icons.cloud_done, color: Colors.green),
    );
  }
}