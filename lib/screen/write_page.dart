import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lolplatform/screen/setting_page.dart';
import 'package:lolplatform/screen/match_page.dart';

class Write extends StatefulWidget {
  @override
  _WriteState createState() => _WriteState();
}

class _WriteState extends State<Write> {
  // 선택한 값을 일시적으로 저장(이후 Firsestore에 저장)
  String? selectedGameType;
  String? selectedMatchType;
  List<String> selectedPositions = [];
  String? selectedMemberCount;
  String? selectedTire;
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController chatLinkController = TextEditingController();
  // 색상 및 스타일 상수
  static const Color primaryBlue = Color(0xFF4A90E2); // 파란색
  static const Color buttonColor = Color(0xFFE5E9F0); // 회색
  static const double borderRadius = 15.0;

  Future<void> saveToFirestore() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DateTime now = DateTime.now(); // 현재 시간을 저장

      Map<String, dynamic> postData = { // 저장할 데이터의 구조와 내용 postData Map
        'type': selectedGameType ?? '', // 게임 타입(소환사의 협곡/칼바람)
        'mode': selectedMatchType ?? '', // 게임 모드(랭크/자유랭크/일반)
        'positions': selectedPositions, // 역할(탑/정글/미드/원딜/서폿) -> positions을 배열로 저장
        'people': selectedMemberCount ?? '', // 모집 인원
        'datetime': dateTimeController.text, // 날짜, 시간
        'chatlink': chatLinkController.text, // 오픈채팅 링크
        'tier' : selectedTire ?? '',
        'createdAt': now, // 생성 시간 저장
      };

      await firestore.collection('write').add(postData);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류가 발생했습니다.')),
      );
    }
  }

  Future<String?> _showDateTimePicker(BuildContext context) async {
    DateTime? pickedDate;
    TimeOfDay? pickedTime;

    return await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "날짜 선택",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Text(
                      pickedDate == null
                          ? "연도, 월, 일, 선택"
                          : "${pickedDate!.year}. ${pickedDate!.month.toString().padLeft(2, '0')}. ${pickedDate!.day.toString().padLeft(2, '0')}",
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          pickedDate = date;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "시간 선택",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    title: Text(
                      pickedTime == null
                          ? "--:--"
                          : "${pickedTime!.hour.toString().padLeft(2, '0')}:${pickedTime!.minute.toString().padLeft(2, '0')}",
                    ),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          pickedTime = time;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (pickedDate != null && pickedTime != null) {
                        DateTime finalDateTime = DateTime(
                          pickedDate!.year,
                          pickedDate!.month,
                          pickedDate!.day,
                          pickedTime!.hour,
                          pickedTime!.minute,
                        );

                        String formattedDateTime =
                            "${finalDateTime.year}. ${finalDateTime.month.toString().padLeft(2, '0')}. ${finalDateTime.day.toString().padLeft(2, '0')} "
                            "${pickedTime!.hour.toString().padLeft(2, '0')}:${pickedTime!.minute.toString().padLeft(2, '0')}";

                        Navigator.pop(context, formattedDateTime); // ✅ 값을 반환하여 팝업 닫기
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("날짜와 시간을 모두 선택하세요.")),
                        );
                      }
                    },
                    child: Text("완료"),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildOptionButtons(
      String title,
      List<String> options,
      dynamic selectedValue,
      Function(dynamic) onSelect,
      {bool isMultiSelect = false, bool isLarge = false} // isLarge 추가
      ) {
    return SizedBox(
      width: double.infinity,
      height: isLarge ? 145 : 100, // "필요한 인원"이면 100, 나머지는 80
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Expanded( // row, column 내에서 남은 공간을 자동으로 채움
                child: Wrap( // 크기가 부족하면 줄바꿈
                  spacing: 15,
                  runSpacing: 8, // 줄이 바뀔때 위아래 간격
                  children: options.map((option) { // option을 버튼 형식으로
                    bool isSelected = isMultiSelect //
                        ? selectedPositions.contains(option) // 다중 선택이며 리스트에서 확인
                        : selectedValue == option; // 단일 선택이면 해당 값과 비교
                    return InkWell(
                      onTap: () {
                        if (isMultiSelect) {
                          setState(() {
                            if (isSelected) {
                              selectedPositions.remove(option);
                            } else {
                              selectedPositions.add(option);
                            }
                          });
                        } else {
                          onSelect(option);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryBlue : buttonColor,
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSelectionBox(List<String> options, String? selectedValue, Function(String?) onSelect) {
    return SizedBox(
      width: double.infinity,
      height: 70, // 고정된 높이
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center, // 중앙 정렬
            children: options.map((option) {
              bool isSelected = selectedValue == option;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    onSelect(isSelected ? null : option);
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryBlue : buttonColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildDateTimeField(String title, TextEditingController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              readOnly: true, // 사용자가 직접 입력하지 못하게 함
              onTap: () async {
                // ✅ `showModalBottomSheet` 실행하여 팝업 띄우기
                String? selectedDateTime = await _showDateTimePicker(context);
                if (selectedDateTime != null) {
                  setState(() {
                    controller.text = selectedDateTime;
                  });
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: buttonColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Icon(Icons.calendar_today, color: Colors.black54), // 캘린더 아이콘 추가
                hintText: "연도. 월. 일. --:--", // 기본 표시
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String title, TextEditingController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: buttonColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      //backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '글 쓰기',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: saveToFirestore,
            child: const Text(
              '완료',
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildSelectionBox(
              ['소환사의 협곡', '칼바람'],
              selectedGameType,
                  (value) => setState(() => selectedGameType = value),
            ),
            const SizedBox(height: 5),
            buildSelectionBox(
              ['랭크', '자유랭크', '일반'],
              selectedMatchType,
                  (value) => setState(() => selectedMatchType = value),
            ),
            const SizedBox(height: 5),
            buildOptionButtons(
              '포지션',
              ['탑', '정글', '미드', '원딜', '서폿'],
              selectedPositions,
                  (value) {},
              isMultiSelect: true,
            ),
            const SizedBox(height: 5),
            buildOptionButtons(
              '필요한 인원',
              List.generate(9, (index) => '${index + 1}명'),
              selectedMemberCount,
                  (value) => setState(() => selectedMemberCount = value),
              isLarge: true, // 필요한 인원 박스만 크기 증가
            ),
            const SizedBox(height: 5),
            buildOptionButtons(
              '티어 조건',
              ['bronze', 'sillver', 'gold', 'Platinum', 'Emerald', 'Diamond', 'Master'],
              selectedTire,
                (value) => setState(() => selectedTire = value),
              isLarge: true,
            ),
            const SizedBox(height: 5),
            buildDateTimeField('날짜/시간', dateTimeController),
            const SizedBox(height: 5),
            buildTextField('오픈채팅 링크', chatLinkController),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MatchScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Setting()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '매칭'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.black87,
      ),
    );
  }

  @override
  void dispose() {
    dateTimeController.dispose();
    chatLinkController.dispose();
    super.dispose();
  }
}