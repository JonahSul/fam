import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:henox/controller/auth/register_account_controller.dart';
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

class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({super.key});

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late RegisterAccountController controller;
  @override
  late OutlineInputBorder outlineInputBorder;

  @override
  void initState() {
    controller = RegisterAccountController();
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
        tag: 'register-account_controller',
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
                      MyText.titleMedium("Free Sign Up", fontWeight: 600),
                      MySpacing.height(8),
                      MyText.bodySmall(
                          "Don't have an account? Create your account, it takes less than a minute",
                          muted: true),
                      MySpacing.height(16),
                      name(),
                      MySpacing.height(12),
                      email(),
                      MySpacing.height(12),
                      password(),
                      MySpacing.height(12),
                      rememberButton(),
                      MySpacing.height(12),
                      signUpBtn(),
                      MySpacing.height(20),
                      Center(
                        child: MyText.titleMedium("Create account using",
                            fontWeight: 600, xMuted: true),
                      ),
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
                      MyText.bodyMedium("Already have account?",
                          fontWeight: 600, muted: true),
                      MySpacing.width(8),
                      InkWell(
                        onTap: () => controller.gotoLogin(),
                        child: MyText.bodyMedium("Log in",
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

  Widget signUpBtn() {
    return MyButton.block(
        onPressed: () => controller.onLogin(),
        backgroundColor: contentTheme.primary,
        elevation: 0,
        child: MyText.bodyMedium("Sign Up", color: contentTheme.onPrimary));
  }

  Widget rememberButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Theme(
          data: ThemeData(unselectedWidgetColor: Colors.transparent),
          child: Checkbox(
            value: controller.termAndConditions,
            onChanged: (value) => controller.termAndConditionsToggle(),
          ),
        ),
        MyText.bodyMedium("I accept Terms and Conditions", fontWeight: 600)
      ],
    );
  }

  Widget name() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium("Name", fontWeight: 600),
        MySpacing.height(8),
        TextFormField(
          controller: controller.basicValidator.getController('first_name'),
          validator: controller.basicValidator.getValidation('first_name'),
          style: MyTextStyle.bodySmall(fontWeight: 600, muted: true),
          decoration: InputDecoration(
            hintText: "Enter your name",
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
        MyText.bodyMedium("Password", fontWeight: 600),
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
}
