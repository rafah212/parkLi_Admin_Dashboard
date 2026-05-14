import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../app_data.dart';
import 'dart:ui' as ui; 

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  // دالة التحديث وإرسال الإشعار للي حدده الأدن سوا الجميع او مستخدم محدد
  Future<void> _updateStatusAndNotify(Map<String, dynamic> item, String newStatus, String customMessage) async {
    try {
      await supabase
          .from('complaints')
          .update({'status': newStatus})
          .match({'id': item['id']});

      // تنبيه فوري يحدده الأدمن 
      await supabase.from('notifications').insert({
        'user_id': item['user_id'],
        'title': 'complaint_solved', 
        'body': customMessage,
        'type': 'complaint',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppData.translate("Status updated and notification sent!")),
            backgroundColor: newStatus == 'solved' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppData.translate('Error')}: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppData.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    Color cardColor = AppData.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = AppData.isDarkMode ? Colors.white : const Color(0xFF195A64);

    return ValueListenableBuilder<bool>(
      valueListenable: AppData.languageNotifier,
      builder: (context, isArabic, child) {
        return Directionality(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: Text(
                AppData.translate("Complaints Management"), 
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              backgroundColor: cardColor,
              elevation: 0,
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppData.translate("User Reports & Issues"), 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: supabase.from('complaints').stream(primaryKey: ['id']).order('created_at'),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return Center(child: Text("${AppData.translate('Error')}: ${snapshot.error}", style: TextStyle(color: textColor)));
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                        final complaints = snapshot.data!;
                        if (complaints.isEmpty) {
                          return Center(
                            child: Text(
                              AppData.translate("No complaints found. Clean inbox!"), 
                              style: TextStyle(color: textColor),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: complaints.length,
                          itemBuilder: (context, index) {
                            final item = complaints[index];
                            return FutureBuilder(
                              future: supabase.from('profiles').select('full_name').eq('id', item['user_id']).maybeSingle(),
                              builder: (context, userSnapshot) {
                                String userName = userSnapshot.hasData && userSnapshot.data != null 
                                    ? userSnapshot.data!['full_name'] 
                                    : AppData.translate("Loading...");
                                return _buildComplaintCard(item, userName, cardColor, textColor);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> item, String userName, Color cardColor, Color textColor) {
    DateTime createdAt = DateTime.parse(item['created_at']);
    String formattedDate = DateFormat('yyyy-MM-dd').format(createdAt);
    String displayDate = AppData.formatNumbers(formattedDate);
    bool isSolved = item['status'] == 'solved';

    return Card(
      color: cardColor, 
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: textColor,
          collapsedIconColor: textColor,
          leading: Icon(
            Icons.warning_amber_rounded, 
            color: isSolved ? Colors.green : Colors.orange,
          ),
          title: Text(
            AppData.translate(item['category'] ?? "General Issue"), 
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          subtitle: Text(
            "${AppData.translate('From')}: $userName | $displayDate", 
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppData.translate("Message:"), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  Text(
                    item['message'] ?? AppData.translate("No message content"), 
                    style: TextStyle(color: textColor.withOpacity(0.8)),
                  ),
                  Divider(height: 30, color: textColor.withOpacity(0.1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isSolved)
                        TextButton(
                          onPressed: () => _updateStatusAndNotify(item, 'pending', "Your issue is currently under review by our team."),
                          child: Text(AppData.translate("Set Pending"), style: const TextStyle(color: Colors.orange)),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showResponseDialog(item, cardColor, textColor),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSolved ? Colors.grey : const Color(0xFFC8D8C3),
                          elevation: 0,
                        ),
                        child: Text(
                          isSolved ? AppData.translate("Solved") : AppData.translate("Mark Solved"), 
                          style: const TextStyle(color: Color(0xFF195A64), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //  اختيار الرد الفوري أو كتابة رد  من الأدمن
  void _showResponseDialog(Map<String, dynamic> item, Color cardColor, Color textColor) {
    final TextEditingController replyController = TextEditingController();
    
    // ردود جاهزه لللأدمن عشان بعضهم ما يحتاج 
    String defaultReply1 = "Your issue regarding ${item['category'] ?? 'Parking'} has been fixed. Thank you!";
    String defaultReply2 = "Please contact our technical support team directly at support@parkli.com for further help.";
    String defaultReply3 = "Your complaint is resolved. If you still face issues, please reply with your plate number.";

    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<bool>(
          valueListenable: AppData.languageNotifier,
          builder: (context, isArabic, child) {
            return Directionality(
              textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  return AlertDialog(
                    backgroundColor: cardColor,
                    title: Text(AppData.translate("Select Resolution Response")),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppData.translate("Quick Responses:"), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          
                          _buildTemplateReplyTile(replyController, defaultReply1, "Issue Fixed ✅", setDialogState, textColor),
                          _buildTemplateReplyTile(replyController, defaultReply2, "Contact Support Email ✉️", setDialogState, textColor),
                          _buildTemplateReplyTile(replyController, defaultReply3, "Request Plate Details 🚗", setDialogState, textColor),
                          
                          const SizedBox(height: 15),
                          Text(AppData.translate("Custom Response / Edit:"), style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: replyController,
                            maxLines: 3,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: AppData.translate("Write a custom response to the user..."),
                              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppData.translate("Cancel"), style: const TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String finalMessage = replyController.text.isEmpty ? defaultReply1 : replyController.text;
                          Navigator.pop(context);
                          _updateStatusAndNotify(item, 'solved', finalMessage);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF195A64)),
                        child: Text(AppData.translate("Send & Solve"), style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTemplateReplyTile(TextEditingController controller, String fullText, String title, StateSetter setDialogState, Color textColor) {
    bool isSelected = controller.text == fullText;
    return Card(
      color: isSelected ? const Color(0xFF195A64).withOpacity(0.1) : Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
      child: ListTile(
        dense: true,
        title: Text(AppData.translate(title), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        onTap: () {
          setDialogState(() {
            controller.text = fullText;
          });
        },
      ),
    );
  }
}