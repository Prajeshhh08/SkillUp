import '../models/customer_address.dart';
import '../models/customer_profile.dart';
import 'api_client.dart';

class CustomerService {
  CustomerService({ApiClient? client}) : _client = client ?? ApiClient.instance;
  static CustomerService instance = CustomerService();

  final ApiClient _client;

  Future<CustomerProfile> getProfile() async {
    final response = await _client.get('/customers/me/profile');
    return CustomerProfile.fromJson(response);
  }

  Future<CustomerMetrics> getMetrics() async {
    final response = await _client.get('/customers/me/metrics');
    return CustomerMetrics.fromJson(response);
  }

  Future<void> updateProfile({String? fullName, String? email}) async {
    final payload = <String, dynamic>{};
    if (fullName != null) {
      payload['full_name'] = fullName;
    }
    if (email != null) {
      payload['email'] = email;
    }
    await _client.patch('/me', data: payload);
  }

  Future<List<CustomerAddress>> getAddresses() async {
    final response = await _client.getList('/addresses');
    return response
        .whereType<Map<String, dynamic>>()
        .map(CustomerAddress.fromJson)
        .toList();
  }

  Future<CustomerAddress> createAddress(AddressCreatePayload payload) async {
    final response = await _client.post('/addresses', data: payload.toJson());
    return CustomerAddress.fromJson(response);
  }

  Future<CustomerAddress> updateAddress(
    String addressId,
    AddressUpdatePayload payload,
  ) async {
    final response = await _client.patch(
      '/addresses/$addressId',
      data: payload.toJson(),
    );
    return CustomerAddress.fromJson(response);
  }

  Future<void> deleteAddress(String addressId) async {
    await _client.delete('/addresses/$addressId');
  }
}
