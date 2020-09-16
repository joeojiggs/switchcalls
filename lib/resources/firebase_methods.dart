import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:switchcalls/models/user.dart';

class FirebaseMethods {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final Firestore firestore = Firestore.instance;

  //user class
  User user = User();

  Future<FirebaseUser> getCurrentUser() async{
    FirebaseUser currentUser;
    currentUser = await _auth.currentUser();
    return currentUser;
  }

  Future<FirebaseUser> signIn() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount.authentication;
    
    final AuthCredential credential = GoogleAuthProvider.getCredential(

        accessToken: _signInAuthentication.accessToken,
        idToken: _signInAuthentication.idToken);

    FirebaseUser user = _auth.signInWithCredential(credential);
      return user;
  }

  Future<bool> authenticateUser(FirebaseUser user) async {

    QuerySnapshot result = await firestore
        .collection("user")
        .where("email", isEqualTo: user.email)
        .getDocuments();

    final List<DocumentSnapshot> docs = result.documents;

    //if the user is registered then length of the list > 0 or else less than 0
    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDb(FirebaseUser currentUser) async{

    String username = utils.getUsername(currentUser.email);
    
    user = User(
      uid: currentUser.uid,
      email: currentUser..email,
      name: currentUser.displayName,
      profilePhoto: currentUser.photoUrl,
      username: username
    );

    firestore
        .collection("users")
        .document(currentUser.uid)
        .setData(user.toMap(user));
  }
}