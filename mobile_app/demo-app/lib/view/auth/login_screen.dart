import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:henox/controller/auth/login_controller.dart';
import 'package:henox/helpers/theme/theme_customizer.dart';
import 'package:henox/helpers/utils/mixins/ui_mixin.dart';
import 'package:henox/helpers/widgets/my_button.dart';
import 'package:henox/helpers/widgets/my_container.dart';
import 'package:henox/helpers/widgets/my_spacing.dart';
import 'package:henox/helpers/widgets/my_text.dart';
import 'package:henox/helpers/widgets/my_text_style.dart';
import 'package:henox/images.dart';
import 'package:henox/view/layouts/auth_layout.dart';
import 'package:remixicon/remixicon.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late LoginController controller;
  @override
  late OutlineInputBorder outlineInputBorder;

  @override
  void initState() {
    controller = LoginController();
    outlineInputBorder = OutlineInputBorder(
        borderSide: BorderSide(
      color: Color(0x3d6c757d),
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: GetBuilder(
        init: controller,
        tag: 'login_controller',
        builder: (controller) {
          return Padding(
            padding: MySpacing.all(20),
            child: Form(
              key: controller.basicValidator.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyContainer(
                    paddingAll: 0,
                    height: 28,
                    child: Image.asset(
                        ThemeCustomizer.instance.theme == ThemeMode.light
                            ? Images.logoDark
                            : Images.logo),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.titleMedium("Sign In", fontWeight: 600),
                      MySpacing.height(8),
                      MyText.bodySmall(
                          "Enter your email address and password to access account.",
                          muted: true),
                      MySpacing.height(16),
                      email(),
                      MySpacing.height(20),
                      password(),
                      MySpacing.height(16),
                      rememberButton(),
                      MySpacing.height(16),
                      loginBtn(),
                      MySpacing.height(20),
                      Center(
                          child: MyText.bodyMedium("Sign in with",
                              fontWeight: 600)),
                      MySpacing.height(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyContainer.roundBordered(
                            onTap: () {},
                            paddingAll: 4,
                            borderColor: contentTheme.primary,
                            child: Icon(Remix.facebook_circle_fill,
                                size: 18, color: contentTheme.primary),
                          ),
                          MySpacing.width(12),
                          MyContainer.roundBordered(
                            onTap: () {},
                            paddingAll: 4,
                            borderColor: contentTheme.danger,
                            child: Icon(Remix.google_fill,
                                size: 18, color: contentTheme.danger),
                          ),
                          MySpacing.width(12),
                          MyContainer.roundBordered(
                            onTap: () {},
                            paddingAll: 4,
                            borderColor: contentTheme.info,
                            child: Icon(Remix.twitter_fill,
                                size: 18, color: contentTheme.info),
                          ),
                          MySpacing.width(12),
                          MyContainer.roundBordered(
                            onTap: () {},
                            paddingAll: 4,
                            borderColor: contentTheme.secondary,
                            child: Icon(Remix.github_fill,
                                size: 18, color: contentTheme.secondary),
                          ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText.bodyMedium("Don't have an account? ",
                          fontWeight: 600, muted: true),
                      InkWell(
                        onTap: () => controller.goToRegisterScreen(),
                        child: MyText.bodyMedium("Sign Up",
                            fontWeight: 600,
                            decoration: TextDecoration.underline),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget loginBtn() {
    return MyButton.block(
        onPressed: () {
          controller.onLogin();
        },
        backgroundColor: contentTheme.primary,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Remix.login_box_line, color: contentTheme.onPrimary, size: 16),
            MySpacing.width(8),
            MyText.bodyMedium("Log In", color: contentTheme.onPrimary),
          ],
        ));
  }

  Widget email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium("Email Address", fontWeight: 600),
        MySpacing.height(8),
        TextFormField(
          controller: controller.basicValidator.getController('email'),
          validator: controller.basicValidator.getValidation('email'),
          style: MyTextStyle.bodySmall(fontWeight: 600, muted: true),
          decoration: InputDecoration(
            hintText: "Enter your email",
            hintStyle: MyTextStyle.bodySmall(fontWeight: 600, muted: true),
            isDense: true,
            contentPadding: MySpacing.xy(12, 12),
            border: outlineInputBorder,
            disabledBorder: outlineInputBorder,
            errorBorder: outlineInputBorder,
            focusedBorder: outlineInputBorder,
            enabledBorder: outlineInputBorder,
          ),
        ),
      ],
    );
  }

  Widget password() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText.bodyMedium("Password", fontWeight: 600),
            forgotButton(),
          ],
        ),
        MySpacing.height(8),
        TextFormField(
          controller: controller.basicValidator.getController('password'),
          validator: controller.basicValidator.getValidation('password'),
          style: MyTextStyle.bodySmall(fontWeight: 600, muted: true),
          decoration: InputDecoration(
            hintText: "Enter your password",
            hintStyle: MyTextStyle.bodySmall(fontWeight: 600, muted: true),
            isDense: true,
            contentPadding: MySpacing.xy(12, 12),
            border: outlineInputBorder,
            disabledBorder: outlineInputBorder,
            errorBorder: outlineInputBorder,
            focusedBorder: outlineInputBorder,
            enabledBorder: outlineInputBorder,
          ),
        ),
      ],
    );
  }

  Widget forgotButton() {
    return InkWell(
        onTap: () => controller.gotoForgotPasswordScreen(),
        child: MyText.bodySmall("Forgot Password?", muted: true));
  }

  Widget rememberButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Theme(
          data: ThemeData(unselectedWidgetColor: Colors.transparent),
          child: Checkbox(
            value: controller.rememberMe,
            onChanged: (value) => controller.rememberToggle(),
          ),
        ),
        MyText.bodyMedium("Remember me", fontWeight: 600)
      ],
    );
  }
}
