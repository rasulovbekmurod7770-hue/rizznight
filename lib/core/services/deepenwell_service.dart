import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepenWellService {
  static const String _baseUrl = 'https://deepwell.uz/api/v1';
  static const int _challengeEventId = 33;

  Future<Map<String, dynamic>?> getUserChallengeStats(
      String username) async {
    try {
      final searchName = username.toLowerCase().trim();
      int page = 1;
      const int perPage = 500;
      bool hasMore = true;

      while (hasMore) {
        final url =
            '$_baseUrl/public/events/$_challengeEventId/leaderboard/'
            '?page=$page&per_page=$perPage';

        final response = await http.get(
          Uri.parse(url),
          headers: {'Accept': 'application/json'},
        );

        if (response.statusCode != 200) {
          return {
            'found': false,
            'error': 'API error: ${response.statusCode}'
          };
        }

        final data = jsonDecode(response.body);

        if (data['success'] != true) {
          return {'found': false, 'error': 'API returned success=false'};
        }

        // IMPORTANT: results is a direct List, NOT results.top_leaderboard
        final leaderboard = data['results'] as List<dynamic>;

        if (leaderboard.isEmpty) {
          hasMore = false;
          break;
        }

        // Search: every typed word must appear in fio
        final searchWords = searchName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .toList();

        final entry = leaderboard.firstWhere(
          (item) {
            final fio =
                (item['user']['fio'] as String).toLowerCase();
            return searchWords.every((word) => fio.contains(word));
          },
          orElse: () => null,
        );

        if (entry != null) {
          final stats = entry['stats'];
          final user = entry['user'];
          final activityType = entry['activity_type'];

          // position is top-level on the entry, NOT inside stats
          // total_distance is in METERS — divide by 1000 for KM
          // total_duration is a string like "39:51:07"
          return {
            'found': true,
            'fio': user['fio'],
            'avatar': user['avatar'],
            'position': entry['position'],
            'activity_type': activityType['name'],
            'total_distance_km':
                (stats['total_distance'] as num) / 1000.0,
            'total_duration': stats['total_duration'],
            'total_points': stats['total_points'],
          };
        }

        // Last page reached
        if (leaderboard.length < perPage) {
          hasMore = false;
        } else {
          page++;
        }
      }

      return {'found': false, 'error': 'Name not found in challenge.'};
    } catch (e) {
      return {'found': false, 'error': 'Error: $e'};
    }
  }
}
