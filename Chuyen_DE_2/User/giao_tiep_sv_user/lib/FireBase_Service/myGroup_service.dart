// MygroupService.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/global_state.dart';

class MygroupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  static Stream<List<DocumentSnapshot>> getMyGroupsStream() {
    return _firestore
        .collection('Groups')
       
        .where('status_id', isEqualTo: 1) 
        .snapshots()
        .map((snapshot) {
 
      return snapshot.docs.where((doc) {
     
        final createdByMap = doc.data().containsKey('created_by') 
            ? doc.data()['created_by'] as Map<String, dynamic> 
            : null;

        return createdByMap?.containsKey(GlobalState.currentUserId) ?? false;
      }).toList();
    });
  }
}