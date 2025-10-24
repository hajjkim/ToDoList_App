import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _titleCtrl = TextEditingController();
  String _category = "Cá nhân";
  DateTime? _dueDate;
  bool _isStarred = false; // ⭐ Mới thêm

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF7B2CBF);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Thêm tác vụ mới",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tiêu đề
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: "Nhập tiêu đề...",
                prefixIcon: const Icon(Icons.title, color: Color(0xFF7B2CBF)),
                filled: true,
                fillColor: const Color(0xFFF3E8FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Danh mục
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF7B2CBF)),
                items: [
                  "Cá nhân",
                  "Công việc",
                  "Yêu thích",
                  "Sinh nhật",
                  "Khác"
                ]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Row(
                            children: [
                              const Icon(Icons.label_outline,
                                  size: 18, color: Color(0xFF7B2CBF)),
                              const SizedBox(width: 8),
                              Text(e),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
            const SizedBox(height: 15),

            // Ngày & giờ
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3E8FF),
                foregroundColor: primaryColor,
              ),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date == null) return;

                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time == null) return;

                setState(() {
                  _dueDate = DateTime(
                      date.year, date.month, date.day, time.hour, time.minute);
                });
              },
              icon: const Icon(Icons.access_time),
              label: Text(
                _dueDate == null
                    ? "Chọn ngày & giờ"
                    : DateFormat("dd/MM/yyyy HH:mm").format(_dueDate!),
              ),
            ),
            const SizedBox(height: 15),

            // ⭐ Đánh dấu ưu tiên
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Đánh dấu sao (ưu tiên)",
                  style: TextStyle(fontSize: 16, color: primaryColor),
                ),
                IconButton(
                  icon: Icon(
                    _isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                    color: _isStarred ? Colors.amber : Colors.grey,
                    size: 28,
                  ),
                  onPressed: () => setState(() => _isStarred = !_isStarred),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Nút Thêm
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (_titleCtrl.text.trim().isEmpty) return;
                  Navigator.pop(context, {
                    'title': _titleCtrl.text.trim(),
                    'category': _category,
                    'due': _dueDate?.toIso8601String(),
                    'isStarred': _isStarred, // ⭐ Thêm vào payload
                  });
                },
                child: const Text(
                  "Thêm tác vụ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
