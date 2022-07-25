import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:themotorwash/blocs/global_auth/global_auth_bloc.dart';
import 'package:themotorwash/data/api/api_service.dart';
import 'package:themotorwash/data/api/auth_interceptor.dart';
import 'package:themotorwash/data/api/log_interceptor.dart';
import 'package:themotorwash/data/local/local_data_service.dart';
import 'package:themotorwash/data/models/sort_param.dart';
import 'package:themotorwash/data/repos/auth_repository.dart';
import 'package:themotorwash/data/repos/auth_rest_repository.dart';

class ApiConstants {
  late GlobalAuthBloc _globalAuthBloc;
  ApiConstants({
    required GlobalAuthBloc globalAuthBloc,
  }) {
    _globalAuthBloc = globalAuthBloc;
    if (kReleaseMode) {
      baseUrl = "api.autoave.in";
    } else {
      baseUrl = "testapi.autoave.in";
    }
  }

  Dio dioClient() {
    var state = _globalAuthBloc.state;
    Map<String, dynamic>? headers;
    if (state is Authenticated) {
      headers = {'Authorization': 'JWT ${state.tokens.accessToken}'};
    }
    BaseOptions options = new BaseOptions(
        // baseUrl: "<URL>",
        responseType: ResponseType.plain,
        headers: headers);
    Dio client = Dio(options);
    client.interceptors.add(Logging());
    client.interceptors.add(AuthInterceptor(
      globalAuthBloc: _globalAuthBloc,
    ));

    return client;
  }

  // final String baseUrl = "motorwash.herokuapp.com";
  // final String baseUrl = "api.autoave.in";

  late final String baseUrl;
  final int pageLimit = 10;

  String getStoreListEndPoint() {
    return "$baseUrl/store/list";
  }

  String getStoreListByLocationEndPoint(
      {required String city,
      required double lat,
      required double long,
      required int offset,
      String? tag,
      SortParam? sortParam}) {
    Map<String, dynamic> params = {
      'offset': offset.toString(),
      'limit': pageLimit.toString(),
      'latitude': lat.toString(),
      'longitude': long.toString(),
    };
    if (tag != null) {
      params.addAll({'tag': tag});
    }
    if (sortParam != null) {
      params.addAll({'sort': sortParam.toParam()});
    }
    var uri = Uri.https(baseUrl, "/store/list/$city", params);
    return uri.toString();
  }

  String getStoreBySlugEndPoint({required String slug}) {
    var uri = Uri.https(baseUrl, "/store/$slug");
    return uri.toString();
  }

  String getStoreReviewBySlugEndPoint(
      {required String slug, required int offset}) {
    Map<String, dynamic> params = {
      'offset': offset.toString(),
      'limit': pageLimit.toString()
    };
    var uri = Uri.https(baseUrl, "/store/$slug/reviews", params);

    return uri.toString();
  }

  String getStoreServicesBySlugVehicleTypeEndPoint(
      {required String slug,
      required String vehicleType,
      required int offset,
      String? firstServiceTag}) {
    Map<String, dynamic> params = {
      'offset': offset.toString(),
      'limit': pageLimit.toString(),
      'vehicle_type': vehicleType.toString()
    };
    if (firstServiceTag != null) {
      params.addAll({'first_service_tag': firstServiceTag});
    }
    var uri = Uri.https(baseUrl, "/store/$slug/services", params);
    return uri.toString();
  }

  String postReviewEndPoint() {
    var uri = Uri.https(baseUrl, "/review/");
    return uri.toString();
  }

  String getReviewEndPoint({required String bookingId}) {
    var uri = Uri.https(baseUrl, "/review/$bookingId");
    return uri.toString();
  }

  String getBookingListEndPoint({required int offset}) {
    Map<String, dynamic> params = {
      'offset': offset.toString(),
      'limit': pageLimit.toString()
    };
    var uri = Uri.https(baseUrl, "/booking/list/consumer", params);
    return uri.toString();
  }

  String getCartEndpoint() {
    var uri = Uri.https(baseUrl, "/cart/getcart/");
    return uri.toString();
  }

  String postAddItemToCartEndpoint() {
    var uri = Uri.https(
      baseUrl,
      "/cart/additem/",
    );
    return uri.toString();
  }

  String postDeleteItemFromCartEndpoint() {
    var uri = Uri.https(baseUrl, "/cart/removeitem/");
    return uri.toString();
  }

  String postCheckOTPEndpoint() {
    var uri = Uri.https(baseUrl, "/consumer/login/checkOTP/");
    return uri.toString();
  }

  String postSendOTPEndpoint() {
    var uri = Uri.https(baseUrl, "/consumer/login/sendOTP/");
    return uri.toString();
  }

  String getBookingDetailsEndpoint({required String bookingId}) {
    var uri = Uri.https(baseUrl, "/booking/$bookingId");
    return uri.toString();
  }

