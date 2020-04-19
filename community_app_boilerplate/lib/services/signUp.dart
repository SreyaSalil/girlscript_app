import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

String name;
String email;
String imageUrl;

Future<FirebaseUser> loginWithGitHub(String code) async {

    //ACCESS TOKEN REQUEST
  final response = await http.post(
    "https://github.com/login/oauth/access_token",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    },
    body: jsonEncode(GitHubLoginRequest(
      clientId: '841cad1c253905cedb95',
      clientSecret: '744fd93d598f84105d4dd7a8d2faf434cbd2c4ac',
      code: code,
    )),
  );

  GitHubLoginResponse loginResponse =
      GitHubLoginResponse.fromJson(json.decode(response.body));

  //FIREBASE STUFF
  final AuthCredential credential = GithubAuthProvider.getCredential(
    token: loginResponse.accessToken,
  );

  final FirebaseUser user = (await FirebaseAuth.instance.signInWithCredential(credential)).user;

  // Checking if email and name is null
  assert(user.email != null);
  assert(user.displayName != null);
  assert(user.photoUrl != null);

  name = user.displayName;
  email = user.email;
  imageUrl = user.photoUrl;

  // Only taking the first part of the name, i.e., First Name
  // if (name.contains(" ")) {
  //   name = name.substring(0, name.indexOf(" "));
  // }

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  name = user.displayName;
  email = user.email;
  imageUrl = user.photoUrl;

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  return user;
}
//GITHUB REQUEST-RESPONSE MODELS
class GitHubLoginRequest {
  String clientId;
  String clientSecret;
  String code;

  GitHubLoginRequest({this.clientId, this.clientSecret, this.code});

  dynamic toJson() => {
        "client_id": clientId,
        "client_secret": clientSecret,
        "code": code,
      };
}

class GitHubLoginResponse {
  String accessToken;
  String tokenType;
  String scope;

  GitHubLoginResponse({this.accessToken, this.tokenType, this.scope});

  factory GitHubLoginResponse.fromJson(Map<String, dynamic> json) =>
      GitHubLoginResponse(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        scope: json["scope"],
      );
}

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  // Checking if email and name is null
  assert(user.email != null);
  assert(user.displayName != null);
  assert(user.photoUrl != null);

  name = user.displayName;
  email = user.email;
  imageUrl = user.photoUrl;

  // Only taking the first part of the name, i.e., First Name
  // if (name.contains(" ")) {
  //   name = name.substring(0, name.indexOf(" "));
  // }

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded: $user';
}

void signOutGoogle() async{
  await googleSignIn.signOut();

  print("User Sign Out");
}