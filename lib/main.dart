import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:themotorwash/ui/screens/offer_stores_list/offer_stores_list_screen.dart';
import 'package:themotorwash/ui/screens/onboarding/onboarding_screen.dart';
import 'package:themotorwash/ui/screens/services_list/services_list_screen.dart';
import 'package:upgrader/upgrader.dart';

import 'package:themotorwash/blocs/cart/cart_function_bloc.dart';
import 'package:themotorwash/blocs/global_auth/global_auth_bloc.dart';
import 'package:themotorwash/blocs/global_cart/bloc/global_cart_bloc.dart';
import 'package:themotorwash/blocs/global_location/global_location_bloc.dart';
import 'package:themotorwash/blocs/global_vehicle_type/bloc/global_vehicle_type_bloc.dart';
import 'package:themotorwash/blocs/location_functions/bloc/location_functions_bloc.dart';
import 'package:themotorwash/blocs/order_review/order_review_bloc.dart';
import 'package:themotorwash/blocs/phone_auth/phone_auth_bloc.dart';
import 'package:themotorwash/data/api/api_constants.dart';
import 'package:themotorwash/data/api/api_methods.dart';
import 'package:themotorwash/data/api/api_service.dart';
import 'package:themotorwash/data/local/local_data_service.dart';
import 'package:themotorwash/data/models/auth_tokens.dart';
import 'package:themotorwash/data/models/multi_day_slot_detail.dart';
import 'package:themotorwash/data/notifications/fcm_helper.dart';
import 'package:themotorwash/data/repos/auth_repository.dart';
import 'package:themotorwash/data/repos/auth_rest_repository.dart';
import 'package:themotorwash/data/repos/payment_repository.dart';
import 'package:themotorwash/data/repos/payment_rest_repository.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/data/repos/rest_repository.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/simple_bloc_observer.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/booking_detail/booking_detail.dart';
import 'package:themotorwash/ui/screens/booking_summary/booking_summary_screen.dart';
import 'package:themotorwash/ui/screens/cancel_order/cancel_order.dart';
import 'package:themotorwash/ui/screens/explore/explore_screen.dart';
import 'package:themotorwash/ui/screens/feedback/feedback_screen.dart';
import 'package:themotorwash/ui/screens/home/home_screen.dart';
import 'package:themotorwash/ui/screens/login/login_screen.dart';
import 'package:themotorwash/ui/screens/offer_selection/offer_selection.dart';
import 'package:themotorwash/ui/screens/order_review/order_review.dart';
import 'package:themotorwash/ui/screens/payment_choice/payment_choice.dart';
import 'package:themotorwash/ui/screens/profile/profile_screen.dart';
import 'package:themotorwash/ui/screens/slot_select/components/pages/multi_day_slot_select_screen.dart';
import 'package:themotorwash/ui/screens/slot_select/slot_select_screen.dart';
import 'package:themotorwash/ui/screens/store_detail/blocs/store_detail_bloc.dart';
import 'package:themotorwash/ui/screens/store_detail/blocs/store_reviews/store_reviews_bloc.dart';
import 'package:themotorwash/ui/screens/store_detail/components/pages/gallery/gallery_view.dart';
import 'package:themotorwash/ui/screens/store_detail/store_detail_screen.dart';
import 'package:themotorwash/ui/screens/store_list/bloc/store_list_bloc.dart';
import 'package:themotorwash/ui/screens/store_list/store_list_screen.dart';
import 'package:themotorwash/ui/screens/verify_phone/verify_phone_screen.dart';
import 'package:themotorwash/ui/screens/your_bookings/bloc/your_bookings_bloc.dart';
import 'package:themotorwash/ui/screens/your_bookings/your_bookings_screen.dart';
import 'package:themotorwash/utils/utils.dart';

import 'firebase_options.dart';

GetIt getIt = GetIt.instance;
// late // mixpanel? // mixpanel;

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