  String postGetSlotsByCartDateEndpoint() {
    var uri = Uri.https(baseUrl, "/slots/create/");
    return uri.toString();
  }

  String postInitiatePaytmPaymentEndpoint() {
    var uri = Uri.https(baseUrl, "/payment/initiate/");
    return uri.toString();
  }

  String postCheckPaytmPaymentStatusEndpoint() {
    var uri = Uri.https(baseUrl, "/payment/callback/");
    return uri.toString();
  }

  String getVehicleTypeListEndpoint() {
    var uri = Uri.https(baseUrl, "/vehicle_type/list/");
    return uri.toString();
  }

  String getServicesBySearchQueryEndPoint(
      {required String query, required int offset, int? pageLim}) {
    Map<String, dynamic> params = {
      'search': query,
      'offset': offset.toString(),
      'limit': pageLim != null ? pageLim.toString() : pageLimit.toString()
    };
    var uri = Uri.https(baseUrl, "/service/tag/list/", params);
    return uri.toString();
  }

  String getStoresBySearchQueryAndLocationEndPoint(
      {required String query,
      required String city,
      required double lat,
      required double long,
      required int offset}) {
    Map<String, dynamic> params = {
      'search': query,
      'offset': offset.toString(),
      'limit': pageLimit.toString(),
      'latitude': lat.toString(),
      'longitude': long.toString()
    };
    var uri = Uri.https(baseUrl, "/store/list/$city", params);
    return uri.toString();
  }

  String getPutPatchAccountEndPoint() {
    var uri = Uri.https(baseUrl, "/account");
    return uri.toString();
  }

  String addFcmTokenEndpoint() {
    var uri = Uri.https(baseUrl, "/account/add_fcm/");
    return uri.toString();
  }

  String subscribeFcmTopicsEndpoint() {
    var uri = Uri.https(baseUrl, "/account/topics/register");
    return uri.toString();
  }

  String getFcmTopicsEndpoint() {
    var uri = Uri.https(baseUrl, "/account/topics/list");
    return uri.toString();
  }

  String getLogoutEndpoint() {
    var uri = Uri.https(baseUrl, "/consumer/logout/app/");
    return uri.toString();
  }

  String getCityListEndpoint() {
    var uri = Uri.https(baseUrl, "/city/list");
    return uri.toString();
  }

  String getFeedbackEndpoint() {
    var uri = Uri.https(baseUrl, "/feedback/");
    return uri.toString();
  }

  String getVehicleWheelListEndpoint() {
    var uri = Uri.https(baseUrl, "/vehicle/wheel/list/");
    return uri.toString();
  }

  String getVehicleBrandListEndpoint({required String wheelCode}) {
    Map<String, dynamic> params = {'wheel': wheelCode.toString()};
    var uri = Uri.https(baseUrl, "/vehicle/brand/list/", params);
    return uri.toString();
  }

  String getVehicleModelListEndpoint({required String brand}) {
    Map<String, dynamic> params = {'brand': brand.toString()};
    var uri = Uri.https(baseUrl, "/vehicle/model/list/", params);
    return uri.toString();
  }

  String getPaymentChoicesEndpoint() {
    var uri = Uri.https(baseUrl, "/payment/choices/");
    return uri.toString();
  }

  String getCancelBookingDataEndpoint({required String bookingId}) {
    var uri = Uri.https(baseUrl, "/booking/cancel/data/$bookingId");
    return uri.toString();
  }

  String postCancelBookingEndpoint({required String bookingId}) {
    var uri = Uri.https(baseUrl, "/booking/cancel/$bookingId/");
    return uri.toString();
  }

  String getOfferListEndpoint() {
    var uri = Uri.https(baseUrl, "/offer/list/");
    return uri.toString();
  }

  String getOfferBannersEndpoint() {
    var uri = Uri.https(baseUrl, "/offer/banner/");
    return uri.toString();
  }

  String postOfferApplyEndpoint() {
    var uri = Uri.https(baseUrl, "/offer/apply/");
    return uri.toString();
  }

  String postOfferRemoveEndpoint() {
    var uri = Uri.https(baseUrl, "/offer/remove/");
    return uri.toString();
  }

  String postInitiateRazorpayPaymentEndpoint() {
    var uri = Uri.https(baseUrl, "/payment/razorpay/initiate/");
    return uri.toString();
  }

  String postCheckRazorpayPaymentStatusEndpoint() {
    var uri = Uri.https(baseUrl, "/payment/razorpay/callback/");
    return uri.toString();
  }

  String getFeaturedStoreListEndPoint({
    required String city,
  }) {
    var uri = Uri.https(baseUrl, "/store/list/$city/featured/");
    return uri.toString();
  }

  String postDirectBookSlotEndpoint() {
    var uri = Uri.https(baseUrl, "/payment/completeofferbooking/");
    return uri.toString();
  }
}
