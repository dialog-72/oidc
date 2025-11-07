// ignore_for_file: avoid_redundant_argument_values

import 'dart:io';

import 'package:async/async.dart';
import 'package:bdaya_shared_value/bdaya_shared_value.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';

//This file represents a global state, which is bad
//in a production app (since you can't test it).

//usually you would use a dependency injection library
//and put these in a service.
final exampleLogger = Logger('oidc.example');

/// Gets the current manager used in the example.
OidcUserManager currentManager = userManager;

final userManager = OidcUserManager.lazy(
  // discoveryDocumentUri: Uri.parse(
  //   'https://connexev3.grandest.fr/gecas/oidc/.well-known/openid-configuration',
  // ),
  discoveryDocumentUri: Uri.parse(
    'https://connexev3.recette.grandest.fr/gecas/oidc/.well-known',
  ),
  clientCredentials: const OidcClientAuthentication.clientSecretBasic(
    // clientId: 'JEUNESTV3-PROD-BENEFICIAIRE-MOBILE',
    // clientSecret: '0gb7Y6QlRLUbk3ncLmZM',
    clientId: 'JEUNESTV3-REC-PART-MOBILE',
    clientSecret: 'GrandEST',
  ),
  keyStore: JsonWebKeyStore(),
  store: OidcDefaultStore(),
  settings: OidcUserManagerSettings(
    frontChannelLogoutUri: Uri(path: 'redirect.html'),
    uiLocales: ['fr'],
    refreshBefore: (token) {
      return const Duration(seconds: 1);
    },
    strictJwtVerification: true,
    supportOfflineAuth: false,
    scope: ['openid', 'rge'],
    // scope: ['openid'],
    // postLogoutRedirectUri:
    //     Uri.parse('com.grandest.jeunest:/oauth2redirect'),
    redirectUri: Uri.parse('com.grandest.jeunest:/oauth2redirect'),
    postLogoutRedirectUri:
        Uri.parse('com.grandest.jeunest:/endsessionredirect'),
    // redirectUri: Uri.parse('com.grandest.jeunest:/oauth2redirect'),
  ),
);

// final certificationManager = OidcUserManager.lazy(
//   discoveryDocumentUri: OidcUtils.getOpenIdConfigWellKnownUri(
//     Uri.parse('https://www.certification.openid.net/test/a/oidc_dart'),
//   ),
//   clientCredentials: const OidcClientAuthentication.clientSecretPost(
//     clientId: 'my_web_client',
//     clientSecret: 'my_web_client_secret',
//   ),
//   store: OidcDefaultStore(),
//   settings: OidcUserManagerSettings(
//     strictJwtVerification: true,
//     scope: ['profile', 'email'],
//     redirectUri: Uri.parse('http://localhost:22433/redirect.html'),
//     frontChannelLogoutUri: Uri.parse(
//       'http://localhost:22433/redirect.html?requestType=front-channel-logout',
//     ),
//     postLogoutRedirectUri: Uri.parse('http://localhost:22433/redirect.html'),
//     userInfoSettings: const OidcUserInfoSettings(
//       accessTokenLocation: OidcUserInfoAccessTokenLocations.formParameter,
//       requestMethod: OidcConstants_RequestMethod.post,
//       sendUserInfoRequest: true,
//       followDistributedClaims: true,
//     ),
//   ),
// );

///===========================

final initMemoizer = AsyncMemoizer<void>();
Future<void> initApp() {
  return initMemoizer.runOnce(() async {
    currentManager.userChanges().listen((event) {
      cachedAuthedUser.$ = event;
      exampleLogger.info(
        'User changed: ${event?.claims.toJson()}, info: ${event?.userInfo}',
      );
    });

    await currentManager.init();
  });
}

final cachedAuthedUser = SharedValue<OidcUser?>(value: null);