// Future<void> initmixpanel() async {
//   // // mixpanel = await // mixpanel.init("28271a708d8c89da55aca5ed84b79ddd",
//   //     optOutTrackingDefault: false);
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } on Exception catch (e) {
    print("helllo" + e.toString());
  }
  PendingDynamicLinkData? initialLink;
  try {
    initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  } on Exception catch (e) {
    print(e.toString() + " Dynamic Link ");
  }
  try {
    await FirebaseAnalytics.instance.logAppOpen();
  } on Exception catch (e) {
    print(e.toString() + " Analytics");
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (e) {}

  try {
    await FirebaseMessaging.instance.getToken();
  } catch (e) {}
  try {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  } catch (e) {
    print(e.toString() + "helll");
  }
  try {
    await Hive.initFlutter();
  } catch (e) {}
  if (Platform.isAndroid) {
    try {
      //TODO : Implement FCM and Local Notification for iOS
      channel = const AndroidNotificationChannel(
        'default_channel', // id
        'High Importance Notifications', // title
        'This channel is used for important notifications.', // description
        importance: Importance.high,
        playSound: true,

        sound: RawResourceAndroidNotificationSound('turbo'),
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } on Exception catch (e) {
      print(e.toString());
    }
  } else if (Platform.isIOS) {
    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  if (Platform.isIOS) {
    FirebaseMessaging.instance.requestPermission();
  }
  Bloc.observer = SimpleBlocObserver();
  // try {
  //   await initmixpanel();
  // } catch (e) {
  //   print(e.toString());
  // }
  runApp(
    MyApp(
      initialLink: initialLink,
    ),
    // Wrap your app
  );
}

class MyApp extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;
  const MyApp({
    Key? key,
    this.initialLink,
  }) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // AppUpdateInfo? _updateInfo;
  late Repository _repository;
  late PaymentRepository _paymentRepository;

  late AuthRepository _authRepository;

  late GlobalAuthBloc _globalAuthBloc;
  late GlobalLocationBloc _globalLocationBloc;
  late GlobalVehicleTypeBloc _globalVehicleTypeBloc;
  late OrderReviewBloc _orderReviewBloc;
  late CartFunctionBloc _cartFunctionBloc;
  late LocalDataService _localDataService;
  late FirebaseMessaging _fcmInstance;
  late GlobalCartBloc _globalCartBloc;

  @override
  void initState() {
    super.initState();
    precacheImage(AssetImage('assets/images/splash_background.png'), context);
    FcmHelper().onMessageFCM();
    _fcmInstance = FirebaseMessaging.instance;
    _globalAuthBloc = GlobalAuthBloc();
    _globalAuthBloc.add(AppStarted());
    getIt.registerSingleton<ApiMethods>(
        ApiService(apiConstants: ApiConstants(globalAuthBloc: _globalAuthBloc)),
        instanceName: ApiService.getItInstanceName);
    getIt.registerSingleton<LocalDataService>(LocalDataService(),
        instanceName: LocalDataService.getItInstanceName);
    ApiMethods _apiMethodsImp =
        getIt.get<ApiMethods>(instanceName: ApiService.getItInstanceName);
    _localDataService = getIt.get<LocalDataService>(
        instanceName: LocalDataService.getItInstanceName);

    _globalVehicleTypeBloc =
        GlobalVehicleTypeBloc(localDataService: _localDataService);

    _globalVehicleTypeBloc.add(CheckSavedVehicleType());
    _repository = RestRepository(apiMethodsImp: _apiMethodsImp);
    _paymentRepository = PaymentRestRepository(apiMethodsImp: _apiMethodsImp);
    _authRepository = AuthRestRepository(apiMethodsImp: _apiMethodsImp);
    _orderReviewBloc = OrderReviewBloc();
    _globalLocationBloc = GlobalLocationBloc(repository: _repository);
    _globalCartBloc = GlobalCartBloc();
    _cartFunctionBloc = CartFunctionBloc(
        repository: _repository,
        orderReviewBloc: _orderReviewBloc,
        globalCartBloc: _globalCartBloc);
    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    //   N
    // });
  }

  int count = 0;
  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      FlutterUxcam.optIntoSchematicRecordings();
      FlutterUxcam.setAutomaticScreenNameTagging(false);
      FlutterUxcam.startWithKey("gmibl3fq1byxxa6").then((value) async {
        if (value == true) {
          String? sessionUrl = await FlutterUxcam.urlForCurrentSession();
          FirebaseCrashlytics.instance.setCustomKey(
              "UXCam: Session Recording link", sessionUrl.toString());
        }
      });
    } else {
      FlutterUxcam.optOutOfSchematicRecordings();
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    return MultiBlocProvider(
      providers: [
        BlocProvider<GlobalAuthBloc>(
          create: (_) => _globalAuthBloc,
        ),
        BlocProvider<StoreDetailBloc>(
            create: (_) => StoreDetailBloc(repository: _repository)),
        BlocProvider<StoreListBloc>(
          create: (_) => StoreListBloc(
              repository: _repository, globalLocationBloc: _globalLocationBloc),
        ),
        BlocProvider<StoreReviewsBloc>(
          create: (_) => StoreReviewsBloc(repository: _repository),
        ),
        BlocProvider<CartFunctionBloc>(
          create: (_) => _cartFunctionBloc,
        ),
        BlocProvider<YourBookingsBloc>(
          create: (_) => YourBookingsBloc(repository: _repository),
        ),
        BlocProvider<PhoneAuthBloc>(
          create: (_) => PhoneAuthBloc(
              repository: _authRepository,
              globalAuthBloc: _globalAuthBloc,
              fcmInstance: _fcmInstance,
              localDataService: _localDataService),
        ),
        BlocProvider<GlobalLocationBloc>(
          create: (_) => _globalLocationBloc,
        ),
        BlocProvider<GlobalVehicleTypeBloc>(
          create: (_) => _globalVehicleTypeBloc,
        ),
        BlocProvider<OrderReviewBloc>(
          create: (_) => _orderReviewBloc,
        ),
        BlocProvider<GlobalCartBloc>(
          create: (_) => _globalCartBloc,
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (_) => _authRepository),
          RepositoryProvider(create: (_) => _repository),
          RepositoryProvider(create: (_) => _paymentRepository),
        ],
        child: MaterialApp(
          // builder: DevicePreview.appBuilder, // Add the locale here
          builder: (context, widget) => ResponsiveWrapper.builder(
              BouncingScrollWrapper.builder(context, widget!),
              maxWidth: 1200,
              minWidth: 420,
              defaultScale: true,
              // mediaQueryData: MediaQueryData(textScaleFactor: 2),
              breakpoints: [
                ResponsiveBreakpoint.resize(
                  420,
                  name: MOBILE,
                ),
                ResponsiveBreakpoint.autoScale(800, name: TABLET),
                ResponsiveBreakpoint.autoScale(1000, name: TABLET),
                ResponsiveBreakpoint.resize(1200, name: DESKTOP),
                ResponsiveBreakpoint.autoScale(2460, name: "4K"),
              ],
              background: Container(color: Color(0xFFF5F5F5))),

          initialRoute: '/',
          debugShowCheckedModeBanner: false,
          title: 'Autoave',
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.white,
                  statusBarBrightness: Brightness.dark),
            ),
            primaryColor: SizeConfig.kPrimaryColor,
            fontFamily: 'DM Sans',
            scaffoldBackgroundColor: Colors.white,
          ),
          home: FutureBuilder<bool>(
              future: _localDataService.isFirstOpen(),
              builder: (ctx, snapshot) {
                if (count == 0) {
                  SizeConfig().init(ctx);
                  count++;
                }
                if (widget.initialLink != null) {
                  autoaveLog('Initial Link');
                  return MainScreen(
                    cartFunctionBloc: _cartFunctionBloc,
                    globalAuthBloc: _globalAuthBloc,
                    initialLink: widget.initialLink,
                  );
                }
                // if(  snapshot.data == true) {
                //   autoaveLog('First Open');
                //   return SplashScreen();
                // }
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  autoaveLog('Snapshot has data');
                  if (snapshot.data ?? false) {
                    autoaveLog('Snapshot has data and is true');
                    return OnboardingScreen();
                  } else {
                    autoaveLog('False Snapshot');
                    return MainScreen(
                      cartFunctionBloc: _cartFunctionBloc,
                      globalAuthBloc: _globalAuthBloc,
                      initialLink: widget.initialLink,
                    );
                  }
                  // return SplashScreen();
                }
                autoaveLog('Returning Splash Main');
                return Scaffold(
                  body: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage('assets/images/splash_background.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Builder(builder: (ctx) {
                        return Image.asset(
                          'assets/images/logo.png',
                          scale: 4,
                        );
                      }),
                    ),
                  ),
                );
              }),
          onGenerateRoute: (settings) {
            if (settings.name == StoreListScreen.route) {
              final args = settings.arguments as StoreListArguments;

              return MaterialPageRoute(
                builder: (context) {
                  return StoreListScreen(
                    city: args.city,
                    title: args.title,
                    serviceTag: args.serviceTag,
                    imageUrl: args.imageUrl,
                  );
                },
              );
            }
            if (settings.name == OfferStoresListScreen.route) {
              final args = settings.arguments as OfferStoresListArguments;

              return MaterialPageRoute(
                builder: (context) {
                  return OfferStoresListScreen(
                    title: args.title,
                    imageUrl: args.imageUrl,
                  );
                },
              );
            }
            if (settings.name == HomeScreen.route) {
              return MaterialPageRoute(
                builder: (context) {
                  return HomeScreen();
                },
              );
            }
            if (settings.name == StoreDetailScreen.route) {
              final args = settings.arguments as StoreDetailArguments;
              return MaterialPageRoute(
                builder: (context) {
                  return StoreDetailScreen(
                    storeSlug: args.storeSlug,
                    serviceTag: args.serviceTag,
                  );
                },
              );
            }
            if (settings.name == SlotSelectScreen.route) {
              final args = settings.arguments as SlotSelectScreenArguments;

              return MaterialPageRoute(
                builder: (context) {
                  return SlotSelectScreen(
                    isMultiDay: args.isMultiDay,
                    cartTotal: args.cartTotal,
                    cartId: args.cardId,
                  );
                },
              );
            }
            if (settings.name == BookingSummaryScreen.route) {
              final args = settings.arguments as BookingSummaryScreenArguments;
              return MaterialPageRoute(
                builder: (context) {
                  return BookingSummaryScreen(
                    bookingId: args.bookingId,
                    isTransactionSuccessful: args.isTransactionSuccesful,
                  );
                },
              );
            }
            if (settings.name == LoginScreen.route) {
              return MaterialPageRoute(
                builder: (context) {
                  return LoginScreen(
                    initialLink: null,
                  );
                },
              );
            }
            if (settings.name == ProfileScreen.route) {
              final args = settings.arguments as ProfileScreenArguments;

              return MaterialPageRoute(
                builder: (context) {
                  return ProfileScreen(
                    showSkip: args.showSkip,
                  );
                },
              );
            }
            if (settings.name == VerifyPhoneScreen.route) {
              final args = settings.arguments as VerifyPhoneScreenArguments;
              return MaterialPageRoute(
                builder: (context) {
                  return VerifyPhoneScreen(phoneNumber: args.phoneNumber);
                },
              );
            }
            if (settings.name == ExploreScreen.route) {
              return MaterialPageRoute(
                builder: (context) {
                  return ExploreScreen(
                    initialLink: null,
                  );
                },
              );
            }
            if (settings.name == OrderReviewScreen.route) {
              final args = settings.arguments as OrderReviewScreenArguments;
              return MaterialPageRoute(
                builder: (context) {
                  return OrderReviewScreen(
                    dateSelected: args.dateSelected,
                    isMultiDay: args.isMultiDay,
                  );
                },
              );
            }
            if (settings.name == YourBookingsScreen.route) {
              final args = settings.arguments as YourBookingsScreenArguments;
              return MaterialPageRoute(
                builder: (context) {
                  return YourBookingsScreen(
                    fromBookingSummary: args.fromBookingSummary,
                  );
                },
              );
            }

            if (settings.name == BookingDetailScreen.route) {
              final args = settings.arguments as BookingDetailScreenArguments;

              return MaterialPageRoute(
                builder: (context) {
                  return BookingDetailScreen(
                      status: args.status, bookingId: args.bookingId);
                },
              );
            }
            if (settings.name == FeedbackScreen.route) {
              final args = settings.arguments as FeedbackScreenArguments;
              return MaterialPageRoute(
                builder: (context) {
                  return FeedbackScreen(
                    isFeedback: args.isFeedback,
                    orderNumber: args.orderNumber,
                  );
                },
              );
            }
            if (settings.name == PaymentChoiceScreen.route) {
              final args = settings.arguments as PaymentChoiceScreenArguments;

              return MaterialPageRoute(
                builder: (context) {
                  return PaymentChoiceScreen(
                    dateSelected: args.dateSelected,
                    slot: args.slot,
                    multiDaySlot: args.multiDaySlot,
                  );
                },
              );
            }
            if (settings.name == CancelOrderScreen.route) {
              final args = settings.arguments as CancelOrderScreenArguments;

              return MaterialPageRoute(
                builder: (context) {
                  return CancelOrderScreen(
                    bookingId: args.bookingId,
                  );
                },
              );
            }
            if (settings.name == OfferSelectionScreen.route) {
              final args = settings.arguments as OfferSelectionScreenArgs;
              return MaterialPageRoute(
                builder: (context) {
                  return OfferSelectionScreen(
                    offerApplyBloc: args.offerApplyBloc,
                  );
                },
              );
            }
            if (settings.name == StoreGalleryViewScreen.route) {
              final args = settings.arguments as StoreGalleryViewArguments;
              return MaterialPageRoute(
                builder: (context) {
                  return StoreGalleryViewScreen(
                    images: args.images,
                  );
                },
              );
            }
            if (settings.name == ServicesListScreen.routeName) {
              return MaterialPageRoute(builder: (_) {
                return ServicesListScreen();
              });
            }
            // if (settings.name == MultiDaySlotSelectScreen.route) {
            //   final args = settings.arguments as MultiDaySlotSelectScreenArgs;
            //   return MaterialPageRoute(
            //     builder: (context) {
            //       return MultiDaySlotSelectScreen(
            //           cartTotal: args.cartTotal, cartId: args.cartId);
            //     },
            //   );
            // }
            assert(false, 'Need to implement ${settings.name}');
          },
        ),
      ),
    );
  }
}

