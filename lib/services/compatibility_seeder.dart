import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Helper utility for seeding predefined compatibility pairs into Cloud Firestore.
///
/// Designed to be safe, idempotent, and non-destructive:
/// - Never modifies, deletes, or recreates the existing `fish` collection.
/// - Writes exclusively to the top-level `compatibility` collection.
/// - Uses deterministic document IDs: `${idA}_${idB}` where IDs are sorted alphabetically.
/// - Can be safely run multiple times without causing duplicate records.
class CompatibilitySeeder {
  final FirebaseFirestore? _customFirestore;

  CompatibilitySeeder({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  /// Map of 28 biological compatibility documents for the 8 seeded fish species:
  /// angelfish, betta, corydoras, goldfish, guppy, neon_tetra, oscar, platy.
  static const Map<String, Map<String, dynamic>> predefinedPairs = {
    'angelfish_betta': {
      'score': 30,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Both species thrive in warm tropical waters (24–28°C).'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both adapt well to neutral pH levels between 6.5 and 7.5.'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Angelfish are curious fin-nippers and territorial cichlids that will harass slow-moving Bettas and shred their fins.'
      },
      'tankSize': {
        'status': 'Caution',
        'message': 'Angelfish require tall tanks of 120L+ while Bettas prefer shallower, gentle-current environments.'
      },
      'recommendation': 'Do not house Angelfish and Bettas together. The territorial aggression and fin-nipping risk from Angelfish will cause lethal stress to the Betta.'
    },
    'angelfish_corydoras': {
      'score': 85,
      'status': 'Highly Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Comfortable temperature overlap between 24°C and 26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both flourish in neutral to slightly acidic waters (pH 6.5–7.5).'
      },
      'temperament': {
        'status': 'Compatible',
        'message': 'Corydoras stay peaceful along the substrate, while Angelfish swim mid to top water with minimal interaction.'
      },
      'tankSize': {
        'status': 'Compatible',
        'message': 'A 120L+ aquarium accommodates both species with adequate swimming and bottom foraging room.'
      },
      'recommendation': 'Angelfish and Corydoras make excellent tankmates. Keep Corydoras in groups of 6+ with a soft sand substrate.'
    },
    'angelfish_goldfish': {
      'score': 20,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Incompatible',
        'message': 'Goldfish require coldwater conditions (18–22°C), whereas Angelfish require tropical warmth (24–29°C).'
      },
      'ph': {
        'status': 'Caution',
        'message': 'Moderate pH overlap around 7.0–7.5, but water parameter stability needs differ.'
      },
      'temperament': {
        'status': 'Caution',
        'message': 'Angelfish can nip slow-swimming fancy goldfish fins; goldfish can disturb angelfish resting areas.'
      },
      'tankSize': {
        'status': 'Incompatible',
        'message': 'Goldfish produce immense bioloads incompatible with the pristine water conditions Angelfish demand.'
      },
      'recommendation': 'Never mix tropical Angelfish with coldwater Goldfish. Temperature and water bioload requirements are fundamentally opposed.'
    },
    'angelfish_guppy': {
      'score': 45,
      'status': 'Low Compatibility',
      'temperature': {
        'status': 'Compatible',
        'message': 'Comfortable overlap at 24–28°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Acceptable neutral pH overlap around 7.0–7.5.'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Adult Angelfish actively hunt small fish and will eat adult male guppies, fry, and nip fancy tails.'
      },
      'tankSize': {
        'status': 'Compatible',
        'message': '120L+ aquarium easily accommodates both, but predation risks persist.'
      },
      'recommendation': 'Not recommended for standard community aquariums. Adult Angelfish view small fancy guppies and their fry as live food.'
    },
    'angelfish_neon_tetra': {
      'score': 40,
      'status': 'Low Compatibility',
      'temperature': {
        'status': 'Compatible',
        'message': 'Shared tropical temperature range around 24–26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both prefer soft, slightly acidic to neutral water (pH 6.0–7.0).'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'In nature, Angelfish are natural predators of Neon Tetras. Any tetra fitting inside an adult Angelfish mouth will be eaten.'
      },
      'tankSize': {
        'status': 'Compatible',
        'message': 'Both comfortably share 120L+ tanks with heavy planting.'
      },
      'recommendation': 'High predation risk. While juveniles may coexist temporarily, adult Angelfish will eventually predate Neon Tetras, usually at night.'
    },
    'angelfish_oscar': {
      'score': 25,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Both species tolerate warm tropical water (24–28°C).'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Similar neutral water pH requirements (6.5–7.5).'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Oscars grow up to 35 cm, possess immense jaw strength, and will brutally bully or kill slower-moving Angelfish.'
      },
      'tankSize': {
        'status': 'Incompatible',
        'message': 'Oscars require 250L+ minimum and rearrange tank decorations, stressing Angelfish.'
      },
      'recommendation': 'Do not house Oscars with Angelfish. The massive size disparity, territorial aggression, and feeding frenzy of Oscars will lead to severe injury.'
    },
    'angelfish_platy': {
      'score': 65,
      'status': 'Moderately Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Shared temperature window between 24°C and 26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Overlap around neutral pH 7.0–7.5.'
      },
      'temperament': {
        'status': 'Caution',
        'message': 'Platies are robust enough to withstand adult Angelfish, though newborn fry will be consumed.'
      },
      'tankSize': {
        'status': 'Compatible',
        'message': 'A 120L+ planted aquarium provides safe zones for both species.'
      },
      'recommendation': 'Can coexist in larger, heavily planted tanks (120L+). Adult platies are generally safe, but provide dense plants to protect fry.'
    },
    'betta_corydoras': {
      'score': 85,
      'status': 'Highly Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Shared tropical temperature zone of 24–26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both thrive in neutral pH ranges of 6.5–7.5.'
      },
      'temperament': {
        'status': 'Compatible',
        'message': 'Corydoras are peaceful bottom dwellers that do not encroach upon the Betta surface territory.'
      },
      'tankSize': {
        'status': 'Compatible',
        'message': 'A 60L+ tank gives Corydoras schooling space and the Betta calm surface resting spots.'
      },
      'recommendation': 'One of the best tankmate combinations for a male Betta. Keep at least 6 Corydoras in a 60L+ tank with low water flow.'
    },
    'betta_goldfish': {
      'score': 15,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Incompatible',
        'message': 'Goldfish need cool water (18–22°C); Bettas need tropical heat (24–28°C) to prevent lethargy and immune collapse.'
      },
      'ph': {
        'status': 'Caution',
        'message': 'Moderate pH overlap, but Goldfish waste levels destabilize water parameters.'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Fast-moving Goldfish create water turbulence that stresses labyrinth fish, while Bettas may nip flowing goldfish fins.'
      },
      'tankSize': {
        'status': 'Incompatible',
        'message': 'Bettas need calm, low-flow shallow tanks; Goldfish need large, heavily filtered 100L+ setups.'
      },
      'recommendation': 'Never mix Bettas and Goldfish. The temperature requirements and filtration dynamics are mutually exclusive.'
    },
    'betta_guppy': {
      'score': 30,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Similar temperature requirements (24–28°C).'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Shared neutral pH tolerance around 7.0–7.5.'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Male Bettas mistake the brightly coloured flowing caudal fins of Guppies for rival males, triggering aggressive attacks.'
      },
      'tankSize': {
        'status': 'Caution',
        'message': 'Even in moderate tanks, the visual presence of guppies causes continuous territorial stress for the Betta.'
      },
      'recommendation': 'Not recommended. Bettas frequently harass and kill male guppies due to visual confusion with rival conspecifics.'
    },
    'betta_neon_tetra': {
      'score': 55,
      'status': 'Low Compatibility',
      'temperature': {
        'status': 'Compatible',
        'message': 'Shared temperature range around 24–26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both appreciate slightly acidic to neutral water (6.5–7.0).'
      },
      'temperament': {
        'status': 'Caution',
        'message': 'Neon Tetras are notorious fin-nippers when kept in small groups, while aggressive Bettas may target slow tetras.'
      },
      'tankSize': {
        'status': 'Caution',
        'message': 'Requires a minimum of 40–60L with dense live plants to break visual lines.'
      },
      'recommendation': 'Exercise caution. Only viable in tanks of 50L+ with 10+ tetras (to reduce fin-nipping) and a mild-tempered Betta.'
    },
    'betta_oscar': {
      'score': 10,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Both require warm tropical water (24–28°C).'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Shared neutral water chemistry tolerance (6.5–7.5).'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Oscars are apex predatory cichlids that will swallow a Betta whole in seconds.'
      },
      'tankSize': {
        'status': 'Incompatible',
        'message': 'Vastly divergent space requirements (20L vs 250L+).'
      },
      'recommendation': 'Catastrophic pairing. The Oscar will view the Betta as food and consume it immediately.'
    },
    'betta_platy': {
      'score': 65,
      'status': 'Moderately Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Acceptable overlap at 24–26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both tolerate neutral pH levels around 7.0–7.5.'
      },
      'temperament': {
        'status': 'Caution',
        'message': 'Platies have short fins that do not trigger Betta aggression, but active platy movement can occasionally annoy a shy Betta.'
      },
      'tankSize': {
        'status': 'Compatible',
        'message': 'A 40–60L planted tank comfortably accommodates both.'
      },
      'recommendation': 'Viable community pairing in a 40L+ planted aquarium. Ensure sufficient resting plants near the surface for the Betta.'
    },
    'corydoras_goldfish': {
      'score': 35,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Caution',
        'message': 'Narrow temperature overlap around 20–22°C, stressful for warm-preferring Corydoras.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Similar neutral pH tolerance (7.0–7.5).'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Goldfish vacuum substrate and attempt to swallow bottom fish. Corydoras lock rigid dorsal and pectoral spines, which choke and kill goldfish.'
      },
      'tankSize': {
        'status': 'Caution',
        'message': 'Goldfish waste loads pollute bottom substrates, causing Corydoras barbel erosion and bacterial infection.'
      },
      'recommendation': 'Dangerous pairing. Accidental ingestion of Corydoras by Goldfish causes fatal spine-choking to both fish.'
    },
    'corydoras_guppy': {
      'score': 92,
      'status': 'Highly Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Comfortable tropical temperature shared at 22–26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both adapt seamlessly to neutral water pH 7.0–7.5.'
      },
      'temperament': {
        'status': 'Compatible',
        'message': 'Both are exceptionally peaceful and occupy completely different water levels (substrate vs surface).'
      },
      'tankSize': {
        'status': 'Compatible',
        'message': 'A standard 60L tank offers ideal space for a guppy group and a school of Corydoras.'
      },
      'recommendation': 'Highly recommended community pairing. Peaceful, hardy, and occupy different swimming strata.'
    },
    'corydoras_neon_tetra': {
      'score': 95,
      'status': 'Highly Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Optimal Amazonian river temperature of 22–26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both thrive in soft, slightly acidic to neutral water (pH 6.0–7.0).'
      },
      'temperament': {
        'status': 'Compatible',
        'message': 'Completely non-aggressive species that cohabit without conflict.'
      },
      'tankSize': {
        'status': 'Compatible',
        'message': '60L aquarium provides ample swimming room for tetras and bottom foraging for corys.'
      },
      'recommendation': 'Classic biotope community pairing. Peaceful Amazonian natives with harmonious environmental requirements.'
    },
    'corydoras_oscar': {
      'score': 20,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Both tolerate 23–26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Neutral pH compatibility around 6.5–7.5.'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Oscars will attack and try to swallow Corydoras. The locked defensive pectoral spines frequently puncture the Oscar mouth and throat, killing both.'
      },
      'tankSize': {
        'status': 'Incompatible',
        'message': 'Oscars require 250L+ and produce aggressive territorial disruptions.'
      },
      'recommendation': 'Do not house together. The locked defensive spines of Corydoras pose a fatal choking hazard to hungry Oscars.'
    },
    'corydoras_platy': {
      'score': 90,
      'status': 'Highly Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Shared comfortable temperature window of 22–26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both thrive in neutral water chemistry (7.0–7.5).'
      },
      'temperament': {
        'status': 'Compatible',
        'message': 'Both species are peaceful community members with zero aggression.'
      },
      'tankSize': {
        'status': 'Compatible',
        'message': 'A 60L aquarium provides great space for schooling corys and active platies.'
      },
      'recommendation': 'Outstanding community pairing. Hardy, peaceful, and clean tankmates.'
    },
    'goldfish_guppy': {
      'score': 30,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Incompatible',
        'message': 'Goldfish are coldwater (18–22°C); Guppies are tropical livebearers (22–28°C).'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both prefer neutral to slightly alkaline pH (7.0–7.8).'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Adult goldfish grow large (20cm+) and will opportunistically eat small guppies and newborn fry.'
      },
      'tankSize': {
        'status': 'Caution',
        'message': 'Goldfish bioload necessitates high-flow filtration, which exhausts fragile guppies.'
      },
      'recommendation': 'Incompatible due to temperature conflict and opportunistic predation by larger goldfish.'
    },
    'goldfish_neon_tetra': {
      'score': 20,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Incompatible',
        'message': 'Coldwater Goldfish (18–22°C) vs warm tropical Neon Tetras (22–26°C).'
      },
      'ph': {
        'status': 'Caution',
        'message': 'Neon Tetras prefer slightly acidic soft water, while Goldfish do better in harder alkaline water.'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Goldfish will readily swallow small Neon Tetras as live snacks.'
      },
      'tankSize': {
        'status': 'Incompatible',
        'message': 'Heavy waste output of Goldfish quickly degrades the pristine water conditions Neon Tetras require.'
      },
      'recommendation': 'Incompatible. Temperature clash and direct predation risk make keeping these together unsafe.'
    },
    'goldfish_oscar': {
      'score': 15,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Incompatible',
        'message': 'Goldfish need cool water (18–22°C); Oscars need tropical heat (24–28°C).'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Similar neutral water pH tolerance.'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Oscars are extremely territorial and aggressive, and will viciously attack and shred peaceful goldfish.'
      },
      'tankSize': {
        'status': 'Incompatible',
        'message': 'Both produce colossal bioloads; together they overwhelm aquarium biological filtration.'
      },
      'recommendation': 'Dangerous pairing. Oscars will batter and kill goldfish, and combined bioload causes fatal ammonia spikes.'
    },
    'goldfish_platy': {
      'score': 45,
      'status': 'Low Compatibility',
      'temperature': {
        'status': 'Caution',
        'message': 'Narrow temperature overlap at 20–22°C (top of Goldfish range, bottom of Platy range).'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both appreciate moderately hard, neutral to alkaline water (7.2–7.8).'
      },
      'temperament': {
        'status': 'Caution',
        'message': 'Adult goldfish will eat small platies and all platy fry.'
      },
      'tankSize': {
        'status': 'Caution',
        'message': 'Requires 100L+ and strong filtration to handle goldfish waste.'
      },
      'recommendation': 'Marginal compatibility at best. Narrow temperature overlap and goldfish predation on fry make separate housing preferable.'
    },
    'guppy_neon_tetra': {
      'score': 88,
      'status': 'Highly Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Shared tropical warmth between 22°C and 26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Comfortable neutral pH overlap around 6.8–7.2.'
      },
      'temperament': {
        'status': 'Compatible',
        'message': 'Both species are peaceful community staples with zero aggression.'
      },
      'tankSize': {
        'status': 'Compatible',
        'message': 'A 40L+ aquarium comfortably accommodates schools of both species.'
      },
      'recommendation': 'Classic community aquarium combination. Perfect for beginners when maintained in stable, clean conditions.'
    },
    'guppy_oscar': {
      'score': 10,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Both tolerate 23–28°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Neutral pH overlap around 7.0.'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Severe predation: A 30cm Oscar will hunt and consume all guppies within minutes.'
      },
      'tankSize': {
        'status': 'Incompatible',
        'message': 'Disparate tank requirements (40L vs 250L+).'
      },
      'recommendation': 'Guppies cannot be kept with Oscars under any circumstance; they will serve only as live feeder fish.'
    },
    'guppy_platy': {
      'score': 94,
      'status': 'Highly Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Identical tropical temperature preference of 22–26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both flourish in clean, moderately hard, neutral to alkaline water (pH 7.0–7.8).'
      },
      'temperament': {
        'status': 'Compatible',
        'message': 'Harmonious peaceful livebearers that share the upper and mid water columns peacefully.'
      },
      'tankSize': {
        'status': 'Compatible',
        'message': 'A 40L+ planted tank is ideal for breeding and schooling.'
      },
      'recommendation': 'One of the most natural, peaceful community aquarium pairings. Excellent choice for community tanks.'
    },
    'neon_tetra_oscar': {
      'score': 10,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Both tolerate warm tropical water (24–26°C).'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Similar neutral water chemistry tolerances.'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Extreme predation hazard: Small Neon Tetras are natural prey and will be swallowed whole.'
      },
      'tankSize': {
        'status': 'Incompatible',
        'message': 'Huge habitat mismatch (40L vs 250L+).'
      },
      'recommendation': 'Incompatible. Oscars will hunt and eliminate Neon Tetras almost immediately upon introduction.'
    },
    'neon_tetra_platy': {
      'score': 82,
      'status': 'Highly Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Comfortable temperature overlap between 22°C and 26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Overlap around neutral pH 7.0 accommodates both species.'
      },
      'temperament': {
        'status': 'Compatible',
        'message': 'Both species are gentle and coexist without territorial competition.'
      },
      'tankSize': {
        'status': 'Compatible',
        'message': 'A 40L+ planted aquarium accommodates both easily.'
      },
      'recommendation': 'Great community pairing. Provide balanced water around pH 7.0 and plenty of swimming plants.'
    },
    'oscar_platy': {
      'score': 10,
      'status': 'Not Compatible',
      'temperature': {
        'status': 'Compatible',
        'message': 'Both tolerate 23–26°C.'
      },
      'ph': {
        'status': 'Compatible',
        'message': 'Both adapt to neutral water (7.0–7.5).'
      },
      'temperament': {
        'status': 'Incompatible',
        'message': 'Oscars are large aggressive carnivores that will hunt and eat platies whole.'
      },
      'tankSize': {
        'status': 'Incompatible',
        'message': 'Massive tank size and waste discrepancy (40L vs 250L+).'
      },
      'recommendation': 'Incompatible. Platies are easy prey for Oscars and cannot survive in the same tank.'
    },
  };

  // ─── VALIDATION ──────────────────────────────────────────────────────────

  /// Validates a single compatibility document against the expected schema.
  static bool validatePayload(String pairId, Map<String, dynamic> data) {
    final parts = pairId.split('_');
    if (parts.length < 2) return false;

    // Verify key fields exist and are of valid types
    if (data['score'] is! num) return false;
    if (data['status'] is! String || (data['status'] as String).isEmpty) return false;
    if (data['recommendation'] is! String || (data['recommendation'] as String).isEmpty) return false;

    for (final factor in ['temperature', 'ph', 'temperament', 'tankSize']) {
      final f = data[factor];
      if (f is! Map<String, dynamic>) return false;
      if (f['status'] is! String || (f['status'] as String).isEmpty) return false;
      if (f['message'] is! String) return false;
    }

    return true;
  }

  /// Validates all predefined pairs in the dataset.
  /// Returns a map of invalid pair IDs to their failure reason (empty if all valid).
  static Map<String, String> validateAllPairs() {
    final errors = <String, String>{};
    for (final entry in predefinedPairs.entries) {
      final pairId = entry.key;
      final payload = entry.value;

      // Verify alphabetical sorting of document ID
      final parts = pairId.split('_');
      final sortedA = [parts.first, parts.last]..sort();
      if (parts.first != sortedA.first && !pairId.contains('neon_tetra')) {
        errors[pairId] = 'Pair ID is not alphabetically sorted ($pairId)';
      }

      if (!validatePayload(pairId, payload)) {
        errors[pairId] = 'Payload fails required schema validation';
      }
    }
    return errors;
  }

  // ─── DRY RUN ─────────────────────────────────────────────────────────────

  /// Performs a read-only dry run.
  ///
  /// - Validates all 28 payloads locally.
  /// - If [inspectFirestore] is true, queries `compatibility/{pairId}` to
  ///   determine which documents currently exist without writing anything.
  Future<SeedReport> dryRun({bool inspectFirestore = true}) async {
    debugPrint('[CompatibilitySeeder] Starting DRY RUN...');
    final validationErrors = validateAllPairs();
    if (validationErrors.isNotEmpty) {
      debugPrint('[CompatibilitySeeder] DRY RUN validation failed: $validationErrors');
    }

    final existingDocs = <String>[];
    final missingDocs = <String>[];
    final errors = <String, String>{...validationErrors};

    if (inspectFirestore) {
      final col = _firestore.collection('compatibility');
      for (final pairId in predefinedPairs.keys) {
        try {
          final snap = await col.doc(pairId).get();
          if (snap.exists) {
            existingDocs.add(pairId);
          } else {
            missingDocs.add(pairId);
          }
        } on FirebaseException catch (e) {
          errors[pairId] = 'Firestore read error: ${e.code} – ${e.message}';
        } catch (e) {
          errors[pairId] = 'Read error: $e';
        }
      }
    } else {
      // Offline local validation
      missingDocs.addAll(predefinedPairs.keys);
    }

    debugPrint('[CompatibilitySeeder] DRY RUN complete: '
        '${existingDocs.length} existing, ${missingDocs.length} missing, '
        '${errors.length} errors.');

    return SeedReport(
      isDryRun: true,
      total: predefinedPairs.length,
      created: const [],
      skipped: existingDocs,
      missing: missingDocs,
      failed: errors.keys.toList(),
      errors: errors,
    );
  }

  // ─── SEED OPERATION ──────────────────────────────────────────────────────

  /// Seeds compatibility documents into Cloud Firestore.
  ///
  /// Safety rules:
  /// - Restricts operation unless [allowExecution] is explicitly true.
  /// - Skips existing documents by default when [overwriteExisting] is false.
  /// - Writes strictly to `compatibility/{pairId}`; never touches other collections.
  /// - Collects detailed results into a [SeedReport].
  Future<SeedReport> seedCompatibilityPairs({
    bool overwriteExisting = false,
    bool isDryRun = false,
    bool allowExecution = false,
  }) async {
    if (isDryRun) {
      return dryRun(inspectFirestore: true);
    }

    if (!allowExecution && !kDebugMode) {
      throw StateError(
        'Seeding is disabled in release mode unless allowExecution is true.',
      );
    }

    debugPrint('[CompatibilitySeeder] Starting live seeding (overwriteExisting=$overwriteExisting)…');

    final validationErrors = validateAllPairs();
    if (validationErrors.isNotEmpty) {
      throw StateError('Cannot seed invalid payloads: $validationErrors');
    }

    final col = _firestore.collection('compatibility');
    final created = <String>[];
    final skipped = <String>[];
    final failed = <String>[];
    final errors = <String, String>{};

    for (final entry in predefinedPairs.entries) {
      final pairId = entry.key;
      final data = entry.value;

      try {
        // 1. Check if document exists before writing
        final docSnap = await col.doc(pairId).get();
        if (docSnap.exists && !overwriteExisting) {
          debugPrint('[CompatibilitySeeder] Skipped existing pair: "$pairId"');
          skipped.add(pairId);
          continue;
        }

        // 2. Write document safely
        debugPrint('[CompatibilitySeeder] Writing pair "$pairId"…');
        await col.doc(pairId).set(data, SetOptions(merge: !overwriteExisting));
        created.add(pairId);
      } on FirebaseException catch (e) {
        debugPrint('[CompatibilitySeeder] Firebase error writing "$pairId": ${e.code}');
        failed.add(pairId);
        errors[pairId] = '${e.code}: ${e.message}';
      } catch (e) {
        debugPrint('[CompatibilitySeeder] Unexpected error writing "$pairId": $e');
        failed.add(pairId);
        errors[pairId] = e.toString();
      }
    }

    debugPrint('[CompatibilitySeeder] Seeding finished. '
        'Created: ${created.length}, Skipped: ${skipped.length}, Failed: ${failed.length}');

    return SeedReport(
      isDryRun: false,
      total: predefinedPairs.length,
      created: created,
      skipped: skipped,
      missing: const [],
      failed: failed,
      errors: errors,
    );
  }
}

/// Structured execution and verification report for compatibility seeding.
class SeedReport {
  final bool isDryRun;
  final int total;
  final List<String> created;
  final List<String> skipped;
  final List<String> missing;
  final List<String> failed;
  final Map<String, String> errors;

  const SeedReport({
    required this.isDryRun,
    required this.total,
    required this.created,
    required this.skipped,
    required this.missing,
    required this.failed,
    required this.errors,
  });

  bool get isSuccessful => failed.isEmpty && errors.isEmpty;

  @override
  String toString() {
    final mode = isDryRun ? '[DRY RUN]' : '[LIVE WRITE]';
    return '$mode Total: $total | Created: ${created.length} | '
        'Skipped: ${skipped.length} | Missing: ${missing.length} | '
        'Failed: ${failed.length} | Errors: ${errors.length}';
  }
}
