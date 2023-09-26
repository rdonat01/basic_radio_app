// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, deprecated_member_use

import 'dart:developer';

import 'package:animated_svg/animated_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:radio_app/models/Station.dart';
import 'package:radio_app/utils/utils.dart';

class RadioHome extends StatefulWidget {
  const RadioHome({super.key});

  @override
  _RadioHomeState createState() => _RadioHomeState();
}

class _RadioHomeState extends State<RadioHome> {
  // VARIABLES

  // Current index of the radio station
  int _currentIndex = 0;
  // Default colors for background and text
  Color backgroundColor = const Color.fromARGB(255, 255, 255, 255);
  Color textColor = Colors.white;

  // Duration for background color animation
  Duration duration = const Duration(milliseconds: 300);

  // List of radio stations
  // Note: The 'status' field is not being used in this code
  // Note 2: These data can be replaced with an API to enhance the experience.
  List<Station> radioStations = [
    Station(
        name: "RAC 1",
        url:
            "https://playerservices.streamtheworld.com/api/livestream-redirect/RAC_1.mp3",
        image: "assets/images/rac1.png",
        status: 0,
        frequency: "87.7"),
    Station(
        name: "esRadio",
        url:
            "https://libertaddigital-radio-live1.flumotion.com/libertaddigital/ld-live1-low.mp3",
        image: "assets/images/esradio.png",
        status: 0,
        frequency: "99.1"),
    Station(
        name: "LOCA FM",
        url: "https://s3.we4stream.com:2020/stream/locafm",
        image: "assets/images/locafm.png",
        status: 0,
        frequency: "90.5"),
    Station(
        name: "Cadena Cope",
        url: "https://flucast-b02-02.flumotion.com/cope/net1.mp3",
        image: "assets/images/cope.png",
        status: 0,
        frequency: "99.0"),
    Station(
        name: "Costa Del Mar",
        url: "https://radio4.cdm-radio.com:18020/stream-mp3-Chill",
        image: "assets/images/costadelmar.png",
        status: 0,
        frequency: "89.5"),
  ]; // (same list as before)

  // Audio player variables
  final player = AudioPlayer();
  bool isPlaying = false; // Whether the radio is currently playing or not
  double volume = 0.5; // Current volume level

  // SVG controllers for animations
  late final SvgController controllerPlayPause;

  @override
  void initState() {
    super.initState();

    // Initialize the SVG controllers
    controllerPlayPause = AnimatedSvgController();

    // Initialize audio player
    initAudio();

    // Remove the native splash screen
    FlutterNativeSplash.remove();

    // Update background color based on the current station's image
    _updateBackgroundColor(radioStations[_currentIndex].image);
  }

  @override
  void dispose() {
    // Dispose the SVG controllers when the widget is removed from the tree
    controllerPlayPause.dispose();
    super.dispose();
  }

  // Method to initialize the audio settings
  void initAudio() async {
    await player.setVolume(volume);
    await player.pause();
  }

  // Update the background color based on the dominant color in the provided image
  _updateBackgroundColor(String imagePath) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      AssetImage(imagePath),
      filters: const <PaletteFilter>[avoidRedBlackWhitePaletteFilter],
    );

    setState(() {
      backgroundColor =
          paletteGenerator.dominantColor?.color ?? Colors.blueAccent;
      textColor =
          Utils.isColorLight(backgroundColor) ? Colors.black : Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: duration,
        color: backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Carousel for the radio stations
              CarouselSlider(
                options: CarouselOptions(
                  height: 425,
                  viewportFraction: 0.9,
                  aspectRatio: 16 / 9,
                  enlargeCenterPage: true,
                  // Handle page changes
                  onPageChanged: (index, reason) {
                    if (isPlaying) {
                      player.stop(); // Stop the radio when the station changes
                      isPlaying = false;
                    }

                    player.setUrl(radioStations[_currentIndex].url);
                    setState(() {
                      _currentIndex = index;
                      // Update background color based on the new station's image
                      _updateBackgroundColor(
                          radioStations[_currentIndex].image);
                    });
                  },
                ),
                items: radioStations.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Column(
                        children: [
                          // Radio station name
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // Radio station image
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 200, // Adjust height as needed
                            margin: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(item.image),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // Play/Pause button
                          GestureDetector(
                            onTap: () {
                              if (isPlaying) {
                                isPlaying = false;
                                player.pause();
                              } else {
                                isPlaying = true;
                                player.play();
                              }
                              setState(() {});
                            },
                            child: SvgPicture.asset(
                              isPlaying
                                  ? 'assets/svgs/player-pause.svg'
                                  : 'assets/svgs/player-play.svg',
                              color: textColor,
                              width: 65,
                              height: 65,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // Volume control slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                volume == 0
                                    ? Icons.volume_mute
                                    : volume < 0.5
                                        ? Icons.volume_down
                                        : Icons.volume_up,
                                color: textColor,
                                size: 30.0,
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 2.0,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 11.0),
                                  ),
                                  child: Slider(
                                    value: volume,
                                    onChanged: (newVolume) {
                                      setState(() {
                                        volume = newVolume;
                                        player.setVolume(volume);
                                      });
                                    },
                                    min: 0.0,
                                    max: 1.0,
                                    activeColor: textColor,
                                    inactiveColor: textColor.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
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
