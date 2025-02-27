import 'package:flutter/material.dart';
import 'package:lolplatform/screen/match_page.dart';
import 'package:lolplatform/screen/reviewed_page.dart';
import 'package:lolplatform/screen/review_page.dart';

const buttonColor = Color(0xFFE5E9F0); // 연한 회색빛 색상
const tintColor = Color(0xFFE5E9F0);

// BottomNavigationBar 설정 클릭시 넘어오는 화면 구현
class Setting extends StatefulWidget {
  @override
  _Setting createState() => _Setting(); // createState 매서드에서 _MatchState라는 State 객체 생성하여 MatchScreen과 연결
}

class _Setting extends State<Setting> {
  static const Color primaryBlue = Color(0xFF4A90E2); // 파란색
  static const Color buttonColor = Color(0xFFE5E9F0);

  Widget buildButton(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5), // 바깥 여백 추가
      child: SizedBox(
        width: double.infinity,
        height: 100, // MatchScreen과 비슷한 높이
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // 내부 여백 추가
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            splashFactory: NoSplash.splashFactory, // 클릭 효과 제거
          ),
          child: Row(
            children: [
              const SizedBox(width: 10), // 왼쪽 여백
              Expanded( // MatchScreen과 유사한 구조
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10), // 오른쪽 여백 추가
            ],
          ),
        ),
      ),
    );
  }
  int _selectedIndex = 1; // 0: 매칭, 1:설정
// 탭을 눌렀을 때 해당 페이지로 이동하는 함수
  void _onItemTapped(int index) {
    if (index != _selectedIndex) { // 현재 페이지가 아닌 다른 탭을 눌렀을 때만
      if (index == 0) { // 추천 탭
        Navigator.push(
          context, MaterialPageRoute(builder: (context) => MatchScreen()),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      backgroundColor: Colors.white,
      appBar: AppBar(
        title : Text (
          'Setting',
          style: TextStyle(
            color:Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white54,
        elevation: 0,
      ),

      body: Container(
        child: Column (
          children: [

            buildButton('나의 정보', () {
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => Reviewed()), // Reviewed 페이지로 이동
              );
            }),
            const SizedBox(height: 10),
            buildButton('내가 남긴 리뷰', (){
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => Review()),
              );
            }),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar (
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex, // currentIndex 속성에 _selectedIndex로 지정
        onTap: (index) { // indexsms 클릭된 items의 위치 (0,1,2)를 자동으로 받음
          if (index == 0) {
            Navigator.pushReplacement (
              context,
              MaterialPageRoute(builder: (context) => MatchScreen()),
            );
          } else if (index == 1) {
            // 현재 페이지
          }
        },
        items: [
          //BottomNavigationBar는 내부적으로 배열로 구현되어있고, 모든 리스트는 0으로부터 시작
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '매칭',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.black87,
      ),
    );
  }
}