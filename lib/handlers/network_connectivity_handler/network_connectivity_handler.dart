import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/connectivity/connectivity_cubit.dart';
import 'package:nostr_pay_kids/handlers/handler/handler.dart';
import 'package:nostr_pay_kids/handlers/handler/handler_context_provider.dart';

final Logger _logger = Logger('NetworkConnectivityHandler');

class NetworkConnectivityHandler extends Handler {
  StreamSubscription<ConnectivityState>? _subscription;
  Flushbar<dynamic>? _flushbar;

  @override
  void init(HandlerContextProvider<StatefulWidget> contextProvider) {
    super.init(contextProvider);
    _subscription = contextProvider
        .getBuildContext()!
        .read<ConnectivityCubit>()
        .stream
        .distinct(
          (ConnectivityState previous, ConnectivityState next) =>
              previous.connectivityResult == next.connectivityResult,
        )
        .listen(_listen);
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _subscription = null;
    _flushbar = null;
  }

  void _listen(ConnectivityState connectivityState) async {
    _logger.info('Received connectivityState $connectivityState');
    if (!connectivityState.hasNetworkConnection) {
      showNoInternetConnectionFlushbar();
    } else {
      dismissFlushbarIfNeed();
    }
  }

  void showNoInternetConnectionFlushbar() {
    dismissFlushbarIfNeed();
    final BuildContext? context = contextProvider?.getBuildContext();
    if (context == null) {
      _logger.info('Skipping connection flushbar as context is null');
      return;
    }
    _flushbar = _getNoConnectionFlushbar(context);
    _flushbar?.show(context);
  }

  void dismissFlushbarIfNeed() async {
    final Flushbar<dynamic>? flushbar = _flushbar;
    if (flushbar == null) {
      return;
    }

    if (flushbar.flushbarRoute != null && flushbar.flushbarRoute!.isActive) {
      final BuildContext? context = contextProvider?.getBuildContext();
      if (context == null) {
        _logger.info(
          'Skipping dismissing connection flushbar as context is null',
        );
        return;
      }
      Navigator.of(context).removeRoute(flushbar.flushbarRoute!);
    }
    _flushbar = null;
  }

  Flushbar<dynamic>? _getNoConnectionFlushbar(BuildContext context) {
    return Flushbar<dynamic>(
      isDismissible: false,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: AppColors.error,
      boxShadows: [
        BoxShadow(
          color: AppColors.error.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ],
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.wifi_off, color: Colors.white, size: 20),
      ),
      messageText: Text(
        'No internet connection',
        style: GoogleFonts.nunito(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
