// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `Attach`
  String get attach {
    return Intl.message(
      'Attach',
      name: 'attach',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Change`
  String get change {
    return Intl.message(
      'Change',
      name: 'change',
      desc: '',
      args: [],
    );
  }

  /// `Change Name`
  String get changeName {
    return Intl.message(
      'Change Name',
      name: 'changeName',
      desc: '',
      args: [],
    );
  }

  /// `Enter your new name below.`
  String get changeNameDescription {
    return Intl.message(
      'Enter your new name below.',
      name: 'changeNameDescription',
      desc: '',
      args: [],
    );
  }

  /// `Change Profile Picture`
  String get changeProfilePicture {
    return Intl.message(
      'Change Profile Picture',
      name: 'changeProfilePicture',
      desc: '',
      args: [],
    );
  }

  /// `Chat Info`
  String get chatInfo {
    return Intl.message(
      'Chat Info',
      name: 'chatInfo',
      desc: '',
      args: [],
    );
  }

  /// `Chats`
  String get chats {
    return Intl.message(
      'Chats',
      name: 'chats',
      desc: '',
      args: [],
    );
  }

  /// `Coming soon...`
  String get comingSoon {
    return Intl.message(
      'Coming soon...',
      name: 'comingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Copy Message`
  String get copyMessage {
    return Intl.message(
      'Copy Message',
      name: 'copyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Start New Chat`
  String get createNewChat {
    return Intl.message(
      'Start New Chat',
      name: 'createNewChat',
      desc: '',
      args: [],
    );
  }

  /// `Create New Chats`
  String get createNewChats {
    return Intl.message(
      'Create New Chats',
      name: 'createNewChats',
      desc: '',
      args: [],
    );
  }

  /// `Customize your account.`
  String get customizeYourAccount {
    return Intl.message(
      'Customize your account.',
      name: 'customizeYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this message?`
  String get deleteMessageDescription {
    return Intl.message(
      'Are you sure you want to delete this message?',
      name: 'deleteMessageDescription',
      desc: '',
      args: [],
    );
  }

  /// `Delete Message`
  String get deleteMessageTitle {
    return Intl.message(
      'Delete Message',
      name: 'deleteMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Delete Profile Picture`
  String get deleteProfilePicture {
    return Intl.message(
      'Delete Profile Picture',
      name: 'deleteProfilePicture',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Edit Messages`
  String get editMessages {
    return Intl.message(
      'Edit Messages',
      name: 'editMessages',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Enable Members List`
  String get enableParticipantsList {
    return Intl.message(
      'Enable Members List',
      name: 'enableParticipantsList',
      desc: '',
      args: [],
    );
  }

  /// `To continue, please enter your password.`
  String get enterPasswordDescription {
    return Intl.message(
      'To continue, please enter your password.',
      name: 'enterPasswordDescription',
      desc: '',
      args: [],
    );
  }

  /// `The email is already in use.`
  String get errorEmailAlreadyInUse {
    return Intl.message(
      'The email is already in use.',
      name: 'errorEmailAlreadyInUse',
      desc: '',
      args: [],
    );
  }

  /// `There are some empty fields.`
  String get errorEmptyFields {
    return Intl.message(
      'There are some empty fields.',
      name: 'errorEmptyFields',
      desc: '',
      args: [],
    );
  }

  /// `This field cannot be empty.`
  String get errorFieldEmpty {
    return Intl.message(
      'This field cannot be empty.',
      name: 'errorFieldEmpty',
      desc: '',
      args: [],
    );
  }

  /// `There is no associated account.`
  String get errorNoAccount {
    return Intl.message(
      'There is no associated account.',
      name: 'errorNoAccount',
      desc: '',
      args: [],
    );
  }

  /// `This operation is not allowed.`
  String get errorOperationNotAllowed {
    return Intl.message(
      'This operation is not allowed.',
      name: 'errorOperationNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `The passwords need to match.`
  String get errorPasswordMismatch {
    return Intl.message(
      'The passwords need to match.',
      name: 'errorPasswordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Your password does not respect the requirements.`
  String get errorPasswordRequirements {
    return Intl.message(
      'Your password does not respect the requirements.',
      name: 'errorPasswordRequirements',
      desc: '',
      args: [],
    );
  }

  /// `Success.`
  String get errorSuccess {
    return Intl.message(
      'Success.',
      name: 'errorSuccess',
      desc: '',
      args: [],
    );
  }

  /// `This {field} is invalid.`
  String errorThisIsInvalid(Object field) {
    return Intl.message(
      'This $field is invalid.',
      name: 'errorThisIsInvalid',
      desc: '',
      args: [field],
    );
  }

  /// `Your requests have been blocked temporarily.`
  String get errorTooManyRequests {
    return Intl.message(
      'Your requests have been blocked temporarily.',
      name: 'errorTooManyRequests',
      desc: '',
      args: [],
    );
  }

  /// `Unknown error.`
  String get errorUnknown {
    return Intl.message(
      'Unknown error.',
      name: 'errorUnknown',
      desc: '',
      args: [],
    );
  }

  /// `This account has been banned.`
  String get errorUserDisabled {
    return Intl.message(
      'This account has been banned.',
      name: 'errorUserDisabled',
      desc: '',
      args: [],
    );
  }

  /// `This username is taken.`
  String get errorUsernameTaken {
    return Intl.message(
      'This username is taken.',
      name: 'errorUsernameTaken',
      desc: '',
      args: [],
    );
  }

  /// `The account hasn't been found.`
  String get errorUserNotFount {
    return Intl.message(
      'The account hasn\'t been found.',
      name: 'errorUserNotFount',
      desc: '',
      args: [],
    );
  }

  /// `It seems that you did not access the link we've sent. Please access it, then try again.`
  String get errorVerificationLinkNotAccessed {
    return Intl.message(
      'It seems that you did not access the link we\'ve sent. Please access it, then try again.',
      name: 'errorVerificationLinkNotAccessed',
      desc: '',
      args: [],
    );
  }

  /// `The password is too weak.`
  String get errorWeakPassword {
    return Intl.message(
      'The password is too weak.',
      name: 'errorWeakPassword',
      desc: '',
      args: [],
    );
  }

  /// `The password is incorrect.`
  String get errorWrongPassword {
    return Intl.message(
      'The password is incorrect.',
      name: 'errorWrongPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enjoy Allo.`
  String get finishScreenDescription {
    return Intl.message(
      'Enjoy Allo.',
      name: 'finishScreenDescription',
      desc: '',
      args: [],
    );
  }

  /// `You're done!`
  String get finishScreenTitle {
    return Intl.message(
      'You\'re done!',
      name: 'finishScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get firstName {
    return Intl.message(
      'Name',
      name: 'firstName',
      desc: '',
      args: [],
    );
  }

  /// `Forgot your password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot your password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `Group`
  String get group {
    return Intl.message(
      'Group',
      name: 'group',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Initials`
  String get initials {
    return Intl.message(
      'Initials',
      name: 'initials',
      desc: '',
      args: [],
    );
  }

  /// `Account Info`
  String get internalAccountInfo {
    return Intl.message(
      'Account Info',
      name: 'internalAccountInfo',
      desc: '',
      args: [],
    );
  }

  /// `Internal Menu`
  String get internalMenu {
    return Intl.message(
      'Internal Menu',
      name: 'internalMenu',
      desc: '',
      args: [],
    );
  }

  /// `These options are experimental and only intended for internal use. Do not use these settings, as they may render the app unusable.`
  String get internalMenuDisclamer {
    return Intl.message(
      'These options are experimental and only intended for internal use. Do not use these settings, as they may render the app unusable.',
      name: 'internalMenuDisclamer',
      desc: '',
      args: [],
    );
  }

  /// `Internal Typing Indicator Demo`
  String get internalTypingIndicatorDemo {
    return Intl.message(
      'Internal Typing Indicator Demo',
      name: 'internalTypingIndicatorDemo',
      desc: '',
      args: [],
    );
  }

  /// `Surname`
  String get lastName {
    return Intl.message(
      'Surname',
      name: 'lastName',
      desc: '',
      args: [],
    );
  }

  /// `To continue, please enter your email address.`
  String get loginScreenDescription {
    return Intl.message(
      'To continue, please enter your email address.',
      name: 'loginScreenDescription',
      desc: '',
      args: [],
    );
  }

  /// `Let's sign in...`
  String get loginScreenTitle {
    return Intl.message(
      'Let\'s sign in...',
      name: 'loginScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logOut {
    return Intl.message(
      'Log Out',
      name: 'logOut',
      desc: '',
      args: [],
    );
  }

  /// `Me`
  String get me {
    return Intl.message(
      'Me',
      name: 'me',
      desc: '',
      args: [],
    );
  }

  /// `Members`
  String get members {
    return Intl.message(
      'Members',
      name: 'members',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get message {
    return Intl.message(
      'Message',
      name: 'message',
      desc: '',
      args: [],
    );
  }

  /// `The message has been copied.`
  String get messageCopied {
    return Intl.message(
      'The message has been copied.',
      name: 'messageCopied',
      desc: '',
      args: [],
    );
  }

  /// `The message has been deleted.`
  String get messageDeleted {
    return Intl.message(
      'The message has been deleted.',
      name: 'messageDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Message Options`
  String get messageOptions {
    return Intl.message(
      'Message Options',
      name: 'messageOptions',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `No camera available.`
  String get noCameraAvailable {
    return Intl.message(
      'No camera available.',
      name: 'noCameraAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No profile picture`
  String get noProfilePicture {
    return Intl.message(
      'No profile picture',
      name: 'noProfilePicture',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Optional`
  String get optional {
    return Intl.message(
      'Optional',
      name: 'optional',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Your password must contain a minimum of 8 characters, which include: letters (uppercase and lowercase), digits, symbols.`
  String get passwordCriteria {
    return Intl.message(
      'Your password must contain a minimum of 8 characters, which include: letters (uppercase and lowercase), digits, symbols.',
      name: 'passwordCriteria',
      desc: '',
      args: [],
    );
  }

  /// `Private`
  String get private {
    return Intl.message(
      'Private',
      name: 'private',
      desc: '',
      args: [],
    );
  }

  /// `Profile Picture`
  String get profilePicture {
    return Intl.message(
      'Profile Picture',
      name: 'profilePicture',
      desc: '',
      args: [],
    );
  }

  /// `Reactions`
  String get reactions {
    return Intl.message(
      'Reactions',
      name: 'reactions',
      desc: '',
      args: [],
    );
  }

  /// `Read`
  String get read {
    return Intl.message(
      'Read',
      name: 'read',
      desc: '',
      args: [],
    );
  }

  /// `Received`
  String get received {
    return Intl.message(
      'Received',
      name: 'received',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get reply {
    return Intl.message(
      'Reply',
      name: 'reply',
      desc: '',
      args: [],
    );
  }

  /// `Reply to Message`
  String get replyToMessage {
    return Intl.message(
      'Reply to Message',
      name: 'replyToMessage',
      desc: '',
      args: [],
    );
  }

  /// `You will receive an email.`
  String get resetLinkSent {
    return Intl.message(
      'You will receive an email.',
      name: 'resetLinkSent',
      desc: '',
      args: [],
    );
  }

  /// `Sent`
  String get sent {
    return Intl.message(
      'Sent',
      name: 'sent',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `To continue, please type your name.`
  String get setupNameScreenDescription {
    return Intl.message(
      'To continue, please type your name.',
      name: 'setupNameScreenDescription',
      desc: '',
      args: [],
    );
  }

  /// `What's your name?`
  String get setupNameScreenTitle {
    return Intl.message(
      'What\'s your name?',
      name: 'setupNameScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get setupNext {
    return Intl.message(
      'Next',
      name: 'setupNext',
      desc: '',
      args: [],
    );
  }

  /// `To continue, please enter a password that you want to use with your account.`
  String get setupPasswordScreenDescription {
    return Intl.message(
      'To continue, please enter a password that you want to use with your account.',
      name: 'setupPasswordScreenDescription',
      desc: '',
      args: [],
    );
  }

  /// `Security is a must.`
  String get setupPasswordScreenTitle {
    return Intl.message(
      'Security is a must.',
      name: 'setupPasswordScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `This is your last step. Adjust the settings below to make the app your own.`
  String get setupPersonalizeScreenDescription {
    return Intl.message(
      'This is your last step. Adjust the settings below to make the app your own.',
      name: 'setupPersonalizeScreenDescription',
      desc: '',
      args: [],
    );
  }

  /// `Personalize your experience.`
  String get setupPersonalizeScreenTitle {
    return Intl.message(
      'Personalize your experience.',
      name: 'setupPersonalizeScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Everyone can see your profile picture. You can skip this step if you want.`
  String get setupProfilePictureScreenDescription {
    return Intl.message(
      'Everyone can see your profile picture. You can skip this step if you want.',
      name: 'setupProfilePictureScreenDescription',
      desc: '',
      args: [],
    );
  }

  /// `Choose a profile picture.`
  String get setupProfilePictureScreenTitle {
    return Intl.message(
      'Choose a profile picture.',
      name: 'setupProfilePictureScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `The username is a unique combination of letters, digits, dots and underlines. It should not contain spaces or other characters.`
  String get setupUsernameRequirements {
    return Intl.message(
      'The username is a unique combination of letters, digits, dots and underlines. It should not contain spaces or other characters.',
      name: 'setupUsernameRequirements',
      desc: '',
      args: [],
    );
  }

  /// `To continue, enter an username that you want to use.`
  String get setupUsernameScreenDescription {
    return Intl.message(
      'To continue, enter an username that you want to use.',
      name: 'setupUsernameScreenDescription',
      desc: '',
      args: [],
    );
  }

  /// `What username do you want?`
  String get setupUsernameScreenTitle {
    return Intl.message(
      'What username do you want?',
      name: 'setupUsernameScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `We've sent you an email that contains a link. Access it, then come back and click "Next".`
  String get setupVerificationScreenDescription {
    return Intl.message(
      'We\'ve sent you an email that contains a link. Access it, then come back and click "Next".',
      name: 'setupVerificationScreenDescription',
      desc: '',
      args: [],
    );
  }

  /// `We want to verify you.`
  String get setupVerificationScreenTitle {
    return Intl.message(
      'We want to verify you.',
      name: 'setupVerificationScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Communicate easy and fast with your loved ones in safety and comfort.`
  String get setupWelcomeScreenDescription {
    return Intl.message(
      'Communicate easy and fast with your loved ones in safety and comfort.',
      name: 'setupWelcomeScreenDescription',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Allo!`
  String get setupWelcomeScreenTitle {
    return Intl.message(
      'Welcome to Allo!',
      name: 'setupWelcomeScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Show previous messages`
  String get showPastMessages {
    return Intl.message(
      'Show previous messages',
      name: 'showPastMessages',
      desc: '',
      args: [],
    );
  }

  /// `Special characters are not allowed.`
  String get specialCharactersNotAllowed {
    return Intl.message(
      'Special characters are not allowed.',
      name: 'specialCharactersNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Blue`
  String get themeBlue {
    return Intl.message(
      'Blue',
      name: 'themeBlue',
      desc: '',
      args: [],
    );
  }

  /// `Burgundy`
  String get themeBurgundy {
    return Intl.message(
      'Burgundy',
      name: 'themeBurgundy',
      desc: '',
      args: [],
    );
  }

  /// `Cyan`
  String get themeCyan {
    return Intl.message(
      'Cyan',
      name: 'themeCyan',
      desc: '',
      args: [],
    );
  }

  /// `Emerald`
  String get themeEmerald {
    return Intl.message(
      'Emerald',
      name: 'themeEmerald',
      desc: '',
      args: [],
    );
  }

  /// `This chat uses a theme that is not available in your app version.`
  String get themeNotAvailable {
    return Intl.message(
      'This chat uses a theme that is not available in your app version.',
      name: 'themeNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Pink`
  String get themePink {
    return Intl.message(
      'Pink',
      name: 'themePink',
      desc: '',
      args: [],
    );
  }

  /// `Purple`
  String get themePurple {
    return Intl.message(
      'Purple',
      name: 'themePurple',
      desc: '',
      args: [],
    );
  }

  /// `Red`
  String get themeRed {
    return Intl.message(
      'Red',
      name: 'themeRed',
      desc: '',
      args: [],
    );
  }

  /// `UID`
  String get uid {
    return Intl.message(
      'UID',
      name: 'uid',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `Upload Picture`
  String get uploadPicture {
    return Intl.message(
      'Upload Picture',
      name: 'uploadPicture',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Welcome back`
  String get welcomeBack {
    return Intl.message(
      'Welcome back',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any chats.`
  String get noChats {
    return Intl.message(
      'You don\'t have any chats.',
      name: 'noChats',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred.`
  String get anErrorOccurred {
    return Intl.message(
      'An error occurred.',
      name: 'anErrorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get image {
    return Intl.message(
      'Image',
      name: 'image',
      desc: '',
      args: [],
    );
  }

  /// `Enable Material 3 in app`
  String get material3App {
    return Intl.message(
      'Enable Material 3 in app',
      name: 'material3App',
      desc: '',
      args: [],
    );
  }

  /// `Enable Material 3 in chats`
  String get material3Chat {
    return Intl.message(
      'Enable Material 3 in chats',
      name: 'material3Chat',
      desc: '',
      args: [],
    );
  }

  /// `The operation was canceled.`
  String get canceledOperation {
    return Intl.message(
      'The operation was canceled.',
      name: 'canceledOperation',
      desc: '',
      args: [],
    );
  }

  /// `Personalise`
  String get personalise {
    return Intl.message(
      'Personalise',
      name: 'personalise',
      desc: '',
      args: [],
    );
  }

  /// `Hide Navigation Hints`
  String get personaliseHideNavigationHints {
    return Intl.message(
      'Hide Navigation Hints',
      name: 'personaliseHideNavigationHints',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Build Number`
  String get buildNumber {
    return Intl.message(
      'Build Number',
      name: 'buildNumber',
      desc: '',
      args: [],
    );
  }

  /// `Package Name`
  String get packageName {
    return Intl.message(
      'Package Name',
      name: 'packageName',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported`
  String get unsupported {
    return Intl.message(
      'Unsupported',
      name: 'unsupported',
      desc: '',
      args: [],
    );
  }

  /// `Preference cleared.`
  String get preferenceCleared {
    return Intl.message(
      'Preference cleared.',
      name: 'preferenceCleared',
      desc: '',
      args: [],
    );
  }

  /// `Change Name`
  String get accountChangeNameTitle {
    return Intl.message(
      'Change Name',
      name: 'accountChangeNameTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your new name.`
  String get accountChangeNameDescription {
    return Intl.message(
      'Enter your new name.',
      name: 'accountChangeNameDescription',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported message.`
  String get unsupportedMessage {
    return Intl.message(
      'Unsupported message.',
      name: 'unsupportedMessage',
      desc: '',
      args: [],
    );
  }

  /// `App Info`
  String get appInfo {
    return Intl.message(
      'App Info',
      name: 'appInfo',
      desc: '',
      args: [],
    );
  }

  /// `Device Info`
  String get deviceInfo {
    return Intl.message(
      'Device Info',
      name: 'deviceInfo',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ro'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
