import 'package:pispapp/models/consent.dart';

/// Abstraction for methods related to read/write consent
/// information from external data sources.

typedef ConsentHandler = void Function(Consent);

abstract class IConsentRepository {
  /// Returns the list of all [Consent] that are associated with
  /// a particular user.
  /// The param [preferCached] dictates whether or not the repository uses
  /// its cached consents. Note that if there is no cache, then regardless of
  /// what [preferCached] is set to, a fresh set of results will be retrieved.
  Future<List<Consent>> getConsents(String userId, {bool preferCached = false});

  /// Returns the list of active [Consent] that are associated with
  /// a particular user. i.e. not including revoked consents
  /// The param [preferCached] dictates whether or not the repository uses
  /// its cached consents. Note that if there is no cache, then regardless of
  /// what [preferCached] is set to, a fresh set of results will be retrieved.
  Future<List<Consent>> getActiveConsents(String userId,
      {bool preferCached = false});

  /// Adds a new consent document to the database.
  Future<String> add(Map<String, dynamic> data);

  /// Updates the value of the given fields in a particular consent document.
  Future<void> updateData(String id, Map<String, dynamic> data);

  /// Listens on the values for a consent document. Whenever a consent
  /// document is updated on the server-side, the [onValue] function (if provided)
  /// will be called with the updated consent object being
  /// passed as a parameter.
  void Function() listen(String id, {ConsentHandler onValue});

  /// Sets the value of the given fields in a particular consent document.
  /// The main difference between [setData] and [updateData] is the flexibility for
  /// set operation to merge the structure. It means that nested fields that are
  /// not specified in the updated [data] will not be removed from the document.
  Future<void> setData(String id, Map<String, dynamic> data,
      {bool merge = false});
}
