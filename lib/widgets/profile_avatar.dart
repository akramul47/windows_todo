import 'package:flutter/material.dart';

class ProfileAvatar extends StatefulWidget {
  final VoidCallback onTap;
  final double size;

  const ProfileAvatar({
    Key? key,
    required this.onTap,
    this.size = 44,
  }) : super(key: key);

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _isHovered = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.6),
                    const Color(0xFFFFE55C).withOpacity(0.5),
                    const Color(0xFFFFA500).withOpacity(0.6),
                  ],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF000000) : Colors.white,
                ),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF1A1A1A),
                              const Color(0xFF0D0D0D),
                            ]
                          : [
                              const Color(0xFFF8F8F8),
                              Colors.white,
                            ],
                    ),
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          const Color(0xFFFFE55C).withOpacity(0.8),
                          const Color(0xFFFFD700).withOpacity(0.9),
                          const Color(0xFFFFA500).withOpacity(0.8),
                        ],
                      ).createShader(bounds),
                      child: Icon(
                        Icons.person_rounded,
                        size: widget.size * 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
