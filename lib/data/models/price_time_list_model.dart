import 'package:json_annotation/json_annotation.dart';

import 'package:themotorwash/data/models/service.dart';

part 'price_time_list_model.g.dart';

class PriceTimeListModel {
  final int? id;

  final service;
  final List<ServiceModel>? tags;
  final DateTime? createdAt;

  final DateTime? updatedAt;

  final int? price;

  final String? timeInterval;

  final String? description;

  final int? store;

  final String? vehicleType;

  final List<int>? bays;

  final int? mrp;
  final PriceTimeOfferDetail? offer;

  PriceTimeListModel(
      {this.id,
      this.service,
      this.createdAt,
      this.updatedAt,
      this.price,
      this.timeInterval,
      this.description,
      this.store,
      this.vehicleType,
      this.bays,
      this.mrp,
      this.offer,
      this.tags});

  factory PriceTimeListModel.fromEntity(PriceTimeListEntity entity) {
    return PriceTimeListModel(
      bays: entity.bays,
      id: entity.id,
      price: entity.price,
      store: entity.store,
      service: entity.service,
      vehicleType: entity.vehicleType,
      timeInterval: entity.timeInterval,
      description: entity.description,
      createdAt:
          entity.createdAt != null ? DateTime.parse(entity.createdAt!) : null,
      updatedAt:
          entity.updatedAt != null ? DateTime.parse(entity.updatedAt!) : null,
      mrp: entity.mrp,
      offer: entity.offer,
      tags: entity.tags != null
          ? entity.tags!.map((e) => ServiceModel.fromEntity(e)).toList()
          : null,
    );
  }

  @override
  String toString() {
    return 'PriceTimeListModel(id: $id, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt, price: $price, timeInterval: $timeInterval, description: $description, store: $store, vehicleType: $vehicleType, bays: $bays, mrp: $mrp, offer: $offer)';
  }
}

@JsonSerializable(explicitToJson: true)
class PriceTimeListEntity {
  final int? id;

  final service; //TODO : typee

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  final int? price;
  final int? mrp;

  final PriceTimeOfferDetail? offer;
  @JsonKey(name: 'time_interval')
  final String? timeInterval;

  final String? description;

  final int? store;

  @JsonKey(name: 'vehicle_type')
  final String? vehicleType;

  final List<int>? bays;
  final List<ServiceEntity>? tags;

  PriceTimeListEntity(
      {this.id,
      this.service,
      this.createdAt,
      this.updatedAt,
      this.price,
      this.timeInterval,
      this.description,
      this.store,
      this.vehicleType,
      this.bays,
      this.mrp,
      this.offer,
      this.tags});

  factory PriceTimeListEntity.fromJson(Map<String, dynamic> data) =>
      _$PriceTimeListEntityFromJson(data);

  Map<String, dynamic> toJson() => _$PriceTimeListEntityToJson(this);
}

@JsonSerializable()
class PriceTimeOfferDetail {
  @JsonKey(name: 'text')
  final String? offerText;
  @JsonKey(name: 'code')
  final String? offerCode;
  PriceTimeOfferDetail({required this.offerText, required this.offerCode});
  factory PriceTimeOfferDetail.fromJson(Map<String, dynamic> data) =>
      _$PriceTimeOfferDetailFromJson(data);

  Map<String, dynamic> toJson() => _$PriceTimeOfferDetailToJson(this);

  @override
  String toString() =>
      'PriceTimeOfferDetail(offerText: $offerText, offerCode: $offerCode)';
}
