import 'package:brick_converter/model/part_group.dart';
import 'package:brick_converter/router.dart';
import 'package:brick_converter/ui/group_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartGroupCard extends StatefulWidget {
  final PartGroup group;

  const PartGroupCard(this.group, {super.key});

  @override
  State<StatefulWidget> createState() => PartGroupCardState();
}

class PartGroupCardState extends State<PartGroupCard> {
  PartGroupCardState();

  PartGroup get group => widget.group;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).colorScheme.secondary,
        elevation: 3,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.go(ScreenPaths.partGroup(group.partNum), extra: group);
            },
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 70,
                    height: 70,
                    alignment: Alignment.center,
                    child: Hero(
                        tag: "part-img-${group.partNum}",
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: group.noMapping ? const Color(0xFF562C2C) : const Color(0xFF0E9594),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            foregroundImage: CachedNetworkImageProvider(group.imgUrl),
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Text("Gesamtanzahl: ${group.quantity}",
                          style: Theme.of(context).textTheme.overline?.copyWith(color: Colors.grey.shade300)),
                      Text(
                        group.partName,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade300),
                      ),
                    ]),
                  )
                ]),
              ),
              const Spacer(),
              SizedBox(height: 40, child: GroupColors(group)),
              const SizedBox(
                height: 20,
              )
            ])));
  }
}
