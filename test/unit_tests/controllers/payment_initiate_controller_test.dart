import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pispapp/controllers/app/auth_controller.dart';
import 'package:pispapp/repositories/firebase/transaction_repository.dart';

class MockAuthController extends Mock implements AuthController {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  // AuthController authController;
  // PaymentInitiationController paymentInitiateController;

  setUp(
    () {
      // paymentInitiateController =
      //     PaymentInitiationController(MockTransactionRepository());
      // authController = MockAuthController();
      // Get.put(authController);
    },
  );

  test(
    'onPhoneNumberChange() on valid input',
    () {
      // valid input
      // const String phoneNumber = '9999999999';
      // const String isoCode = 'IN';
      // expect(paymentInitiateController.phoneNumber, phoneNumber);
      // expect(paymentInitiateController.phoneIsoCode, isoCode);
      // expect(paymentInitiateController.validPhoneNumber, true);
      // expect(paymentInitiateController.phoneNumberPrompt, false);
    },
  );

  test(
    'onPhoneNumberChange() on invalid input',
    () {
      // invalid input
      // const String phoneNumber = '1234';
      // const String isoCode = 'IN';
      // expect(paymentInitiateController.phoneNumber, phoneNumber);
      // expect(paymentInitiateController.phoneIsoCode, isoCode);
      // expect(paymentInitiateController.validPhoneNumber, false);
      // expect(paymentInitiateController.phoneNumberPrompt, false);
    },
  );
  test(
    'onPayNow() with invalid phone number',
    () async {
      // paymentInitiateController.validPhoneNumber = false;
      // await paymentInitiateController.onPayNow();
      // expect(paymentInitiateController.phoneNumberPrompt, true);
    },
  );
}
