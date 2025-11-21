class DecodeInvoiceException implements Exception {
  final String errorMessage;

  DecodeInvoiceException({this.errorMessage = 'Failed to decode invoice'});

  @override
  String toString() => 'DecodeInvoiceException: $errorMessage';
}
