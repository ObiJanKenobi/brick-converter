import 'package:brick_converter/ui/back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';

import '../common_libs.dart';

class BricklinkScreen extends StatefulWidget {
  const BricklinkScreen({super.key});

  @override
  State<StatefulWidget> createState() => BricklinkScreenState();
}

class BricklinkScreenState extends State<BricklinkScreen> {
  BricklinkScreenState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final extend = size.width > 500 ? size.width / 2 : size.width;
    final aspect = size.width > 500 ? 6.0 : 4.0;

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          snap: false,
          floating: false,
          expandedHeight: 100.0,
          elevation: 10,
          leading: const MyBackButton(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              height: 4,
              decoration: const BoxDecoration(color: Color(0xFFF2542D)
                  // gradient: LinearGradient(
                  //   colors: <Color>[Color(0xFFF2542D), Colors.red],
                  // ),
                  ),
            ),
          ),
          // backgroundColor: const Color(0xFF562C2C),
          flexibleSpace: FlexibleSpaceBar(
            title: Text("Teile: ${appLogic.partsMissingCount}"),
            background: Align(
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton.icon(
                    onPressed: _openShop,
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SvgPicture.asset("assets/bl_logo.svg"),
                    ),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Kaufen"),
                    ),
                  )),
              alignment: Alignment.centerRight,
            ),
          ),
        ),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: extend,
            mainAxisSpacing: 6.0,
            crossAxisSpacing: 6.0,
            childAspectRatio: aspect,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return _buildPartListItem(appLogic.missingParts[index]);
            },
            childCount: appLogic.missingParts.length,
          ),
        ),
      ]),
    );
  }

  Widget _buildPartListItem(BrickPart part) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Slidable(
          // Specify a key if the Slidable is dismissible.
          key: ValueKey(part.color),

          // The start action pane is the one at the left or the top side.
          startActionPane: ActionPane(
            // A motion is a widget used to control how the pane animates.
            motion: const DrawerMotion(),

            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(onDismissed: () {}),

            // All actions are defined in the children parameter.
            children: [
              // A SlidableAction can have an icon and/or a label.
              SlidableAction(
                onPressed: (BuildContext context) {
                  handleDelete(part);
                },
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
              // SlidableAction(
              //   onPressed: doNothing,
              //   backgroundColor: Color(0xFF21B7CA),
              //   foregroundColor: Colors.white,
              //   icon: Icons.share,
              //   label: 'Share',
              // ),
            ],
          ),

          // The child of the Slidable is what the user sees when the
          // component is not dragged.
          child: ListTile(
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: HexColor.fromHex(part.rgb!),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      foregroundImage: CachedNetworkImageProvider(part.details?.imgUrl ?? ""),
                    ),
                  ),
                ),
              ),
              title: Text("${part.name} (${part.colorName})"),
              subtitle: Text(
                "Anzahl: ${part.quantity}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ))),
    );
  }

  void _openShop() {
    appLogic.openBricklink();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("XML in Zwischenablage kopiert")));
  }

  void handleDelete(BrickPart part) {
    appLogic.removeFromBricklink(part);
  }
}
