



import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
import 'lunchscreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for any async code in the main function

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool firstLaunch = prefs.getBool('firstLaunch') ?? true;

  runApp(
    ChangeNotifierProvider(
      create: (context) => CoinData(), // replace CoinData with the name of your ChangeNotifier class
      child: MyApp(firstLaunch: firstLaunch),
    ),
  );
}



class MyApp extends StatelessWidget {
  final bool firstLaunch;

  MyApp({required this.firstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: firstLaunch ? launchscreen() : MergeGameApp(),
    );
  }
}







class CoinData extends ChangeNotifier {
  late int _coins;

  CoinData() {
    _coins = 0;
    _loadCoins();
  }

  int get coins => _coins;

  set coins(int newValue) {
    _coins = newValue;
    notifyListeners(); // Notify listeners to rebuild
    _saveCoins(newValue); // Save the new coin value
  }

  Future<void> _loadCoins() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 0;
    notifyListeners(); // Notify listeners to rebuild after loading coins
  }

  Future<void> _saveCoins(int coins) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('coins', coins);
  }
}








StreamController<int> streamController = StreamController<int>();


class Square {
final int value;
final Key key;
final int profitMultiplier;
final int specialMultiplier;


Square(this.value, this.key, this.profitMultiplier, this.specialMultiplier);
  }






class MergeGameApp extends StatelessWidget {
  const MergeGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: MergeGameHome(title: ''),
            ),
            Expanded(
              child: QuizPage(),
            ),
          ],
        ),
      ),
    );
  }
}







int coins = 20;



