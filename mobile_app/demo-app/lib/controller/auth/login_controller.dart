import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:henox/controller/my_controller.dart';
import 'package:henox/helpers/services/auth_service.dart';
import 'package:henox/helpers/widgets/my_form_validator.dart';
import 'package:henox/helpers/widgets/my_validators.dart';

class LoginController extends MyController {
  bool rememberMe = false;
  MyFormValidator basicValidator = MyFormValidator();

  @override
  void onInit() {
    basicValidator.addField('email',
        required: true,
        label: "Email",
        validators: [MyEmailValidator()],
        controller: TextEditingController(text: 'henox@coderthemes.com'));

    basicValidator.addField('password',
        required: true,
        label: "Password",
        validators: [MyLengthValidator(min: 6, max: 10)],
        controller: TextEditingController(text: '123456789'));
    super.onInit();
  }

  void rememberToggle() {
    rememberMe = !rememberMe;
    update();
  }

  Future<void> onLogin() async {
    if (basicValidator.validateForm()) {
      update();
      var errors = await AuthService.loginUser(basicValidator.getData());
      if (errors != null) {
        basicValidator.addErrors(errors);
        basicValidator.validateForm();
        basicValidator.clearErrors();
      } else {
        String nextUrl =
            Uri.parse(ModalRoute.of(Get.context!)?.settings.name ?? "")
                    .queryParameters['next'] ??
                "/dashboard";
        Get.toNamed(nextUrl);
      }
      update();
    }
  }

  void gotoForgotPasswordScreen() {
    Get.toNamed('/auth/forgot_password');
  }

  void goToRegisterScreen() {
    Get.toNamed('/auth/register_account');
  }
}
