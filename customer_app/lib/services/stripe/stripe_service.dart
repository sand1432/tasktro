import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';

class StripeService {
  StripeService({required this.apiClient});

  final ApiClient apiClient;

  static Future<void> initialize() async {
    Stripe.publishableKey = AppConstants.stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  Future<Result<String>> createPaymentIntent({
    required double amount,
    required String currency,
    required String customerId,
    String? description,
    Map<String, String>? metadata,
  }) async {
    return ErrorHandler.guard(() async {
      final response = await apiClient.invokeFunction(
        'create-payment-intent',
        body: {
          'amount': (amount * 100).toInt(),
          'currency': currency,
          'customer_id': customerId,
          'description': description,
          'metadata': metadata,
        },
      );

      final clientSecret = response['client_secret'] as String?;
      if (clientSecret == null) {
        throw const PaymentException('Failed to create payment intent');
      }

      return clientSecret;
    });
  }

  Future<Result<bool>> confirmPayment(String clientSecret) async {
    return ErrorHandler.guard(() async {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: AppConstants.appName,
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    });
  }

  Future<Result<bool>> processRefund({
    required String paymentIntentId,
    double? amount,
    String? reason,
  }) async {
    return ErrorHandler.guard(() async {
      final response = await apiClient.invokeFunction(
        'process-refund',
        body: {
          'payment_intent_id': paymentIntentId,
          'amount': amount != null ? (amount * 100).toInt() : null,
          'reason': reason,
        },
      );

      return response['success'] as bool? ?? false;
    });
  }

  Future<Result<Map<String, dynamic>>> getPaymentMethods(
    String customerId,
  ) async {
    return ErrorHandler.guard(() async {
      final response = await apiClient.invokeFunction(
        'get-payment-methods',
        body: {'customer_id': customerId},
      );
      return response;
    });
  }
}
