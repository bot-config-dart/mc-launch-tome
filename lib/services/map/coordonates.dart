import 'package:dart_autogui/dart_autogui.dart';
import 'package:gmail/services/entities/utils.dart';

import '../../fruitz.dart';

class Coord {
  final String name;
  final int x;
  final int y;
  final String? color;
  final String type;
  bool needColor;
  int tried = 0;
  final String? keystroke;
  final int? toX;
  final int? toY;
  final Fruitz fruitz;

  Coord({required this.name, required this.x, required this.y, required this.type, this.color, required this.needColor, this.keystroke, this.toX, this.toY, required this.fruitz});

  Future<void> click() async {
    print("Click: $name coords = x: $x, y: $y");

    if (!needColor) {
      await Mouse.moveTo(x: x, y: y);
      await Future.delayed(Duration(milliseconds: 500));
      await Mouse.click(x: x, y: y);
      return;
    }


    await waitColorWithTries(60, () async {
      await Mouse.moveTo(x: x, y: y);
      await Future.delayed(Duration(milliseconds: 500));
      await Mouse.click(x: x, y: y);
    });
  }

  Future<void> drag() async {
    print("Drag: $name coords = x: $x, y: $y");
    print("Drag: $name coords = toX: $toX, toY: $toY");
    await Mouse.moveTo(x: x, y: y);
    await Future.delayed(Duration(milliseconds: 500));
    await Mouse.dragTo(x: x, y: y, toX: toX!, toY: toY!, tween: MouseTween.linear);
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> doubleClick() async {
    print("Double click: $name coords = x: $x, y: $y");

    if (!needColor) {
      await Mouse.doubleClick(x: x, y: y);
      return;
    }

    await waitColorWithTries(40, () async {
      await Mouse.doubleClick(x: x, y: y);
    });
  }

  Future<void> moove() async {
    await Mouse.moveTo(x: x, y: y);
  }

  Future<void> write(String text, {int interval = 0, bool enterKey = true, bool click = true}) async {
    if (!needColor) {
      await Mouse.moveTo(x: x, y: y);
      if (click) {
        await Mouse.click(x: x, y: y);
      }
      await Keyboard.typeWord(text, interval: interval);
      if (enterKey) {
        await Keyboard.hotKey(["enter"]);
      }
      return;
    }

    await waitColorWithTries(40, () async {
      await Mouse.moveTo(x: x, y: y);
      if (click) {
        await Mouse.click(x: x, y: y);
      }
      await Keyboard.typeWord(text, interval: interval);
      if (enterKey) {
        await Keyboard.hotKey(["enter"]);
      }
    });
  }

  Future<void> keyboard() async {
    if (!needColor) {
      await Mouse.moveTo(x: x, y: y);
      await Keyboard.hotKey(keystroke!.split("+"));
      return;
    }

    await waitColorWithTries(40, () async {
      await Mouse.moveTo(x: x, y: y);
      await Keyboard.hotKey(keystroke!.split("+"));
    });
  }

  Future<bool> verifyColor() async {
    MouseColor color = await Mouse.getColorAt(x, y);
    print("${color.toHex()}, need: ${this.color} = $name, tries = $tried");
    return color.toHex() == this.color;
  }

  Future<void> waitColorWithTries(int maxTries, Future<void> Function() function) async {
    if (tried > maxTries) {
      print("Tried $maxTries times, giving up");
      if (name == "birth_day") {
        print("BANNED NUMBER: ${fruitz.activePhone.number}, order id: ${fruitz.activePhone.orderId}");
        await Utils.send("@everyone BANNED NUMBER: ${fruitz.activePhone.number}, order id: ${fruitz.activePhone.orderId}");
      }
      return await fruitz.reset("Tried $maxTries times, giving up, on coord $name");
    }

    if (await verifyColor()) {
      tried = 0;
      await function();
    } else {
      tried++;
      await Future.delayed(Duration(milliseconds: 500));
      await waitColorWithTries(maxTries, function);
    }
  }

  Future<void> waitColor() async {
    await waitColorWithTries(100, () async {});
  }

  void reset() {
    tried = 0;
  }
}
