import 'package:flutter/material.dart';

class RuleItem extends StatefulWidget {
  final String value;
  final int index;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;

  static const Color mainColor = Color(0xFF3CA2A2);

  const RuleItem({
    super.key,
    required this.value,
    required this.index,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<RuleItem> createState() => _RuleItemState();
}

class _RuleItemState extends State<RuleItem> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(RuleItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isEditing) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveEdit() {
    setState(() => _isEditing = false);
    if (_controller.text.trim().isNotEmpty) {
      widget.onChanged(_controller.text);
    } else {
      _controller.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEditing ? RuleItem.mainColor : Colors.grey.shade200,
          width: _isEditing ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 48,
            decoration: BoxDecoration(
              color: RuleItem.mainColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                bottomLeft: Radius.circular(11),
              ),
            ),
            child: Center(
              child: Text(
                '${widget.index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: RuleItem.mainColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLength: 100,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _saveEdit(),
                  )
                : GestureDetector(
                    onTap: () => setState(() => _isEditing = true),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        widget.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check, color: RuleItem.mainColor, size: 20),
              onPressed: _saveEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36),
            )
          else
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.grey.shade500, size: 18),
              onPressed: () => setState(() => _isEditing = true),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36),
            ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 18),
            onPressed: widget.onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
