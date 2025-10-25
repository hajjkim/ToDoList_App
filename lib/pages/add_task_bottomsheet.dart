import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _titleCtrl = TextEditingController();
  String _category = "Cá nhân";
  DateTime? _selectedDate;
  bool _isStarred = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh kéo nhỏ
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const Text(
              "Thêm tác vụ mới",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B2CBF),
              ),
            ),
            const SizedBox(height: 24),

            // Ô nhập tiêu đề
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.edit_note, color: Color(0xFF7B2CBF)),
                hintText: "Tiêu đề tác vụ...",
                filled: true,
                fillColor: const Color(0xFFF6EDFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown chọn loại
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EDFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF7B2CBF)),
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
            const SizedBox(height: 16),

            // Chọn ngày giờ
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
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
                  _selectedDate = DateTime(
                      date.year, date.month, date.day, time.hour, time.minute);
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EDFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF7B2CBF)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? "Chọn ngày & giờ"
                            : DateFormat("dd/MM/yyyy HH:mm").format(_selectedDate!),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Color(0xFF7B2CBF)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Đánh dấu ưu tiên
            Row(
              children: [
                const Icon(Icons.star_border_rounded, color: Color(0xFF7B2CBF)),
                const SizedBox(width: 8),
                const Text(
                  "Đánh dấu ưu tiên",
                  style: TextStyle(fontSize: 15),
                ),
                const Spacer(),
                Switch(
                  activeColor: const Color(0xFF7B2CBF),
                  value: _isStarred,
                  onChanged: (v) => setState(() => _isStarred = v),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nút thêm tác vụ
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2CBF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  if (_titleCtrl.text.trim().isEmpty) return;
                  Navigator.pop(context, {
                    "title": _titleCtrl.text.trim(),
                    "category": _category,
                    "due": _selectedDate?.toIso8601String(),
                    "isStarred": _isStarred,
                  });
                },
                child: const Text(
                  "Thêm tác vụ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
