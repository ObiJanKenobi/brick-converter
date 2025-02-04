import 'dart:io';

import 'package:brick_converter/ui/part_group_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:brick_converter/common_libs.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class AddFileScreen extends StatefulWidget {
  AddFileScreen();

  @override
  State<StatefulWidget> createState() => AddFileScreenState();
}

class AddFileScreenState extends State<AddFileScreen> {
  AddFileScreenState();

  @override
  void initState() {
    super.initState();
  }

  bool _loading = false;
  bool _fileLoaded = false;

  void _loadFile() async {
    setState(() {
      _loading = true;
    });
    await appLogic.loadFile();

    setState(() {
      _loading = false;
      _fileLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final factor = size.width % 350;

    final double maxCardWidth = 350 + factor;
    print("Width: ${size.width} | Cardw: $maxCardWidth");

    return Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 60.0,
            elevation: 10,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                height: 4,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary // Color(0xFFF2542D)
                    // gradient: LinearGradient(
                    //   colors: <Color>[Color(0xFFF2542D), Colors.red],
                    // ),
                    ),
              ),
            ),
            // backgroundColor: const Color(0xFF562C2C),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                  "Teile: ${appLogic.partsMappedCount ?? '-'} | Fehlend: ${appLogic.partsMissingCount ?? '-'} | Bestellt: ${appLogic.partsOrderedCount ?? '-'}"),
              // background: Align(
              //   child: Padding(
              //     padding: const EdgeInsets.all(20.0),
              //     child: SvgPicture.asset(
              //       "assets/fpe.svg",
              //       color: Colors.white,
              //     ),
              //   ),
              //   alignment: Alignment.centerRight,
              // ),
            ),
          ),
          ValueListenableBuilder<List<PartGroup>>(
            builder: (BuildContext context, List<PartGroup> value, Widget? child) {
              if (_loading) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              final List<PartGroup> ordered = [...value];
              ordered.sort((a, b) {
                if (a.quantity > b.quantity) {
                  return -1;
                } else if (b.quantity > a.quantity) {
                  return 1;
                }

                return 0;
              });
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCardWidth,
                  mainAxisSpacing: 6.0,
                  crossAxisSpacing: 6.0,
                  childAspectRatio: 2.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return PartGroupCard(ordered[index]);
                  },
                  childCount: value.length,
                ),
              );
            },
            valueListenable: appLogic.groups,
            child: const SliverToBoxAdapter(child: Center(child: Text("No CSV loaded"))),
          )
        ]),
        floatingActionButton:
            SpeedDial(icon: Icons.menu, foregroundColor: Colors.white, backgroundColor: Theme.of(context).colorScheme.secondary, children: [
          SpeedDialChild(
            child: const Icon(Icons.add, color: Colors.white),
            label: 'Load CSV',
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onTap: () {
              _loadFile();
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.shopping_basket, color: Colors.white),
            label: 'Ordered',
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onTap: () {
              context.go(ScreenPaths.ordered);
            },
          ),
          SpeedDialChild(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset("assets/bl_logo.svg"),
            ),
            label: 'Bricklink',
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onTap: () {
              context.go(ScreenPaths.bricklink);
            },
          ),
        ])
        // FloatingActionButton(
        //   backgroundColor: Theme.of(context).colorScheme.secondary,
        //   onPressed: _loadFile,
        //   tooltip: 'Load CSV',
        //   child: const Icon(Icons.add),
        // ), // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
