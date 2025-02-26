// ignore_for_file: prefer_const_constructors, duplicate_ignore

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ai_radio/model/radio.dart';
import 'package:flutter_ai_radio/utils/ai_util.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => __HomePageState();
}

class __HomePageState extends State<HomePage> {
  late List<MyRadio> radios;
  late MyRadio _selectedRadio;
  Color? _selectedColor;
  bool _isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchRadios();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    // ignore: avoid_print
    print(radios);
    setState(() {});
  }

  _playMusic(String url) {
    _audioPlayer.play(UrlSource(url));
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: prefer_const_constructors
      drawer: Drawer(),
      body: Stack(
        // ignore: sort_child_properties_last
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(colors: [
                  AIColors.primaryColor2,
                  _selectedColor ?? AIColors.primaryColor1,
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              )
              .make(),
          AppBar(
            title: "AI Radio".text.xl4.bold.white.make().shimmer(
                primaryColor: Vx.purple300, secondaryColor: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ).h(100).p16(),
          VxSwiper.builder(
            itemCount: radios.length,
            aspectRatio: 1.0,
            enlargeCenterPage: true,
            onPageChanged: (index) {
              final colorHex = radios[index].color;
              _selectedColor = Color(int.tryParse(colorHex)!.toInt());
              setState(() {});
            },
            itemBuilder: (context, index) {
              final rad = radios[index];

              return VxBox(
                      child: ZStack(
                [
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: VxBox(
                      child: rad.category.text.uppercase.white.make().p16(),
                    )
                        .height(45)
                        .black
                        .alignCenter
                        .withRounded(value: 10.0)
                        .make(),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: VStack(
                      [
                        rad.name.text.xl3.white.bold.make(),
                        5.heightBox,
                        rad.tagline.text.sm.white.semiBold.make()
                      ],
                      crossAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: VStack(
                      [
                        Icon(
                          CupertinoIcons.play_circle,
                          color: Colors.white,
                        ),
                        "Double tap to play".text.gray300.make(),
                        10.heightBox,
                      ],
                      crossAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                ],
              ))
                  .clip(Clip.antiAlias)
                  .bgImage(
                    DecorationImage(
                        image: NetworkImage(rad.image),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3), BlendMode.darken)),
                  )
                  .border(color: Colors.black, width: 5.0)
                  .withRounded(value: 60.0)
                  .make()
                  .onInkDoubleTap(() {
                _playMusic(rad.url);
              }).p16();
            },
          ).centered(),
          Align(
            alignment: Alignment.bottomCenter,
            child: VStack(
              [
                if (_isPlaying)
                  "Playing Now - ${_selectedRadio.name} FM"
                      .text
                      .white
                      .makeCentered(),
                Icon(
                        _isPlaying
                            ? CupertinoIcons.stop_circle
                            : CupertinoIcons.play_circle,
                        color: Colors.white,
                        size: 50.0)
                    .onInkTap(
                  () {
                    if (_isPlaying) {
                      _audioPlayer.stop();
                    } else {
                      _playMusic(_selectedRadio.url);
                    }
                  },
                ).centered(),
              ],
            ),
          ).pOnly(bottom: context.percentHeight * 12)
        ],
        fit: StackFit.expand,
      ),
    );
  }
}
