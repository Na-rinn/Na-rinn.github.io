import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Reviewed extends StatefulWidget {
  @override
  _Reviewed createState() => _Reviewed();
}

class _Reviewed extends State<Reviewed> {
  static const Color buttonColor = Color(0xFFE5E9F0);

  String? currentuserID;
  double rating = 0.0; // 평점
  String tier = "Unranked";

  @override
  void initState() {
    super.initState();
    _fetchCurrentuserID(); // 로그인한 유저 ID 가져오기
  }

  // 현재 로그인한 유저 ID 및 정보 가져오기
  void _fetchCurrentuserID() async {
    User? user= FirebaseAuth.instance.currentUser;
    if(user != null) {
      setState(() {
        currentuserID = user.uid; // 로그인한 사용자 ID로 변경
      });
      _fetchUserInfo(user.uid);
    }
  }

  void _fetchUserInfo(String userID) async {
    DocumentSnapshot reviewDoc =
        await FirebaseFirestore.instance.collection('review').doc(userID).get();

    if(reviewDoc.exists) {
      setState(() {
        rating = (reviewDoc['rating'] ?? 0.0).toDouble(); // ⭐평점
        tier = reviewDoc['tier'] ?? "Unranked"; //🏆 티어
      });
    }
  }
  //Firestore에서 리뷰 데이터 가져오는 Stream
  Stream<QuerySnapshot> getReview() {
    if(currentuserID == null) {
      return const Stream.empty(); // 로그인 정보 없으면 빈 스트림 반환
    }
    return FirebaseFirestore.instance
        .collection('review')
        .where('revieweduserID', isEqualTo: currentuserID) // 받은 리뷰만 가져오기
        .orderBy('createdAt', descending: true) // 최신 순으로 정렬
        .snapshots();
  }

  // intl 패키지 없이 날짜 포맷팅하는 함수
  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}';
  }

  // 숫자를 2자리로 포맷팅 (ex: 1 -> 01)
  String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';
  /*String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }*/

  // 프로필 위젯 생성 함수
  Widget buildProfileWidget() {
    return Container(
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
            radius: 28,
            child: Icon(Icons.person, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentuserID ?? '로그인 필요',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '🏆 $tier', // 티어 정보
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16), // 간격 추가
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '${rating.toStringAsFixed(1)}/5.0', // 평균 평점 표시
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReviewedCard(String userID, String content, Timestamp createdAt) {
    String formattedDate = formatDate(createdAt.toDate());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white),
      ),
      constraints: const BoxConstraints(
        minHeight: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                userID,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                formattedDate, // 오른쪽 위에 날짜 표시
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Review',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: StreamBuilder<QuerySnapshot>(
          stream: getReview(),
          builder: (context, snapshot) {
            // 기본 리스트 위젯 (프로필 포함)
            List<Widget> widgetList = [
              // 프로필 정보 (항상 표시됨)
              buildProfileWidget(),
              const SizedBox(height: 10),
            ];
            // 리뷰 데이터가 없는 경우
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              widgetList.add(
                  const Expanded(
                    child: Center(child: Text('리뷰가 없습니다.')),
                  )
              );
              return ListView(children: widgetList);
            }
            // 리뷰 데이터가 있는 경우
            snapshot.data!.docs.forEach((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String userID = data['userID'] ?? '알 수 없음';
              String content = data['content'] ?? '내용 없음';
              Timestamp createdAt = data['createdAt'] ?? Timestamp.now();

              // 리뷰 카드 추가
              widgetList.add(buildReviewedCard(userID, content, createdAt));
            });

            return ListView(children: widgetList);
          },
        ),
      ),
    );
  }
}