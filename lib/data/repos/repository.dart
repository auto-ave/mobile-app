import 'package:themotorwash/data/models/direct_booking_response.dart';
import 'package:themotorwash/data/models/multi_day_slot_detail.dart';
import 'package:themotorwash/data/models/booking_detail.dart';
import 'package:themotorwash/data/models/booking_list_model.dart';
import 'package:themotorwash/data/models/cancel_booking_data.dart';
import 'package:themotorwash/data/models/cart.dart';
import 'package:themotorwash/data/models/city.dart';
import 'package:themotorwash/data/models/initiate_paytm_payment.dart';
import 'package:themotorwash/data/models/location_model.dart';
import 'package:themotorwash/data/models/offer.dart';
import 'package:themotorwash/data/models/payment_choice.dart';
import 'package:themotorwash/data/models/price_time_list_model.dart';
import 'package:themotorwash/data/models/review.dart';
import 'package:themotorwash/data/models/service.dart';
import 'package:themotorwash/data/models/slot.dart';
import 'package:themotorwash/data/models/sort_param.dart';
import 'package:themotorwash/data/models/store.dart';
import 'package:themotorwash/data/models/store_list_model.dart';
import 'package:themotorwash/data/models/user_profile.dart';
import 'package:themotorwash/data/models/vehicle_brand.dart';
import 'package:themotorwash/data/models/vehicle_model.dart';
import 'package:themotorwash/data/models/vehicle_wheel.dart';

abstract class Repository {
  Future<List<StoreListModel>> getStoreListByLocation(
      {required LocationModel locationModel,
      required int offset,
      String? tag,
      SortParam? sortParam});
  Future<Store> getStoreDetailBySlug({required String slug});
  Future<List<Review>> getStoreReviewsBySlug(
      {required String slug, required int offset});
  Future<List<PriceTimeListModel>> getStoreServicesBySlugAndVehicleType(
      {required String slug,
      required String vehicleType,
      required int offset,
      String? firstServiceTag});

  Future<CartModel> postAddItemToCart(
      {required int itemId, required String vehicleModel});

  Future<CartModel> postDeleteItemFromCart({required int itemId});

  Future<CartModel> getCart();

  Future<List<BookingListModel>> getYourBookings({required int offset});
  Future<BookingDetailModel> getBookingDetail({required String bookingId});
  Future<List<Slot>> createSlots(
      {required String date, required String cartId});

  Future<List<VehicleModel>> getVehicleTypeList();

  Future<List<StoreListModel>> searchStores(
      {required String query,
      required LocationModel locationModel,
      required int offset});

  Future<List<ServiceModel>> searchServices(
      {required String query, required int offset, int? pageLimit});

  Future<Review> getReview({required String bookingId});
  Future<Review> addReview({required ReviewEntity review});

  Future<UserProfile> getAccountDetails();
  Future<UserProfile> updateAccountDetails(
      {required UserProfileEntity userProfileEntity});

  Future<List<City>> getListOfCities();
  Future<void> sendFeedback(
      {required String email,
      required String phoneNumber,
      required String message});

  Future<List<VehicleWheel>> getVehicleWheelList();
  Future<List<VehicleBrand>> getVehicleBrandlList({required String wheelCode});
  Future<List<VehicleModel>> getVehicleModelList({required String brand});
  Future<List<PaymentChoice>> getPaymentChoices();
  Future<CancelBookingData> getCancelBookingData({required String bookingId});
  Future<void> cancelBooking(
      {required String bookingId, required String reason});
  Future<List<OfferModel>> getOfferList();
  Future<List<OfferModel>> getOfferBanners();
  Future<CartModel> applyOffer(String code);
  Future<CartModel> removeOffer();
  Future<MultiDaySlotDetailModel> getMultiDaySlotDetail(
      {required String date, required String cartId});
  Future<List<StoreListModel>> getFeaturedStores({
    required LocationModel locationModel,
  });
  Future<DirectBookingResponse> directBookSlot(
      {required String date,
      required int? bay,
      required String? slotStart,
      required String? slotEnd});
}
