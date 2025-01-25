import 'package:flutter/material.dart';
import '../Helper/Color.dart';

Future<void> showOverlay(
  String msg,
  BuildContext context,
) async {
  final OverlayState overlayState = Overlay.of(context);
  OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        bottom: 0,
        child: Material(
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: fontColor,
                    fontSize: 14,
                    fontFamily: 'ubuntu',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  overlayState.insert(overlayEntry);
  await Future.delayed(const Duration(seconds: 2)).then(
    (value) {
      overlayEntry.remove();
    },
  );
}