class MergeGameHome extends StatefulWidget {
  const MergeGameHome({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MergeGameHome> createState() => _MergeGameHomeState();
}

class _MergeGameHomeState extends State<MergeGameHome> {
  Map<Key, Square> grid = {};
  final random = Random();
   
  bool canCollect = true; 
  double collectCooldown = 5.0; 
  double remainingTime = 0.0; 
  Timer? countdownTimer; 
  bool autoCollectEnabled = false;
  bool autoMergeEnabled = false;
  int highestValueReached = 1;
  int profitMultiplier = 1;
  double totalEarnings = 0.0;
  int reincarnations = 0;
  int specialMultiplier = 1;
  int reincarnateCost = 10000000;
  bool purchase3 = false;
  SharedPreferences? _prefs;
  int getTreesSaved() {
    return (totalEarnings).floor();
  }

  int getCarbonOffset() {
    return (totalEarnings / 20).floor();
  }

  ValueNotifier<double> placeSquareCost = ValueNotifier<double>(5.0);
  ValueNotifier<double> increaseTileValueCost = ValueNotifier<double>(100.0);
  ValueNotifier<double> speedUpCost = ValueNotifier<double>(10.0);
  ValueNotifier<double> autoCollectCost = ValueNotifier<double>(1500.0);
  ValueNotifier<double> autoMergeCost = ValueNotifier<double>(1500.0);
  ValueNotifier<double> levelTwoCost = ValueNotifier<double>(50.0);
  ValueNotifier<double> levelThreeCost = ValueNotifier<double>(100.0);
  ValueNotifier<double> levelFourCost = ValueNotifier<double>(200.0);
  ValueNotifier<double> levelFiveCost = ValueNotifier<double>(400.0);
  ValueNotifier<double> levelSixCost = ValueNotifier<double>(800.0);
  ValueNotifier<double> levelSevenCost = ValueNotifier<double>(1600.0);
  ValueNotifier<int> highestMergedValue = ValueNotifier<int>(1);

void resetBoard() {
  setState(() {
    grid.clear();
    highestMergedValue.value = 1; // Reset highest merged value to 1
    // Reset any other necessary game state
  });
}
void resetShopUpgrades() {
  setState(() {
    placeSquareCost.value = 5.0;
    increaseTileValueCost.value = 100.0;
    speedUpCost.value = 10.0;
    autoCollectCost.value = 1500.0;
    autoMergeCost.value = 1500.0;
    levelTwoCost.value = 50.0;
    levelThreeCost.value = 100.0;
    levelFourCost.value = 200.0;
    levelFiveCost.value = 400.0;
    levelSixCost.value = 800.0;
    levelSevenCost.value = 1600.0;
    collectCooldown = 5.0; 
    profitMultiplier = 1;
  });
}
void reincarnate() {
  if (coins >= reincarnateCost) {
    setState(() {
      coins = 40;
      reincarnations++;
      resetBoard();
      resetShopUpgrades();
      specialMultiplier++; 
      reincarnateCost = reincarnateCost*2;
    });
  }
}

  void onAdWatched() {
    setState(() {
      totalEarnings += 0.01; // Assume you earn $0.01 per ad view
      
    });
  }
  void onPurchaseMade(double purchaseAmount) {
  setState(() {
    totalEarnings += purchaseAmount;
  });
  }
  void autoCollect() {
    if (coins >= autoCollectCost.value.ceil()) {
      setState(() {
        coins -= autoCollectCost.value.ceil();
        autoCollectEnabled = true;
      });
    }
  }
  Key getRandomEmptyKey() {
  List<Key> availableCells = List<Key>.generate(
    16,
    (index) => ValueKey<Offset>(Offset(index / 4, index % 4)),
  )..removeWhere((key) => grid.containsKey(key));

  if (availableCells.isNotEmpty) {
    return availableCells[random.nextInt(availableCells.length)];
  } else {
    throw Exception("No empty keys available!");
  }
}


// Add similar functions for levelFour and levelFive
  void autoMerge() {
    if (coins >= autoMergeCost.value.ceil()) {
      setState(() {
        coins -= autoMergeCost.value.ceil();
        autoMergeEnabled = true;
                  mergeTiles();
      });
    }
  }



  void watchAd() {
  print("watch ad!");

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-9457512370089235/2281820150'
      : 'ca-app-pub-9457512370089235/9182000923';

  RewardedAd? _rewardedAd;

  RewardedAd.load(
      adUnitId: _adUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('RewardedAd loaded.');
          _rewardedAd = ad;
          _rewardedAd?.show(onUserEarnedReward: (Ad ad, RewardItem reward) {
            print('Reward: ${reward.amount} ${reward.type}');
            setState(() {
              totalEarnings += 0.1; // You earn $0.10 for watching an ad
              
            });
            Provider.of<CoinData>(context, listen: false).coins += 200;
            saveGameData();
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );
}








  void makePurchase1() {
    setState(() {
      totalEarnings += 1;
      coins = coins*2; 
    });
    saveGameData();
  }

  void makePurchase2() {
    setState(() {
      totalEarnings += 5; 
      coins = coins*4;
    });
    saveGameData();
  }
    void makePurchase3() {
    setState(() {
      totalEarnings += 5; 
      specialMultiplier++;
      purchase3 = true;
    });
    saveGameData();
  }
  void collectCoins() {
  if (!canCollect) return;
  int totalValue = 0;
  for (Square square in grid.values) {
    totalValue += pow(2, square.value).toInt() * square.profitMultiplier;
  }
    setState(() {
      coins += totalValue;
      canCollect = false;
      remainingTime = collectCooldown;
    });

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        remainingTime = (remainingTime - 0.1).toDouble();
        remainingTime = num.parse(remainingTime.toStringAsFixed(2)) as double;
        if (remainingTime <= 0) {
          canCollect = true;
          timer.cancel();
          if (autoCollectEnabled) {
            collectCoins();
          }
        }
      });
    });
  }
void speedUp() {
  if (coins >= speedUpCost.value.ceil()) {
    setState(() {
      coins -= speedUpCost.value.ceil();
      speedUpCost.value *= 1.2;
      if (collectCooldown > 0.1) {
        collectCooldown -= 0.1;
      }
    });
  }
}






















void placeRandomSquare() {
  List<Key> availableCells = List<Key>.generate(
    16,
    (index) => ValueKey<Offset>(Offset(index / 4, index % 4)),
  )..removeWhere((key) => grid.containsKey(key));

  // Get the current coin value from CoinData
  int currentCoins = Provider.of<CoinData>(context, listen: false).coins;

  if (availableCells.isNotEmpty && currentCoins >= placeSquareCost.value.ceil()) {
    Key selected = availableCells[random.nextInt(availableCells.length)];
    setState(() {
      grid[selected] = Square(1, selected, profitMultiplier, specialMultiplier);
      // Decrease the coin value in CoinData
      Provider.of<CoinData>(context, listen: false).coins = currentCoins - placeSquareCost.value.ceil();
    });
    placeSquareCost.value *= 1.025;
    highestValueReached = max(highestValueReached, 2);

    if (autoMergeEnabled) {
      mergeTiles();
    }
    saveGameData();
  }
  else{
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('We are sorry,', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
          content: Text('You do not have enough coins to place a square. The cost is ' + placeSquareCost.value.ceil().toString() + ' coins.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}




void increaseTileValue() {
  if (coins >= increaseTileValueCost.value.ceil()) {
    setState(() {
      coins -= increaseTileValueCost.value.ceil();
      profitMultiplier += 1;
      grid.updateAll((key, square) => Square(square.value, square.key, profitMultiplier, specialMultiplier));
    });
    increaseTileValueCost.value *= 2;
  }
}
void mergeTiles() {
  print("Merging tiles");
  bool didMerge;
  do {
    didMerge = false;
    for (Key key in grid.keys) {
      Square? square = grid[key];
      if (square != null) {
        List<Key> sameValueKeys = grid.entries
            .where((entry) => entry.value.value == square.value)
            .map((entry) => entry.key)
            .toList();
        if (sameValueKeys.length > 1) {
          Key mergeKey = sameValueKeys.firstWhere((k) => k != key);
          setState(() {
            grid[mergeKey] = Square(grid[mergeKey]!.value + 1, mergeKey, grid[mergeKey]!.profitMultiplier, specialMultiplier);
            highestMergedValue.value = max(highestMergedValue.value, grid[mergeKey]!.value); // Update highestMergedValue
            print("lul");
            grid.remove(key);
          });
          didMerge = true;
          
          break;
        }
      }
    }
  } while (didMerge);
  
  saveGameData();
  print("saving game data mergeTiles()");
}
  void purchaseLevelTwo() {
    if (coins >= levelTwoCost.value.ceil()) {
      setState(() {
        coins -= levelTwoCost.value.ceil();
        Key emptyKey = getRandomEmptyKey();
        grid[emptyKey] = Square(2, emptyKey, profitMultiplier, specialMultiplier);  // use the global profitMultiplier
      });
      levelTwoCost.value *= 1.15; 
              if (autoMergeEnabled) {
          mergeTiles();
        }
    }
  }

void purchaseLevelThree() {
  if (coins >= levelThreeCost.value.ceil()) {
    setState(() {
      coins -= levelThreeCost.value.ceil();
      Key emptyKey = getRandomEmptyKey();
      grid[emptyKey] = Square(3, emptyKey, profitMultiplier, specialMultiplier);
    });
    levelThreeCost.value *= 1.15; 
            if (autoMergeEnabled) {
          mergeTiles();
        }
  }
}

void purchaseLevelFour() {
  if (coins >= levelFourCost.value.ceil()) {
    setState(() {
      coins -= levelFourCost.value.ceil();
      Key emptyKey = getRandomEmptyKey();
      grid[emptyKey] = Square(4, emptyKey, profitMultiplier, specialMultiplier);
    });
    levelFourCost.value *= 1.15; 
            if (autoMergeEnabled) {
          mergeTiles();
        }
  }
}

void purchaseLevelFive() {
  if (coins >= levelFiveCost.value.ceil()) {
    setState(() {
      coins -= levelFiveCost.value.ceil();
      Key emptyKey = getRandomEmptyKey();
      grid[emptyKey] = Square(5, emptyKey, profitMultiplier, specialMultiplier);
    });
    levelFiveCost.value *= 1.15; 
            if (autoMergeEnabled) {
          mergeTiles();
        }
  }
}

void purchaseLevelSix() {
  if (coins >= levelSixCost.value.ceil()) {
    setState(() {
      coins -= levelSixCost.value.ceil();
      Key emptyKey = getRandomEmptyKey();
      grid[emptyKey] = Square(6, emptyKey, profitMultiplier, specialMultiplier);
    });
    levelSixCost.value *= 1.15; 
            if (autoMergeEnabled) {
          mergeTiles();
        }
  }
}

void purchaseLevelSeven() {
  if (coins >= levelSevenCost.value.ceil()) {
    setState(() {
      coins -= levelSevenCost.value.ceil();
      Key emptyKey = getRandomEmptyKey();
      grid[emptyKey] = Square(7, emptyKey, profitMultiplier, specialMultiplier);
    });
    levelSevenCost.value *= 1.15; 
            if (autoMergeEnabled) {
          mergeTiles();
        }
  }
}
void saveGameData() {
  print("saving game data");
  if (_prefs != null) {
    _prefs!.setInt('coins', coins);
    _prefs!.setBool('canCollect', canCollect);
    _prefs!.setDouble('collectCooldown', collectCooldown);
    _prefs!.setDouble('remainingTime', remainingTime);
    _prefs!.setBool('autoCollectEnabled', autoCollectEnabled);
    _prefs!.setBool('autoMergeEnabled', autoMergeEnabled);
    _prefs!.setInt('highestValueReached', highestValueReached);
    _prefs!.setInt('profitMultiplier', profitMultiplier);
    _prefs!.setDouble('totalEarnings', totalEarnings);
    _prefs!.setInt('reincarnations', reincarnations);
    _prefs!.setInt('specialMultiplier', specialMultiplier);
    _prefs!.setInt('reincarnateCost', reincarnateCost);
    _prefs!.setBool('purchase3', purchase3);
    _prefs!.setDouble('placeSquareCost', placeSquareCost.value);
    _prefs!.setDouble('increaseTileValueCost', increaseTileValueCost.value);
    _prefs!.setDouble('speedUpCost', speedUpCost.value);
    _prefs!.setDouble('autoCollectCost', autoCollectCost.value);
    _prefs!.setDouble('autoMergeCost', autoMergeCost.value);

    // Save squares
    final squareData = grid.entries.map((entry) {
     final key = entry.key as ValueKey<Offset>;
     final square = entry.value;
  return {
    'keyRow': key.value.dx, 
    'keyCol': key.value.dy,
    'value': square.value,
    'profitMultiplier': square.profitMultiplier,
    'specialMultiplier': square.specialMultiplier,
  };
}).toList();
_prefs!.setStringList('squares', squareData.map((data) => jsonEncode(data)).toList());

  }
}

void loadGameData() {
  print("loading game data");
  if (_prefs != null) {
    setState(() {
      coins = _prefs!.getInt('coins') ?? coins;
      canCollect = _prefs!.getBool('canCollect') ?? canCollect;
      collectCooldown = _prefs!.getDouble('collectCooldown') ?? collectCooldown;
      remainingTime = _prefs!.getDouble('remainingTime') ?? remainingTime;
      autoCollectEnabled = _prefs!.getBool('autoCollectEnabled') ?? autoCollectEnabled;
      autoMergeEnabled = _prefs!.getBool('autoMergeEnabled') ?? autoMergeEnabled;
      highestValueReached = _prefs!.getInt('highestValueReached') ?? highestValueReached;
      profitMultiplier = _prefs!.getInt('profitMultiplier') ?? profitMultiplier;
      totalEarnings = _prefs!.getDouble('totalEarnings') ?? totalEarnings;
      reincarnations = _prefs!.getInt('reincarnations') ?? reincarnations;
      specialMultiplier = _prefs!.getInt('specialMultiplier') ?? specialMultiplier;
      reincarnateCost = _prefs!.getInt('reincarnateCost') ?? reincarnateCost;
      purchase3 = _prefs!.getBool('purchase3') ?? purchase3;
      placeSquareCost.value = _prefs!.getDouble('placeSquareCost') ?? placeSquareCost.value;
      increaseTileValueCost.value = _prefs!.getDouble('increaseTileValueCost') ?? increaseTileValueCost.value;
      speedUpCost.value = _prefs!.getDouble('speedUpCost') ?? speedUpCost.value;
      autoCollectCost.value = _prefs!.getDouble('autoCollectCost') ?? autoCollectCost.value;
      autoMergeCost.value = _prefs!.getDouble('autoMergeCost') ?? autoMergeCost.value;

      // Load squares
      final squareData = _prefs!.getStringList('squares') ?? [];
grid = squareData.fold<Map<Key, Square>>({}, (map, data) {
  final parsedData = jsonDecode(data);
  final key = ValueKey<Offset>(Offset(parsedData['keyRow'], parsedData['keyCol']));
  final value = parsedData['value'];
  final profitMultiplier = parsedData['profitMultiplier'];
  final specialMultiplier = parsedData['specialMultiplier'];
  map[key] = Square(value, key, profitMultiplier, specialMultiplier);
  return map;
});

    });
  }
}
@override
void initState() {
  super.initState();
  SharedPreferences.getInstance().then((prefs) {
    _prefs = prefs;
    loadGameData(); // Now this will only run after _prefs has been initialized.
  });
}


Future<void> _initPrefs() async {
  _prefs = await SharedPreferences.getInstance();
}



Widget buildSquare(Key key) {
  Square? square = grid[key];
  return DragTarget<Key>(
    builder: (context, candidateData, rejectedData) {
      return square != null
          ? Draggable<Key>(
              data: key,
              child: Container(
                child: Center(child: Image.asset('assets/sprite${square.value}.png')),
              ),
              feedback: Container(
                child: Center(child: Image.asset('assets/sprite${square.value}.png')),
              ),
            )
          : Container(); 
    },
    onWillAccept: (draggedKey) {
      return square == null || (square.value == grid[draggedKey]?.value);
    },
    onAccept: (draggedKey) {
      setState(() {
        if (draggedKey != key) { 
          if (square == null || (square.value == grid[draggedKey]?.value)) {
            if (square != null) {
              grid[key] = Square(square.value + 1, key, square.profitMultiplier, specialMultiplier);
            } else {
              grid[key] = grid[draggedKey]!;
            }
            grid.remove(draggedKey);
            if (autoMergeEnabled) {
              mergeTiles();
            }
          }
        } 
      });
    },
  );
}

  @override
  void dispose() {
    


    countdownTimer?.cancel();
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      // refresh coin amount button

      

  
  actions: [
    IconButton(
      // heart icon
      icon: Icon(Icons.favorite, color: Colors.red,),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SupportScreen()),
        );
      },
    ),
    IconButton(
      // your chosen icon for the 'Open Shop'
      icon: Icon(Icons.shopping_bag_outlined, color: Color.fromARGB(255, 230, 111, 0),),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 200,
              color: Colors.amber,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Shop Items'),
                                              ValueListenableBuilder<double>(
                valueListenable: placeSquareCost,
                builder: (context, value, child) => ElevatedButton(
                  onPressed: placeRandomSquare,
                  child: Text('Place Square (Cost: ${value.ceil()} coins)'),
                ),
              ),
             ValueListenableBuilder<double>(
  valueListenable: increaseTileValueCost,
  builder: (context, value, child) => ListTile(
    title: Text('Increase All Tile Profits (Increase: ${profitMultiplier * 100}%, Cost: ${value.ceil()} coins)'),
    trailing: IconButton(
      icon: const Icon(Icons.arrow_upward),
      onPressed: increaseTileValue,
    ),
  ),
),

autoCollectEnabled
  ? ListTile(
      title: Text('Auto Collect (Purchased)'),
      trailing: Icon(Icons.check),
    )
  : ValueListenableBuilder<double>(
      valueListenable: autoCollectCost,
      builder: (context, value, child) => ListTile(
        title: Text('Auto Collect (Cost: ${value.ceil()} coins)'),
        trailing: IconButton(
          icon: const Icon(Icons.autorenew),
          onPressed: autoCollect,
        ),
      ),
    ),
autoMergeEnabled
  ? ListTile(
      title: Text('Auto Merge (Purchased)'),
      trailing: Icon(Icons.check),
    )
  : ValueListenableBuilder<double>(
      valueListenable: autoMergeCost,
      builder: (context, value, child) => ListTile(
        title: Text('Auto Merge (Cost: ${value.ceil()} coins)'),
        trailing: IconButton(
          icon: const Icon(Icons.call_merge),
          onPressed: autoMerge,
        ),
      ),
    ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
        IconButton(
      // your chosen icon for the 'Open Shop'
      icon: Icon(Icons.crop_square_outlined, color: Color.fromARGB(255, 0, 134, 230),),
      onPressed: () {
        showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
                return Container(
                    height: 200, // increased the height
                    color: Colors.amber,
                    child: Center(
                        child: SingleChildScrollView(
                            child: ValueListenableBuilder<int>(
                                valueListenable: highestMergedValue,
                                builder: (context, value, child) => AdvancedTileShop(
                                    highestMergedValue: value,
                                    levelTwoCost: levelTwoCost,
                                    levelThreeCost: levelThreeCost,
                                    levelFourCost: levelFourCost,
                                    levelFiveCost: levelFiveCost,
                                    levelSixCost: levelSixCost,
                                    levelSevenCost: levelSevenCost,
                                    purchaseLevelTwo: purchaseLevelTwo,
                                    purchaseLevelThree: purchaseLevelThree,
                                    purchaseLevelFour: purchaseLevelFour,
                                    purchaseLevelFive: purchaseLevelFive,
                                    purchaseLevelSix: purchaseLevelSix,
                                    purchaseLevelSeven: purchaseLevelSeven,
                                ),
                            ),
                        ),
                    ),
                );
            },
        );
      },
        ),
            IconButton(
      // your chosen icon for the 'Open Shop'
      icon: Icon(Icons.shopping_cart_outlined, color: Color.fromARGB(255, 42, 230, 0),),
      onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 200,
                        color: Colors.amber,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('Trees Saved: ${getTreesSaved()} - Carbon Offset: ${getCarbonOffset()}kg - R:$reincarnations'),
                                const Text('Offset Shop '),
             ValueListenableBuilder<double>(
  valueListenable: increaseTileValueCost,
  builder: (context, value, child) => ListTile(
    title: Text('Watch Ad - (Earns \$0.1) + 200 Coins'),
    trailing: IconButton(
      icon: const Icon(Icons.video_camera_back),
      onPressed: watchAd,
    ),
  ),
),
ValueListenableBuilder<double>(
  valueListenable: speedUpCost,
  builder: (context, value, child) => ListTile(
    title: Text('2x Current Coins - (Cost \$1)'),
    trailing: IconButton(
      icon: Icon(Icons.keyboard_double_arrow_up),
      onPressed: makePurchase1,
    ),
  ),
),
  ValueListenableBuilder<double>(
      valueListenable: autoCollectCost,
      builder: (context, value, child) => ListTile(
        title: Text('4x Current Coins - (Cost \$3))'),
        trailing: IconButton(
          icon: const Icon(Icons.unfold_more_double),
          onPressed: makePurchase2,
        ),
      ),
    ),
purchase3
  ? ListTile(
      title: Text('Double Coins (Purchased)'),
      trailing: Icon(Icons.check),
    )
  : ValueListenableBuilder<double>(
      valueListenable: autoMergeCost,
      builder: (context, value, child) => ListTile(
        title: Text('Double Coins (Cost: \$5 coins)'),
        trailing: IconButton(
          icon: const Icon(Icons.trending_up),
          onPressed: makePurchase3,
        ),
      ),
    ),
                ],
              ),
            ),
          ),
        );
      },
    );
      },
            ),
                        IconButton(
      // your chosen icon for the 'Open Shop'
      icon: Icon(Icons.recycling_rounded, color: coins >= reincarnateCost ? Color.fromARGB(255, 167, 0, 227):Colors.grey),
      onPressed: () {
coins >= reincarnateCost ? reincarnate : null;
      },
                        ),
      IconButton(icon: Icon(Icons.add), onPressed: () {
        placeRandomSquare();
      }),
  ],
),
body: Flex(
  direction: Axis.vertical,
  children: [
    // Upadted UI on change of coins

    
    Text('Coins: ${Provider.of<CoinData>(context).coins}', style: TextStyle(fontSize: 20),),
    // Money Shop column on the left with a fixed flex factor
    Flexible(
      flex: 2,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centers the contents vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Centers the contents horizontally
          children: [
            // Add more in-app purchases as needed
          ],
        ),
      ),
    ),
    // Existing UI with a larger flex factor
    Flexible(
      flex: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centers the contents vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Centers the contents horizontally
        children: [
Expanded(
  child: Center(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 5,
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0), // Add padding to the grid
        itemCount: 16,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8, // Add vertical spacing
          crossAxisSpacing: 8, // Add horizontal spacing
        ),
        itemBuilder: (BuildContext context, _) {
          Key key = ValueKey<Offset>(Offset(_ / 4, _ % 4));
          return buildSquare(key);
        },
      ),
    ),
  ),
),
          
        ],
      ),
    ),
    
  ]
)
  );
}
void updateCoins() {
  setState(() {
    coins += 10;
  });
}

}



