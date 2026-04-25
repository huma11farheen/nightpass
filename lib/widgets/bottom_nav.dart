import 'package:clubship/colors.dart';
import 'package:flutter/material.dart';

class BottomNavBarItem {
  final String title;
  final Widget icon;
  BottomNavBarItem({
    required this.title,
    required this.icon,
  });
}

class BottomNavBar extends StatefulWidget {
  final List<BottomNavBarItem> children;
  final int curentIndex ;

  final Color? backgroundColor;
  final Function(int)? onTap;
  const BottomNavBar(
      {super.key,
        required this.children,
        required this.curentIndex,
        this.backgroundColor,
        required this.onTap});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
   int curentIndex =0;
  @override
  void initState() {

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    curentIndex = widget.curentIndex;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: widget.backgroundColor ?? Theme.of(context).colorScheme.primary,
      ),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
      height: 70,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          widget.children.length,
              (index) => NavBarItem(
            index: index,
            item: widget.children[index],
            selected: curentIndex == index,
            onTap: () {
              setState(() {
                curentIndex = index;
                widget.onTap!(curentIndex);
              });
            },
          ),
        ),
      ),
    );
  }
}

class NavBarItem extends StatefulWidget {
  final BottomNavBarItem item;
  final int index;
  final bool selected;
  final Function onTap;
  final Color? backgroundColor;
  const NavBarItem({
    super.key,
    required this.item,
    this.selected = false,
    required this.onTap,
    this.backgroundColor,
    required this.index,
  });

  @override
  State<NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<NavBarItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: AnimatedContainer(
        margin: const EdgeInsets.all(12),
        duration: const Duration(milliseconds: 300),
        constraints: BoxConstraints(minWidth: widget.selected ?



        MediaQuery.of(context).size.width/5-16 : 32),
        height: 56,
        decoration: BoxDecoration(
          color: widget.selected
              ? widget.backgroundColor ?? Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(!widget.selected)
            widget.item.icon,
            const SizedBox(width: 2,),
            Offstage(
              offstage: !widget.selected, child: Padding(
              padding: const EdgeInsets.only(left: 8,right: 8),
                child: Text(widget.item.title,
                style: const TextStyle(color: ColorPallete.cardColor ,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                ),
                            ),
              ),),
          ],
        ),
      ),
    );
  }
}