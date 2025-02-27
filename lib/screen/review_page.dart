import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Review extends StatefulWidget {
  @override
  _Review createState() => _Review();
}

class _Review extends State<Review> {
  static const Color buttonColor = Color(0xFFE5E9F0);

  String? currentuserID;
  double rating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCurrentuserID();
  }

  void _fetchCurrentuserID() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentuserID = user.uid;
      });
      _fetchUserInfo(user.uid);
    }
  }

  void _fetchUserInfo(String userID) async {
    DocumentSnapshot reviewDoc =
    await FirebaseFirestore.instance.collection('review').doc(userID).get();

    if (reviewDoc.exists) {
      setState(() {
        rating = (reviewDoc['rating'] ?? 0.0).toDouble();
      });
    }
  }

  Stream<QuerySnapshot> getReview() {
    if (currentuserID == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('review')
        .where('userID', isEqualTo: currentuserID)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}';
  }

  String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';

  Widget buildReviewCard(String revieweduserID, String content, Timestamp createdAt, double rating) {
    String formattedDate = formatDate(createdAt.toDate());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                revieweduserID,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              Text(
                rating.toStringAsFixed(1), // 평점을 소수점 한 자리까지 표시
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
          '남긴 평가',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: StreamBuilder<QuerySnapshot>(
          stream: getReview(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  '리뷰가 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            var reviewDocs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: reviewDocs.length,
              itemBuilder: (context, index) {
                var review = reviewDocs[index];
                return buildReviewCard(
                  review['userID'],
                  review['content'],
                  review['createdAt'],
                  (review['rating'] ?? 0.0).toDouble(), // 평점 추가
                );
              },
            );
          },
        ),
      ),
    );
  }
}