class SupportScreen extends StatelessWidget {
  // Function to launch the email app
  void _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support Us'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.withOpacity(0.6), Colors.blue],
              ),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: 300,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 145, color: Colors.red),
                        SizedBox(height: 20),
                        Text(
                          'We are a team of 4 creators who are passionate about creating amazing applications that can make a difference. Each of us brings a unique set of skills and experiences to the table, and together, we strive to push the boundaries of what is possible. We believe in the power of technology to transform lives and are committed to making a positive impact through our work. Your support helps us continue doing what we love and we truly appreciate it!',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.amber[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {},
                          child: Text('Buy a Coffee for the Creators'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {},
                          child: Text('Plant a Tree'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            _launchEmail('nepomuk@crhonek.com'); // Launch the email app when the button is clicked
                          },
                          child: Text('Other Support'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class AdvancedTileShop extends StatelessWidget {
  final ValueNotifier<double> levelTwoCost;
  final ValueNotifier<double> levelThreeCost;
  final ValueNotifier<double> levelFourCost;
  final ValueNotifier<double> levelFiveCost;
  final ValueNotifier<double> levelSixCost;
  final ValueNotifier<double> levelSevenCost;
  final VoidCallback purchaseLevelTwo;
  final VoidCallback purchaseLevelThree;
  final VoidCallback purchaseLevelFour;
  final VoidCallback purchaseLevelFive;
  final VoidCallback purchaseLevelSix;
  final VoidCallback purchaseLevelSeven;
  final int highestMergedValue;

  AdvancedTileShop({
    required this.levelTwoCost,
    required this.levelThreeCost,
    required this.levelFourCost,
    required this.levelFiveCost,
    required this.levelSixCost,
    required this.levelSevenCost,
    required this.purchaseLevelTwo,
    required this.purchaseLevelThree,
    required this.purchaseLevelFour,
    required this.purchaseLevelFive,
    required this.purchaseLevelSix,
    required this.purchaseLevelSeven,
    required this.highestMergedValue,
  });
  
  @override
Widget build(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      const Text('Square Shop'),
      highestMergedValue >= 5
        ? ValueListenableBuilder<double>(
            valueListenable: levelTwoCost,
            builder: (context, value, child) => ListTile(
              title: Text('Level 2 Square (Cost: ${value.ceil()} coins)'),
              trailing: IconButton(
                icon: const Icon(Icons.add_box),
                onPressed: purchaseLevelTwo,
              ),
            ),
          )
        : Container(),
      highestMergedValue >= 6
        ? ValueListenableBuilder<double>(
            valueListenable: levelThreeCost,
            builder: (context, value, child) => ListTile(
              title: Text('Level 3 Square (Cost: ${value.ceil()} coins)'),
              trailing: IconButton(
                icon: const Icon(Icons.add_box),
                onPressed: purchaseLevelThree,
              ),
            ),
          )
        : Container(),
      highestMergedValue >= 7
        ? ValueListenableBuilder<double>(
            valueListenable: levelFourCost,
            builder: (context, value, child) => ListTile(
              title: Text('Level 4 Square (Cost: ${value.ceil()} coins)'),
              trailing: IconButton(
                icon: const Icon(Icons.add_box),
                onPressed: purchaseLevelFour,
              ),
            ),
          )
        : Container(),
      highestMergedValue >= 8
        ? ValueListenableBuilder<double>(
            valueListenable: levelFiveCost,
            builder: (context, value, child) => ListTile(
              title: Text('Level 5 Square (Cost: ${value.ceil()} coins)'),
              trailing: IconButton(
                icon: const Icon(Icons.add_box),
                onPressed: purchaseLevelFive,
              ),
            ),
          )
        : Container(),
              highestMergedValue >= 9
        ? ValueListenableBuilder<double>(
            valueListenable: levelSixCost,
            builder: (context, value, child) => ListTile(
              title: Text('Level 6 Square (Cost: ${value.ceil()} coins)'),
              trailing: IconButton(
                icon: const Icon(Icons.add_box),
                onPressed: purchaseLevelSix,
              ),
            ),
          )
        : Container(),
                      highestMergedValue >= 10
        ? ValueListenableBuilder<double>(
            valueListenable: levelSevenCost,
            builder: (context, value, child) => ListTile(
              title: Text('Level 7 Square (Cost: ${value.ceil()} coins)'),
              trailing: IconButton(
                icon: const Icon(Icons.add_box),
                onPressed: purchaseLevelSeven,
              ),
            ),
          )
        : Container(),
    ],
  );
}
}































//wtfman








class dsd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     debugShowCheckedModeBanner: false,
      home: QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String question = '';
  List<int> options = [];
  late int correctAnswerIndex;
  int remainingSeconds = 0;
  bool showQuestion = true;
  int? selectedAnswerIndex;
  double size = 1.0;
  double opacity = 1.0;
  bool isAnswered = false;
  int correctAnswerCount = 0; // Counter for correct answers
  int maxNumber = 10; // Maximum number for the random numbers in the question

  @override
  void initState() {
    
    super.initState();
    generateQuestion();
  }

  void generateQuestion() {
    int a = Random().nextInt(maxNumber) + 1;
    int b = Random().nextInt(maxNumber) + 1;
    question = '$a + $b';
    Parser p = Parser();
    Expression exp = p.parse(question);
    ContextModel cm = ContextModel();
    double correctAnswer = exp.evaluate(EvaluationType.REAL, cm);

    Set<int> optionsSet = {correctAnswer.toInt()};
    while (optionsSet.length < 4) {
      optionsSet.add(Random().nextInt(2 * maxNumber) + 1);
    }
    options = optionsSet.toList();
    options.shuffle();
    correctAnswerIndex = options.indexOf(correctAnswer.toInt());
  }

  void answerQuestion(int selectedAnswerIndex) {
    setState(() {
      this.selectedAnswerIndex = selectedAnswerIndex;
      size = 0.0;
      opacity = 0.0;
      isAnswered = true;
    });

    if (selectedAnswerIndex != correctAnswerIndex) {
      HapticFeedback.heavyImpact(); // Error feedback
      Provider.of<CoinData>(context, listen: false).coins -= 5;
    } else {
      Provider.of<CoinData>(context, listen: false).coins += 10;
      HapticFeedback.lightImpact(); // Success feedback
      correctAnswerCount++; // Increase the counter for correct answers
      if (correctAnswerCount % 10 == 0) { // If the counter reaches 10
        maxNumber += 10; // Increase the range of the random numbers
      }
    }

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        this.selectedAnswerIndex = null;
        size = 1.0;
        opacity = 1.0;
        isAnswered = false;
        generateQuestion();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                question,
                style: TextStyle(fontSize: 24, color: Colors.black), // Changed color to black
              ),
              SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                children: options.map((option) {
                  int index = options.indexOf(option);
                  if (isAnswered && index != selectedAnswerIndex && index != correctAnswerIndex) {
                    print("correct");
                    



                    streamController.sink.add(10);
                    // place random squares
                    return AnimatedOpacity(
                      opacity: opacity,
                      duration: Duration(seconds: 1),
                      child: Transform.scale(
                        scale: size,
                        child: Container(),
                      ),
                    );
                  }
                  return Container(
                    margin: EdgeInsets.all(10),
                    child: GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        HapticFeedback.vibrate(); // Short vibration when the button is pressed
                      },
                      onTap: () {
                        answerQuestion(index);
                      },
                      child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        curve: Curves.ease,
                        decoration: BoxDecoration(
                          color: isAnswered
                              ? index == correctAnswerIndex
                                  ? Colors.green
                                  : selectedAnswerIndex == index
                                      ? Colors.red
                                      : Colors.white
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: Text(
                            '$option',
                            style: TextStyle(
                              fontSize: selectedAnswerIndex == index
                                  ? 30
                                  : 20,
                              color: Colors.blueGrey[900],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
