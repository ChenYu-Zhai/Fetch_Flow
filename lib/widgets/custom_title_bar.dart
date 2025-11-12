import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: Container(
        height: 32,
        color: const Color(0xFF2D2D2D),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                children:  [
                  // 你可以替换成自己的应用图标
                  Image.asset(
                    'assets/logo/logo.png', // <-- 这里是您图片的路径
                    width: 16,
                    height: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Featch Flow',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500,letterSpacing: 0.5,),
                    
                  ),
                ],
              ),
            ),

            const Expanded(child: SizedBox()),

            _WindowControlButton(
              icon: Icons.minimize,
              onPressed: () => windowManager.minimize(),
            ),
            _WindowControlButton(
              icon: Icons.check_box_outline_blank,
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
            ),
            _WindowControlButton(
              icon: Icons.close,
              hoverColor: const Color(0xFFD32F2F),
              isCloseButton: true,
              onPressed: () => windowManager.close(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(32);
}

class _WindowControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? hoverColor;
  final bool isCloseButton;

  const _WindowControlButton({
    required this.icon,
    required this.onPressed,
    this.hoverColor,
    this.isCloseButton = false,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: double.infinity,
            minWidth: 46,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: _isHovering
                ? (widget.hoverColor ?? Colors.white.withOpacity(0.1))
                : Colors.transparent,
            child: Center(
              child: widget.isCloseButton
                  ? AnimatedRotation(
                      turns: _isHovering ? 0.25 : 0,
                      duration: const Duration(milliseconds: 80),
                      child: Icon(widget.icon, color: Colors.white, size: 18),
                    )
                  : Icon(widget.icon, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
