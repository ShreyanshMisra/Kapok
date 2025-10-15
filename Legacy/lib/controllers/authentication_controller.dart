import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:kapok_new/models/person_model.dart';


class AuthenticationController extends GetxController {
  static AuthenticationController authController = Get.find();
  late Rx<User?> firebaseCurrentUser;
  String? userName;

  Future<void> createNewUserAccount(String email, String password) async {
    try {
      // 1. Authenticate user and create user with email and password
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      // 2. Send verification email
      //await sendVerificationEmail(credential.user!);

      //3. Save User to FireStore Database
      Person personInstance = Person(
        uid: FirebaseAuth.instance.currentUser!.uid,
        email: email,
        password: password,
        publishedDateTime: DateTime.now().millisecondsSinceEpoch,
      );

      await FirebaseFirestore.instance.collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(personInstance.toJson());

      await FirebaseFirestore.instance.collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(personInstance.toJson());

      // 4. Show alert dialog

    } catch (errorMsg) {
      throw errorMsg.toString(); // Throw the error instead of showing a snackbar
    }
  }

  retreiveUserName() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseCurrentUser.value!.uid)
        .get()
        .then((userDoc) {
      if (userDoc.exists) {
        userName = userDoc.data()?["name"];
      }});
  }

  loginUser(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (await isEmailVerified()) {
      await retreiveUserName();

      if (userName == null) {
        Get.to(const (), transition: Transition.fade, duration: const Duration(milliseconds: 400));
      } else {
        Get.to(const (), transition: Transition.fade, duration: const Duration(milliseconds: 400));
      }

    } else {
      User? credential = FirebaseAuth.instance.currentUser;
      await sendVerificationEmail(credential!);
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }


  Future<void> sendVerificationEmail(User user) async {
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  void onReady() {
    //TODO: implement onReady
    super.onReady();

    firebaseCurrentUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    firebaseCurrentUser.bindStream(FirebaseAuth.instance.authStateChanges());

    //ever(firebaseCurrentUser, checkIfUserIsLoggedIn);
  }
}