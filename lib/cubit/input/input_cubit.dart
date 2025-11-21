import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/models/ln_invoice.dart';
import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:nostr_pay_kids/utils/exceptions.dart';

import 'input_state.dart';

final Logger _logger = Logger('InputCubit');

class InputCubit extends Cubit<InputState> {
  InputCubit() : super(const InputState.empty());

  LNInvoice decodeInvoice(String invoice) {
    _logger.info('Decoding invoice: $invoice');

    String description = '';
    int amountInSats = 0;

    try {
      final req = Bolt11PaymentRequest(invoice);
      for (TaggedField? tag in req.tags) {
        if (tag!.type == 'description') {
          description = tag.data as String;
        }
      }

      amountInSats = (req.amount.toDouble() * 100000000).round();

      return LNInvoice(
        bolt11: invoice,
        description: description,
        amountSat: amountInSats,
      );
    } catch (e) {
      _logger.severe('Error decoding invoice: $e');
      throw DecodeInvoiceException(errorMessage: e.toString());
    }
  }
}
