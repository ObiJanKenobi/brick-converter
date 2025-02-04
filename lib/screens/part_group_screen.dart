import 'package:brick_converter/common_libs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PartGroupScreen extends StatefulWidget {
  final PartGroup group;

  const PartGroupScreen(this.group, {super.key});

  @override
  State<StatefulWidget> createState() => PartGroupScreenState();
}

class PartGroupScreenState extends State<PartGroupScreen> {
  PartGroupScreenState();

  PartGroup get group => widget.group;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final extend = size.width > 500 ? size.width / 2 : size.width;
    final aspect = size.width > 500 ? 6.0 : 4.0;

    final sorted = <BrickPart>[];
    sorted.addAll(group.parts);
    sorted.sort((a, b) {
      if (a.quantity > b.quantity) {
        return -1;
      } else if (b.quantity > a.quantity) {
        return 1;
      }

      return 0;
    });

    return Stack(children: [
      Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Row(children: [
            Hero(
                tag: "part-img-${group.partNum}",
                child: CircleAvatar(
                    radius: 50,
                    backgroundColor: group.noMapping ? const Color(0xFF562C2C) : const Color(0xFF0E9594),
                    child: group.imgUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 46,
                            backgroundColor: Colors.white,
                            foregroundImage: CachedNetworkImageProvider(group.imgUrl),
                          )
                        : CircleAvatar(radius: 46, backgroundColor: Colors.white))),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text("Gesamtanzahl: ${group.quantity}", style: Theme.of(context).textTheme.headlineMedium),
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: group.partNum));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Teilenummer in Zwischenablage kopiert")));
                  },
                  child: Text(
                    group.partNum,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ]),
            ),
            IconButton(
              onPressed: _openShop,
              icon: const Icon(Icons.add_shopping_cart),
              iconSize: 48,
            ),
          ])),
      group.parts.isNotEmpty
          ? Positioned(
              top: 150,
              left: 10,
              right: 10,
              bottom: 0,
              child: CustomScrollView(
                slivers: [
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: extend,
                      mainAxisSpacing: 6.0,
                      crossAxisSpacing: 6.0,
                      childAspectRatio: aspect,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return _buildPartListItem(sorted[index]);
                      },
                      childCount: group.parts.length,
                    ),
                  )
                ],
              )
              // SingleChildScrollView(
              //   child: Column(children: group.parts.map((e) => _buildPartListItem(e)).toList()),
              // ),
              )
          : const Center(child: Text("No Parts"))
    ]);
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
                backgroundColor: Color(0xFFFE4A49),
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

          // The end action pane is the one at the right or the bottom side.
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                // An action can be bigger than the others.
                flex: 2,
                onPressed: (BuildContext context) {
                  handleOrdered(part);
                },
                backgroundColor: Color(0xFF7BC043),
                foregroundColor: Colors.white,
                icon: Icons.archive,
                label: 'Ordered',
              ),
              SlidableAction(
                onPressed: (BuildContext context) {
                  handleBricklink(part);
                },
                backgroundColor: Color(0xFF0392CF),
                foregroundColor: Colors.white,
                icon: Icons.save,
                label: 'Bricklink',
              ),
            ],
          ),

          // The child of the Slidable is what the user sees when the
          // component is not dragged.
          child: ListTile(
              leading: AspectRatio(
                aspectRatio: 1,
                child: ColoredBox(
                  color: HexColor.fromHex(part.rgb!),
                ),
              ),
              title: Text("${part.colorName} (${part.gobricksColor})"),
              subtitle: Text(
                "Anzahl: ${part.quantity}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ))),
    );
  }

  doNothing(BuildContext context) {}

  void _openShop() {
    appLogic.openPart(group.parts.first);
  }

  void handleBricklink(BrickPart part) {
    appLogic.orderFromBricklink(group, part);
    setState(() {});
  }

  void handleOrdered(BrickPart part) {
    appLogic.orderPart(group, part);
    setState(() {});
  }

  void handleDelete(BrickPart part) {
    appLogic.deletePart(group, part);
    setState(() {});
  }
}