// TODO : Implement Vehicle type ui with bloc
// TODO : Implement search services bloc with ui  and apis
// TODO : Implement search stores bloc with ui  and apis
// TODO :
// TODO : remove ! force check
// TODO : create home screen blocs, integrate them with ui
class MainScreen extends StatefulWidget {
  final GlobalAuthBloc globalAuthBloc;
  final CartFunctionBloc cartFunctionBloc;
  final PendingDynamicLinkData? initialLink;
  const MainScreen(
      {Key? key,
      required this.cartFunctionBloc,
      required this.globalAuthBloc,
      required this.initialLink})
      : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
        BlocListener<GlobalAuthBloc, GlobalAuthState>(
      bloc: widget.globalAuthBloc,
      listener: (context, state) {
        // TODO: implement listener
        if (state is Authenticated) {
          // autoaveLog('GetCartCal')
          widget.cartFunctionBloc.add(GetCart());
        }
      },

      child: FutureBuilder<AuthTokensModel>(
          future: LocalDataService().getAuthTokens(),
          builder: (ctx, snapshot) {
            // SizeConfig().init(ctx);
            autoaveLog('MainScreen FutureBuilder ' +
                snapshot.connectionState.toString());
            // if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (snapshot.data != null && snapshot.data!.authenticated) {
                // return OfferSelectionScreen();
                // return BookingSummaryScreen(bookingId: '8D6D98');
                // return CancelOrderScreen();

                return ExploreScreen(
                  initialLink: widget.initialLink,
                );
              } else {
                // return OnboardingScreen();
                return LoginScreen(
                  initialLink: widget.initialLink,
                );
              }
            }
            // }
            autoaveLog('Returning Splash 2');
            // return Text('asd');
            return Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/splash_background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Builder(builder: (ctx) {
                    return Image.asset(
                      'assets/images/logo.png',
                      scale: 4,
                    );
                  }),
                ),
              ),
            );
          }),
      // ),
    );
  }
}
