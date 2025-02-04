import 'dart:io';

import 'package:brick_converter/common_libs.dart';
import 'package:brick_lib/model/part_group.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

const ywSearchUrl = "https://www.yourwobb.com/search?q=";
const bricklinkUploadUrl = "https://www.bricklink.com/v2/wanted/upload.page?utm_content=subnav";

class AppLogic {
  final Logger log = getLogger("AppLogic");

  /// Indicates to the rest of the app that bootstrap has not completed.
  /// The router will use this to prevent redirects while bootstrapping.
  bool isBootstrapComplete = false;

  List<BrickPart> currentParts = [];
  List<BrickPart> missingParts = [];
  List<BrickPart> orderedParts = [];
  final Map<String, PartGroup> groupedParts = {};

  int get partsMappedCount => currentParts.fold(0, (previousValue, element) => previousValue + element.quantity);

  int get partsMissingCount => missingParts.fold(0, (previousValue, element) => previousValue + element.quantity);

  int get partsOrderedCount => orderedParts.fold(0, (previousValue, element) => previousValue + element.quantity);
  String mocName = "";

  bool get csvLoaded => groupedParts.isNotEmpty;

  final ValueNotifier<List<PartGroup>> groups = ValueNotifier<List<PartGroup>>([]);

  Future<void> bootstrap() async {
    await brickConverterLogic.load();

    isBootstrapComplete = true;

    appRouter.go(ScreenPaths.home);
  }

  reset() {
    currentParts.clear();
    missingParts.clear();
    orderedParts.clear();
    groupedParts.clear();
    groups.value = [];
  }

  Future<void> loadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv'], allowMultiple: true);
    if (result != null) {
      for (var i = 0; i < result.files.length; ++i) {
        final fileRef = result.files[i];

        File file = File(fileRef.path!);

        log.i("Loading parts from ${fileRef.name}");

        // final filenameWithoutExtension =
        //     result.files.single.name.split(".csv")[0];
        // mocName = filenameWithoutExtension.replaceFirst("rebrickable_parts_", "");

        String content = await file.readAsString();
        List<String> csvLines = content.split("\r\n");
        final List<BrickPart> parts = await brickConverterLogic.parseParts(csvLines);

        for (var i = 0; i < parts.length; ++i) {
          final part = parts[i];
          // if (part.goBrickPart?.isNotEmpty == true) {
          currentParts.add(part);
          if (groupedParts.containsKey(part.part) == false) {
            groupedParts[part.part!] = PartGroup();
          }
          groupedParts[part.part]?.addPart(part);
          if (part.goBrickPart == null || part.goBrickPart?.isEmpty == true) {
            missingParts.add(part);
          }
        }

        updateGroups();
      }
    } else {
      // User canceled the picker
    }
  }

  void updateGroups() {
    groups.value = groupedParts.values.toList();
  }

  void openPart(BrickPart part) async {
    final url = "$ywSearchUrl${part.goBrickPart}";

    launchUrlString(url, mode: LaunchMode.externalApplication);
  }

  void orderFromBricklink(PartGroup group, BrickPart part) {
    missingParts.add(part);
    group.parts.remove(part);
  }

  void removeFromBricklink(BrickPart part) {
    missingParts.remove(part);
    final group = groupedParts[part.part];
    group?.addPart(part);
  }

  void openBricklink() async {
    final xml = bricklinkLogic.generateXml(missingParts);
    await Clipboard.setData(ClipboardData(text: xml));
    final Uri url = Uri.parse(bricklinkUploadUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void orderPart(PartGroup group, BrickPart part) {
    orderedParts.add(part);
    group.parts.remove(part);

    if (group.parts.isEmpty) {
      groupedParts.remove(part.part);
      updateGroups();
    }
  }

  void deletePart(PartGroup group, BrickPart part) {
    group.parts.remove(part);

    if (group.parts.isEmpty) {
      groupedParts.remove(part.part);
      updateGroups();
    }
  }

  void removeFromOrdered(BrickPart part) {
    orderedParts.remove(part);
    final group = groupedParts[part.part];
    group?.addPart(part);
  }

  Future<void> saveOrdered() async {
    final export = brickConverterLogic.exportParts(orderedParts);
    final f = DateFormat('yyyy-MM-dd');
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: '${f.format(DateTime.now())}-export-parts-ordered.csv',
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(export.join("\r\n"));
    }
  }
}
