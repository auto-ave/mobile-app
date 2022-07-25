import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:themotorwash/blocs/order_review/order_review_bloc.dart';
import 'package:themotorwash/blocs/paytm_payment/paytm_payment_bloc.dart';
import 'package:themotorwash/blocs/slot_selection/bloc/slot_selection_bloc.dart';
import 'package:themotorwash/data/models/initiate_paytm_payment.dart';
import 'package:themotorwash/data/models/slot.dart';
import 'package:themotorwash/data/repos/payment_repository.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/booking_summary/booking_summary_screen.dart';
import 'package:themotorwash/ui/screens/order_review/order_review.dart';
import 'package:themotorwash/ui/screens/slot_select/components/date_selection_tab.dart';
import 'package:themotorwash/ui/screens/slot_select/components/pages/multi_day_slot_select_screen.dart';
import 'package:themotorwash/ui/screens/slot_select/components/pages/normal_slot_select_screen.dart';
import 'package:themotorwash/ui/screens/slot_select/components/slot_selection_tab.dart';
import 'package:themotorwash/ui/widgets/common_button.dart';
import 'package:themotorwash/ui/widgets/error_widget.dart';
import 'package:themotorwash/utils/utils.dart';

class SlotSelectScreen extends StatelessWidget {
  SlotSelectScreen(
      {Key? key,
      required this.cartTotal,
      required this.cartId,
      required this.isMultiDay})
      : super(key: key);
  final String cartTotal;
  final String cartId;
  final bool isMultiDay;
  static final String route = '/slotSelect';
  @override
  Widget build(BuildContext context) {
    return isMultiDay
        ? MultiDaySlotSelectScreen(
            cartId: cartId,
            cartTotal: cartTotal,
            isOldPaymentRoute: false,
          )
        : NormalSlotSelectScreen(
            cartId: cartId,
            cartTotal: cartTotal,
            isOldPaymentRoute: false,
          );
  }
}
