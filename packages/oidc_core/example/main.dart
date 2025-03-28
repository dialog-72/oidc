// ignore_for_file: avoid_print, omit_local_variable_types

import 'package:jose_plus/jose.dart';
import 'package:oidc_core/oidc_core.dart';

// Check this file to see how the user manager is implemented
import 'cli_user_manager.dart';

// This example shows how to use the authorization code flow using
// https://demo.duendesoftware.com idp from the cli.
// you can login with google, or with bob/bob, or with alice/alice.

final idp = Uri.parse('https://demo.duendesoftware.com/');
const String clientId = 'interactive.public';
final store = OidcMemoryStore();

void main() async {
  final manager = CliUserManager.lazy(
    ///rge
    discoveryDocumentUri: Uri.parse(
        'https://connexev3.recette.grandest.fr/gecas/oidc/.well-known'),
    clientCredentials: const OidcClientAuthentication.clientSecretBasic(
      clientId: 'JEUNESTV3-REC-PART-MOBILE',
      clientSecret: 'GrandEST',
    ),

    ///original
    // discoveryDocumentUri: OidcUtils.getOpenIdConfigWellKnownUri(
    //   Uri.parse('https://demo.duendesoftware.com'),
    // ),
    // // this is a public client,
    // // so we use [OidcClientAuthentication.none] constructor.
    // clientCredentials: const OidcClientAuthentication.none(
    //   clientId: 'interactive.public.short',
    // ),
    keyStore: JsonWebKeyStore(),
    store: store,
    settings: OidcUserManagerSettings(
      frontChannelLogoutUri: Uri(path: 'redirect.html'),
      uiLocales: ['fr'],
      refreshBefore: (token) {
        return const Duration(seconds: 1);
      },
      strictJwtVerification: true,
      supportOfflineAuth: false,

      /// rge
      scope: ['openid', 'rge'],

      // /// original
      // scope: ['openid', 'profile', 'email', 'offline_access'],
      postLogoutRedirectUri:
          Uri.parse('com.bdayadev.oidc.example:/endsessionredirect'),
      redirectUri: Uri.parse('com.bdayadev.oidc.example:/oauth2redirect'),
    ),
  );

  print('Initializing the CLI user manager ...');
  await manager.init();
  print('User manager initialized !');

  manager.currentUser ??
      await manager.loginCustomAuthorizationCodeFlow(
        clientId: 'JEUNESTV3-REC-PART-MOBILE',
        ssoUri: 'https://preprod.www.memberz.fr/jeunest/sso',
      );
}
