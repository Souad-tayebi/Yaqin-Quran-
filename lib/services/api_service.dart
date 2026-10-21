import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track_model.dart';
import '../models/category_model.dart';

class ApiService {
  static const _baseUrl = 'https://api.alquran.cloud/v1';

  static final Map<String, Set<int>> _memCache = {};

  static const _prefKeyReciters   = 'cached_reciters_v2';
  static const _prefKeySurahsBase = 'cached_surahs_v2_'; 
  static const _prefKeySurahList  = 'cached_surah_list_v1';

  static const List<Map<String, String>> defaultReciters = [
    {'id': 'ar.alafasy',        'name': 'Mishary Alafasy'},
    {'id': 'ar.ahmedajamy',      'name': 'Ahmed Al-Ajamy'},
    {'id': 'ar.abdullahbasfar',  'name': 'Abdullah Basfar'},
    {'id': 'ar.minshawi',        'name': 'Al-Minshawi'},
    {'id': 'ar.hudhaify',        'name': 'Al-Hudhaify'},
    {'id': 'ar.mahermuaiqly',    'name': 'Maher Al-Muaiqly'},
    {'id': 'ar.saoodshuraym',    'name': 'Saud Al-Shuraim'},
    {'id': 'ar.shaatree',        'name': 'Abu Bakr Al-Shatri'},
  ];

  static Future<List<CategoryModel>> fetchCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<dynamic> surahsData;

      final rawSurahs = prefs.getString(_prefKeySurahList);
      if (rawSurahs != null) {
        surahsData = jsonDecode(rawSurahs);
      } else {
        final res = await http
            .get(Uri.parse('$_baseUrl/surah'))
            .timeout(const Duration(seconds: 10));
        
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body) as Map<String, dynamic>;
          surahsData = body['data'] as List<dynamic>;

          await prefs.setString(_prefKeySurahList, jsonEncode(surahsData));
        } else {
          return _fallback();
        }
      }

      List<Map<String, String>> recitersList = [];
      final rawReciters = prefs.getString(_prefKeyReciters);
      if (rawReciters != null) {
        final List parsedList = jsonDecode(rawReciters);
        recitersList = parsedList.map((e) => {
          'id': e['identifier'] as String? ?? e['id'] as String? ?? '',
          'name': e['englishName'] as String? ?? e['name'] as String? ?? 'Récitant',
        }).toList();
      } else {
        try {
          final res = await http
              .get(Uri.parse('$_baseUrl/edition?format=audio&language=ar'))
              .timeout(const Duration(seconds: 8));
          if (res.statusCode == 200) {
            final List data = jsonDecode(res.body)['data'];
            final filtered = data
                .where((r) => (r['identifier'] as String).startsWith('ar.'))
                .map((r) => {
                  'id': r['identifier'] as String,
                  'name': (r['englishName'] ?? r['name'] ?? 'Récitant') as String,
                }).toList();
            
            if (filtered.isNotEmpty) {
              recitersList = filtered;
              await prefs.setString(_prefKeyReciters, jsonEncode(filtered));
            }
          }
        } catch (_) {}
      }

      if (recitersList.isEmpty) {
        recitersList = defaultReciters;
      }

      return surahsData.map((s) {
        final number = s['number'] as int;
        final englishName = s['englishName'] as String;
        final arabicName = s['name'] as String;
        final meaning = (s['englishNameTranslation'] ?? '') as String;

        final tracks = recitersList.map((r) {
          final reciterId = r['id']!;
          return TrackModel(
            id: 'surah_${number}_$reciterId',
            title: r['name']!,
            categoryId: number.toString(),
            categoryName: englishName,
            audioUrl: 'https://cdn.islamic.network/quran/audio-surah/128/$reciterId/$number.mp3',
          );
        }).toList();

        return CategoryModel(
          id: number.toString(),
          name: meaning.isNotEmpty ? '$englishName – $meaning' : englishName,
          arabicName: arabicName,
          tracks: tracks,
        );
      }).toList();
    } catch (e) {
      return _fallback();
    }
  }

  static List<CategoryModel> _fallback() {
    final surahs = [
      {'n': 1,   'e': 'Al-Fatiha',    'm': 'The Opening',       'a': 'الفاتحة'},
      {'n': 2,   'e': 'Al-Baqarah',   'm': 'The Cow',           'a': 'البقرة'},
      {'n': 3,   'e': 'Ali Imran',    'm': 'Family of Imran',   'a': 'آل عمران'},
      {'n': 18,  'e': 'Al-Kahf',      'm': 'The Cave',          'a': 'الكهف'},
      {'n': 36,  'e': 'Ya-Sin',       'm': 'Ya Sin',            'a': 'يس'},
      {'n': 55,  'e': 'Ar-Rahman',    'm': 'The Beneficent',    'a': 'الرحمن'},
      {'n': 67,  'e': 'Al-Mulk',      'm': 'The Sovereignty',   'a': 'الملك'},
      {'n': 112, 'e': 'Al-Ikhlas',    'm': 'Sincerity',         'a': 'الإخلاص'},
      {'n': 113, 'e': 'Al-Falaq',     'm': 'The Daybreak',      'a': 'الفلق'},
      {'n': 114, 'e': 'An-Nas',       'm': 'Mankind',           'a': 'الناس'},
    ];

    return surahs.map((s) {
      final number = s['n'] as int;
      final eng    = s['e'] as String;
      
      final tracks = defaultReciters.map((r) => TrackModel(
        id:           'surah_${number}_${r['id']}',
        title:        r['name']!,
        categoryId:   number.toString(),
        categoryName: eng,
        audioUrl:     'https://cdn.islamic.network/quran/audio-surah/128/${r['id']}/$number.mp3',
      )).toList();

      return CategoryModel(
        id:         number.toString(),
        name:       '$eng – ${s['m']}',
        arabicName: s['a'] as String,
        tracks:     tracks,
      );
    }).toList();
  }

  // ── CDN VALIDATION HOOKS (Optional, synced for compatibility) ───────────

  static Future<Set<int>> fetchAvailableSurahs(String reciterId) async {
    if (_memCache.containsKey(reciterId)) return _memCache[reciterId]!;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefKeySurahsBase$reciterId');
    if (raw != null) {
      final List list = jsonDecode(raw);
      final cached = list.map((e) => e as int).toSet();
      _memCache[reciterId] = cached;
      return cached;
    }

    final isKnownReciter = defaultReciters.any((r) => r['id'] == reciterId);
    if (isKnownReciter) {
      final all = Set<int>.from(List.generate(114, (i) => i + 1));
      _memCache[reciterId] = all;
      await prefs.setString('$_prefKeySurahsBase$reciterId', jsonEncode(all.toList()));
      return all;
    }
    return {};
  }

    static void clearCache() => _memCache.clear();
  }

