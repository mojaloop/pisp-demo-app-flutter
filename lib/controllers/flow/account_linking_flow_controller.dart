import 'package:get/get.dart';
import 'package:pispapp/controllers/app/auth_controller.dart';
import 'package:pispapp/models/consent.dart';
import 'package:pispapp/models/party.dart';
import 'package:pispapp/models/user.dart';
import 'package:pispapp/repositories/interfaces/i_consent_repository.dart';
import 'package:pispapp/ui/pages/account-linking/account_selection_screen.dart';
import 'package:pispapp/ui/pages/account-linking/otp_auth.dart';
import 'package:pispapp/ui/pages/account-linking/web_auth.dart';
import 'package:pispapp/utils/log_printer.dart';

class AccountLinkingFlowController extends GetxController {

  AccountLinkingFlowController(this._consentRepository);

  static final logger =  getLogger('AccountLinkingFlowController');

  IConsentRepository _consentRepository;

  bool isAwaitingUpdate = false;

  Consent consent;
  String documentId;

  void Function() _unsubscriber;

  /// Adds a new consent object which notifies the
  /// PISP server to initiate discovery on the accounts
  /// linked to this [opaqueId]
  Future<void> initiateDiscovery(String opaqueId, String fspId) async {
    _setAwaitingUpdate(true);

    final User user = Get.find<AuthController>().user;

    // Construct a new consent
    final Consent newConsent = Consent(
      userId: user.id,
      party: Party(
        partyIdInfo: PartyIdInfo(
          partyIdType: PartyIdType.opaque,
          partyIdentifier: opaqueId,
          fspId: fspId,
        ),
      ),
    );

    documentId = await _consentRepository.add(newConsent.toJson());

    _startListening(documentId);
  }

  Future<void> initiateConsentRequest(List<Account> accsToLink) async {
    _setAwaitingUpdate(true);

    final Consent updatedConsent = Consent(
      authChannels: [AuthChannel.web, AuthChannel.otp],
      accounts: accsToLink
    );
    await _consentRepository.updateData(documentId, updatedConsent.toJson());
  }

  Future<void> sendAuthToken(String authToken) async {
    _setAwaitingUpdate(true);

    final Consent updatedConsent = Consent(authToken: authToken);
    await _consentRepository.updateData(documentId, updatedConsent.toJson());
  }

  void _startListening(String id) {
    _unsubscriber = _consentRepository.listen(id, onValue: _onValue);
  }

  void _stopListening() {
    _unsubscriber();
  }

  void _onValue(Consent consent) {
    // Put the document id in the model object
    consent.id = documentId;

    final oldValue = this.consent;
    // Update consent with latest change
    this.consent = consent;

    // TODO(kkzeng): Figure out what needs to be done in each state and explore state machine library use
    switch (consent.status) {
      case ConsentStatus.pendingPartyLookup:
        break;
      case ConsentStatus.pendingPartyConfirmation:
        if (oldValue.status == ConsentStatus.pendingPartyLookup) {
          // The consent data has been updated
          _setAwaitingUpdate(false);

          // Redirect to the next stage in account linking flow
          // Display list of associated accounts
          Get.to<dynamic>(AccountSelectionScreen(this));
        }
        break;
      case ConsentStatus.authenticationRequired:
        if (oldValue.status == ConsentStatus.pendingPartyConfirmation) {
          // The consent data has been updated
          _setAwaitingUpdate(false);

          switch(consent.authChannels[0]) {
            case AuthChannel.otp:
              Get.to<dynamic>(OTPAuth(this));
              break;
            case AuthChannel.web:
              Get.to<dynamic>(WebAuth(this));
              break;
            default:
              // not supported
          }
        }
        break;
      case ConsentStatus.consentGranted:
        break;
      case ConsentStatus.challengeGenerated:
        break;
      case ConsentStatus.active:
        _stopListening();
        break;
      case ConsentStatus.revoked:
        _stopListening();
        break;
      default:
        // we are not interested in other statuses
        logger.w('The consent had an unexpected status: ${consent.status}');
        break;
    }
  }

  void _setAwaitingUpdate(bool isAwaitingUpdate) {
    // This is intended to inform the UI that the user is not expected to
    // make any action and just need to wait. For example, a circular progress
    // indicator could be displayed.
    this.isAwaitingUpdate = isAwaitingUpdate;
    update();
  }
}
