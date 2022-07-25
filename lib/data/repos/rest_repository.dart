import 'package:themotorwash/data/api/api_methods.dart';
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
import 'package:themotorwash/data/models/service.dart';
import 'package:themotorwash/data/models/slot.dart';
import 'package:themotorwash/data/models/sort_param.dart';
import 'package:themotorwash/data/models/store_list_model.dart';
import 'package:themotorwash/data/models/store.dart';
import 'package:themotorwash/data/models/review.dart';
import 'package:themotorwash/data/models/user_profile.dart';
import 'package:themotorwash/data/models/vehicle_brand.dart';
import 'package:themotorwash/data/models/vehicle_model.dart';
import 'package:themotorwash/data/models/vehicle_wheel.dart';
import 'package:themotorwash/data/repos/repository.dart';

class RestRepository implements Repository {
  ApiMethods _apiMethodsImp;
  RestRepository({required ApiMethods apiMethodsImp})
      : _apiMethodsImp = apiMethodsImp;
  @override
  Future<Store> getStoreDetailBySlug({required String slug}) async {
    StoreEntity entity = await _apiMethodsImp.getStoreDetailBySlug(slug: slug);
    return Store.fromEntity(entity);
  }

  @override
  Future<List<StoreListModel>> getStoreListByLocation(
      {required LocationModel locationModel,
      required int offset,
      String? tag,
      SortParam? sortParam}) async {
    print('tag' + tag.toString() + "yoyo");
    List<StoreListEntity> entities =
        await _apiMethodsImp.getStoreListByLocation(
            city: locationModel.cityCode,
            lat: locationModel.lat,
            long: locationModel.long,
            offset: offset,
            tag: tag,
            sortParam: sortParam);
    List<StoreListModel> stores =
        entities.map((e) => StoreListModel.fromEntity(e)).toList();
    return stores;
  }

  @override
  Future<List<Review>> getStoreReviewsBySlug(
      {required String slug, required int offset}) async {
    List<ReviewEntity> entities =
        await _apiMethodsImp.getStoreReviewsBySlug(slug: slug, offset: offset);
    List<Review> reviews = entities.map((e) => Review.fromEntity(e)).toList();
    return reviews;
  }

  @override
  Future<List<PriceTimeListModel>> getStoreServicesBySlugAndVehicleType(
      {required String slug,
      required String vehicleType,
      required int offset,
      String? firstServiceTag}) async {
    List<PriceTimeListEntity> entities =
        await _apiMethodsImp.getStoreServicesBySlugAndVehicleType(
            slug: slug,
            vehicleType: vehicleType,
            offset: offset,
            firstServiceTag: firstServiceTag);
    List<PriceTimeListModel> services =
        entities.map((e) => PriceTimeListModel.fromEntity(e)).toList();
    return services;
  }

  @override
  Future<CartModel> getCart() async {
    CartEntity entity = await _apiMethodsImp.getCart();
    return CartModel.fromEntity(entity);
  }

  @override
  Future<CartModel> postAddItemToCart(
      {required int itemId, required String vehicleModel}) async {
    CartEntity entity = await _apiMethodsImp.postAddItemToCart(
        itemId: itemId, vehicleModel: vehicleModel);
    return CartModel.fromEntity(entity);
  }

  @override
  Future<CartModel> postDeleteItemFromCart({required int itemId}) async {
    CartEntity entity =
        await _apiMethodsImp.postDeleteItemFromCart(itemId: itemId);
    return CartModel.fromEntity(entity);
  }

  @override
  Future<List<BookingListModel>> getYourBookings({required int offset}) async {
    List<BookingListEntity> entity =
        await _apiMethodsImp.getYourBookings(offset: offset);
    print(entity.toString() + "entity");
    List<BookingListModel> bookings =
        entity.map((e) => BookingListModel.fromEntity(e)).toList();
    return bookings;
  }

  @override
  Future<BookingDetailModel> getBookingDetail(
      {required String bookingId}) async {
    BookingDetailEntity e =
        await _apiMethodsImp.getBookingDetail(bookingId: bookingId);

    return BookingDetailModel.fromEntity(e);
  }

  @override
  Future<List<Slot>> createSlots(
      {required String date, required String cartId}) async {
    List<SlotEntity> entities =
        await _apiMethodsImp.createSlots(date: date, cartId: cartId);
    List<Slot> slots = entities.map<Slot>((e) => Slot.fromEntity(e)).toList();
    return slots;
  }

  @override
  Future<List<VehicleModel>> getVehicleTypeList() async {
    List<VehicleModelEntity> entities =
        await _apiMethodsImp.getVehicleTypeList();
    List<VehicleModel> vehicleTypes =
        entities.map<VehicleModel>((e) => VehicleModel.fromEntity(e)).toList();

    return vehicleTypes;
  }

  @override
  Future<List<StoreListModel>> searchStores(
      {required String query,
      required LocationModel locationModel,
      required int offset}) async {
    List<StoreListEntity> entities = await _apiMethodsImp.searchStores(
        query: query,
        city: locationModel.cityCode,
        lat: locationModel.lat,
        long: locationModel.long,
        offset: offset);
    List<StoreListModel> stores =
        entities.map((e) => StoreListModel.fromEntity(e)).toList();
    return stores;
  }

  @override
  Future<List<ServiceModel>> searchServices(
      {required String query, required int offset, int? pageLimit}) async {
    List<ServiceEntity> entities = await _apiMethodsImp.searchServices(
        query: query, offset: offset, pageLimit: pageLimit);
    List<ServiceModel> services =
        entities.map<ServiceModel>((e) => ServiceModel.fromEntity(e)).toList();
    return services;
  }

