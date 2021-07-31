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
  final ImageUploadProvider imageUploadProvider = ImageUploadProvider();
  UserProvider userProvider;
  User user;

  TextEditingController nameCont;
  TextEditingController usernameCont;
  TextEditingController phoneCont;
  TextEditingController emailCont;
  FocusNode usernameNode = FocusNode();
  bool isEditing = false;
  bool isLoading = false;
  File image;

  @override
  void initState() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    user = userProvider.getUser;
    nameCont = TextEditingController(text: user.name);
    usernameCont = TextEditingController(text: user.username);
    phoneCont = TextEditingController(text: user.phoneNumber);
    emailCont = TextEditingController(text: user.email);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UserDetailsBody oldWidget) {
    nameCont.text = user.name;
    usernameCont.text = user.username;
    phoneCont.text = user.phoneNumber;
    emailCont.text = user.email;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            // height: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: InkWell(
                    // onTap: () => isEditing ? getImage() : null,
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
                              loadingBuilder:
                                  (context, child, loadingProgress) {
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
                ),
                SizedBox(height: 10),
                Center(
                  child: FlatButton(
                    color: UniversalVariables.lightBlueColor,
                    child: Text('Change Profile Picture'),
                    onPressed: () async {
                      await getImage();
                      String s;
                      showLoader();
                      if (image != null) {
                        s = await StorageMethods().uploadImageToStorage(image);
                      }
                      User newDetails = user;
                      if (s != null) newDetails.profilePhoto = s;
                      await authMethods.addDataToDb(user);
                      showLoader();
                    },
                  ),
                ),
                SizedBox(height: 30),
                InfoTile(
                  cont: nameCont,
                  label: 'Name',
                  icon: Icons.person,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InfoTile(
                        cont: usernameCont,
                        label: 'Username',
                        icon: Icons.person_pin_rounded,
                        enabled: isEditing,
                        focus: usernameNode,
                        onSubmitted: (val) async {
                          FocusScope.of(context).unfocus();
                          if (val.length <= 3) {
                            return _showSnackBar(
                                message: 'Enter a valid username');
                          }
                          if (user.username != val) {
                            showLoader();
                            User newDetails = user;
                            newDetails.username = val;
                            setState(() => isEditing = true);
                            await authMethods.addDataToDb(user);
                            showLoader();
                          }
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        print('Editing');
                        setState(() => isEditing = true);
                        usernameNode.requestFocus();
                      },
                      child: Icon(Icons.edit),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                InfoTile(
                  cont: phoneCont,
                  label: 'Phone Number',
                  icon: Icons.phone,
                ),
                SizedBox(height: 10),
                InfoTile(
                  cont: emailCont,
                  label: 'Email Address',
                  icon: Icons.email,
                ),
                Container(height: MediaQuery.of(context).size.height),
              ],
            ),
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

  // Widget _buildInfoTiles(String title, String info, [bool isEditing = false]) {
  //   return Builder(
  //     builder: (context) {
  //       return Padding(
  //         padding: EdgeInsets.all(8.0),
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               title,
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 18,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             SizedBox(width: 30),
  //             Flexible(
  //               child: Visibility(
  //                 visible: isEditing,
  //                 child: TextFormField(
  //                   controller: usernameCont,
  //                   // initialValue: '$info',
  //                   keyboardType: TextInputType.text,
  //                   textCapitalization: TextCapitalization.words,
  //                   validator: (val) =>
  //                       val.length <= 3 ? 'Enter a valid username' : null,
  //                   decoration: InputDecoration(
  //                     hintText: 'User name',
  //                     filled: true,
  //                     border: OutlineInputBorder(),
  //                     enabledBorder: OutlineInputBorder(),
  //                   ),
  //                 ),
  //                 replacement: Text(
  //                   info,
  //                   maxLines: 2,
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 18,
  //                     color: Colors.white.withOpacity(0.7),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Future getImage() async {
    try {
      image = await Utils.pickImage(source: ImageSource.gallery);
      image = await Utils.cropImage(image);
      print("Image Path ${image?.path}");
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({
    Key key,
    @required this.cont,
    @required this.label,
    @required this.icon,
    this.focus,
    this.enabled = false,
    this.onSubmitted,
  }) : super(key: key);

  final TextEditingController cont;
  final String label;
  final IconData icon;
  final bool enabled;
  final Function(String) onSubmitted;
  final FocusNode focus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: cont.text,
      // controller: cont,
      focusNode: focus,
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        enabled: enabled,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
      ),
      onFieldSubmitted: onSubmitted,
    );
  }
}
