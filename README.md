# Allo
### A messaging app with high standards.
---
Welcome to Allo. 
Allo is a messaging app developed by me which is mainly an experiment. I want to see how my developing and problem solving skills are, developing for the front end and for the backend as well.

Allo is pure work in progress. I always challenge myself to build this beautiful app with beautiful design and mesmerizing animations.

---

## Features

Here is a list of features that I have implemented as of 19 june 2022. This list may be outdated, but make sure to check commit history, there is full describing of the changes I implement in a version of the app.

1. Personalisation of the account:
    - profile picture,
    - name,
    - username;
2. Private chats and group chats;
3. Sending messages:
    - text messages,
    - image messages;
4. Replying to messages;
5. Password resetting;
6. Personalising the app:
    - change the app theme using Material 3 style design (even though I built this in Flutter, there may be huge inconsistencies between native behavior and the app behavior, things that I want to adress with my own implementation of things),
    - use the phone's dynamic color (Android 12+),
    - light and dark mode, option to synchronize with settings;

And many more features, just for you, freshly baked! :)

---

## Availability

Allo is available on Android via the Google Play Store, and on the web via our PWA (Progressive Web Application).

>Currently, we are not supporting iOS because we need an Apple device to build for this platform, and an App Store Connect account to publish the app (because of the restrictive politices Apple inforces).
Also, we are not supporting Windows, Linux and MacOS because the packages we are using (mainly Firebase modules) are not compatible with the platform (and we do not own an Apple device).

### Installing from Google Play

This app is available on Google Play. Press the icon below to install it on your Android and Chrome OS devices.

<a href="https://play.google.com/store/apps/details?id=com.relays.messenger">
    <img src="get_it_on_google_play.png" alt="Get it on Google Play" width=200>
</a>

### Installing as a PWA

This app is available as a Progressive Web App if you access the site on a compatible browser.
You may need to dig deeper into the menus to install it to your device, I recommend checking [this](https://mobilesyrup.com/2020/05/24/how-install-progressive-web-app-pwa-android-ios-pc-mac/) guide.

<a href="https://allo-ms.web.app">
<img src="launch_as_pwa.svg" alt="Launch as PWA" width=180>
</a>

---

## Channels

This app is available into multiple channels: stable, beta and alpha. 

- stable: Updates that are not frequent, a more stable app experience.
- beta: Somewhat frequent updates, prone to few bugs, verified and tested builds from the alpha channel.
- alpha: Frequent updates, may have many bugs, minimally verified and tested. Can break the app sometimes, use at your own risk.

The stable channel is the default version installed from the Google Play Store, and from https://allo-ms.web.app.

The beta channel is the recommended version if you want to test the features of the new app without having a whole lot of bugs (like in the alpha channel). This is offered by default if you become a tester in the Google Play page of the app (or by accessing [this link](https://play.google.com/apps/testing/com.relays.messenger) to become a tester), or if you access https://allobeta.web.app.

The alpha channel can only be accessed from the web version of the app. The Google Play version can only be tested under exceptional circumstances, by our internal workers. You can access the web alpha channel version [here](https://allo-alpha.web.app).

---

## Contributing

We always welcome contribution from anyone.
Contributions may come in 2 forms:

1. Opening issues on this repository.
    - you can always open issues on this repository if you think you are occuring a bug or want to request a feature. 
    - although, you may need to provide lots of information about how to reproduce the bug, maybe a screenshot / screen recording, for us to better understand the occured behavior.
    - for feature requests, it will be very useful for you to specify what impact you think the feature will have on the database reads/writes/deletes - remember that this app is free, and that means we need to keep costs down.
2. Opening pull requests on this repository.
    - you may want to first open a issue about the thing you are trying to change with your pull request.
    - after we approve, you can start to work on the feature/bugfix you want to implement.
    - keep in mind that you may want to keep the code as descriptive as possible, mainly using documentation as a form of describing what your code does:

    ```dart 
    import 'package:flutter/material.dart';

    // This is an example of how you should document methods.

    /// [getChats] calls the database for the chat list, then converts that list to a format that is easier to digest and is fully compatible with intellisense.
    Future<T> getChats<T>(/*Arguments*/) async {
        final chats = await database.query(/*query*/).catchError((e) {
            throw Exception('Example of exception');
        });
        return T.convertChatList(chats);
    }
    ```
    - try to not obfuscate the code, the goal here is to make the code usable, but also modifiable based on the future changes to the code base.
---

## Building the source code

You can always build your own version of the app. Though, make sure that you are using your own Firebase Database details, as it may pollute our database, and you can actually see the data structure by yourself.

> For security purposes, you cannot build a release flavor of the app because of malicious updates that you can make signing the app with the genuine key.

Building the app:

1. Make sure you install the latest version of Flutter that the channel uses.
    - the stable channel uses the stable version of Flutter
    - the beta and alpha channel use the latest beta version of Flutter.
    - sometimes, the app may not build because it is not migrated to the latest version of Flutter (breaking changes) - do not hesitate to create an issue on this repository requesting us to upgrade the Flutter version and fix the breaking changes.
2. After installing the tooling, build the app on the following platforms with the following commands:
    - ```flutter build apk --flavor debug``` for Android. You can add the ```--split-per-abi``` if you want separate apks based on the processor architecture, and replace ```apk``` with ```appbundle``` if you want a .aab file.
    -- ```flutter build web``` for building the app for the web platform. 


If you are having any issues building the app or any questions, do not hesitate to create an issue.

---

# Thank you!

Thank you for giving us some of your time. I hope we caught your attention and we welcome your contribution everytime.