  @override
  Future<Review> addReview({required ReviewEntity review}) async {
    ReviewEntity entity = await _apiMethodsImp.addReview(review: review);
    Review reviewModel = Review.fromEntity(entity);
    return reviewModel;
  }

  @override
  Future<Review> getReview({required String bookingId}) async {
    ReviewEntity entity = await _apiMethodsImp.getReview(bookingId: bookingId);
    Review reviewModel = Review.fromEntity(entity);
    return reviewModel;
  }

  @override
  Future<UserProfile> getAccountDetails() async {
    UserProfileEntity entity = await _apiMethodsImp.getAccountDetails();
    UserProfile profileModel = UserProfile.fromEntity(entity: entity);
    return profileModel;
  }

  @override
  Future<UserProfile> updateAccountDetails(
      {required UserProfileEntity userProfileEntity}) async {
    UserProfileEntity entity = await _apiMethodsImp.patchAccountDetails(
        userProfileEntity: userProfileEntity);
    UserProfile profileModel = UserProfile.fromEntity(entity: entity);
    return profileModel;
  }

  @override
  Future<List<City>> getListOfCities() async {
    List<CityEntity> entities = await _apiMethodsImp.getListOfCities();
    List<City> citites = entities.map((e) => City.fromEntity(e)).toList();
    return citites;
  }

  @override
  Future<void> sendFeedback(
      {required String email,
      required String phoneNumber,
      required String message}) async {
    await _apiMethodsImp.sendFeedback(
        email: email, phoneNumber: phoneNumber, message: message);
  }

  @override
  Future<List<VehicleBrand>> getVehicleBrandlList(
      {required String wheelCode}) async {
    List<VehicleBrandEntity> entities =
        await _apiMethodsImp.getVehicleBrandlList(wheelCode: wheelCode);

    return entities
        .map<VehicleBrand>((e) => VehicleBrand.fromEntity(e))
        .toList();
  }

  @override
  Future<List<VehicleModel>> getVehicleModelList(
      {required String brand}) async {
    List<VehicleModelEntity> entities =
        await _apiMethodsImp.getVehicleModelList(brand: brand);

    return entities
        .map<VehicleModel>((e) => VehicleModel.fromEntity(e))
        .toList();
  }

  @override
  Future<List<VehicleWheel>> getVehicleWheelList() async {
    List<VehicleWheelEntity> entities =
        await _apiMethodsImp.getVehicleWheelList();

    return entities
        .map<VehicleWheel>((e) => VehicleWheel.fromEntity(e))
        .toList();
  }

  @override
  Future<List<PaymentChoice>> getPaymentChoices() async {
    List<PaymentChoiceEntity> paymentChoices =
        await _apiMethodsImp.getPaymentChoices();

    return paymentChoices
        .map<PaymentChoice>((e) => PaymentChoice.fromEntity(e))
        .toList();
  }

  @override
  Future<void> cancelBooking(
      {required String bookingId, required String reason}) async {
    await _apiMethodsImp.cancelBooking(bookingId: bookingId, reason: reason);
  }

  @override
  Future<CancelBookingData> getCancelBookingData(
      {required String bookingId}) async {
    CancelBookingDataEntity entity =
        await _apiMethodsImp.getCancelBookingData(bookingId: bookingId);
    return CancelBookingData.fromEntity(entity);
  }

  @override
  Future<List<OfferModel>> getOfferList() async {
    List<OfferEntity> offers = await _apiMethodsImp.getOfferList();

    return offers.map<OfferModel>((e) => OfferModel.fromEntity(e)).toList();
  }

  @override
  Future<List<OfferModel>> getOfferBanners() async {
    List<OfferEntity> offers = await _apiMethodsImp.getOfferBanners();

    return offers.map<OfferModel>((e) => OfferModel.fromEntity(e)).toList();
  }

  @override
  Future<CartModel> applyOffer(String code) async {
    CartEntity cart = await _apiMethodsImp.applyOffer(code);
    return CartModel.fromEntity(cart);
  }

  @override
  Future<CartModel> removeOffer() async {
    CartEntity cart = await _apiMethodsImp.removeOffer();
    return CartModel.fromEntity(cart);
  }

  @override
  Future<MultiDaySlotDetailModel> getMultiDaySlotDetail(
      {required String date, required String cartId}) async {
    MultiDaySlotDetailEntity entity =
        await _apiMethodsImp.getMultiDaySlotDetail(date: date, cartId: cartId);
    return MultiDaySlotDetailModel.fromEntity(entity);
  }

  @override
  Future<List<StoreListModel>> getFeaturedStores(
      {required LocationModel locationModel}) async {
    List<StoreListEntity> stores =
        await _apiMethodsImp.getFeaturedStores(city: locationModel.cityCode);

    final List<StoreListModel> storeList =
        stores.map((e) => StoreListModel.fromEntity(e)).toList();
    return storeList;
  }

  @override
  Future<DirectBookingResponse> directBookSlot(
      {required String date,
      required int? bay,
      required String? slotStart,
      required String? slotEnd}) async {
    DirectBookingResponseEntity directBookingResponse =
        await _apiMethodsImp.directBookSlot(
            date: date, bay: bay, slotStart: slotStart, slotEnd: slotEnd);
    return DirectBookingResponse.fromEntity(directBookingResponse);
  }
}
