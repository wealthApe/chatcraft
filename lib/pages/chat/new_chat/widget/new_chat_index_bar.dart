import 'package:flutter/material.dart';
import 'package:flutter_chat_craft/res/styles.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class NewChatIndexBar extends StatefulWidget {
  final GlobalKey parentKey;

  final List<String> symbols;

  final void Function(
    int index,
    Offset cursorOffset,
  )? onSelectionUpdate;

  final void Function()? onSelectionEnd;

  const NewChatIndexBar({
    Key? key,
    required this.parentKey,
    required this.symbols,
    this.onSelectionUpdate,
    this.onSelectionEnd,
  }) : super(key: key);

  @override
  State<NewChatIndexBar> createState() => _NewChatIndexBarState();
}

class _NewChatIndexBarState extends State<NewChatIndexBar> {
  ListObserverController observerController = ListObserverController();

  double observeOffset = 0;

  ValueNotifier<int> selectedIndex = ValueNotifier(-1);

  @override
  Widget build(BuildContext context) {
    Widget resultWidget = ListViewObserver(
      controller: observerController,
      dynamicLeadingOffset: () => observeOffset,
      child: _buildListView(),
    );
    resultWidget = GestureDetector(
      onVerticalDragUpdate: _onGestureHandler,
      onVerticalDragDown: _onGestureHandler,
      onVerticalDragCancel: _onGestureEnd,
      onVerticalDragEnd: _onGestureEnd,
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildListView() {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (BuildContext context, int value, Widget? child) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final isSelected = value == index;
            Widget resultWidget = Text(
              widget.symbols[index],
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
            resultWidget = Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? PageStyle.chatColor : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: resultWidget,
            );
            resultWidget = Align(
              alignment: Alignment.centerLeft,
              child: resultWidget,
            );
            return resultWidget;
          },
          itemCount: widget.symbols.length,
        );
      },
    );
  }

  _onGestureHandler(dynamic details) async {
    if (details is! DragUpdateDetails && details is! DragDownDetails) return;
    observeOffset = details.localPosition.dy;

    final result = await observerController.dispatchOnceObserve(
      isDependObserveCallback: false,
    );
    final observeResult = result.observeResult;
    // Nothing has changed.
    if (observeResult == null) return;

    final firstChildModel = observeResult.firstChild;
    if (firstChildModel == null) return;
    final firstChildIndex = firstChildModel.index;
    selectedIndex.value = firstChildIndex;

    // Calculate cursor offset.
    final firstChildRenderObj = firstChildModel.renderObject;
    final firstChildRenderObjOffset = firstChildRenderObj.localToGlobal(
      Offset.zero,
      ancestor: widget.parentKey.currentContext?.findRenderObject(),
    );
    final cursorOffset = Offset(
      firstChildRenderObjOffset.dx,
      firstChildRenderObjOffset.dy + firstChildModel.size.width * 0.5,
    );
    widget.onSelectionUpdate?.call(
      firstChildIndex,
      cursorOffset,
    );
  }

  _onGestureEnd([_]) {
    selectedIndex.value = -1;
    widget.onSelectionEnd?.call();
  }
}
