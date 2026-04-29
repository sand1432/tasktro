import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';
import 'connectivity_service.dart';

class ApiClient {
  ApiClient({
    required this.supabase,
    required this.connectivityService,
  });

  final SupabaseClient supabase;
  final ConnectivityService connectivityService;

  Future<Map<String, dynamic>> invokeFunction(
    String functionName, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    if (!await connectivityService.isConnected) {
      throw const NetworkException(
        'No internet connection',
        code: 'NO_INTERNET',
      );
    }

    try {
      final response = await supabase.functions.invoke(
        functionName,
        body: body,
        headers: headers,
      );

      if (response.status >= 400) {
        throw ServerException(
          'Server error: ${response.status}',
          code: response.status.toString(),
        );
      }

      final data = response.data;
      if (data is String) {
        return json.decode(data) as Map<String, dynamic>;
      }
      return data as Map<String, dynamic>;
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('ApiClient.invokeFunction error: $e');
      throw ServerException('Failed to invoke $functionName: $e');
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    if (!await connectivityService.isConnected) {
      throw const NetworkException(
        'No internet connection',
        code: 'NO_INTERNET',
      );
    }

    try {
      PostgrestFilterBuilder<PostgrestList> filterBuilder =
          supabase.from(table).select(select ?? '*');

      if (filters != null) {
        for (final entry in filters.entries) {
          filterBuilder = filterBuilder.eq(entry.key, entry.value);
        }
      }

      PostgrestTransformBuilder<PostgrestList> transformBuilder = filterBuilder;

      if (orderBy != null) {
        transformBuilder =
            transformBuilder.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        transformBuilder = transformBuilder.limit(limit);
      }

      if (offset != null) {
        transformBuilder =
            transformBuilder.range(offset, offset + (limit ?? 20) - 1);
      }

      final response = await transformBuilder;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Query failed on $table: $e');
    }
  }

  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response =
          await supabase.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Insert failed on $table: $e');
    }
  }

  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response =
          await supabase.from(table).update(data).eq('id', id).select().single();
      return response;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Update failed on $table: $e');
    }
  }

  Future<void> delete(String table, String id) async {
    try {
      await supabase.from(table).delete().eq('id', id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Delete failed on $table: $e');
    }
  }
}
