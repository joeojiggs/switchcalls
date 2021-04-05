import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:switchcalls/constants/strings.dart';
import 'package:switchcalls/enum/user_state.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthMethods {
  static final Firestore _firestore = Firestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final Firestore firestore = Firestore.instance;

  static final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser;
    currentUser = await _auth.currentUser();
    return currentUser;
  }

  Future<User> getUserDetails() async {
    FirebaseUser currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot =
        await _userCollection.document(currentUser.uid).get();
    return User.fromMap(documentSnapshot.data);
  }

  Future<User> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _userCollection.document(id).get();
      return User.fromMap(documentSnapshot.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User> addGoogleAcct() async {
    try {
      GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
      if (_signInAccount == null) {
        throw 'Error! User did not register account';
      }
      FirebaseUser signedInUser = await getCurrentUser();

      User user = User(
        uid: signedInUser.uid,
        phoneNumber: signedInUser.phoneNumber,
        email: _signInAccount.email,
        name: _signInAccount.displayName,
        profilePhoto: _signInAccount.photoUrl,
        username: Utils.getUsername(_signInAccount.displayName),
      );

      // GoogleSignInAuthentication _signInAuthentication =
      //     await _signInAccount.authentication;

      // final AuthCredential credential = GoogleAuthProvider.getCredential(
      //     accessToken: _signInAuthentication.accessToken,
      //     idToken: _signInAuthentication.idToken);

      // credential;

      // FirebaseUser user = await _auth.signInWithCredential(credential);
      return user;
    } catch (e) {
      print("Auth methods error");
      print(e);
      return null;
    }
  }

  Future<bool> authenticateUser(FirebaseUser user) async {
    QuerySnapshot result = await firestore
        .collection(USERS_COLLECTION)
        .where('phone_number', isEqualTo: user.phoneNumber)
        .getDocuments();

    final List<DocumentSnapshot> docs = result.documents;

    print(docs);

    //if user is registered then length of list > 0 or else less than 0
    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDb(User currentUser) async {
    // String username = Utils.getUsername(currentUser.email);

    // User user = User(
    //     uid: currentUser.uid,
    //     email: currentUser.email,
    //     name: currentUser.displayName,
    //     profilePhoto: currentUser.photoUrl,
    //     username: username);

    firestore
        .collection(USERS_COLLECTION)
        .document(currentUser.uid)
        .setData(currentUser.toMap(currentUser));
  }

  Future<void> updatePhoneNumber(String phone) async {
    try {
      User user = await getUserDetails();
      user.phoneNumber = '+234' + phone.substring(1);
      print(user.phoneNumber);

      await firestore
          .collection(USERS_COLLECTION)
          .document(user.uid)
          .updateData(user.toMap(user));
    } catch (e) {
      print(e.toString);
    }
  }

  Future<User> getUserByPhone(String number) async {
    print(number);
    QuerySnapshot docs = (await _userCollection.getDocuments());
    DocumentSnapshot doc = docs.documents.firstWhere(
        (element) => element.data['phone_number'] == number,
        orElse: () => null);
    if (doc != null) return User.fromMap(doc.data);
    return null;
  }

  Future<User> getUserByProfilePic(String url) async {
    print(url);
    QuerySnapshot docs = (await _userCollection.getDocuments());
    DocumentSnapshot doc = docs.documents.firstWhere(
        (element) => element.data['profile_photo'] == url,
        orElse: () => null);
    if (doc != null) return User.fromMap(doc.data);
    return null;
  }

  Future<List<User>> fetchAllUsers(FirebaseUser currentUser) async {
    List<User> userList = List<User>();

    QuerySnapshot querySnapshot =
        await firestore.collection(USERS_COLLECTION).getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != currentUser.uid) {
        userList.add(User.fromMap(querySnapshot.documents[i].data));
      }
    }
    return userList;
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void setUserState(
      {@required String userId, @required UserState userState}) async {
    try {
      int stateNum = Utils.stateToNum(userState);

      await _userCollection.document(userId).updateData({
        "state": stateNum,
      });
    } on Exception catch (e) {
      print('SET USER STATE ERROR: $e');
    }
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      _userCollection.document(uid).snapshots();
}
