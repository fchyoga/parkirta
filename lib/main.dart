import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirta/bloc/auth_bloc.dart';
import 'package:parkirta/color.dart';
import 'package:parkirta/ui/auth/login_page.dart';
import 'package:parkirta/ui/auth/pre_login_page.dart';
import 'package:parkirta/ui/auth/register_page.dart';
import 'package:parkirta/ui/auth/splash_page.dart';
import 'package:parkirta/ui/home_page.dart';
import 'package:parkirta/utils/contsant/authentication.dart';
import 'package:sp_util/sp_util.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();
  Bloc.observer = AppBlocObserver();
  runApp(App());
}

/// Custom [BlocObserver] that observes all bloc and cubit state changes.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) debugPrint(change.toString());
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint(transition.toString());
  }
}

class App extends StatelessWidget {
  /// {@macro app}
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => AuthenticationBloc(),
        child: const AppView()
    );
  }
}

class AppView extends StatelessWidget {

  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Parkirta',
        theme: ThemeData(
          primaryColor: Red50,
        ),
        initialRoute: "/",
        routes: {
          '/': (context) => AppRoute(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/pre_login': (context) => const PreLoginPage(),
          '/home': (context) => HomePage(),
        }
    );
  }
}

class AppRoute extends StatelessWidget {
  const AppRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, Authentication>(
          builder: (context, state) {
            debugPrint("state change $state");
            switch (state) {
              case Authentication.Authenticated:
                return HomePage();
              case Authentication.Unauthenticated:
                return LoginPage();
              default:
                return const SplashPage();
            }
          },
    );

  }
}
