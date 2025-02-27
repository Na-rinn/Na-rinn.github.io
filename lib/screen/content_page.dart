import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lolplatform/screen/reviewed_page.dart';

class Content extends StatefulWidget {
  final String nickname;
  final String rating;
  final String type;
  final String mode;
  final List<String> position;
  final String people;
  final String datetime;
  final String chatlink;
  final String tier;

  const Content({
    super.key,
    required this.nickname,
    required this.rating,
    required this.type,
    required this.mode,
    required this.position,
    required this.people,
    required this.datetime,
    required this.chatlink,
    required this.tier,
  });

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  static const Color primaryBlue = Color(0xFF4A90E2); // 파란색
  static const Color buttonColor = Color(0xFFE5E9F0); // 연한 회색

  Future<void> _launchURL() async {
    if (widget.chatlink.isNotEmpty) {
      final Uri url = Uri.parse(widget.chatlink);
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "미정",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String positionText = widget.position.isNotEmpty ? widget.position.join(", ") : "미정";
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: ListView(
          children: [
            // 작성자 정보
            Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: buttonColor), // 가운데 선
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 24,
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => Reviewed()),
                                );
                              },
                              child: Text(
                                'Faker',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color : Colors.black,
                                ),
                              )
                            ),
                            const SizedBox(width: 170),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                '3.9/5.0',
                                //'${widget.rating}/5.0',
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Text(
              '게임정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('게임 타입', widget.type),
            _buildInfoRow('게임 모드', widget.mode),
            _buildInfoRow('포지션', positionText),
            _buildInfoRow('모집 인원', widget.people),
            _buildInfoRow('티어 조건', widget.tier),
            _buildInfoRow('날짜/시간', widget.datetime),

            const SizedBox(height: 30),

            // 신청하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.chatlink.isNotEmpty ? _launchURL : null, //링크가 있을때만 활성화
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '신청하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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