import 'package:flutter/foundation.dart';

import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../src/model/api_code_option.dart';

class CodesRepository {
  CodesRepository(this._apiService);

  final ApiService _apiService;

  static final Map<int, List<ApiCodeOption>> _cache =
  <int, List<ApiCodeOption>>{};

  Future<List<ApiCodeOption>> getCodes({
    required int majorCode,
    bool forceRefresh = false,
  }) async {
    if (majorCode <= 0) return const <ApiCodeOption>[];

    if (!forceRefresh && _cache.containsKey(majorCode)) {
      return _cache[majorCode]!;
    }

    // Backend confirmed: POST with JSON body {'major_code': <int>}
    // Response shape: {"status":"success","data":[{MAJOR_CODE, MINOR_CODE, EN_NAME, AR_NAME}, ...]}
    final attempts = <Future<dynamic> Function()>[
          () => _apiService.post(
        ApiConstants.getCodes,
        body: {'major_code': majorCode},
        isReadOperation: true,
      ),
          () => _apiService.post(
        ApiConstants.getCodes,
        body: {'MAJOR_CODE': majorCode},
        isReadOperation: true,
      ),
      // GET fallbacks in case the handler accepts both methods
          () => _apiService.get(
        ApiConstants.getCodes,
        queryParams: {'major_code': '$majorCode'},
        isReadOperation: true,
      ),
          () => _apiService.get(
        ApiConstants.getCodes,
        queryParams: {'MAJOR_CODE': '$majorCode'},
        isReadOperation: true,
      ),
    ];

    Object? lastError;

    for (final attempt in attempts) {
      try {
        final response = await attempt();
        final options  = _extractOptions(response);

        if (kDebugMode) {
          debugPrint(
            '[CodesRepository] majorCode=$majorCode '
                '→ ${options.length} options: '
                '${options.map((o) => '${o.minorCode}:${o.label}').toList()}',
          );
        }

        _cache[majorCode] = options;
        return options;
      } catch (error) {
        lastError = error;
        if (kDebugMode) {
          debugPrint('[CodesRepository] attempt failed: $error');
        }
      }
    }

    if (lastError != null) throw lastError;
    return const <ApiCodeOption>[];
  }

  // ── Parsing ───────────────────────────────────────────────────────────────

  List<ApiCodeOption> _extractOptions(dynamic response) {
    final rows       = _extractRows(response);
    final seenMinors = <int>{};

    return rows
        .map(ApiCodeOption.fromJson)
        .where((o) => o.isRenderable)               // filters out minorCode==0 header
        .where((o) => seenMinors.add(o.minorCode))  // deduplicate
        .toList()
      ..sort((a, b) => a.minorCode.compareTo(b.minorCode));
  }

  List<Map<String, dynamic>> _extractRows(dynamic response) {
    if (response == null) return const [];

    // Bare list — e.g. [{MAJOR_CODE:1, MINOR_CODE:1, EN_NAME:'Pending'}, ...]
    if (response is List) {
      return response
          .whereType<Map>()
          .map((i) => Map<String, dynamic>.from(i))
          .toList();
    }

    if (response is Map<String, dynamic>) {
      // FIX: extract 'data' directly instead of routing through
      // ApexResponseHelper.unwrapResponse which was throwing on valid responses.
      // The confirmed response shape is {"status":"success","data":[...]}.
      for (final key in const [
        'data',   'DATA',
        'codes',  'CODES',
        'items',  'ITEMS',
        'result', 'RESULT',
        'rows',   'ROWS',
      ]) {
        final candidate = response[key];
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((i) => Map<String, dynamic>.from(i))
              .toList();
        }
      }
    }

    return const [];
  }
}