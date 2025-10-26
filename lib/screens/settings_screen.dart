import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.backgroundGradientStartDark,
                  AppTheme.backgroundGradientEndDark,
                ]
              : [
                  AppTheme.backgroundGradientStart,
                  AppTheme.backgroundGradientEnd,
                ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.08),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
          title: Text(
            'Settings',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: ResponsiveLayout.responsivePadding(context).copyWith(top: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appearance Section
                  _buildSectionHeader(context, 'Appearance', Icons.palette_outlined),
                  const SizedBox(height: 20),
                  _buildThemeSelector(context, themeProvider, isDark),
                  const SizedBox(height: 40),
                  
                  // About Section
                  _buildSectionHeader(context, 'About', Icons.info_outline),
                  const SizedBox(height: 20),
                  _buildAboutCard(context, isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor),
                  (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 22,
              color: isDark ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeProvider themeProvider, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.04),
                ]
              : [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 35,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: isDark
                ? AppTheme.primaryColorDark.withOpacity(0.1)
                : Colors.white.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Theme Mode',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor),
                      (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  themeProvider.themeModeDisplayName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.black : Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildThemeOption(
            context,
            'System',
            'Follow device settings',
            Icons.brightness_auto_rounded,
            AppThemeMode.system,
            themeProvider,
            isDark,
          ),
          const SizedBox(height: 14),
          _buildThemeOption(
            context,
            'Light',
            'Bright & colorful',
            Icons.light_mode_rounded,
            AppThemeMode.light,
            themeProvider,
            isDark,
          ),
          const SizedBox(height: 14),
          _buildThemeOption(
            context,
            'Dark',
            'Pure AMOLED black',
            Icons.dark_mode_rounded,
            AppThemeMode.dark,
            themeProvider,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    AppThemeMode mode,
    ThemeProvider themeProvider,
    bool isDark,
  ) {
    final isSelected = themeProvider.themeMode == mode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            themeProvider.setThemeMode(mode);
          },
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: isDark
                          ? [
                              AppTheme.primaryColorDark.withOpacity(0.25),
                              AppTheme.primaryColorDark.withOpacity(0.12),
                            ]
                          : [
                              AppTheme.primaryColor.withOpacity(0.15),
                              AppTheme.primaryColor.withOpacity(0.08),
                            ],
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.03)),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor)
                    : (isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.1)),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                              (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.85),
                            ],
                          )
                        : LinearGradient(
                            colors: isDark
                                ? [
                                    Colors.white.withOpacity(0.10),
                                    Colors.white.withOpacity(0.06),
                                  ]
                                : [
                                    Colors.black.withOpacity(0.08),
                                    Colors.black.withOpacity(0.04),
                                  ],
                          ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 26,
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? AppTheme.textMediumDark : AppTheme.textMedium),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor),
                          (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: isDark ? Colors.black : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.04),
                ]
              : [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 35,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: isDark
                ? AppTheme.primaryColorDark.withOpacity(0.1)
                : Colors.white.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                      (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.verified_rounded,
                  size: 34,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quest',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor),
                            (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'v1.0.0',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.black : Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_rounded,
                  size: 20,
                  color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'A beautiful todo app with quest-based task management and stunning UI.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                      height: 1.5,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                context,
                Icons.color_lens_rounded,
                'Modern UI',
                isDark,
              ),
              const SizedBox(width: 10),
              _buildInfoChip(
                context,
                Icons.dark_mode_rounded,
                'AMOLED',
                isDark,
              ),
              const SizedBox(width: 10),
              _buildInfoChip(
                context,
                Icons.stars_rounded,
                'Crystal Gold',
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, bool isDark) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.15),
              (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
