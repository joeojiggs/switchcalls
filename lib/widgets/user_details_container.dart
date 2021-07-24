import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switchcalls/enum/user_state.dart';
import 'package:switchcalls/models/user.dart';
import 'package:switchcalls/provider/user_provider.dart';
import 'package:switchcalls/resources/auth_methods.dart';
import 'package:switchcalls/utils/universal_variables.dart';
import 'package:switchcalls/widgets/cached_image.dart';
import 'package:switchcalls/screens/auth/views/login_screen.dart';
import 'package:switchcalls/widgets/appbar.dart';
import 'package:switchcalls/utils/utilities.dart';
import 'package:image_picker/image_picker.dart';
import 'package:switchcalls/resources/storage_methods.dart';
import '../screens/messages/widgets/shimmering_logo.dart';
import 'package:switchcalls/provider/image_upload_provider.dart';

class UserDetailsContainer extends StatelessWidget {
  final AuthMethods authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    // final key = GlobalKey<FormState>();

    final UserProvider userProvider = Provider.of<UserProvider>(context);

    signOut() async {
      final bool isLoggedOut = await AuthMethods().signOut();
      if (isLoggedOut) {
        // set userState to offline as the user logs out'
        authMethods.setUserState(
          userId: userProvider.getUser.uid,
          userState: UserState.Offline,
        );

        // move the user to login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(top: 25),
      child: Column(
        children: <Widget>[
          CustomAppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            centerTitle: true,
            title: ShimmeringLogo(),
            actions: <Widget>[
              FlatButton(
                onPressed: () => signOut(),
                child: Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            ],
          ),
          Expanded(child: UserDetailsBody()),
        ],
      ),
    );
  }
}

class UserDetailsBody extends StatefulWidget {
  @override
  _UserDetailsBodyState createState() => _UserDetailsBodyState();
}

class _UserDetailsBodyState extends State<UserDetailsBody> {
  final AuthMethods authMethods = AuthMethods();
  TextEditingController usernameCont = TextEditingController();
  ImageUploadProvider imageUploadProvider = ImageUploadProvider();
  bool isEditing = false;
  bool isLoading = false;
  File image;

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final User user = userProvider.getUser;
    usernameCont.text = user.username;

    return Stack(
      children: [
        Container(
          height: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: InkWell(
                  onTap: () => isEditing ? getImage() : null,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: image != null && isEditing
                        ? Image.file(
                            image,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            user.profilePhoto,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder:
                                (context, Object e, StackTrace stackTrace) {
                              print(e.toString());
                              return Container(color: Colors.red);
                            },
                          ),
                  ),
                ),
                // CachedImage(
                //       user.profilePhoto,
                //       isRound: true,
                //       radius: 200,
                //     ),
              ),
              SizedBox(height: 30),
              Center(
                child: Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  user.phoneNumber,
                  style: TextStyle(
                      fontSize: 16, color: Colors.white.withOpacity(0.7)),
                ),
              ),
              SizedBox(height: 30),
              _buildInfoTiles("Username:", user.username, isEditing),
              Divider(),
              SizedBox(height: 10),
              _buildInfoTiles("Email Address:", user.email),
              SizedBox(height: 70),
              Center(
                child: FlatButton(
                  color: UniversalVariables.lightBlueColor,
                  child: Text(isEditing ? "Save Profile" : "Edit Profile"),
                  onPressed: () async {
                    String s;
                    print(isEditing);
                    if (isEditing) {
                      setState(() => isLoading = true);
                      if (usernameCont.text.length <= 3) {
                        return _showSnackBar(message: 'Enter a valid username');
                      }
                      if (image != null) {
                        s = await StorageMethods().uploadImageToStorage(image);
                      }
                      showLoader();
                      User newDetails = user;
                      newDetails.username = usernameCont.text;
                      if (s != null) newDetails.profilePhoto = s;
                      // await Future.delayed(Duration(seconds: 5));
                      await authMethods.addDataToDb(user);
                      showLoader();
                    }
                    isEditing = !isEditing;
                    setState(() => isLoading = false);
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          child: Visibility(
            visible: isLoading,
            child: Container(
              // height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            replacement: Container(),
          ),
        ),
      ],
    );
  }

  SnackBar _showSnackBar({String message}) {
    return SnackBar(
        content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ));
  }

  void showLoader() {
    isLoading = !isLoading;
    setState(() {});
  }

  Widget _buildInfoTiles(String title, String info, [bool isEditing = false]) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 30),
              Flexible(
                child: Visibility(
                  visible: isEditing,
                  child: TextFormField(
                    controller: usernameCont,
                    // initialValue: '$info',
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    validator: (val) =>
                        val.length <= 3 ? 'Enter a valid username' : null,
                    decoration: InputDecoration(
                      hintText: 'User name',
                      filled: true,
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(),
                    ),
                  ),
                  replacement: Text(
                    info,
                    maxLines: 2,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage() async {
    try {
      image = await Utils.pickImage(source: ImageSource.gallery);
      print("Image Path ${image.path}");
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }
}
