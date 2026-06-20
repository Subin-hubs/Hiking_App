import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedTrails() async {
  final collection = FirebaseFirestore.instance.collection('trails');

  final List<Map<String, dynamic>> trails = [
    {
      'name': 'Everest Base Camp Trek',
      'region': 'Everest',
      'difficulty': 'Hard',
      'duration': 14,
      'elevation': 5364,
      'distance': 130.0,
      'description':
      'The Everest Base Camp Trek is one of the most iconic treks in the world. Starting from Lukla, the trail winds through Sherpa villages, rhododendron forests, and glacial moraines to reach the foot of the world\'s highest mountain. The journey offers breathtaking views of Everest, Lhotse, Nuptse, and Ama Dablam.',
      'imageUrl':
      'https://images.unsplash.com/photo-1516912481808-3406841bd33c?w=800',
      'highlights': [
        'Namche Bazaar — the gateway to Everest',
        'Tengboche Monastery with Ama Dablam views',
        'Khumbu Glacier and Icefall views',
        'Kala Patthar sunrise panorama',
        'Sherpa culture and hospitality',
      ],
      'startPoint': 'Lukla (fly from Kathmandu)',
      'bestSeason': 'Mar–May, Sep–Nov',
    },
    {
      'name': 'Annapurna Circuit Trek',
      'region': 'Annapurna',
      'difficulty': 'Moderate',
      'duration': 21,
      'elevation': 5416,
      'distance': 200.0,
      'description':
      'The Annapurna Circuit is a classic long-distance trek encircling the Annapurna massif. The trail crosses the Thorong La Pass at 5,416m, passing through diverse landscapes from subtropical lowlands to arid high-altitude plateaus, with stunning views of Dhaulagiri, Annapurna, and Machhapuchhre.',
      'imageUrl':
      'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
      'highlights': [
        'Thorong La Pass — highest point of the circuit',
        'Muktinath Temple — sacred Hindu and Buddhist site',
        'Manang village acclimatization day',
        'Pisang Peak views',
        'Apple orchards of Marpha',
      ],
      'startPoint': 'Besisahar (bus from Pokhara)',
      'bestSeason': 'Oct–Nov, Mar–Apr',
    },
    {
      'name': 'Langtang Valley Trek',
      'region': 'Langtang',
      'difficulty': 'Moderate',
      'duration': 10,
      'elevation': 4984,
      'distance': 65.0,
      'description':
      'The Langtang Valley Trek takes you into the heart of the Langtang National Park, home to snow leopards, red pandas, and Tamang communities. The trail follows the Langtang River through dense forests to the high-altitude Kyanjin Gompa, offering close-up views of the Langtang and Gangchempo peaks.',
      'imageUrl':
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      'highlights': [
        'Kyanjin Gompa — ancient Buddhist monastery',
        'Tserko Ri viewpoint at 4,984m',
        'Tamang cultural villages',
        'Yak cheese factory at Kyanjin',
        'Langtang and Gangchempo peak views',
      ],
      'startPoint': 'Syabrubesi (bus from Kathmandu)',
      'bestSeason': 'Mar–May, Oct–Nov',
    },
    {
      'name': 'Annapurna Base Camp Trek',
      'region': 'Annapurna',
      'difficulty': 'Moderate',
      'duration': 11,
      'elevation': 4130,
      'distance': 110.0,
      'description':
      'The Annapurna Base Camp Trek takes you deep into the Annapurna Sanctuary, a natural amphitheatre surrounded by towering peaks. The trail passes through Gurung villages, rhododendron and bamboo forests, and the famous Modi Khola river valley before reaching the base camp at 4,130m.',
      'imageUrl':
      'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800',
      'highlights': [
        'Annapurna Sanctuary — natural mountain amphitheatre',
        'Machhapuchhre (Fishtail) mountain views',
        'Ghorepani Poon Hill sunrise',
        'Gurung cultural villages',
        'Rhododendron forests in bloom',
      ],
      'startPoint': 'Nayapul (bus from Pokhara)',
      'bestSeason': 'Oct–Nov, Mar–Apr',
    },
    {
      'name': 'Upper Mustang Trek',
      'region': 'Mustang',
      'difficulty': 'Moderate',
      'duration': 14,
      'elevation': 3840,
      'distance': 190.0,
      'description':
      'The Upper Mustang Trek explores the ancient kingdom of Lo, a remote and restricted area that retains its Tibetan Buddhist culture. The landscape is stark and dramatic — eroded canyons, wind-carved caves, and whitewashed monasteries dot the high desert plateau bordering Tibet.',
      'imageUrl':
      'https://images.unsplash.com/photo-1533130061792-64b345e4a833?w=800',
      'highlights': [
        'Lo Manthang — walled ancient capital',
        'Chhoser cave temples',
        'Tibetan Buddhist monasteries',
        'Dramatic desert canyon landscapes',
        'Sky caves of Mustang',
      ],
      'startPoint': 'Jomsom (fly from Pokhara)',
      'bestSeason': 'May–Oct (rain shadow region)',
    },
    {
      'name': 'Manaslu Circuit Trek',
      'region': 'Manaslu',
      'difficulty': 'Hard',
      'duration': 16,
      'elevation': 5160,
      'distance': 177.0,
      'description':
      'The Manaslu Circuit Trek is a remote and challenging alternative to the Annapurna Circuit. Circling the world\'s eighth-highest mountain, the trail crosses the Larkya La Pass at 5,160m and passes through traditional Gurung and Tibetan-influenced Nubri villages with fewer crowds than other popular routes.',
      'imageUrl':
      'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=800',
      'highlights': [
        'Larkya La Pass — dramatic high mountain crossing',
        'Manaslu peak views at 8,163m',
        'Nubri and Tsum valley cultures',
        'Pungyen Gompa monastery',
        'Remote and uncrowded trails',
      ],
      'startPoint': 'Soti Khola (bus from Kathmandu)',
      'bestSeason': 'Mar–May, Sep–Nov',
    },
    {
      'name': 'Poon Hill Trek',
      'region': 'Annapurna',
      'difficulty': 'Easy',
      'duration': 4,
      'elevation': 3210,
      'distance': 42.0,
      'description':
      'The Poon Hill Trek is the perfect short trek for beginners and families. The highlight is the sunrise view from Poon Hill at 3,210m, offering a stunning panorama of the Annapurna and Dhaulagiri ranges. The trail passes through beautiful rhododendron forests and charming Gurung villages.',
      'imageUrl':
      'https://images.unsplash.com/photo-1605640840605-14ac1855827b?w=800',
      'highlights': [
        'Poon Hill sunrise with Himalayan panorama',
        'Annapurna South and Dhaulagiri views',
        'Ghorepani rhododendron forests',
        'Tikhedhunga and Ulleri villages',
        'Ideal for beginners and families',
      ],
      'startPoint': 'Nayapul (bus from Pokhara)',
      'bestSeason': 'Oct–Apr',
    },
    {
      'name': 'Kanchenjunga Base Camp Trek',
      'region': 'Kanchenjunga',
      'difficulty': 'Expert',
      'duration': 28,
      'elevation': 5143,
      'distance': 210.0,
      'description':
      'The Kanchenjunga Base Camp Trek is one of Nepal\'s most remote and rewarding adventures. Reaching the base of the world\'s third-highest peak requires crossing two high passes and passing through pristine wilderness rarely visited by trekkers.',
      'imageUrl':
      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
      'highlights': [
        'Kanchenjunga North and South Base Camps',
        'Sinion La and Mirgin La passes',
        'Pristine wilderness and wildlife',
        'Limbu and Sherpa villages',
        'Truly off-the-beaten-path experience',
      ],
      'startPoint': 'Taplejung (fly from Kathmandu)',
      'bestSeason': 'Mar–May, Oct–Nov',
    },
    {
      'name': 'Gokyo Lakes Trek',
      'region': 'Everest',
      'difficulty': 'Hard',
      'duration': 14,
      'elevation': 5357,
      'distance': 110.0,
      'description':
      'The Gokyo Lakes Trek is a stunning alternative to the classic Everest Base Camp route. The trail leads to the Gokyo Valley, home to six sacred glacial lakes and the Ngozumpa Glacier — the largest glacier in Nepal.',
      'imageUrl':
      'https://images.unsplash.com/photo-1515859005217-8a1f08870f59?w=800',
      'highlights': [
        'Gokyo Ri — 360° Himalayan panorama',
        'Six sacred Gokyo lakes',
        'Ngozumpa Glacier — largest in Nepal',
        'Views of Everest, Cho Oyu, Makalu, Lhotse',
        'Quieter than the EBC trail',
      ],
      'startPoint': 'Lukla (fly from Kathmandu)',
      'bestSeason': 'Mar–May, Sep–Nov',
    },
    {
      'name': 'Rolwaling Valley Trek',
      'region': 'Rolwaling',
      'difficulty': 'Expert',
      'duration': 18,
      'elevation': 5755,
      'distance': 150.0,
      'description':
      'The Rolwaling Valley Trek is one of Nepal\'s hidden gems, crossing the challenging Tesi Lapcha Pass at 5,755m into the Khumbu region. The remote valley is sacred to the Sherpa people and offers dramatic scenery with glacial lakes and high passes.',
      'imageUrl':
      'https://images.unsplash.com/photo-1434394354979-a235cd36269d?w=800',
      'highlights': [
        'Tsho Rolpa glacial lake',
        'Tesi Lapcha Pass at 5,755m',
        'Remote and sacred Sherpa valley',
        'Dramatic glacial landscapes',
        'Connects to Khumbu region',
      ],
      'startPoint': 'Charikot (bus from Kathmandu)',
      'bestSeason': 'Oct–Nov',
    },
  ];

  print('🌱 Starting trail seeding...');

  for (final trail in trails) {
    try {
      await collection.add(trail);
      print('✅ Added: ${trail['name']}');
    } catch (e) {
      print('❌ Failed to add ${trail['name']}: $e');
    }
  }

  print('🎉 Seeding complete! ${trails.length} trails added to Firestore.');
}